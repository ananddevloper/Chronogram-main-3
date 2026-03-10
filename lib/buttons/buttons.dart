import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final bool isEnabled;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.title,
    required this.onTap,
    this.isEnabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    bool effectivelyEnabled = isEnabled && !isLoading;
    
    return InkWell(
      onTap: effectivelyEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: effectivelyEnabled
              ? const LinearGradient(
                  colors: [Color(0xffFF8C00), Color(0xffFF5E00)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : LinearGradient(
                  colors: [Colors.grey.shade800, Colors.grey.shade900],
                ),
          boxShadow: effectivelyEnabled
              ? [
                  BoxShadow(
                    color: const Color(0xffFF5E00).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: effectivelyEnabled ? Colors.white : Colors.white38,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}
