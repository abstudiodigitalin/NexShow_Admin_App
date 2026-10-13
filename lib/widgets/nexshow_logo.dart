import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The NexShow logo with a neon pink/purple glow behind it.
class NexShowLogo extends StatelessWidget {
  const NexShowLogo({super.key, this.size = 320, this.glowStrength = 1.0});

  final double size;

  /// 0.0 (no glow) to 1.0 (full glow) — driven by the splash animation.
  final double glowStrength;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonPink.withOpacity(0.35 * glowStrength),
            blurRadius: 60,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: AppTheme.neonPurple.withOpacity(0.35 * glowStrength),
            blurRadius: 90,
            spreadRadius: 20,
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/nexshow_logo.png',
        width: size * 0.8,
        fit: BoxFit.contain,
      ),
    );
  }
}
