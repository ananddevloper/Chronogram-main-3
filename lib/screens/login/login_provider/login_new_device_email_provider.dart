import 'dart:async';
import 'package:flutter/material.dart';
import '../../../service/api_service.dart';
import '../../home_screen/home_screen.dart';
import '../../../app_helper/token_saver_helper/token_saver_helper.dart';

class LoginNewDeviceEmailProvider extends ChangeNotifier {
  TextEditingController otpController = TextEditingController();
  bool isOtpValid = false;
  bool isLoading = false;
  String? error;
  String temporaryToken;

  /// TIMER
  int seconds = 60;
  Timer? _timer;
  bool canResend = false;
  bool isResending = false;

  LoginNewDeviceEmailProvider({required this.temporaryToken}) {
    otpController.addListener(checkOtp);
    startTimer();
  }

  void checkOtp() {
    String value = otpController.text.trim();
    isOtpValid = RegExp(r'^\d{6}$').hasMatch(value);
    notifyListeners();
  }

  /// VERIFY NEW DEVICE EMAIL OTP
  Future<void> verifyEmailOtp(BuildContext context, String mobile) async {
    try {
      final result = await ApiService.verifyNewDeviceEmailOtp(
        mobile: mobile,
        otp: otpController.text.trim(),
        temporaryToken: temporaryToken,
      );

      if (result["status"] == "success") {
        await TokenHelper.saveToken(result["token"]);

        if (!context.mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
            settings: const RouteSettings(name: "HomeScreen"),
          ),
          (route) => false,
        );
      } else {
        error = result['error'] ??
            result['message'] ??
            "Error ${result['statusCode']}";
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// TIMER START
  void startTimer() {
    seconds = 60;
    canResend = false;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds > 0) {
        seconds--;
        notifyListeners();
      } else {
        canResend = true;
        timer.cancel();
        notifyListeners();
      }
    });
  }

  String get timerText {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    if (m > 0) return "$m:${s.toString().padLeft(2, '0')}";
    return "$s sec";
  }

  /// RESEND
  Future<void> resendOtp(String temporaryToken) async {
    if (isResending) return;
    isResending = true;
    notifyListeners();
    bool sent = await ApiService.resendNewDeviceOtp(temporaryToken);
    isResending = false;
    if (sent) {
      startTimer();
    } else {
      error = "Failed to resend OTP";
    }

    notifyListeners();
  }

  @override
  void dispose() {
    otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
