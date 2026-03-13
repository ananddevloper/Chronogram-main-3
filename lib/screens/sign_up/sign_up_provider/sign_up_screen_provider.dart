// import 'package:chronogram/app_helper/token_saver_helper/token_saver_helper.dart';
// import 'package:chronogram/service/api_service.dart';
// import 'package:flutter/material.dart';

// class SignUpScreenProvider extends ChangeNotifier {
//   TextEditingController mobileController = TextEditingController();
//   String? mobileError;
//   bool isMobileValid = false;
//   bool isLoading = false;

//   DateTime? lastOtpSentTime;
//   String? lastOtpMobile;
//   static const int otpCooldown = 60; // 5 min
//   // Mobile Validation (realtime)
//   void checkMobileValid() {
//     String value = mobileController.text.trim();
//     final mobileRegex = RegExp(r'^[6-9]\d{9}$');
//     isMobileValid = mobileRegex.hasMatch(value);
//     notifyListeners();
//   }

//   bool validateMobile() {
//     String value = mobileController.text.trim();
//     if (value.isEmpty) {
//       mobileError = "Mobile number is required";
//     } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//       mobileError = "Only digits allowed";
//     } else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
//       // 6,7,8,9 se start aur total 10 digit
//       mobileError = "Please enter a valid mobile number";
//     } else {
//       mobileError = null;
//     }
//     notifyListeners();
//     return mobileError == null;
//   }

//   void clearMobile() {
//     mobileController.clear();
//     mobileError = null;
//     isMobileValid = false;
//     notifyListeners();
//   }

//   bool isCooldownActive(String mobile) {
//     if (lastOtpSentTime == null) return false;
//     if (lastOtpMobile != mobile) return false;
//     final diff = DateTime.now().difference(lastOtpSentTime!).inSeconds;
//     return diff < otpCooldown;
//   }

//   int remainingSeconds() {
//     if (lastOtpSentTime == null) return 0;
//     final diff = DateTime.now().difference(lastOtpSentTime!).inSeconds;
//     return otpCooldown - diff;
//   }

//   Future<String> sendOtp(String mobile) async {
//     mobileError = null;
//     isLoading = true;
//     notifyListeners();
//     try {
//       final result = await ApiService.sendOtp(mobile);

//     if (result["status"] != "success") {
//       String errorMessage = result['error'] ?? result['message'] ?? "";
//       String lowerError = errorMessage.toLowerCase();

//       // REGISTRATION COLLISION CHECK
//       // If the mobile is already registered/in-use, we HARD STOP.
//       bool isAlreadyRegistered = lowerError.contains("already in use") ||
//                                  lowerError.contains("already registered") ||
//                                  lowerError.contains("taken");

//       if (isAlreadyRegistered) {
//         showErrorTemporarily(errorMessage);
//         return "error";
//       }

//       // RATE LIMIT / COOLDOWN BYPASS
//       // If OTP is already sent to THIS specific user, we can move forward (bypass).
//       if (lowerError.contains("already sent") ||
//           lowerError.contains("wait") ||
//           lowerError.contains("active") ||
//           lowerError.contains("exists") ||
//           lowerError.contains("check your messages")) {

//         final RegExp regex = RegExp(r'wait (\d+) seconds');
//         final match = regex.firstMatch(errorMessage);
//         if (match != null) {
//           int remaining = int.tryParse(match.group(1)!) ?? otpCooldown;
//           lastOtpSentTime = DateTime.now().subtract(Duration(seconds: otpCooldown - remaining));
//           lastOtpMobile = mobile;
//         } else {
//           lastOtpSentTime = DateTime.now();
//           lastOtpMobile = mobile;
//         }
//         return "success";
//       }

//       showErrorTemporarily(errorMessage);
//       return "error";
//     }

//     lastOtpSentTime = DateTime.now();
//     lastOtpMobile = mobile;

//     return "success";
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }

//   //auto-hide logic add karo for user already exists error after 3 seconds
//   void showErrorTemporarily(String message) {
//     mobileError = message;
//     notifyListeners();
//     Future.delayed(const Duration(seconds: 7), () {
//       mobileError = null;
//       notifyListeners();
//     });
//   }

//   void clearState() {
//     mobileController.clear();
//     lastOtpSentTime = null;
//     lastOtpMobile = null;
//     mobileError = null;
//     isMobileValid = false;
//     notifyListeners();
//   }
// }


import 'package:chronogram/app_helper/token_saver_helper/token_saver_helper.dart';
import 'package:chronogram/service/api_service.dart';
import 'package:flutter/material.dart';

class SignUpScreenProvider extends ChangeNotifier {
  TextEditingController mobileController = TextEditingController();
  String? mobileError;
  bool isMobileValid = false;
  bool isLoading = false;

  DateTime? lastOtpSentTime;
  String? lastOtpMobile;
  static const int otpCooldown = 300; // 5 min
  // Mobile Validation (realtime)
  void checkMobileValid() {
    String value = mobileController.text.trim();
    final mobileRegex = RegExp(r'^[6-9]\d{9}$');
    isMobileValid = mobileRegex.hasMatch(value);
    notifyListeners();
  }

  bool validateMobile() {
    String value = mobileController.text.trim();
    if (value.isEmpty) {
      mobileError = "Mobile number is required";
    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      mobileError = "Only digits allowed";
    } else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      // 6,7,8,9 se start aur total 10 digit
      mobileError = "Please enter a valid mobile number";
    } else {
      mobileError = null;
    }
    notifyListeners();
    return mobileError == null;
  }

  void clearMobile() {
    mobileController.clear();
    mobileError = null;
    isMobileValid = false;
    notifyListeners();
  }

  bool isCooldownActive(String mobile) {
    if (lastOtpSentTime == null) return false;
    if (lastOtpMobile != mobile) return false;
    final diff = DateTime.now().difference(lastOtpSentTime!).inSeconds;
    return diff < otpCooldown;
  }

  int remainingSeconds() {
    if (lastOtpSentTime == null) return 0;
    final diff = DateTime.now().difference(lastOtpSentTime!).inSeconds;
    return otpCooldown - diff;
  }

  Future<String> sendOtp(String mobile) async {
    mobileError = null;
    isLoading = true;
    notifyListeners();
    try {
      final result = await ApiService.sendOtp(mobile);

    if (result["status"] != "success") {
      String errorMessage = result['error'] ?? result['message'] ?? "";
      String lowerError = errorMessage.toLowerCase();

      // REGISTRATION COLLISION CHECK: Hard stop on 409 or "already registered"
      if (result['statusCode'] == 409 || 
          lowerError.contains("already registered") || 
          lowerError.contains("already in use")) {
        showErrorTemporarily(errorMessage);
        return "error";
      }

      // RATE LIMIT / COOLDOWN BYPASS
      if (result['isAlreadySent'] == true || 
          lowerError.contains("wait") || 
          lowerError.contains("active")) {
        
        final RegExp regex = RegExp(r'wait (\d+)');
        final match = regex.firstMatch(errorMessage);
        if (match != null) {
          int unitValue = int.tryParse(match.group(1)!) ?? 0;
          int waitSecs = errorMessage.contains("minute") ? unitValue * 60 : unitValue;
          lastOtpSentTime = DateTime.now().subtract(Duration(seconds: otpCooldown - waitSecs));
          lastOtpMobile = mobile;
        } else {
          lastOtpSentTime = DateTime.now();
          lastOtpMobile = mobile;
        }
        return "success";
      }

      showErrorTemporarily(errorMessage);
      return "error";
    }

    lastOtpSentTime = DateTime.now();
    lastOtpMobile = mobile;

    return "success";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //auto-hide logic add karo for user already exists error after 3 seconds
  void showErrorTemporarily(String message) {
    mobileError = message;
    notifyListeners();
    Future.delayed(const Duration(seconds: 7), () {
      mobileError = null;
      notifyListeners();
    });
  }

  void clearState() {
    mobileController.clear();
    lastOtpSentTime = null;
    lastOtpMobile = null;
    mobileError = null;
    isMobileValid = false;
    notifyListeners();
  }
}