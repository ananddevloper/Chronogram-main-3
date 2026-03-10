import 'package:chronogram/screens/home_screen/chat_screen.dart';
import 'package:chronogram/screens/home_screen/photo_screen.dart';
import 'package:chronogram/screens/home_screen/video_screen.dart';
import 'package:chronogram/screens/settings_screen/settings_screen.dart';
import 'package:chronogram/screens/login/login_helper/aseet_helper.dart';
import 'package:chronogram/screens/login/login_provider/login_screen_provider.dart';
import 'package:chronogram/screens/login/login_screen/login_screen.dart';
import 'package:chronogram/service/api_service.dart';
import 'package:chronogram/modal/user_detail_modal.dart';
import 'package:chronogram/screens/sign_up/sign_up_screen/sign_up_email_screen.dart';
import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  int currentIndex = 0;
  String userName = "Loading...";
  UserDetailModal? user;
  late AnimationController glowController;

  @override
  void initState() {
    super.initState();
    _fetchUser();

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  Future<void> _fetchUser() async {
    try {
      // 1. Fetch user profile first (Independent of permissions)
      final userProfile = await ApiService.getUserProfile();
      if (userProfile != null) {
        if (mounted) {
          setState(() {
            user = userProfile;
            userName = userProfile.name ?? userProfile.mobileNumber ?? "User";
          });
        }
      }
      
      // 2. Request permissions (Optional here as children also handle it)
      // Moving this after profile ensures name is updated even if this hangs
      PhotoManager.requestPermissionExtend().then((ps) {
         if (ps.isAuth && mounted) {
           // Permission granted
         }
      });

    } catch (e) {
      if (mounted) {
        setState(() {
          userName = "User";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> pages = [
      PhotoScreen(user: user, userName: userName),
      VideoScreen(user: user, userName: userName),
      ChatScreen(),
      SettingsScreen(user: user, userName: userName),
    ];

    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: Column(
          children: [

            /// PAGES
            Expanded(
              child: IndexedStack(
                index: currentIndex,
                children: pages,
              ),
            ),
          ],
        ),
      ),

      /// 🔥 PREMIUM BOTTOM NAV
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xff111111),
          border: Border(
            top: BorderSide(color: Colors.white12),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                navItem(Icons.camera_alt_outlined, "Photos", 0),
                navItem(Icons.videocam_outlined, "Videos", 1),
                navItem(Icons.chat_bubble_outline, "Chat", 2),
                navItem(Icons.settings_outlined, "Settings", 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// NAV ITEM
  Widget navItem(IconData icon, String label, int index) {
    bool active = currentIndex == index;

    return _SmoothClick(
      onTap: () {
        setState(() => currentIndex = index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? const Color(0xffFF8C00).withOpacity(.15)
                  : Colors.transparent,
            ),
            child: Icon(
              icon,
              color: active ? const Color(0xffFF8C00) : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xffFF8C00) : Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    glowController.dispose();
    super.dispose();
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
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}


