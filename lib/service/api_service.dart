// import 'dart:convert';
// import 'package:chronogram/app_helper/constent.dart';
// import 'package:chronogram/app_helper/device_helper/device_helper.dart';
// import 'package:chronogram/modal/user_detail_modal.dart';
// import 'package:chronogram/app_helper/token_saver_helper/token_saver_helper.dart';
// import 'package:chronogram/service/api_client.dart';
// import 'package:dio/dio.dart';

// class ApiService {
//   static final api = ApiClient();

//   /// ================== ERROR SANITIZATION ==================
//   static Map<String, dynamic> _cleanMap(Map<String, dynamic> map, {int? statusCode}) {
//     // Handle Network Errors from ApiClient
//     if (map.containsKey('isNetworkError') && map['isNetworkError'] == true) {
//       return map; 
//     }
//     // Handle 429 Too Many Requests
//     if (statusCode == 429) {
//       String blockMsg = "You have made too many requests. Please wait and try again later.";
//       if (map.containsKey('error') && map['error'] != null) {
//         String errMsg = map['error'].toString();
//         if (!errMsg.startsWith('uri=') && !errMsg.startsWith('path=')) {
//           blockMsg = errMsg;
//         }
//       }
//       if (map.containsKey('message') && map['message'] != null) {
//         String msg = map['message'].toString();
//         if (msg.startsWith('uri=') || msg.startsWith('path=')) {
//            if (msg.contains('send-otp')) {
//              blockMsg = blockMsg.contains("wait") ? blockMsg : "OTP already sent. Please wait or check your messages.";
//            }
//         } else {
//            blockMsg = msg;
//         }
//       }
//       return {"message": blockMsg, "isBlocked": true, "error": blockMsg};
//     }
//     // Spring Boot technical message handling
//     if (map.containsKey('error') && map['error'] != null) {
//       String errMsg = map['error'].toString();
      
//       // Clean up common technical patterns
//       if (errMsg.contains("INVALID_OTP_SESSION")) {
//         map['message'] = "OTP session expired. Please request a new OTP.";
//       } else if (errMsg.contains("OTP_EXPIRED")) {
//         map['message'] = "OTP has expired. Please try resending.";
//       } else if (errMsg.startsWith('uri=') || errMsg.startsWith('path=')) {
//         map['message'] = "An error occurred. Please try again.";
//       } else {
//         map['message'] = errMsg;
//       }
//     }

//     if (map.containsKey('message') && map['message'] != null) {
//       String msg = map['message'].toString();
      
//       if (msg.startsWith('uri=') || msg.startsWith('path=')) {
//         if (msg.contains('send-otp')) {
//           map['message'] = "OTP already sent. Please wait or check your messages.";
//         } else if (msg.contains('verify-otp')) {
//           map['message'] = "Invalid or expired OTP session.";
//         } else if (msg.contains('verify-email')) {
//           map['message'] = "Email verification session failed. Please resend.";
//         } else {
//           map['message'] = "Action failed. Please try again."; 
//         }
//       } else if (msg.contains("INVALID_OTP_SESSION")) {
//         map['message'] = "Session expired. Please request a new OTP.";
//       } else {
//         // Generic Exception cleanup
//         final exceptionMatch = RegExp(r'Exception: (.*)').firstMatch(msg);
//         if (exceptionMatch != null) {
//           String match = exceptionMatch.group(1) ?? "";
//           if (match.endsWith("]")) {
//             match = match.substring(0, match.length - 1);
//           }
//           map['message'] = match.trim();
//         }
//       }
//     }
    
//     return map;
//   }

//   static Map<String, dynamic> _parseData(dynamic data, {int? statusCode}) {
//     Map<String, dynamic> resultMap = {};
    
//     if (data == null) {
//       resultMap = {};
//     } else if (data is Map<String, dynamic>) {
//       resultMap = _cleanMap(data, statusCode: statusCode);
//     } else if (data is Map) {
//       resultMap = _cleanMap(Map<String, dynamic>.from(data), statusCode: statusCode);
//     } else if (data is String) {
//       if (data.isNotEmpty) {
//         try {
//           final decoded = jsonDecode(data);
//           if (decoded is Map) {
//             resultMap = _cleanMap(Map<String, dynamic>.from(decoded), statusCode: statusCode);
//           } else {
//             resultMap = {"message": data};
//           }
//         } catch (e) {
//           if (data.contains("url=") || data.contains("path=")) {
//             resultMap = {"message": "Action failed. Please try again."};
//           } else {
//             resultMap = {"message": data};
//           }
//         }
//       }
//     } else {
//       String strData = data.toString();
//       final exceptionMatch = RegExp(r'Exception: (.*)').firstMatch(strData);
//       if (exceptionMatch != null) {
//           String match = exceptionMatch.group(1) ?? "";
//           if (match.endsWith("]")) match = match.substring(0, match.length - 1);
//           resultMap = {"message": match.trim()};
//       } else if (strData.contains("url=") || strData.contains("path=")) {
//          final match = RegExp(r'message=([^,]+)').firstMatch(strData);
//          if (match != null) resultMap = {"message": match.group(1)};
//          else resultMap = {"message": "Action failed. Please try again."};
//       } else {
//         resultMap = {"message": strData};
//       }
//     }

//     if (statusCode != null) {
//       resultMap['statusCode'] = statusCode;
//     }
//     return resultMap;
//   }

//   /// ================== REGISTRATION FLOW ==================

//   static Future<Map<String, dynamic>> sendOtp(String mobile) async {
//     try {
//       const String url = "auth/register/send-otp";
//       final device = await DeviceHelper.getDeviceData();
//       final response = await api.post(url, data: {"mobileNumber": mobile, "deviceId": device["deviceId"]});
      
//       final data = _parseData(response.data, statusCode: response.statusCode);
//       if (response.statusCode == 200) {
//         if (data["otpSessionToken"] != null) {
//           await TokenHelper.saveOtpSessionToken(data["otpSessionToken"]);
//         }
//         return {"status": "success", ...data};
//       }
//       return data;
//     } catch (e) {
//       return {"error": Constent.sometingWntWrong};
//     }
//   }

//   static Future<Map<String, dynamic>?> verifyOtp({required String mobile, required String otp}) async {
//     try {
//       const url = "auth/verify-otp";
//       final device = await DeviceHelper.getDeviceData();
//       final otpSessionToken = await TokenHelper.getOtpSessionToken();

//       final response = await api.post(url, data: {
//         "mobileNumber": mobile, 
//         "otpCode": otp, 
//         "otpSessionToken": otpSessionToken,
//         ...device
//       });

//       final data = _parseData(response.data, statusCode: response.statusCode);
//       if (response.statusCode == 200) {
//         if (data["accessToken"] != null) {
//           await TokenHelper.saveRegistrationToken(data["accessToken"]);
//         }
//         data["status"] = "success";
//       }
//       return data;
//     } catch (e) {
//       return {"error": Constent.sometingWntWrong};
//     }
//   }

//   static Future<Map<String, dynamic>> sendEmailOtp({required String email}) async {
//     try {
//       const url = "auth/send-email-otp";
//       String? regToken = await TokenHelper.getRegistrationToken();
//       final device = await DeviceHelper.getDeviceData();
//       final response = await api.post(url, data: {
//         "email": email, 
//         "registrationToken": regToken,
//         "deviceId": device["deviceId"],
//       });

//       final data = _parseData(response.data, statusCode: response.statusCode);
//       if (response.statusCode == 200) {
//         if (data["accessToken"] != null) {
//           await TokenHelper.saveRegistrationToken(data["accessToken"]);
//         }
//         data["status"] = "success";
//       }
//       return data;
//     } catch (e) {
//       return {"error": Constent.sometingWntWrong};
//     }
//   }


//   static Future<Map<String, dynamic>?> verifyEmailOtp({required String email, required String otp}) async {
//     try {
//       String? regToken = await TokenHelper.getRegistrationToken();
//       const url = "auth/verify-email-registration-otp";
//       final response = await api.post(url, data: {
//         "email": email,
//         "otpCode": otp,
//         "registrationToken": regToken,
//       });

//       final data = _parseData(response.data, statusCode: response.statusCode);
//       if (response.statusCode == 200) {
//          if (data["accessToken"] != null) {
//            await TokenHelper.saveRegistrationToken(data["accessToken"]);
//          }
//          data["status"] = "success";
//       }
//       return data;
//     } catch (e) {
//       return {"error": Constent.sometingWntWrong};
//     }
//   }

//   static Future<Map<String, dynamic>?> completeProfile({required String name, required String dob, required String mobile}) async {
//     try {
//       const url = "auth/complete-profile";
//       String? regToken = await TokenHelper.getRegistrationToken();
//       final device = await DeviceHelper.getDeviceData();
//       final response = await api.post(url, data: {
//         "name": name,
//         "dob": dob,
//         "mobileNumber": mobile,
//         "registrationToken": regToken,
//         ...device,
//       });

//       final data = _parseData(response.data, statusCode: response.statusCode);
//       if (response.statusCode == 200) {
//         if (data["accessToken"] != null) await TokenHelper.saveToken(data["accessToken"]);
//         if (data["refreshToken"] != null) await TokenHelper.saveRefreshToken(data["refreshToken"]);
//         data["status"] = "success";
//       }
//       return data;
//     } catch (e) {
//       return {"error": Constent.sometingWntWrong};
//     }
//   }

//   /// ================== LOGIN FLOW ==================

//   static Future<Map<String, dynamic>> sendLoginOtp(String mobile) async {
//     try {
//       const url = "auth/login/send-otp";
//       final device = await DeviceHelper.getDeviceData();
//       final response = await api.post(url, data: {"mobileNumber": mobile, "deviceId": device["deviceId"]});
      
//       final data = _parseData(response.data, statusCode: response.statusCode);
//       if (response.statusCode == 200) {
//         if (data["otpSessionToken"] != null) {
//           await TokenHelper.saveOtpSessionToken(data["otpSessionToken"]);
//         }
//         return {"status": "success", ...data};
//       }
//       return data;
//     } catch (e) {
//       return {'error': Constent.sometingWntWrong};
//     }
//   }

//   static Future<Map<String, dynamic>> verifyLoginOtp({required String mobile, required String otp}) async {
//     try {
//       const url = "auth/verify-login-otp";
//       final device = await DeviceHelper.getDeviceData();
//       final otpSessionToken = await TokenHelper.getOtpSessionToken();

//       final response = await api.post(url, data: {
//         "mobileNumber": mobile, 
//         "otpCode": otp, 
//         "otpSessionToken": otpSessionToken,
//         ...device
//       });

//       final data = _parseData(response.data, statusCode: response.statusCode);
//       if (response.statusCode == 200) {
//         if (data["accessToken"] != null) await TokenHelper.saveToken(data["accessToken"]);
//         if (data["refreshToken"] != null) await TokenHelper.saveRefreshToken(data["refreshToken"]);
//         return {"status": "success", "token": data["accessToken"]};
//       } else if (response.statusCode == 401) {
//         return {
//           "status": "untrusted",
//           "maskedEmail": data["maskedEmail"],
//           "temporaryToken": data["temporaryToken"],
//         };
//       }
//       return data;
//     } catch (e) {
//       return {"error": Constent.sometingWntWrong};
//     }
//   }

//   static Future<Map<String, dynamic>> verifyNewDeviceEmailOtp({required String mobile, required String otp, required String temporaryToken}) async {
//     try {
//       const url = "auth/verify-new-device";
//       final device = await DeviceHelper.getDeviceData();
//       final response = await api.post(url, data: {
//         "mobileNumber": mobile,
//         "otp": otp,
//         "temporaryToken": temporaryToken,
//         ...device,
//       });

//       final data = _parseData(response.data, statusCode: response.statusCode);
//       if (response.statusCode == 200) {
//         if (data["accessToken"] != null) await TokenHelper.saveToken(data["accessToken"]);
//         if (data["refreshToken"] != null) await TokenHelper.saveRefreshToken(data["refreshToken"]);
//         return {"status": "success", "token": data["accessToken"]};
//       }
//       return data;
//     } catch (e) {
//       return {"error": Constent.sometingWntWrong};
//     }
//   }

//   /// ================== RESEND ENDPOINTS ==================

//   static Future<Map<String, dynamic>> resendOtp({String? mobile, String? email}) async {
//     try {
//       const String url = "auth/register/resend-otp";
//       final device = await DeviceHelper.getDeviceData();
      
//       Map<String, dynamic> body = email != null
//           ? {
//               "email": email,
//               "registrationToken": await TokenHelper.getRegistrationToken(),
//               "deviceId": device["deviceId"]
//             }
//           : {
//               "mobileNumber": mobile, 
//               "deviceId": device["deviceId"]
//             };

//       final response = await api.post(url, data: body);
//       final data = _parseData(response.data, statusCode: response.statusCode);
      
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         // Backend guide states resending an OTP invalidates the previous token.
//         // We MUST save the new one immediately to keep the session in sync.
//         if (data["otpSessionToken"] != null) {
//           await TokenHelper.saveOtpSessionToken(data["otpSessionToken"]);
//         }
//         if (data["registrationToken"] != null) {
//           await TokenHelper.saveRegistrationToken(data["registrationToken"]);
//         }
//         // Step 3 (Email OTP) often returns 'accessToken' as the Step-token
//         if (data["accessToken"] != null) {
//           await TokenHelper.saveRegistrationToken(data["accessToken"]);
//         }
//         return {"success": true, ...data};
//       }
//       return {"success": false, ...data};
//     } catch (e) {
//       return {"success": false, "message": Constent.sometingWntWrong};
//     }
//   }

//   static Future<Map<String, dynamic>> resendRegistrationEmailOtp({required String email}) async {
//     return await resendOtp(email: email);
//   }

//   static Future<bool> resendLoginOtp({required String mobile}) async {
//     try {
//       final device = await DeviceHelper.getDeviceData();
//       const String url = "auth/login/resend-otp";
//       final response = await api.post(url, data: {"mobileNumber": mobile, "deviceId": device["deviceId"]});
      
//       final data = _parseData(response.data, statusCode: response.statusCode);
//       if (response.statusCode == 200) {
//         if (data["otpSessionToken"] != null) {
//           await TokenHelper.saveOtpSessionToken(data["otpSessionToken"]);
//         }
//         return true;
//       }
//       return false;
//     } catch (e) {
//       return false;
//     }
//   }

//   static Future<bool> resendNewDeviceOtp(String temporaryToken) async {
//     try {
//       const url = "auth/resend-new-device-otp";
//       final response = await api.post(url, data: {"temporaryToken": temporaryToken});
//       final data = _parseData(response.data, statusCode: response.statusCode);
      
//       if (response.statusCode == 200) {
//         // Handle any tokens if returned
//         return true;
//       }
//       return false;
//     } catch (e) {
//       return false;
//     }
//   }

//   /// ================== USER & SESSION ==================

//   static Future<UserDetailModal?> getUserProfile() async {
//     try {
//       final response = await api.get("auth/me");
//       if (response.statusCode == 200) {
//         return UserDetailModal.fromJson(_parseData(response.data, statusCode: response.statusCode));
//       }
//       throw Exception(response.data);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   static Future<bool> logout() async {
//     try {
//       String? token = await TokenHelper.getToken();
//       String? refreshToken = await TokenHelper.getRefreshToken();

//       if (token == null || refreshToken == null) {
//         await TokenHelper.clear();
//         return true;
//       }

//       const String url = "auth/logout";
      
//       // Use dio directly with queryParameters to ensure JWT chars (+, /, .) are URL-encoded.
//       // The backend @RequestParam expects encoded dots/chars in the URL.
//       await api.dio.post(
//         url,
//         queryParameters: {"refreshToken": refreshToken},
//         options: Options(
//           headers: {"Authorization": "Bearer $token"}
//         ),
//       );
      
//       await TokenHelper.clear();
//       return true;
//     } catch (e) {
//       await TokenHelper.clear();
//       return true;
//     }
//   }
// }



  //====== NEW CODE =====


import 'dart:convert';
import 'package:chronogram/app_helper/constent.dart';
import 'package:chronogram/app_helper/device_helper/device_helper.dart';
import 'package:chronogram/modal/user_detail_modal.dart';
import 'package:chronogram/app_helper/token_saver_helper/token_saver_helper.dart';
import 'package:chronogram/service/api_client.dart';
import 'package:dio/dio.dart';

class ApiService {
  static final api = ApiClient();

  /// ================== ERROR MAPPING & SANITIZATION ==================
  
  static const Map<String, String> _errorMessages = {
    "Invalid mobile number format": "Please enter a valid 10-digit mobile number.",
    "Device ID is required": "Device initialization error. Please restart the app.",
    "User already registered. Please login.": "This number is already registered. Please login instead.",
    "Your account is temporarily locked": "Your account is locked for 15 minutes due to multiple failed attempts.",
    "Invalid Mobile OTP": "Incorrect OTP. Please check and try again.",
    "OTP not found or expired": "OTP has expired. Please request a new one.",
    "Invalid session": "Session expired. Please request a new OTP.",
    "OTP session mismatch": "Security session mismatch. Please request a new OTP.",
    "Email is required for registration": "Email address is required.",
    "Invalid email format": "Please enter a valid email address.",
    "Email already in use": "This email is already associated with another account.",
    "Invalid registration token": "Registration session expired. Please start over.",
    "Invalid OTP": "Incorrect OTP. Please try again.",
    "OTP expired": "OTP has expired. Please try resending.",
    "Only alphabetic characters": "Name should only contain letters.",
    "Users must be 12 years or older": "You must be at least 12 years old to register.",
    "User not found. Please register.": "This number is not registered. Please sign up first.",
    "APPROVAL_REQUIRED": "New device detected. OTP sent to your email.",
    "INVALID_OTP_SESSION": "Session expired. Please request a new OTP.",
    "OTP_EXPIRED": "OTP has expired. Please resend.",
  };

  static String _getMappedMessage(String technicalMsg) {
    for (var entry in _errorMessages.entries) {
      if (technicalMsg.contains(entry.key)) {
        return entry.value;
      }
    }
    return technicalMsg;
  }

  static Map<String, dynamic> _cleanMap(Map<String, dynamic> map, {int? statusCode}) {
    // 1. Handle Network Errors from ApiClient
    if (map.containsKey('isNetworkError') && map['isNetworkError'] == true) {
      return map; 
    }

    // 2. Handle 429 Too Many Requests (Rate Limiting)
    if (statusCode == 429) {
      String blockMsg = _errorMessages["Your account is temporarily locked"]!;
      if (map.containsKey('message') || map.containsKey('error')) {
        String raw = (map['message'] ?? map['error']).toString();
        if (!raw.startsWith('uri=') && !raw.startsWith('path=')) {
          blockMsg = _getMappedMessage(raw);
        }
      }
      return {"message": blockMsg, "isBlocked": true, "error": blockMsg, "statusCode": 429};
    }

    // 3. Handle 403 Forbidden (Security Mismatches)
    if (statusCode == 403) {
      String msg = "Access denied. Please try again.";
      if (map.containsKey('message') || map.containsKey('error')) {
        msg = _getMappedMessage((map['message'] ?? map['error']).toString());
      }
      return {"message": msg, "error": msg, "statusCode": 403};
    }

    // 4. Spring Boot technical message handling
    String? currentMessage = map['message']?.toString() ?? map['error']?.toString();
    
    if (currentMessage != null) {
      // Clean up "Exception: " prefix if present
      final exceptionMatch = RegExp(r'Exception: (.*)').firstMatch(currentMessage);
      if (exceptionMatch != null) {
        currentMessage = exceptionMatch.group(1) ?? currentMessage;
        if (currentMessage.endsWith("]")) {
          currentMessage = currentMessage.substring(0, currentMessage.length - 1);
        }
      }

      // If it's a technical URI/Path without a clear message, use a fallback
      if (currentMessage.startsWith('uri=') || currentMessage.startsWith('path=')) {
        if (currentMessage.contains('send-otp') || currentMessage.contains('resend')) {
          // 🛑 CRITICAL: Preserve the "wait X seconds" for the timer logic
          final waitMatch = RegExp(r'wait (\d+) seconds').firstMatch(currentMessage);
          if (waitMatch != null) {
            String seconds = waitMatch.group(1)!;
            String sanitized = "OTP already sent. Please wait $seconds seconds.";
            map['message'] = sanitized;
            map['error'] = sanitized;
            map['isAlreadySent'] = true;
          } else {
            String sanitized = "OTP already sent. Please wait or check your messages.";
            map['message'] = sanitized;
            map['error'] = sanitized;
            map['isAlreadySent'] = true;
          }
        } else {
          map['message'] = "Action failed. Please try again."; 
        }
      } else {
        // Apply mapping for known technical strings
        String sanitized = _getMappedMessage(currentMessage.trim());
        map['message'] = sanitized;
        map['error'] = sanitized; // Ensure both are consistent for UI providers
        
        // Add bypass flag if it matches bypassable patterns
        if (sanitized.contains("already sent") || sanitized.contains("already exists")) {
          map['isAlreadySent'] = true;
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
      resultMap = _cleanMap(Map<String, dynamic>.from(data), statusCode: statusCode);
    } else if (data is String) {
      if (data.isNotEmpty) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map) {
            resultMap = _cleanMap(Map<String, dynamic>.from(decoded), statusCode: statusCode);
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
         if (match != null) resultMap = {"message": match.group(1)};
         else resultMap = {"message": "Action failed. Please try again."};
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
      final response = await api.post(url, data: {"mobileNumber": mobile, "deviceId": device["deviceId"]});      
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

  static Future<Map<String, dynamic>?> verifyOtp({required String mobile, required String otp}) async {
    try {
      const url = "auth/verify-otp";
      final device = await DeviceHelper.getDeviceData();
      final otpSessionToken = await TokenHelper.getOtpSessionToken();

      final response = await api.post(url, data: {
        "mobileNumber": mobile, 
        "otpCode": otp, 
        "otpSessionToken": otpSessionToken,
        ...device
      });

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

  static Future<Map<String, dynamic>> sendEmailOtp({required String email}) async {
    try {
      const url = "auth/send-email-otp";
      String? regToken = await TokenHelper.getRegistrationToken();
      final device = await DeviceHelper.getDeviceData();
      final response = await api.post(url, data: {
        "email": email, 
        "registrationToken": regToken,
        "deviceId": device["deviceId"],
      });

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


  static Future<Map<String, dynamic>?> verifyEmailOtp({required String email, required String otp}) async {
    try {
      String? regToken = await TokenHelper.getRegistrationToken();
      const url = "auth/verify-email-registration-otp";
      final response = await api.post(url, data: {
        "email": email,
        "otpCode": otp,
        "registrationToken": regToken,
      });

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

  static Future<Map<String, dynamic>?> completeProfile({required String name, required String dob, required String mobile}) async {
    try {
      const url = "auth/complete-profile";
      String? regToken = await TokenHelper.getRegistrationToken();
      final device = await DeviceHelper.getDeviceData();
      final response = await api.post(url, data: {
        "name": name,
        "dob": dob,
        "mobileNumber": mobile,
        "registrationToken": regToken,
        ...device,
      });

      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        if (data["accessToken"] != null) await TokenHelper.saveToken(data["accessToken"]);
        if (data["refreshToken"] != null) await TokenHelper.saveRefreshToken(data["refreshToken"]);
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
      final response = await api.post(url, data: {"mobileNumber": mobile, "deviceId": device["deviceId"]});
      
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

  static Future<Map<String, dynamic>> verifyLoginOtp({required String mobile, required String otp}) async {
    try {
      const url = "auth/verify-login-otp";
      final device = await DeviceHelper.getDeviceData();
      final otpSessionToken = await TokenHelper.getOtpSessionToken();

      final response = await api.post(url, data: {
        "mobileNumber": mobile, 
        "otpCode": otp, 
        "otpSessionToken": otpSessionToken,
        ...device
      });

      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        if (data["accessToken"] != null) await TokenHelper.saveToken(data["accessToken"]);
        if (data["refreshToken"] != null) await TokenHelper.saveRefreshToken(data["refreshToken"]);
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

  static Future<Map<String, dynamic>> verifyNewDeviceEmailOtp({required String mobile, required String otp, required String temporaryToken}) async {
    try {
      const url = "auth/verify-new-device";
      final device = await DeviceHelper.getDeviceData();
      final response = await api.post(url, data: {
        "mobileNumber": mobile,
        "otp": otp,
        "temporaryToken": temporaryToken,
        ...device,
      });

      final data = _parseData(response.data, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        if (data["accessToken"] != null) await TokenHelper.saveToken(data["accessToken"]);
        if (data["refreshToken"] != null) await TokenHelper.saveRefreshToken(data["refreshToken"]);
        return {"status": "success", "token": data["accessToken"]};
      }
      return data;
    } catch (e) {
      return {"error": Constent.sometingWntWrong};
    }
  }

  /// ================== RESEND ENDPOINTS ==================

  static Future<Map<String, dynamic>> resendOtp({String? mobile, String? email}) async {
    try {
      const String url = "auth/register/resend-otp";
      final device = await DeviceHelper.getDeviceData();
      
      Map<String, dynamic> body = email != null
          ? {
              "email": email,
              "registrationToken": await TokenHelper.getRegistrationToken(),
              "deviceId": device["deviceId"]
            }
          : {
              "mobileNumber": mobile, 
              "deviceId": device["deviceId"]
            };

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

  static Future<Map<String, dynamic>> resendRegistrationEmailOtp({required String email}) async {
    return await resendOtp(email: email);
  }

  static Future<bool> resendLoginOtp({required String mobile}) async {
    try {
      final device = await DeviceHelper.getDeviceData();
      const String url = "auth/login/resend-otp";
      final response = await api.post(url, data: {"mobileNumber": mobile, "deviceId": device["deviceId"]});
      
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
      final response = await api.post(url, data: {"temporaryToken": temporaryToken});
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
        return UserDetailModal.fromJson(_parseData(response.data, statusCode: response.statusCode));
      }
      throw Exception(response.data);
    } catch (e) {
      rethrow;
    }
  }

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
        options: Options(
          headers: {"Authorization": "Bearer $token"}
        ),
      );
      
      await TokenHelper.clear();
      return true;
    } catch (e) {
      await TokenHelper.clear();
      return true;
    }
  }
}