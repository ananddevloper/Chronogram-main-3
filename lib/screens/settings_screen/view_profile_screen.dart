import 'package:flutter/material.dart';
import 'package:chronogram/modal/user_detail_modal.dart';

class ViewProfileScreen extends StatefulWidget {
  final UserDetailModal? user;
  final String userName;

  const ViewProfileScreen({super.key, this.user, required this.userName});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Profile Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            /// Profile Picture Avatar with Glow
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.orange.shade700, Colors.orange.shade400],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 112,
                        height: 112,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(widget.userName),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2.5),
                          ),
                          child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Member Since 2024",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 45),

            /// INFO LIST
            _buildInfoTile(
              icon: Icons.person_outline_rounded,
              title: "Full Name",
              value: widget.userName,
            ),
            _buildInfoTile(
              icon: Icons.cake_outlined,
              title: "Date of Birth",
              value: widget.user?.dob ?? "Not set",
            ),
            _buildInfoTile(
              icon: Icons.email_outlined,
              title: "Email Address",
              value: _maskEmail(widget.user?.email ?? "no-email@chronogram.com"),
              isLocked: true,
            ),
            _buildInfoTile(
              icon: Icons.phone_android_outlined,
              title: "Phone Number",
              value: _maskPhone(widget.user?.mobileNumber ?? "Not verified"),
              isLocked: true,
            ),
            
            const SizedBox(height: 30),
            
            /// SECURITY NOTE
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: Colors.orange, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "To update your verified email or phone, please contact support for security reasons.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    bool isLocked = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xff1A1A1A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.orange.shade400, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (isLocked)
            const Icon(Icons.lock_outline_rounded, color: Colors.white24, size: 18)
          else
            const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 20),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return "U";
    List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String _maskEmail(String email) {
    if (!email.contains('@')) return email;
    List<String> parts = email.split('@');
    String namePart = parts[0];
    String domainPart = parts[1];
    if (namePart.length <= 2) return email;
    String maskedName = namePart.substring(0, 2) + '*' * (namePart.length - 2) + namePart.substring(namePart.length - 1);
    return '$maskedName@$domainPart';
  }

  String _maskPhone(String phone) {
    if (phone.length < 6) return phone;
    String visibleStart = phone.substring(0, 3);
    String visibleEnd = phone.substring(phone.length - 3);
    String maskedMiddle = '*' * (phone.length - 6);
    return '$visibleStart $maskedMiddle $visibleEnd';
  }
}
