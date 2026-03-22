import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../widgets/onboarding_widgets.dart';

class WelcomePage extends StatefulWidget {
  final VoidCallback onNext;
  const WelcomePage({super.key, required this.onNext});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {
  late AnimationController _ringController;
  late AnimationController _pulseController;
  late Animation<double> _ringAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _ringAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ringController, curve: Curves.linear));
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.0).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ringController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            Text('GLYSERA', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.4), letterSpacing: 3)),

            // Ring fills middle space
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_ringAnim, _pulseAnim]),
                    builder: (context, _) => CustomPaint(
                      painter: _RingPainter(progress: _ringAnim.value, scale: _pulseAnim.value),
                      child: Center(
                        child: ScaleTransition(
                          scale: _pulseAnim,
                          child: Container(
                            width: 72, height: 72,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: Icon(Icons.water_drop_outlined, color: AppColors.black.withOpacity(0.4), size: 28),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 1, height: 18, color: Colors.white.withOpacity(0.2)),
                  const SizedBox(width: 8),
                  Text('Simulated CGM active', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.35))),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const OnboardingHeading(
              title: 'Better glucose.\nBetter life.',
              subtitle: 'Real-time monitoring, AI-powered insights, and smart alerts — all in one place.',
            ),

            const SizedBox(height: 24),
            const OnboardingDots(current: 0, total: 4),
            const SizedBox(height: 20),

            OnboardingCta(label: 'Get started', onTap: widget.onNext),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double scale;
  _RingPainter({required this.progress, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 8;
    canvas.drawCircle(c, r, Paint()..color = Colors.white.withOpacity(0.08)..style = PaintingStyle.stroke..strokeWidth = 1.5);
    canvas.drawCircle(c, r + 16, Paint()..color = Colors.white.withOpacity(0.04)..style = PaintingStyle.stroke..strokeWidth = 1);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -pi / 2 + progress * 2 * pi, pi * 0.6, false,
        Paint()..color = AppColors.accent..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round);
    final a = -pi / 2 + progress * 2 * pi;
    canvas.drawCircle(Offset(c.dx + r * cos(a), c.dy + r * sin(a)), 4, Paint()..color = AppColors.accent);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress || old.scale != scale;
}
