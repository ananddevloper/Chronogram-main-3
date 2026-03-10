import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chronogram/screens/login/login_provider/login_otp_provider.dart';
import 'package:chronogram/screens/login/login_provider/login_screen_provider.dart';

class EditLoginMobileDialog extends StatelessWidget {
  const EditLoginMobileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xff1C1C1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        "Change Number?",
        style: TextStyle(color: Colors.white),
      ),
      content: const Text(
        "Do you want to change login mobile number?",
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextButton(
          onPressed: () {
            // Stop the OTP timer before leaving
            context.read<LoginMobileOtpScreenProvider>().stopTimer();

            // Clear the login state
            context.read<LoginMobileScreenProvider>().clearState();

            Navigator.pop(context); // close dialog
            Navigator.pop(context); // go back to login screen
          },
          child: const Text(
            "Yes Change",
            style: TextStyle(color: Colors.orange),
          ),
        ),
      ],
    );
  }
}