import 'package:flutter/material.dart';

class AnimatedBackground extends StatelessWidget {
  final Color primaryColor;
  final Widget child;

  const AnimatedBackground({
    super.key,
    required this.primaryColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withValues(alpha: 0.05),
            Colors.white,
            primaryColor.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: child,
    );
  }
}
