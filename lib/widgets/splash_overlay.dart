import 'package:flutter/material.dart';

import 'nexshow_logo.dart';

/// Full-screen white splash overlay that zooms/fades the NexShow logo in.
///
/// This widget only renders the animation — it has no timer and does not
/// navigate anywhere. The parent decides when to remove it from the tree
/// (typically by fading it out once the splash duration elapses).
class SplashOverlay extends StatefulWidget {
  const SplashOverlay({super.key});

  @override
  State<SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<SplashOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _zoom;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );
    _zoom = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeIn.value,
              child: Transform.scale(
                scale: _zoom.value,
                child: const NexShowLogo(size: 460, glowStrength: 0),
              ),
            );
          },
        ),
      ),
    );
  }
}
