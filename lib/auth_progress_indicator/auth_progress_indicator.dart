import 'package:flutter/material.dart';

class AuthProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String message;

  const AuthProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.message = "Continue to complete your registration.",
  });

  @override
  Widget build(BuildContext context) {
    double progressValue = currentStep / totalSteps;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progressValue),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Column(
          children: [

            /// Progress bar + step text in one row
            Row(
              children: [
                /// Progress line expand hogi
                Expanded(
                  child: SizedBox(
                    height: 10,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        /// Background Bar
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.white10,
                          ),
                        ),

                        /// Animated Fill
                        FractionallySizedBox(
                          widthFactor: value,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xffFF8C00),
                                  Color(0xffFF5E00),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                /// Step Text OUTSIDE line
                Text(
                  "$currentStep / $totalSteps",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        );
      },
    );
  }
}
