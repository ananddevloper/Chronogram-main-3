import 'dart:convert';
import 'dart:io';
import 'package:chronogram/app_helper/constent.dart';
import 'package:chronogram/app_helper/device_helper/device_helper.dart';
import 'package:chronogram/modal/user_detail_modal.dart';
import 'package:chronogram/app_helper/token_saver_helper/token_saver_helper.dart';
import 'package:chronogram/service/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' hide MultipartFile, Response;

class ApiService {
  static final api = ApiClient();
  final ApiClient client = ApiClient();

  /// ================== ERROR SANITIZATION ==================

  static Map<String, dynamic> _cleanMap(
    Map<String, dynamic> map, {
    int? statusCode,
  }) {
    // Handle Network Errors from ApiClient
    if (map.containsKey('isNetworkError') && map['isNetworkError'] == true) {
      return map;
    }

    // Handle 429 Too Many Requests
    if (statusCode == 429) {
      String blockMsg =
          "You have made too many requests. Please wait and try again later.";
      if (map.containsKey('error') && map['error'] != null) {
        String errMsg = map['error'].toString();
        if (!errMsg.startsWith('uri=') && !errMsg.startsWith('path=')) {
          blockMsg = errMsg;
        }
      }

      if (map.containsKey('message') && map['message'] != null) {
        String msg = map['message'].toString();
        if (msg.startsWith('uri=') || msg.startsWith('path=')) {
          if (msg.contains('send-otp')) {
            blockMsg = blockMsg.contains("wait")
                ? blockMsg
                : "OTP already sent. Please wait or check your messages.";
          }
        } else {
          blockMsg = msg;
        }
      }
      return {"message": blockMsg, "isBlocked": true, "error": blockMsg};
    }
    // Spring Boot technical message handling
    if (map.containsKey('error') && map['error'] != null) {
      String errMsg = map['error'].toString();

      // Clean up common technical patterns
      if (errMsg.contains("INVALID_OTP_SESSION")) {
        map['message'] = "OTP session expired. Please request a new OTP.";
      } else if (errMsg.contains("OTP_EXPIRED")) {
        map['message'] = "OTP has expired. Please try resending.";
      } else if (errMsg.startsWith('uri=') || errMsg.startsWith('path=')) {
        map['message'] = "An error occurred. Please try again.";
      } else {
        map['message'] = errMsg;
      }
    }

    if (map.containsKey('message') && map['message'] != null) {
      String msg = map['message'].toString();

      if (msg.startsWith('uri=') || msg.startsWith('path=')) {
        if (msg.contains('send-otp')) {
          map['message'] =
              "OTP already sent. Please wait or check your messages.";
        } else if (msg.contains('verify-otp')) {
          map['message'] = "Invalid or expired OTP session.";
        } else if (msg.contains('verify-email')) {
          map['message'] = "Email verification session failed. Please resend.";
        } else {
          map['message'] = "Action failed. Please try again.";
        }
      } else if (msg.contains("INVALID_OTP_SESSION")) {
        map['message'] = "Session expired. Please request a new OTP.";
      } else {
        // Generic Exception cleanup
        final exceptionMatch = RegExp(r'Exception: (.*)').firstMatch(msg);
        if (exceptionMatch != null) {
          String match = exceptionMatch.group(1) ?? "";
          if (match.endsWith("]")) {
            match = match.substring(0, match.length - 1);
          }
          map['message'] = match.trim();
        }
      }
    }

    return map;
  }

  static Map<String, dynamic> _parseData(dynamic data, {int? statusCode}) {
    Map<String, dynamic> resultMap = {};
    if (data == null) {
      resultMap = {};
    } else if (data is Map<String, dynamic>) {
      resultMap = _cleanMap(data, statusCode: statusCode);
    } else if (data is Map) {
      resultMap = _cleanMap(
        Map<String, dynamic>.from(data),
        statusCode: statusCode,
      );
    } else if (data is String) {
      if (data.isNotEmpty) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map) {
            resultMap = _cleanMap(
              Map<String, dynamic>.from(decoded),
              statusCode: statusCode,
            );
          } else {
            resultMap = {"message": data};
          }
        } catch (e) {
          if (data.contains("url=") || data.contains("path=")) {
            resultMap = {"message": "Action failed. Please try again."};
          } else {
            resultMap = {"message": data};
          }
        }
      }
    } else {
      String strData = data.toString();
      final exceptionMatch = RegExp(r'Exception: (.*)').firstMatch(strData);
      if (exceptionMatch != null) {
        String match = exceptionMatch.group(1) ?? "";
        if (match.endsWith("]")) match = match.substring(0, match.length - 1);
        resultMap = {"message": match.trim()};
      } else if (strData.contains("url=") || strData.contains("path=")) {
        final match = RegExp(r'message=([^,]+)').firstMatch(strData);
        if (match != null)
          resultMap = {"message": match.group(1)};
        else
          resultMap = {"message": "Action failed. Please try again."};
      } else {
        resultMap = {"message": strData};
      }
    }
    if (statusCode != null) {
      resultMap['statusCode'] = statusCode;
    }
    return resultMap;
  }

  /// ================== REGISTRATION FLOW ==================

  static Future<Map<String, dynamic>> sendOtp(String mobile) async {
    try {
      const String url = "auth/register/send-otp";
      final device = await DeviceHelper.getDeviceData();
      final response = await api.post(
        url,
        data: {"mobileNumber": mobile, "deviceId": device["deviceId"]},
      );
      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        if (data["otpSessionToken"] != null) {
          await TokenHelper.saveOtpSessionToken(data["otpSessionToken"]);
        }
        return {"status": "success", ...data};
      }
      return data;
    } catch (e) {
      return {"error": Constent.sometingWntWrong};
    }
  }

  static Future<Map<String, dynamic>?> verifyOtp({
    required String mobile,
    required String otp,
  }) async {
    try {
      const url = "auth/verify-otp";
      final device = await DeviceHelper.getDeviceData();
      final otpSessionToken = await TokenHelper.getOtpSessionToken();

      final response = await api.post(
        url,
        data: {
          "mobileNumber": mobile,
          "otpCode": otp,
          "otpSessionToken": otpSessionToken,
          ...device,
        },
      );

      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        if (data["accessToken"] != null) {
          await TokenHelper.saveRegistrationToken(data["accessToken"]);
        }
        data["status"] = "success";
      }
      return data;
    } catch (e) {
      return {"error": Constent.sometingWntWrong};
    }
  }

  static Future<Map<String, dynamic>> sendEmailOtp({
    required String email,
  }) async {
    try {
      const url = "auth/send-email-otp";
      String? regToken = await TokenHelper.getRegistrationToken();
      final device = await DeviceHelper.getDeviceData();
      final response = await api.post(
        url,
        data: {
          "email": email,
          "registrationToken": regToken,
          "deviceId": device["deviceId"],
        },
      );

      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        if (data["accessToken"] != null) {
          await TokenHelper.saveRegistrationToken(data["accessToken"]);
        }
        data["status"] = "success";
      }
      return data;
    } catch (e) {
      return {"error": Constent.sometingWntWrong};
    }
  }

  static Future<Map<String, dynamic>?> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      String? regToken = await TokenHelper.getRegistrationToken();
      const url = "auth/verify-email-registration-otp";
      final response = await api.post(
        url,
        data: {"email": email, "otpCode": otp, "registrationToken": regToken},
      );

      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        if (data["accessToken"] != null) {
          await TokenHelper.saveRegistrationToken(data["accessToken"]);
        }
        data["status"] = "success";
      }
      return data;
    } catch (e) {
      return {"error": Constent.sometingWntWrong};
    }
  }

  static Future<Map<String, dynamic>?> completeProfile({
    required String name,
    required String dob,
    required String mobile,
  }) async {
    try {
      const url = "auth/complete-profile";
      String? regToken = await TokenHelper.getRegistrationToken();
      final device = await DeviceHelper.getDeviceData();
      final response = await api.post(
        url,
        data: {
          "name": name,
          "dob": dob,
          "mobileNumber": mobile,
          "registrationToken": regToken,
          ...device,
        },
      );

      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        if (data["accessToken"] != null)
          await TokenHelper.saveToken(data["accessToken"]);
        if (data["refreshToken"] != null)
          await TokenHelper.saveRefreshToken(data["refreshToken"]);
        data["status"] = "success";
      }
      return data;
    } catch (e) {
      return {"error": Constent.sometingWntWrong};
    }
  }

  /// ================== LOGIN FLOW ==================

  static Future<Map<String, dynamic>> sendLoginOtp(String mobile) async {
    try {
      const url = "auth/login/send-otp";
      final device = await DeviceHelper.getDeviceData();
      final response = await api.post(
        url,
        data: {"mobileNumber": mobile, "deviceId": device["deviceId"]},
      );

      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        if (data["otpSessionToken"] != null) {
          await TokenHelper.saveOtpSessionToken(data["otpSessionToken"]);
        }
        return {"status": "success", ...data};
      }
      return data;
    } catch (e) {
      return {'error': Constent.sometingWntWrong};
    }
  }

  static Future<Map<String, dynamic>> verifyLoginOtp({
    required String mobile,
    required String otp,
  }) async {
    try {
      const url = "auth/verify-login-otp";
      final device = await DeviceHelper.getDeviceData();
      final otpSessionToken = await TokenHelper.getOtpSessionToken();

      final response = await api.post(
        url,
        data: {
          "mobileNumber": mobile,
          "otpCode": otp,
          "otpSessionToken": otpSessionToken,
          ...device,
        },
      );

      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        if (data["accessToken"] != null)
          await TokenHelper.saveToken(data["accessToken"]);
        if (data["refreshToken"] != null)
          await TokenHelper.saveRefreshToken(data["refreshToken"]);
        return {"status": "success", "token": data["accessToken"]};
      } else if (response.statusCode == 401) {
        return {
          "status": "untrusted",
          "maskedEmail": data["maskedEmail"],
          "temporaryToken": data["temporaryToken"],
        };
      }
      return data;
    } catch (e) {
      return {"error": Constent.sometingWntWrong};
    }
  }

  static Future<Map<String, dynamic>> verifyNewDeviceEmailOtp({
    required String mobile,
    required String otp,
    required String temporaryToken,
  }) async {
    try {
      const url = "auth/verify-new-device";
      final device = await DeviceHelper.getDeviceData();
      final response = await api.post(
        url,
        data: {
          "mobileNumber": mobile,
          "otp": otp,
          "temporaryToken": temporaryToken,
          ...device,
        },
      );

      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        if (data["accessToken"] != null)
          await TokenHelper.saveToken(data["accessToken"]);
        if (data["refreshToken"] != null)
          await TokenHelper.saveRefreshToken(data["refreshToken"]);
        return {"status": "success", "token": data["accessToken"]};
      }
      return data;
    } catch (e) {
      return {"error": Constent.sometingWntWrong};
    }
  }

  /// ================== RESEND ENDPOINTS ==================

  static Future<Map<String, dynamic>> resendOtp({
    String? mobile,
    String? email,
  }) async {
    try {
      const String url = "auth/register/resend-otp";
      final device = await DeviceHelper.getDeviceData();

      Map<String, dynamic> body = email != null
          ? {
              "email": email,
              "registrationToken": await TokenHelper.getRegistrationToken(),
              "deviceId": device["deviceId"],
            }
          : {"mobileNumber": mobile, "deviceId": device["deviceId"]};

      final response = await api.post(url, data: body);

      final data = _parseData(response.data, statusCode: response.statusCode);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Backend guide states resending an OTP invalidates the previous token.
        // We MUST save the new one immediately to keep the session in sync.
        if (data["otpSessionToken"] != null) {
          await TokenHelper.saveOtpSessionToken(data["otpSessionToken"]);
        }
        if (data["registrationToken"] != null) {
          await TokenHelper.saveRegistrationToken(data["registrationToken"]);
        }
        // Step 3 (Email OTP) often returns 'accessToken' as the Step-token
        if (data["accessToken"] != null) {
          await TokenHelper.saveRegistrationToken(data["accessToken"]);
        }
        return {"success": true, ...data};
      }
      return {"success": false, ...data};
    } catch (e) {
      return {"success": false, "message": Constent.sometingWntWrong};
    }
  }

  static Future<Map<String, dynamic>> resendRegistrationEmailOtp({
    required String email,
  }) async {
    return await resendOtp(email: email);
  }

  static Future<bool> resendLoginOtp({required String mobile}) async {
    try {
      final device = await DeviceHelper.getDeviceData();
      const String url = "auth/login/resend-otp";
      final response = await api.post(
        url,
        data: {"mobileNumber": mobile, "deviceId": device["deviceId"]},
      );

      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        if (data["otpSessionToken"] != null) {
          await TokenHelper.saveOtpSessionToken(data["otpSessionToken"]);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> resendNewDeviceOtp(String temporaryToken) async {
    try {
      const url = "auth/resend-new-device-otp";
      final response = await api.post(
        url,
        data: {"temporaryToken": temporaryToken},
      );
      final data = _parseData(response.data, statusCode: response.statusCode);

      if (response.statusCode == 200) {
        // Handle any tokens if returned
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// ================== USER & SESSION ==================

  static Future<UserDetailModal?> getUserProfile() async {
    try {
      final response = await api.get("auth/me");
      if (response.statusCode == 200) {
        return UserDetailModal.fromJson(
          _parseData(response.data, statusCode: response.statusCode),
        );
      }
      throw Exception(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// ===== Logout =====

  static Future<bool> logout() async {
    try {
      String? token = await TokenHelper.getToken();
      String? refreshToken = await TokenHelper.getRefreshToken();

      if (token == null || refreshToken == null) {
        await TokenHelper.clear();
        return true;
      }

      const String url = "auth/logout";

      // Use dio directly with queryParameters to ensure JWT chars (+, /, .) are URL-encoded.
      // The backend @RequestParam expects encoded dots/chars in the URL.
      await api.dio.post(
        url,
        queryParameters: {"refreshToken": refreshToken},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      await TokenHelper.clear();
      return true;
    } catch (e) {
      await TokenHelper.clear();
      return true;
    }
  }

  /// ======  Profile Photo ======

  static Future<Map<String, dynamic>> uploadProfilePhoto(File imageFile) async {
    try {
      String url = 'profile/photo';
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });
      final response = await api.post(url, data: formData);
      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        return {'status': 'status', 'photoUrl': data['photoUrl']};
      }
      return data;
    } catch (e) {
      return {'error': Constent.sometingWntWrong};
    }
  }

  // ============================================================
  // STORAGE APIs
  // ============================================================

  /// Storage usage fetch karo (used vs limit)
  static Future<Map<String, dynamic>> getStorageUsage() async {
    try {
      final response = await api.get("storage/usage");
      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        return {"status": "success", ...data};
      }
      return data;
    } catch (e) {
      return {"error": Constent.sometingWntWrong};
    }
  }

  /// Storage breakdown fetch karo (photos vs videos alag alag)

  static Future<Map<String, dynamic>> getStorageDetails() async {
    try {
      final response = await api.get("storage/details");
      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        return {"status": "success", ...data};
      }
      return data;
    } catch (e) {
      return {"error": Constent.sometingWntWrong};
    }
  }

  /// ====== SETTINGS APIs =======

  static Future<Map<String, dynamic>> getSyncPreference() async {
    try {
      final response = await api.get('settings/sync');
      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        return {'status': 'success', ...data};
      }
      return data;
    } catch (e) {
      return {'error': Constent.sometingWntWrong};
    }
  }

  static Future<Map<String, dynamic>> updateSyncPreference(String mode) async {
    try {
      final response = await api.put('settings/sync', data: {'mode': mode});
      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        return {'status': 'success', ...data};
      }
      return data;
    } catch (e) {
      return {'error': Constent.sometingWntWrong};
    }
  }

  // ============= Image Service =================


// ============= Image Service =================

static Future<Map<String, dynamic>> uploadImages({
  required List<File> imageFiles,
  String type = 'personal',
}) async {
  try {
    String url = 'images/bulk';

    // Build multipart list — key must be 'files' (plural)
    List<MultipartFile> multipartFiles = [];
    for (final file in imageFiles) {
      multipartFiles.add(
        await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      );
    }

    FormData formData = FormData.fromMap({
      'files': multipartFiles,
      'type': type,
    });

    final response = await api.post(url, data: formData);
    final statusCode = response.statusCode;

    // Success — response is a JSON array
    if (statusCode == 200 || statusCode == 201) {
      final rawData = response.data;

      // Dio returns List directly for JSON arrays
      if (rawData is List) {
        return {
          'status': 'success',
          'images': rawData,
        };
      }

      return {'status': 'success', 'images': []};
    }

    // Error — parse as map
    final data = _parseData(response.data, statusCode: statusCode);
    return data;
  } catch (e) {
    return {'error': Constent.sometingWntWrong};
  }
}

  



}
