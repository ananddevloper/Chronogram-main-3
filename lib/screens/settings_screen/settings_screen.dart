import 'package:chronogram/screens/settings_screen/about_screen.dart';
import 'package:chronogram/screens/settings_screen/help_support_screen.dart';
import 'package:chronogram/screens/settings_screen/notifications_screen.dart';
import 'package:chronogram/screens/settings_screen/privacy_security_screen.dart';
import 'package:chronogram/screens/settings_screen/storage_screen.dart';
import 'package:chronogram/screens/settings_screen/view_profile_screen.dart';
import 'package:chronogram/screens/sign_up/sign_up_screen/sign_up_screen.dart';
import 'package:chronogram/app_helper/token_saver_helper/token_saver_helper.dart';
import 'package:chronogram/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chronogram/screens/login/login_provider/login_screen_provider.dart';
import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_screen_provider.dart';
import 'package:chronogram/modal/user_detail_modal.dart';

class SettingsScreen extends StatelessWidget {
  final UserDetailModal? user;
  final String userName;

  const SettingsScreen({super.key, this.user, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Settings",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              /// Profile Header
              _SmoothClick(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewProfileScreen(user: user, userName: userName),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.orange, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.3),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(userName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user?.email != null ? _maskEmail(user!.email!) : "tap to view profile",
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(children: [
                            const Text(
                              "View Profile",
                              style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 3),
                            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.orange, size: 10),
                          ]),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white54),
                  ],
                ),
              ),
              const SizedBox(height: 35),

              /// STORAGE SECTION
              _buildSectionTitle("STORAGE"),
              const SizedBox(height: 15),
              _SmoothClick(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StorageScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xff121212),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xff3B260D),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.sd_storage_outlined, color: Colors.orange),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Storage Usage",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              "6.8 GB of 10 GB used",
                              style: TextStyle(color: Colors.white60, fontSize: 13),
                            ),
                            const SizedBox(height: 10),
                            Stack(
                              children: [
                                Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.white12,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: 0.68,
                                  child: Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.chevron_right, color: Colors.white54),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// SYNC PREFERENCES
              _buildSectionTitle("SYNC PREFERENCES"),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xff121212),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    _buildSyncPreference(
                      icon: Icons.wifi,
                      title: "Wi-Fi Only",
                      subtitle: "Sync only when connected to Wi-Fi",
                      iconBg: const Color(0xff3B260D),
                      trailing: const Icon(Icons.radio_button_checked, color: Colors.orange),
                    ),
                    const Divider(color: Colors.white12, height: 1),
                    _buildSyncPreference(
                      icon: Icons.phone_android,
                      title: "Mobile Network",
                      subtitle: "Sync using mobile data (may incur charges)",
                      iconBg: Colors.white10,
                      trailing: const Icon(Icons.radio_button_off, color: Colors.white38),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// GENERAL
              _buildSectionTitle("GENERAL"),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xff121212),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    _buildListTile(Icons.notifications_none, "Notifications", onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                    }),
                    const Divider(color: Colors.white12, height: 1),
                    _buildListTile(Icons.shield_outlined, "Privacy & Security", onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()));
                    }),
                    const Divider(color: Colors.white12, height: 1),
                    _buildListTile(Icons.help_outline, "Help & Support", onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
                    }),
                    const Divider(color: Colors.white12, height: 1),
                    _buildListTile(Icons.info_outline, "About", onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              /// LOGOUT BUTTON
              _SmoothClick(
                onTap: () async {
                  // Show confirmation before logging out
                  final confirm = await showDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xff1A1A1A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Text("Log Out?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      content: const Text(
                        "Are you sure you want to log out of your account?",
                        style: TextStyle(color: Colors.white60, fontSize: 14),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Yes, Logout", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                  if (confirm != true) return;
                  await ApiService.logout();
                  if (!context.mounted) return;
                  context.read<LoginMobileScreenProvider>().clearState();
                  context.read<SignUpScreenProvider>().clearState();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    (route) => false,
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.redAccent, width: 1.5),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.redAccent),
                      SizedBox(width: 10),
                      Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
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
    if (namePart.length <= 2) {
      return email;
    }
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.orange,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildSyncPreference({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBg,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconBg == Colors.white10 ? Colors.white54 : Colors.orange, size: 20),
          ),
          const SizedBox(width: 15),
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
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          trailing,
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, {VoidCallback? onTap}) {
    return _SmoothClick(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white54, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}

class _SmoothClick extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _SmoothClick({required this.child, this.onTap});

  @override
  State<_SmoothClick> createState() => _SmoothClickState();
}

class _SmoothClickState extends State<_SmoothClick> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}
