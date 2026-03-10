import 'package:flutter/material.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});
  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _twoFactor = true;
  bool _biometric = false;
  bool _activityLog = true;

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
          "Privacy & Security",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("ACCOUNT SECURITY"),
            const SizedBox(height: 12),
            _buildCard([
              _buildToggle(
                icon: Icons.verified_user_outlined,
                title: "Two-Factor Authentication",
                subtitle: "Require OTP on every new device login",
                value: _twoFactor,
                onChanged: (v) => setState(() => _twoFactor = v),
              ),
              const Divider(color: Colors.white12, height: 1),
              _buildToggle(
                icon: Icons.fingerprint,
                title: "Biometric Unlock",
                subtitle: "Use fingerprint or face to open the app",
                value: _biometric,
                onChanged: (v) => setState(() => _biometric = v),
              ),
              const Divider(color: Colors.white12, height: 1),
              _buildToggle(
                icon: Icons.history_outlined,
                title: "Login Activity Log",
                subtitle: "Track all login events across devices",
                value: _activityLog,
                onChanged: (v) => setState(() => _activityLog = v),
              ),
            ]),
            const SizedBox(height: 28),
            _sectionTitle("PRIVACY"),
            const SizedBox(height: 12),
            _buildCard([
              _buildNavTile(Icons.lock_person_outlined, "Data & Permissions", onTap: () {}),
              const Divider(color: Colors.white12, height: 1),
              _buildNavTile(Icons.delete_outline_rounded, "Delete Account", color: Colors.redAccent, onTap: () {}),
            ]),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.orange.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: Colors.orange, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Chronogram uses end-to-end encryption to protect your media and personal data.",
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5));

  Widget _buildCard(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: const Color(0xff121212),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(children: children),
      );

  Widget _buildToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xff3B260D), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ]),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: Colors.orange),
        ],
      ),
    );
  }

  Widget _buildNavTile(IconData icon, String title, {Color? color, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color != null ? color.withOpacity(0.1) : Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color ?? Colors.white54, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title,
                  style: TextStyle(color: color ?? Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            Icon(Icons.chevron_right, color: color ?? Colors.white54),
          ],
        ),
      ),
    );
  }
}
