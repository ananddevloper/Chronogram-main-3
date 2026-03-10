import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Notifications", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xff121212),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              _buildSwitchItem("Push Notifications", "Receive push notifications", true),
              const Divider(color: Colors.white12, height: 1),
              _buildSwitchItem("Email Notifications", "Receive email updates", false),
              const Divider(color: Colors.white12, height: 1),
              _buildSwitchItem("SMS Alerts", "Get SMS notifications", false),
              const Divider(color: Colors.white12, height: 1),
              _buildSwitchItem("Upload Complete", "Notify when uploads finish", true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem(String title, String subtitle, bool initialValue) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: initialValue,
            onChanged: (val) {},
            activeColor: Colors.white,
            activeTrackColor: Colors.orange,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.white24,
          )
        ],
      ),
    );
  }
}
