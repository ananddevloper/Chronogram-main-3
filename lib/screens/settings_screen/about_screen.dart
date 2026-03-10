import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
        title: const Text("About", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // App Logo & Name
            Center(
              child: Column(children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xff1A1A1A),
                    border: Border.all(color: Colors.orange.withOpacity(0.4), width: 2),
                    boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.2), blurRadius: 25)],
                  ),
                  child: const Center(
                    child: Icon(Icons.photo_library_outlined, color: Colors.orange, size: 38),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("CHRONOGRAM", style: TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 4,
                )),
                const SizedBox(height: 6),
                Text("Version 1.0.0 (Build 1)", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                const SizedBox(height: 4),
                Text("Preserving Moments Forever", style: TextStyle(color: Colors.orange.withOpacity(0.7), fontSize: 12, letterSpacing: 1.5)),
              ]),
            ),
            const SizedBox(height: 36),
            _buildCard([
              _buildInfoRow("Developer", "Chronogram Team"),
              const Divider(color: Colors.white12, height: 1),
              _buildInfoRow("Platform", "Android & iOS"),
              const Divider(color: Colors.white12, height: 1),
              _buildInfoRow("Framework", "Flutter 3.x"),
              const Divider(color: Colors.white12, height: 1),
              _buildInfoRow("Release Date", "2024"),
            ]),
            const SizedBox(height: 28),
            _buildCard([
              _buildNavTile(Icons.policy_outlined, "Privacy Policy", onTap: () {}),
              const Divider(color: Colors.white12, height: 1),
              _buildNavTile(Icons.gavel_outlined, "Terms of Service", onTap: () {}),
              const Divider(color: Colors.white12, height: 1),
              _buildNavTile(Icons.terminal_rounded, "Open Source Licenses", onTap: () {}),
            ]),
            const SizedBox(height: 40),
            Text("Made with ❤️ in India", style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 12)),
            const SizedBox(height: 6),
            Text("© 2024 Chronogram. All rights reserved.", style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> c) => Container(
        decoration: BoxDecoration(
          color: const Color(0xff121212), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white12)),
        child: Column(children: c),
      );

  Widget _buildInfoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _buildNavTile(IconData icon, String title, {VoidCallback? onTap}) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: Colors.white54, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600))),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ]),
        ),
      );
}
