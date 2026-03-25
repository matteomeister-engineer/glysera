import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';
import '../../../providers.dart';
import '../../../data/models/glucose_reading.dart';
import '../../../shared/widgets/glass_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  final _pageController = PageController();
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(glucoseStreamProvider); // keep stream active
    final latest = ref.watch(latestGlucoseProvider);
    final profile = ref.watch(userProfileProvider);
    final repo = ref.read(glucoseRepositoryProvider);
    final history = ref.read(glucoseSimulatorProvider).recentHistory;
    final unit = profile.glucoseUnit;
    final displayName = profile.name.isNotEmpty ? profile.name : 'there';

    final mgdl = latest?.valueMgdl ?? 100.0;
    final status = latest?.status ?? GlucoseStatus.inRange;
    final trend = latest?.trend ?? GlucoseTrend.stable;
    final tir = repo.timeInRange(low: profile.targetLowMgdl, high: profile.targetHighMgdl);
    final avg = repo.average();

    return Scaffold(
      backgroundColor: AppColors.backgroundSurface,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Fixed header ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.screenHorizontal, 16,
                AppDimens.screenHorizontal, 0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          displayName,
                          style: GoogleFonts.montserrat(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Page dots
                  _PageDots(current: _pageIndex, total: 2),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Alert banner (only when out of range)
            if (status != GlucoseStatus.inRange)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.screenHorizontal, 0,
                  AppDimens.screenHorizontal, 10,
                ),
                child: _AlertBanner(
                  status: status,
                  mgdl: mgdl,
                  unit: unit,
                  trend: trend,
                ),
              ),

            // ── Swipeable pages ───────────────────────────
            Expanded(
              child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _pageIndex = i),
                  children: [
                    // ── Page 1: Main dashboard ─────────────
                    _MainPage(
                      mgdl: mgdl,
                      unit: unit,
                      trend: trend,
                      status: status,
                      tir: tir,
                      avg: avg,
                      history: history,
                      targetLow: profile.targetLowMgdl,
                      targetHigh: profile.targetHighMgdl,
                      pulseAnim: _pulseAnim,
                    ),
                    // ── Page 2: Activity ───────────────────
                    _ActivityPage(
                      mgdl: mgdl,
                      unit: unit,
                      history: history,
                    ),
                  ],
              ),
            ),

            // Bottom padding for nav bar
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}

// ── Page dots ─────────────────────────────────────────────────

class _PageDots extends StatelessWidget {
  final int current, total;
  const _PageDots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(left: 4),
          width: active ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? AppColors.textPrimary : AppColors.textTertiary,
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          ),
        );
      }),
    );
  }
}

// ── Alert banner ──────────────────────────────────────────────

class _AlertBanner extends StatelessWidget {
  final GlucoseStatus status;
  final double mgdl;
  final GlucoseUnit unit;
  final GlucoseTrend trend;

  const _AlertBanner({
    required this.status,
    required this.mgdl,
    required this.unit,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forGlucose(mgdl);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: color,
                  boxShadow: [BoxShadow(color: color.withOpacity(0.7), blurRadius: 6)],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.4),
                    children: [
                      TextSpan(text: '${status.label} — ', style: TextStyle(fontWeight: FontWeight.w600, color: color)),
                      TextSpan(text: '${GlucoseConverter.format(mgdl, unit)} ${unit.label} ${trend.arrow}', style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Page 1: Main dashboard ────────────────────────────────────

class _MainPage extends StatelessWidget {
  final double mgdl, tir, avg, targetLow, targetHigh;
  final GlucoseUnit unit;
  final GlucoseTrend trend;
  final GlucoseStatus status;
  final List<double> history;
  final Animation<double> pulseAnim;

  const _MainPage({
    required this.mgdl,
    required this.unit,
    required this.trend,
    required this.status,
    required this.tir,
    required this.avg,
    required this.history,
    required this.targetLow,
    required this.targetHigh,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row — both cards same height via IntrinsicHeight
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: _GlucoseCard(
                    mgdl: mgdl, unit: unit, trend: trend,
                    status: status, pulseAnim: pulseAnim,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: _TirCard(tir: tir, avg: avg, unit: unit),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Sparkline — takes all remaining space
          Expanded(
            child: _SparklineCard(
              history: history,
              targetLow: targetLow,
              targetHigh: targetHigh,
              latest: mgdl,
            ),
          ),

          const SizedBox(height: 8),

          // AI prediction card
          _AiPredictionCard(history: history, mgdl: mgdl, unit: unit),

          // Swipe hint — fixed height, right arrow only
          SizedBox(
            height: 32,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Swipe for activity', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                  Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.textTertiary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 2: Activity ──────────────────────────────────────────

class _ActivityPage extends StatelessWidget {
  final double mgdl;
  final GlucoseUnit unit;
  final List<double> history;

  const _ActivityPage({
    required this.mgdl,
    required this.unit,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenHorizontal),
      child: Column(
        children: [
          // Section title
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Today's activity",
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Activity cards — take remaining space
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _ActivityCard.white(activity: 'Morning walk',     duration: '30 min',    mgdl: 108, unit: unit),
                const SizedBox(height: 8),
                _ActivityCard.dark(activity: 'Breakfast',         duration: '45g carbs', mgdl: 156, unit: unit),
                const SizedBox(height: 8),
                _ActivityCard.lime(activity: 'Strength training', duration: '1h 30min',  mgdl: 94,  unit: unit),
              ],
            ),
          ),

          // Swipe hint — fixed same height as page 1, left arrow only
          SizedBox(
            height: 32,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.chevron_left_rounded, size: 14, color: AppColors.textTertiary),
                  Text('Swipe for dashboard', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Glucose card ──────────────────────────────────────────────

class _GlucoseCard extends StatelessWidget {
  final double mgdl;
  final GlucoseUnit unit;
  final GlucoseTrend trend;
  final GlucoseStatus status;
  final Animation<double> pulseAnim;

  const _GlucoseCard({
    required this.mgdl, required this.unit, required this.trend,
    required this.status, required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    final isInRange = status == GlucoseStatus.inRange;
    final bg = isInRange ? AppColors.accent : AppColors.textPrimary;
    final textColor = isInRange ? AppColors.textPrimary : Colors.white;
    final subColor = isInRange ? AppColors.textPrimary.withOpacity(0.5) : Colors.white54;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            children: [
              ScaleTransition(
                scale: pulseAnim,
                child: Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isInRange ? AppColors.textPrimary : AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text('Live', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: subColor, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            GlucoseConverter.format(mgdl, unit),
            style: GoogleFonts.montserrat(fontSize: 42, fontWeight: FontWeight.w700, color: textColor, letterSpacing: -2, height: 1),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Text(unit.label, style: TextStyle(fontSize: 11, color: subColor, fontWeight: FontWeight.w500)),
              const SizedBox(width: 5),
              Text(trend.arrow, style: TextStyle(fontSize: 14, color: textColor, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isInRange ? AppColors.textPrimary.withOpacity(0.12) : Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            ),
            child: Text(
              status.label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isInRange ? AppColors.textPrimary : Colors.white, letterSpacing: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

// ── TIR card ──────────────────────────────────────────────────

class _TirCard extends StatelessWidget {
  final double tir, avg;
  final GlucoseUnit unit;
  const _TirCard({required this.tir, required this.avg, required this.unit});

  @override
  Widget build(BuildContext context) {
    final pct = (tir * 100).round();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          const Text('In range', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('$pct%', style: GoogleFonts.montserrat(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -1.5, height: 1)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            child: LinearProgressIndicator(
              value: tir.clamp(0.0, 1.0),
              backgroundColor: AppColors.backgroundSurface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          const Text('Avg', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: avg > 0 ? GlucoseConverter.format(avg, unit) : '--',
                  style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.5),
                ),
                TextSpan(
                  text: '  ${unit.label}',
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sparkline card ────────────────────────────────────────────

class _SparklineCard extends StatelessWidget {
  final List<double> history;
  final double targetLow, targetHigh, latest;
  const _SparklineCard({required this.history, required this.targetLow, required this.targetHigh, required this.latest});

  @override
  Widget build(BuildContext context) {
    final values = history.isEmpty ? [latest] : [...history, latest];
    return Container(
      padding: const EdgeInsets.all(AppDimens.xl),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('3-hour trend', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(AppDimens.radiusFull)),
                child: const Text('LIVE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 0.8)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: CustomPaint(
              painter: _SparklinePainter(values: values, targetLow: targetLow, targetHigh: targetHigh),
              size: Size.infinite,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('3h ago', style: TextStyle(fontSize: 10, color: Colors.white38)),
              Row(children: [
                Container(width: 8, height: 2, color: AppColors.accent.withOpacity(0.5)),
                const SizedBox(width: 4),
                const Text('Target range', style: TextStyle(fontSize: 10, color: Colors.white38)),
              ]),
              const Text('Now', style: TextStyle(fontSize: 10, color: Colors.white38)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final double targetLow, targetHigh;
  const _SparklinePainter({required this.values, required this.targetLow, required this.targetHigh});

  Color _lineColor(double v) {
    if (v < 54 || v > 250) return AppColors.glucoseUrgentLow;
    if (v < targetLow || v > targetHigh) return AppColors.glucoseHigh;
    return AppColors.accent;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    const minV = 40.0, maxV = 300.0;
    double toY(double v) => size.height - ((v - minV) / (maxV - minV)) * size.height;
    double toX(int i) => (i / (values.length - 1)) * size.width;

    final lowY  = toY(targetLow);
    final highY = toY(targetHigh);
    final latest = values.last;
    final lineColor = _lineColor(latest);

    // Range band
    canvas.drawRect(Rect.fromLTRB(0, highY, size.width, lowY),
        Paint()..color = AppColors.accent.withOpacity(0.06));
    final dash = Paint()..color = AppColors.accent.withOpacity(0.2)..strokeWidth = 0.5;
    for (final y in [highY, lowY]) {
      double x = 0;
      while (x < size.width) { canvas.drawLine(Offset(x, y), Offset(x + 4, y), dash); x += 8; }
    }

    // Build smooth path
    final smooth = Path()..moveTo(toX(0), toY(values[0]));
    for (int i = 1; i < values.length; i++) {
      final cx = (toX(i - 1) + toX(i)) / 2;
      smooth.cubicTo(cx, toY(values[i - 1]), cx, toY(values[i]), toX(i), toY(values[i]));
    }

    // Gradient fill under curve
    final fillPath = Path.from(smooth)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withOpacity(0.45),
          lineColor.withOpacity(0.15),
          lineColor.withOpacity(0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Stroke
    canvas.drawPath(smooth, Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);

    // End dot
    final lx = toX(values.length - 1);
    final ly = toY(values.last);
    canvas.drawCircle(Offset(lx, ly), 8, Paint()..color = lineColor.withOpacity(0.25));
    canvas.drawCircle(Offset(lx, ly), 5, Paint()..color = lineColor);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => old.values != values;
}

// ── AI prediction card ────────────────────────────────────────

class _AiPredictionCard extends StatelessWidget {
  final List<double> history;
  final double mgdl;
  final GlucoseUnit unit;

  const _AiPredictionCard({required this.history, required this.mgdl, required this.unit});

  double _predict(int minutes) {
    if (history.length < 2) return mgdl;
    final roc = (history.last - history[history.length > 1 ? history.length - 2 : 0]) /
        (AppConstants.cgmSimulatedInterval.inSeconds / 60.0);
    return (mgdl + roc * (minutes / (AppConstants.cgmSimulatedInterval.inSeconds / 60.0)) * 0.6).clamp(40.0, 400.0);
  }

  @override
  Widget build(BuildContext context) {
    final p10 = _predict(10);
    final p20 = _predict(20);
    final p30 = _predict(30);
    final isRising = p30 > mgdl + 10;
    final isFalling = p30 < mgdl - 10;

    return GlassCard.lime(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 11, color: AppColors.textPrimary),
              const SizedBox(width: 5),
              Text('AI PREDICTION · 30 MIN', style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textPrimary.withOpacity(0.5), letterSpacing: 0.8)),
              const Spacer(),
              Text(isRising ? 'Rising ↑' : isFalling ? 'Falling ↓' : 'Stable →', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                GlucoseConverter.format(p30, unit),
                style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -1.5, height: 1),
              ),
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(unit.label, style: TextStyle(fontSize: 11, color: AppColors.textPrimary.withOpacity(0.45), fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _PredictStep(label: 'Now',  value: GlucoseConverter.format(mgdl, unit), isNow: true),
              const SizedBox(width: 5),
              _PredictStep(label: '+10m', value: GlucoseConverter.format(p10, unit)),
              const SizedBox(width: 5),
              _PredictStep(label: '+20m', value: GlucoseConverter.format(p20, unit)),
              const SizedBox(width: 5),
              _PredictStep(label: '+30m', value: GlucoseConverter.format(p30, unit), isWarning: p30 > 180 || p30 < 70),
            ],
          ),
        ],
      ),
    );
  }
}

class _PredictStep extends StatelessWidget {
  final String label, value;
  final bool isNow, isWarning;
  const _PredictStep({required this.label, required this.value, this.isNow = false, this.isWarning = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
        decoration: BoxDecoration(
          color: isWarning ? Colors.orange.withOpacity(0.2) : isNow ? AppColors.textPrimary.withOpacity(0.1) : Colors.black.withOpacity(0.06),
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: isWarning ? Border.all(color: Colors.orange.withOpacity(0.4)) : null,
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w700, color: isWarning ? Colors.orange.shade800 : AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 9, color: AppColors.textPrimary.withOpacity(0.45))),
          ],
        ),
      ),
    );
  }
}

// ── Activity cards ────────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  final String activity, duration;
  final double mgdl;
  final GlucoseUnit unit;
  final Color backgroundColor, textColor, subTextColor, pillBg, pillText;

  const _ActivityCard._({
    required this.activity, required this.duration, required this.mgdl, required this.unit,
    required this.backgroundColor, required this.textColor, required this.subTextColor,
    required this.pillBg, required this.pillText,
  });

  factory _ActivityCard.white({required String activity, required String duration, required double mgdl, required GlucoseUnit unit}) =>
      _ActivityCard._(activity: activity, duration: duration, mgdl: mgdl, unit: unit,
        backgroundColor: AppColors.backgroundPrimary, textColor: AppColors.textPrimary,
        subTextColor: AppColors.textSecondary, pillBg: AppColors.backgroundSurface, pillText: AppColors.textSecondary);

  factory _ActivityCard.dark({required String activity, required String duration, required double mgdl, required GlucoseUnit unit}) =>
      _ActivityCard._(activity: activity, duration: duration, mgdl: mgdl, unit: unit,
        backgroundColor: AppColors.textPrimary, textColor: Colors.white,
        subTextColor: Colors.white54, pillBg: Colors.white12, pillText: Colors.white70);

  factory _ActivityCard.lime({required String activity, required String duration, required double mgdl, required GlucoseUnit unit}) =>
      _ActivityCard._(activity: activity, duration: duration, mgdl: mgdl, unit: unit,
        backgroundColor: AppColors.accent, textColor: AppColors.textPrimary,
        subTextColor: AppColors.textPrimary.withOpacity(0.5),
        pillBg: AppColors.textPrimary.withOpacity(0.1), pillText: AppColors.textPrimary);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(AppDimens.radiusLg)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: pillBg, borderRadius: BorderRadius.circular(AppDimens.radiusFull)),
                  child: Text(duration, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: pillText)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(GlucoseConverter.format(mgdl, unit), style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.w700, color: textColor, letterSpacing: -1, height: 1)),
              Text(unit.label, style: TextStyle(fontSize: 11, color: subTextColor)),
            ],
          ),
        ],
      ),
    );
  }
}
