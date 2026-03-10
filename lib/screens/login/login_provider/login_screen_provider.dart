// import 'package:chronogram/app_helper/token_saver_helper/token_saver_helper.dart';
// import 'package:chronogram/service/api_service.dart';
// import 'package:flutter/material.dart';

// class LoginMobileScreenProvider extends ChangeNotifier {
//   TextEditingController mobileController = TextEditingController();

// DateTime? lastOtpSentTime;
// String? lastOtpMobile;
// static const int otpCooldown = 60; // 5 min

//   String? mobileError;
//   bool isMobileValid = false;
//   bool isLoading = false;
//   String? successMessage;

//   LoginMobileScreenProvider() {
//     mobileController.addListener(checkMobileValid);
//   }

//   // ================= REAL-TIME MOBILE VALIDATION =================
//   void checkMobileValid() {
//     String value = mobileController.text.trim();
//     // Indian industrial mobile regex (6-9 start + 10 digits)
//     final mobileRegex = RegExp(r'^[6-9]\d{9}$');
//     isMobileValid = mobileRegex.hasMatch(value);
//     notifyListeners();
//   }

//   // ================= BUTTON CLICK VALIDATION =================
//   bool validateMobile() {
//     String value = mobileController.text.trim();

//     if (value.isEmpty) {
//       mobileError = "Mobile number is required";
//     } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//       mobileError = "Only digits allowed";
//     } else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
//       mobileError = "Please enter a valid mobile number";
//     } else {
//       mobileError = null;
//     }

//     notifyListeners();
//     return mobileError == null;
//   }
// ////////
//   void setError(String message) {
//   mobileError = message;
//   notifyListeners();

//   Future.delayed(const Duration(seconds: 4), () {
//     mobileError = null;
//     notifyListeners();
//   });
// }

// bool isCooldownActive(String mobile) {
//   if (lastOtpSentTime == null) return false;
//   if (lastOtpMobile != mobile) return false;
//   final diff = DateTime.now().difference(lastOtpSentTime!).inSeconds;
//   return diff < otpCooldown;
// }

// int remainingSeconds() {
//   if (lastOtpSentTime == null) return 0;
//   final diff = DateTime.now().difference(lastOtpSentTime!).inSeconds;
//   return otpCooldown - diff;
// }

// ////Api Method
// Future<String> sendLoginOtp(String mobile) async {
//   mobileError = null;
//   isLoading = true;
//   notifyListeners();
//   try {
//     final result = await ApiService.sendLoginOtp(mobile);

//   if (result['status'] != 'success') {
//     String errorMessage = result['error'] ?? result['message'] ?? "";
//     String lowerError = errorMessage.toLowerCase();

//     if (lowerError.contains("already sent") || 
//         lowerError.contains("wait") || 
//         lowerError.contains("active") || 
//         lowerError.contains("exists") ||
//         lowerError.contains("check your messages")) {
      
//       final RegExp regex = RegExp(r'wait (\d+) seconds');
//       final match = regex.firstMatch(errorMessage);
//       if (match != null) {
//         int remaining = int.tryParse(match.group(1)!) ?? otpCooldown;
//         lastOtpSentTime = DateTime.now().subtract(Duration(seconds: otpCooldown - remaining));
//         lastOtpMobile = mobile;
//       } else {
//         lastOtpSentTime = DateTime.now();
//         lastOtpMobile = mobile;
//       }
//       return "success";
//     }

//     showErrorTemporarily(errorMessage);
//     return 'error';
//   }

//   lastOtpSentTime = DateTime.now();
//   lastOtpMobile = mobile;

//   return 'success';
//   } finally {
//     isLoading = false;
//     notifyListeners();
//   }
// }


//   @override
//   void dispose() {
//     mobileController.dispose();
//     super.dispose();
//   }
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
//     successMessage = null;
//     notifyListeners();
//   }
// }


import 'package:chronogram/app_helper/token_saver_helper/token_saver_helper.dart';
import 'package:chronogram/service/api_service.dart';
import 'package:flutter/material.dart';

class LoginMobileScreenProvider extends ChangeNotifier {
  TextEditingController mobileController = TextEditingController();

DateTime? lastOtpSentTime;
String? lastOtpMobile;
static const int otpCooldown = 300; // 5 min

  String? mobileError;
  bool isMobileValid = false;
  bool isLoading = false;
  String? successMessage;

  LoginMobileScreenProvider() {
    mobileController.addListener(checkMobileValid);
  }

  // ================= REAL-TIME MOBILE VALIDATION =================
  void checkMobileValid() {
    String value = mobileController.text.trim();
    // Indian industrial mobile regex (6-9 start + 10 digits)
    final mobileRegex = RegExp(r'^[6-9]\d{9}$');
    isMobileValid = mobileRegex.hasMatch(value);
    notifyListeners();
  }

  // ================= BUTTON CLICK VALIDATION =================
  bool validateMobile() {
    String value = mobileController.text.trim();

    if (value.isEmpty) {
      mobileError = "Mobile number is required";
    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      mobileError = "Only digits allowed";
    } else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      mobileError = "Please enter a valid mobile number";
    } else {
      mobileError = null;
    }

    notifyListeners();
    return mobileError == null;
  }
////////
  void setError(String message) {
  mobileError = message;
  notifyListeners();

  Future.delayed(const Duration(seconds: 4), () {
    mobileError = null;
    notifyListeners();
  });
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

////Api Method
Future<String> sendLoginOtp(String mobile) async {
  mobileError = null;
  isLoading = true;
  notifyListeners();
  try {
    final result = await ApiService.sendLoginOtp(mobile);

    if (result["status"] != "success") {
      String errorMessage = result['error'] ?? result['message'] ?? "";
      String lowerError = errorMessage.toLowerCase();

      // Bypass logic
      if (result['isAlreadySent'] == true || 
          lowerError.contains("already sent") || 
          lowerError.contains("wait") || 
          lowerError.contains("active") || 
          lowerError.contains("exists") ||
          lowerError.contains("check your messages")) {
        
        final RegExp regex = RegExp(r'wait (\d+) seconds');
        final match = regex.firstMatch(errorMessage);
        if (match != null) {
          int remaining = int.tryParse(match.group(1)!) ?? otpCooldown;
          lastOtpSentTime = DateTime.now().subtract(Duration(seconds: otpCooldown - remaining));
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

  return 'success';
  } finally {
    isLoading = false;
    notifyListeners();
  }
}


  @override
  void dispose() {
    mobileController.dispose();
    super.dispose();
  }
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
    successMessage = null;
    notifyListeners();
  }
}

