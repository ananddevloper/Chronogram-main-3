import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_email_provider.dart';
import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_email_otp_provider.dart';

class EditEmailDialog extends StatelessWidget {
  const EditEmailDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xff1C1C1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        "Change Email?",
        style: TextStyle(color: Colors.white),
      ),
      content: const Text(
        "Do you want to change your email address?",
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
            context.read<SignUpEmailOtpProvider>().stopTimer();

            /// 🔥 clear email
            context.read<SignUpEmailProvider>().clearEmail();

            /// close dialog
            Navigator.pop(context);

            /// back to email screen
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