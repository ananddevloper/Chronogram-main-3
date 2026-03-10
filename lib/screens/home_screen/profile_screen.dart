import 'package:flutter/material.dart';
import 'package:chronogram/modal/user_detail_modal.dart';

class ProfileScreen extends StatefulWidget {
  final UserDetailModal? user;
  const ProfileScreen({super.key, this.user});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 80, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              widget.user?.name ?? 'Loading Profile...',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.user?.mobileNumber ?? '',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            if (widget.user?.email != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.user!.email!,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
