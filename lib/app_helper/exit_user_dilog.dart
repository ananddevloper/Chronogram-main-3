import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExitUser extends StatelessWidget {
  const ExitUser({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xff1C1C1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
     
      content: const Text(
        "Are you sure you want to exit?",
        style: TextStyle(color: Colors.white70,fontSize: 17),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "No",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextButton(
          onPressed: () {
            SystemNavigator.pop(); // 🔥 app close
          },
          child: const Text(
            "Yes",
            style: TextStyle(color: Colors.orange),
          ),
        ),
      ],
    );
  }
}