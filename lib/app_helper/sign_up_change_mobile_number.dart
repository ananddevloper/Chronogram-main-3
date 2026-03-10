import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_screen_provider.dart';
import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_mobile_otp_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class EditMobileDialog extends StatelessWidget {
  const EditMobileDialog({super.key});

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
        "Do you want to change mobile number?",
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
            context.read<SignUpMobileOtpProvider>().stopTimer();

            /// clear mobile
            context.read<SignUpScreenProvider>().clearMobile();

            /// close dialog
            Navigator.pop(context);

            /// back to signup screen
            Navigator.pop(context);
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