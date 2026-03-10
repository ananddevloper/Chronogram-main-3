import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:chronogram/screens/login/login_helper/aseet_helper.dart';
import 'package:chronogram/screens/sign_up/sign_up_screen/sign_up_screen.dart';
import 'package:chronogram/screens/home_screen/home_screen.dart';
import 'package:chronogram/app_helper/token_saver_helper/token_saver_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _dotsController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _ringAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.6, curve: Curves.easeInOutCubic)),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic)),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.1, 0.7, curve: Curves.easeInOutCubic)),
    );
    _ringAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.4, 1.0, curve: Curves.easeInOutCubic)),
    );

    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);

    _dotsController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat();

    _mainController.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 3800));
    String? token = await TokenHelper.getToken();
    if (!mounted) return;
    Widget next = (token != null && token.isNotEmpty) ? const HomeScreen() : const SignUpScreen();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => next,
        settings: next is HomeScreen ? const RouteSettings(name: "HomeScreen") : null,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Glow: top-right ──
          Positioned(
            top: -100, right: -60,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Container(
                width: 300, height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.08 + 0.05 * _pulseController.value),
                      blurRadius: 140, spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ── Glow: bottom-left ──
          Positioned(
            bottom: -60, left: -40,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepOrange.withOpacity(0.05 + 0.03 * _pulseController.value),
                      blurRadius: 110, spreadRadius: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Main content ──
          Center(
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ── Logo with sweeping ring ──
                          SizedBox(
                            width: 170, height: 170,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer breathing ring
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (_, __) => Container(
                                    width: 154,
                                    height: 154,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.orange.withOpacity(0.06 + 0.05 * _pulseController.value),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                                // Sweeping arc with rotation
                                Transform.rotate(
                                  angle: _ringAnimation.value * 1.5,
                                  child: CustomPaint(
                                    size: const Size(130, 130),
                                    painter: _RingPainter(_ringAnimation.value),
                                  ),
                                ),
                                // Logo glow
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (_, __) => Container(
                                    width: 105, height: 105,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.orange.withOpacity(0.2 + 0.12 * _pulseController.value),
                                          blurRadius: 50, spreadRadius: 10,
                                        ),
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.1 * _pulseController.value),
                                          blurRadius: 20, spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Image.asset(ScreenImage.allLogoBr, height: 92),
                              ],
                            ),
                          ),

                          const SizedBox(height: 42),

                          // ── App name with gradient ──
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.orange.shade300.withOpacity(0.8 + 0.2 * _pulseController.value),
                                    Colors.white,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  stops: [0.0, 0.4 + 0.2 * _pulseController.value, 1.0],
                                ).createShader(bounds),
                                child: const Text(
                                  "CHRONOGRAM",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 8.0,
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 12),

                          // ── Tagline ──
                          FadeTransition(
                            opacity: CurvedAnimation(parent: _mainController, curve: const Interval(0.6, 1.0)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.symmetric(
                                  horizontal: BorderSide(color: Colors.white.withOpacity(0.06), width: 1),
                                ),
                              ),
                              child: Text(
                                "PRESERVING MOMENTS FOREVER",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.28),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 4.0,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 80),

                          // ── 3-dot bouncing loader ──
                          AnimatedBuilder(
                            animation: _dotsController,
                            builder: (_, __) => _DotsLoader(progress: _dotsController.value),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),


          // ── Version ──
          Positioned(
            bottom: 36, left: 0, right: 0,
            child: Center(
              child: Text(
                "v1.0.0",
                style: TextStyle(color: Colors.white.withOpacity(0.14), fontSize: 10, letterSpacing: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Sweeping orange arc during logo reveal
class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = SweepGradient(
        colors: [Colors.orange.withOpacity(0.0), Colors.orange.withOpacity(0.55 * progress)],
        stops: const [0.0, 1.0],
        transform: GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// 3 dots that bounce in sequence
class _DotsLoader extends StatelessWidget {
  final double progress;
  const _DotsLoader({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final offset = (progress - i * 0.18).clamp(0.0, 1.0);
        final bounce = math.sin(offset * math.pi);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 6, height: 6,
          transform: Matrix4.translationValues(0, -9 * bounce, 0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.orange.withOpacity(0.25 + 0.75 * bounce),
          ),
        );
      }),
    );
  }
}
