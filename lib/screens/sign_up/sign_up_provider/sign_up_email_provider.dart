import 'package:chronogram/app_helper/token_saver_helper/token_saver_helper.dart';
import 'package:chronogram/service/api_service.dart';
import 'package:flutter/material.dart';

class SignUpEmailProvider extends ChangeNotifier {
  TextEditingController emailController = TextEditingController();
  String? emailError;
  bool isEmailValid = false;
  bool isLoading = false;

  SignUpEmailProvider() {
    emailController.addListener(() {
      if (emailController.text.isNotEmpty) {
        validateEmail();
      } else {
        emailError = null;
        isEmailValid = false;
        notifyListeners();
      }
    });
  }

  DateTime? lastOtpSentTime;
  String? lastOtpEmail;
  static const int otpCooldown = 60; // 5 min

  bool isCooldownActive(String email) {
    if (lastOtpSentTime == null) return false;
    if (lastOtpEmail != email) return false;
    final diff = DateTime.now().difference(lastOtpSentTime!).inSeconds;
    return diff < otpCooldown;
  }

  int remainingSeconds() {
    if (lastOtpSentTime == null) return 0;
    final diff = DateTime.now().difference(lastOtpSentTime!).inSeconds;
    return otpCooldown - diff;
  }

 bool validateEmail() {
  String input = emailController.text.trim();

  final emailRegex = RegExp(
    r'^[a-zA-Z0-9](?!.*\.\.)[a-zA-Z0-9._%+-]{2,}@[gG][mM][aA][iI][lL]\.[cC][oO][mM]$'
  );

  if (input.isEmpty) {
    emailError = null;
    isEmailValid = false;
  }

  else if (input.contains(" ")) {
    emailError = "Spaces not allowed";
    isEmailValid = false;
  }

  else if (input.startsWith(".")) {
    emailError = "Dot cannot be at beginning";
    isEmailValid = false;
  }

  else if (input.contains(".@")) {
    emailError = "Dot not allowed before @";
    isEmailValid = false;
  }

  else if (input.contains("..")) {
    emailError = "Double dots not allowed";
    isEmailValid = false;
  }

  else if (!input.toLowerCase().endsWith("@gmail.com")) {
    emailError = "Email must end with @gmail.com";
    isEmailValid = false;
  }

  else if (!emailRegex.hasMatch(input)) {
    emailError = "Enter valid gmail (example: abcd123@gmail.com)";
    isEmailValid = false;
  }

  else {
    emailError = null;
    isEmailValid = true;
  }

  notifyListeners();
  return emailError == null;
}
  
Future<String> linkEmailApi() async {
  if (!validateEmail()) return "invalid";
  isLoading = true;
  notifyListeners();
  try {
    String email = emailController.text.trim();
    final result = await ApiService.sendEmailOtp(email: email);

  /// 🟢 SUCCESS
  if (result["statusCode"] == 200 || result["statusCode"] == 201) {
      String? token = result["registrationToken"] ?? result["token"] ?? result["accessToken"];
      if (token != null) {
          await TokenHelper.saveRegistrationToken(token);
          print("REGISTRATION TOKEN (EMAIL OTP) SAVED: $token");
      }
      lastOtpSentTime = DateTime.now();
      lastOtpEmail = email;
      return 'success';
  }
  
  String errorMessage = result['error'] ?? result['message'] ?? "Error ${result['statusCode']}";
  
  String lowerError = errorMessage.toLowerCase();
  
  // Safe bypass ONLY for rate limit or "already sent to you" cases.
  // Explicitly EXCLUDE "in use" or "taken" which means someone else owns it.
  bool isRateLimit = lowerError.contains("wait") || lowerError.contains("seconds") || lowerError.contains("active otp");
  bool isAlreadySentToUser = lowerError.contains("already sent") && !lowerError.contains("in use");

  if (isRateLimit || isAlreadySentToUser) {
      final RegExp regex = RegExp(r'wait (\d+) seconds');
      final match = regex.firstMatch(errorMessage);
      if (match != null) {
          int remaining = int.tryParse(match.group(1)!) ?? otpCooldown;
          lastOtpSentTime = DateTime.now().subtract(Duration(seconds: otpCooldown - remaining));
          lastOtpEmail = email;
      } else {
          lastOtpSentTime = DateTime.now();
          lastOtpEmail = email;
      }

      // Force resend to sync the backend Registration Token with this specific email!
      final resendResult = await ApiService.resendRegistrationEmailOtp(email: email);
      if (resendResult["statusCode"] == 200 || resendResult["statusCode"] == 201) {
         String? token = resendResult["registrationToken"] ?? resendResult["token"] ?? resendResult["accessToken"];
         if (token != null) {
            await TokenHelper.saveRegistrationToken(token);
         }
         return 'success';
      }
      return 'success'; // Proceed to OTP screen if we suspect an active session exists
  }
  
  emailError = errorMessage;
  notifyListeners();
  return "message";
  } finally {
    isLoading = false;
    notifyListeners();
  }
}
////// For Email Edit 
  void clearEmail() {
  emailController.clear();
  emailError = null;
  isEmailValid = false;
  notifyListeners();
}
}

