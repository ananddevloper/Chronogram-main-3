import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
          "Help & Support",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.withOpacity(0.15), Colors.orange.withOpacity(0.03)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.withOpacity(0.2)),
              ),
              child: Column(children: [
                const Icon(Icons.support_agent_rounded, color: Colors.orange, size: 40),
                const SizedBox(height: 12),
                const Text("How can we help?",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text("We're here 24/7 for any questions or issues.", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
              ]),
            ),
            const SizedBox(height: 28),
            _sectionTitle("CONTACT US"),
            const SizedBox(height: 12),
            _buildCard([
              _buildNavTile(Icons.email_outlined, "Email Support", subtitle: "support@chronogram.app", onTap: () {}),
              const Divider(color: Colors.white12, height: 1),
              _buildNavTile(Icons.chat_bubble_outline_rounded, "Live Chat", subtitle: "Available 9AM – 6PM IST", onTap: () {}),
            ]),
            const SizedBox(height: 28),
            _sectionTitle("RESOURCES"),
            const SizedBox(height: 12),
            _buildCard([
              _buildNavTile(Icons.menu_book_outlined, "FAQ", subtitle: "Frequently asked questions", onTap: () {}),
              const Divider(color: Colors.white12, height: 1),
              _buildNavTile(Icons.policy_outlined, "Privacy Policy", onTap: () {}),
              const Divider(color: Colors.white12, height: 1),
              _buildNavTile(Icons.gavel_outlined, "Terms of Service", onTap: () {}),
            ]),
            const SizedBox(height: 28),
            _sectionTitle("REPORT AN ISSUE"),
            const SizedBox(height: 12),
            _buildCard([
              _buildNavTile(Icons.bug_report_outlined, "Report a Bug", onTap: () {}),
              const Divider(color: Colors.white12, height: 1),
              _buildNavTile(Icons.feedback_outlined, "Send Feedback", onTap: () {}),
            ]),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5));

  Widget _buildCard(List<Widget> c) => Container(
        decoration: BoxDecoration(
            color: const Color(0xff121212),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white12)),
        child: Column(children: c),
      );

  Widget _buildNavTile(IconData icon, String title, {String? subtitle, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xff3B260D), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ]),
          ),
          const Icon(Icons.chevron_right, color: Colors.white54),
        ]),
      ),
    );
  }
}
