import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../service/api_service.dart';
import '../../../app_helper/token_saver_helper/token_saver_helper.dart';
import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_email_provider.dart';

class SignUpEmailOtpProvider extends ChangeNotifier {

bool canResend = false;
bool isResending = false;

//Varivable add
int seconds = 60;
Timer? _timer;

  // ================= EMAIL CONTROLLER =================
  TextEditingController emailController = TextEditingController();
  String? emailError;
  bool isEmailValid = false;

  // ================= OTP CONTROLLER =================
  TextEditingController emailOtpController = TextEditingController();
  String? emailOtpError;
  bool isEmailOtpValid = false;
  bool isLoading = false;

  SignUpEmailOtpProvider(){
    emailController.addListener(checkEmailValidation);
    emailOtpController.addListener(checkEmailOtpFill);
  }

  void init(BuildContext context) {
    // Don't kill an already-running valid timer.
    final alreadyRunning = _timer != null && _timer!.isActive;
    if (alreadyRunning) return;

    if (context.mounted) {
      final remaining = context.read<SignUpEmailProvider>().remainingSeconds();
      seconds = remaining > 0 ? remaining : 0;
    }

    canResend = seconds <= 0;
    if (!canResend) {
      startTimer(context);
    }
    notifyListeners();
  }
  
  // ================= INDUSTRIAL EMAIL REGEX =================
  final String emailPattern =
      r'^(?!.*\.\.)[A-Za-z0-9]+([._%+-]?[A-Za-z0-9]+)*@[A-Za-z0-9-]+(\.[A-Za-z]{2,})+$';

  void checkEmailValidation() {
    String value = emailController.text.trim();
    isEmailValid = RegExp(emailPattern).hasMatch(value);
    notifyListeners();
  }

  bool validateEmail() {
    String value = emailController.text.trim();

    if (value.isEmpty) {
      emailError = "Enter email";
    } else if (!RegExp(emailPattern).hasMatch(value)) {
      emailError = "Enter valid email";
    } else {
      emailError = null;
    }

    notifyListeners();
    return emailError == null;
  }

  // ================= OTP VALIDATION =================
  void checkEmailOtpFill(){
    String value = emailOtpController.text.trim();
    isEmailOtpValid = RegExp(r'^\d{6}$').hasMatch(value);
    notifyListeners();
  }

  bool validEmailOtp() {
    String value = emailOtpController.text.trim();

    if (value.isEmpty) {
      emailOtpError = 'Enter OTP';
    } else if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      emailOtpError = 'OTP must be 6 digit number';
    } else {
      emailOtpError = null;
    }

    notifyListeners();
    return emailOtpError == null;
  }

  // ================= VERIFY EMAIL OTP API (UNCHANGED) =================
  Future<bool> verifyEmailOtpApi(String email) async {

    if(!validEmailOtp()) return false;

    isLoading = true;
    notifyListeners();

    String otp = emailOtpController.text.trim();

    

    try {
      final result = await ApiService.verifyEmailOtp(
        email: email,
        otp: otp,
      );

      if (result != null) {
        if (result['statusCode'] == 200 || result['statusCode'] == 201) {
          String? accessToken = result["accessToken"] ??
              result["token"] ??
              result["accessToken"];

          if (accessToken != null) {
            await TokenHelper.saveRegistrationToken(accessToken);
            print("STEP4 EMAIL TOKEN SAVED: $accessToken");
          } else {
            print("STEP4 EMAIL VERIFIED BUT NO TOKEN IN RESPONSE: $result");
          }

          return true;
        } else {
          emailOtpError = result['error'] ??
              result['message'] ??
              "Error ${result['statusCode']}";
          return false;
        }
      } else {
        emailOtpError = "Verification failed";
        return false;
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

void startTimer(BuildContext context) {
  canResend = false;
  _timer?.cancel();

  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (!context.mounted) {
      timer.cancel();
      return;
    }
    final provider = context.read<SignUpEmailProvider>();
    int remaining = provider.remainingSeconds();

    if (remaining > 0) {
      seconds = remaining;
      notifyListeners();
    } else {
      timer.cancel();
      canResend = true;
      seconds = 0;
      notifyListeners();
    }
  });
}

/// 🔥 STOP TIMER
void stopTimer() {
  _timer?.cancel();
  _timer = null;
  notifyListeners();
}


///TEXT FORMAT getter (important)

String get timerText {
  int minutes = seconds ~/ 60;
  int remainingSeconds = seconds % 60;

  if (minutes > 0) {
    if (remainingSeconds == 0) {
      return "$minutes min";
    }
    return "$minutes min $remainingSeconds sec";
  } else {
    return "$remainingSeconds sec";
  }
}


// Resend Function
Future<void> resendOtp(String email, BuildContext context) async {
  if (isResending) return;

  isResending = true;
  emailOtpError = null;
  notifyListeners();

  try {
    final result = await ApiService.resendOtp(email: email);
    if (result['success'] == true) {
      // 🔥 UPDATE PARENT PROVIDER COOLDOWN
      if (context.mounted) {
        final parent = context.read<SignUpEmailProvider>();
        parent.lastOtpSentTime = DateTime.now();
        parent.lastOtpEmail = email;
      }
      startTimer(context); // restart timer
    } else {
      emailOtpError = result['error'] ?? result['message'] ?? "Resend failed";
    }
  } catch (e) {
    emailOtpError = e.toString().replaceAll("Exception: ", "");
  }

  isResending = false;
  notifyListeners();
}

@override
void dispose() {
  _timer?.cancel();
  emailController.dispose();
  emailOtpController.dispose();
  super.dispose();
}
}
