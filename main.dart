import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'core/theme/theme.dart';
import 'core/router/app_router.dart';
import 'providers.dart';
import 'services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Hive: init boxes then warm the repository cache ──────────
  await HiveService.init();
  // Pre-load persisted readings into the repository cache so the
  // dashboard shows historical data immediately on first frame.
  final container = ProviderContainer();
  await container.read(glucoseRepositoryProvider).load();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  runApp(UncontrolledProviderScope(
    container: container,
    child: const GlyseraApp(),
  ));
}

class GlyseraApp extends ConsumerStatefulWidget {
  const GlyseraApp({super.key});
  @override
  ConsumerState<GlyseraApp> createState() => _GlyseraAppState();
}

class _GlyseraAppState extends ConsumerState<GlyseraApp>
    with SingleTickerProviderStateMixin {

  // 0 = Lottie, 1 = sensor ring, 2 = app
  int _phase = 0;

  late AnimationController _ringController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    ref.read(glucoseSimulatorProvider);

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ringController,
        curve: const Interval(0, 0.3, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  void _onLottieComplete() {
    if (mounted) setState(() => _phase = 1);
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _phase = 2);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_phase == 0) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: _LottieScreen(onComplete: _onLottieComplete),
        builder: _mqBuilder,
      );
    }
    if (_phase == 1) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: _SplashScreen(fadeAnim: _fadeAnim),
        builder: _mqBuilder,
      );
    }
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Glysera',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      builder: _mqBuilder,
    );
  }

  Widget _mqBuilder(BuildContext context, Widget? child) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(
          MediaQuery.of(context).textScaler.scale(1.0).clamp(0.85, 1.3),
        ),
      ),
      child: child!,
    );
  }
}

// ── Lottie splash — capped at 3 seconds ──────────────────────

class _LottieScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const _LottieScreen({required this.onComplete});

  @override
  State<_LottieScreen> createState() => _LottieScreenState();
}

class _LottieScreenState extends State<_LottieScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this);
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      body: Center(
        child: Lottie.asset(
          'assets/animations/loading_animation.json',
          controller: _ctrl,
          onLoaded: (composition) {
            final capped = composition.duration > const Duration(seconds: 3)
                ? const Duration(seconds: 3)
                : composition.duration;
            _ctrl.duration = capped;
            _ctrl.forward();
          },
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

// ── Sensor ring splash with sonar pulse ──────────────────────

class _SplashScreen extends StatelessWidget {
  final Animation<double> fadeAnim;
  const _SplashScreen({required this.fadeAnim});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.screenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              FadeTransition(
                opacity: fadeAnim,
                child: Text(
                  'Glysera',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const Spacer(),
              Center(child: _SonarPulse()),
              const SizedBox(height: 20),
              Center(
                child: FadeTransition(
                  opacity: fadeAnim,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.accent, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text('Connecting to sensor...',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.45))),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              FadeTransition(
                opacity: fadeAnim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Better glucose.\nBetter life.',
                        style: GoogleFonts.montserrat(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -1,
                            height: 1.15)),
                    const SizedBox(height: 8),
                    Text('AI-powered glucose monitoring',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.4))),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sonar pulse ───────────────────────────────────────────────

class _SonarPulse extends StatefulWidget {
  @override
  State<_SonarPulse> createState() => _SonarPulseState();
}

class _SonarPulseState extends State<_SonarPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  static const double _centerRadius = 36.0;
  static const double _maxRadius    = 110.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _maxRadius * 2,
      height: _maxRadius * 2,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _SonarPainter(
            progress: _ctrl.value,
            centerRadius: _centerRadius,
            maxRadius: _maxRadius,
          ),
          child: Center(
            child: Container(
              width: _centerRadius * 2,
              height: _centerRadius * 2,
              decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
              child: Icon(Icons.water_drop_outlined,
                  color: AppColors.black.withOpacity(0.4), size: 28),
            ),
          ),
        ),
      ),
    );
  }
}

class _SonarPainter extends CustomPainter {
  final double progress;
  final double centerRadius;
  final double maxRadius;
  const _SonarPainter(
      {required this.progress,
      required this.centerRadius,
      required this.maxRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const ringCount = 4;
    for (int i = ringCount - 1; i >= 0; i--) {
      final phase = (progress + i / ringCount) % 1.0;
      final radius = centerRadius + (maxRadius - centerRadius) * phase;
      final opacity = ((1.0 - phase) * 0.35).clamp(0.0, 1.0);
      canvas.drawCircle(center, radius,
          Paint()
            ..color = const Color(0xFFC8FF00).withOpacity(opacity)
            ..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(_SonarPainter old) => old.progress != progress;
}

// ── Ring painter (unused — kept for reference) ────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  const _RingPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 8;
    canvas.drawCircle(c, r,
        Paint()..color = Colors.white.withOpacity(0.08)
          ..style = PaintingStyle.stroke..strokeWidth = 1.5);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r),
        -pi / 2 + progress * 2 * pi, pi * 0.6, false,
        Paint()..color = AppColors.accent
          ..style = PaintingStyle.stroke..strokeWidth = 3
          ..strokeCap = StrokeCap.round);
    final a = -pi / 2 + progress * 2 * pi;
    canvas.drawCircle(Offset(c.dx + r * cos(a), c.dy + r * sin(a)), 4,
        Paint()..color = AppColors.accent);
  }
  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
