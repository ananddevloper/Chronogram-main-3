import 'dart:async';
import 'package:chronogram/service/api_service.dart';
import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_screen_provider.dart';
import 'package:chronogram/app_helper/token_saver_helper/token_saver_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpMobileOtpProvider extends ChangeNotifier {
  TextEditingController mobileOtpController = TextEditingController();
  String? mobileOtpError;
  bool isMobileOtpValid = false;
  bool isLoading = false;

  /// 🔥 TIMER
  int seconds = 60;
  Timer? _timer;

  /// constructor
  SignUpMobileOtpProvider() {
    mobileOtpController.addListener(checkMobileOtpFill);
    // start when screen open
  }

  void init(BuildContext context) {
    mobileOtpError = null;
    isMobileOtpValid = false;
    isLoading = false;
    isResending = false;

    // If a timer is already running with time still left, don't reset it.
    // This prevents the "Resend OTP" flicker when the screen rebuilds
    // or when the user opens/dismisses the Change Number dialog.
    final alreadyRunning = _timer != null && _timer!.isActive;
    if (alreadyRunning) return;

    // Seed seconds immediately so the UI shows correct time from frame 1
    // (avoids a 1-second "0 sec" flash before the first timer tick).
    if (context.mounted) {
      final remaining = context.read<SignUpScreenProvider>().remainingSeconds();
      seconds = remaining > 0 ? remaining : 0;
    }

    canResend = seconds <= 0;
    if (!canResend) {
      startTimer(context);
    }
    notifyListeners();
  }

  /// realtime check for button enable
  void checkMobileOtpFill() {
    String value = mobileOtpController.text.trim();
    final mobileOtpRegex = RegExp(r'^\d{6}$');
    isMobileOtpValid = mobileOtpRegex.hasMatch(value);
    notifyListeners();
  }

  /// 🔥 TIMER START
  void startTimer(BuildContext context) {
    canResend = false;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds:1), (timer) {
      if (!context.mounted) {
        timer.cancel();
        return;
      }
      final provider = context.read<SignUpScreenProvider>();
      int remaining = provider.remainingSeconds();
      
      if (remaining > 0) {
        seconds = remaining;
        notifyListeners();
      } else {
        seconds = 0;
        canResend = true; // 🔥 enable resend
        timer.cancel();
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


  /// final validation
  bool validMobileOtp() {
    String value = mobileOtpController.text.trim();

    if (value.isEmpty) {
      mobileOtpError = 'Please enter OTP';
    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      mobileOtpError = 'OTP must be digits only';
    } else if (value.length != 6) {
      mobileOtpError = 'OTP must be 6 digits';
    } else {
      mobileOtpError = null;
    }

    notifyListeners();
    return mobileOtpError == null;
  }

  /// VERIFY OTP API HIT
  Future<bool> verifyMobileOtp(BuildContext context) async {
    if (!validMobileOtp()) return false;

    isLoading = true;
    notifyListeners();

    String mobile = context.read<SignUpScreenProvider>().mobileController.text;

    String otp = mobileOtpController.text.trim();

    try {
      final result = await ApiService.verifyOtp(mobile: mobile, otp: otp);

      if (result != null) {
        if (result['statusCode'] == 200 || result['statusCode'] == 201) {
          String? token = result["registrationToken"] ??
              result["token"] ??
              result["accessToken"];
          if (token != null) {
            await TokenHelper.saveRegistrationToken(token);
            print("REGISTRATION TOKEN SAVED: $token");
            mobileOtpError = null;
            return true;
          } else {
            mobileOtpError = "Missing token: $result";
            return false;
          }
        } else {
          mobileOtpError =
              result['error'] ?? result['message'] ?? "Error ${result['statusCode']}";
        }
      } else {
        mobileOtpError = "Verification failed";
      }
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

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

  bool canResend = false;
  bool isResending = false;

  /// 🔁 RESEND OTP
  Future<void> resendOtp(BuildContext context) async {
    if (!canResend) return;

    String mobile = context.read<SignUpScreenProvider>().mobileController.text;

    isResending = true;
    mobileOtpError = null;
    notifyListeners();

    try {
      final result = await ApiService.resendOtp(mobile: mobile);
      if (result['success'] == true) {
        // 🔥 UPDATE PARENT PROVIDER COOLDOWN
        if (context.mounted) {
           final parent = context.read<SignUpScreenProvider>();
           parent.lastOtpSentTime = DateTime.now();
           parent.lastOtpMobile = mobile;
        }
        startTimer(context); // 🔥 timer restart
      } else {
        mobileOtpError = result['error'] ?? result['message'] ?? "Resend failed";
      }
    } catch (e) {
      mobileOtpError = e.toString().replaceAll("Exception: ", "");
    }

    isResending = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    mobileOtpController.dispose();
    super.dispose();
  }
}


