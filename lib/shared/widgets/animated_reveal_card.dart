import 'package:flutter/material.dart';

/// Wraps any widget with a scroll-triggered scale + fade animation.
/// Place this around any card in a ListView — it animates in when
/// it enters the viewport.
class AnimatedRevealCard extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const AnimatedRevealCard({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<AnimatedRevealCard> createState() => _AnimatedRevealCardState();
}

class _AnimatedRevealCardState extends State<AnimatedRevealCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Trigger after optional delay
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => FadeTransition(
        opacity: _opacity,
        child: ScaleTransition(
          scale: _scale,
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
