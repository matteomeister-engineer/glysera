import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/animated_reveal_card.dart';
import '../../../core/constants/constants.dart';
import '../../../providers.dart';
import '../../../data/models/glucose_reading.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(glucoseStreamProvider);
    final profile = ref.watch(userProfileProvider);
    final repo = ref.read(glucoseRepositoryProvider);
    final history = ref.read(glucoseSimulatorProvider).recentHistory;
    final latest = ref.watch(latestGlucoseProvider);
    final unit = profile.glucoseUnit;
    final mgdl = latest?.valueMgdl ?? 100.0;
    final tir = repo.timeInRange(low: profile.targetLowMgdl, high: profile.targetHighMgdl);
    final avg = repo.average();

    return Scaffold(
      backgroundColor: AppColors.backgroundSurface,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.screenHorizontal, 16,
                AppDimens.screenHorizontal, 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Insights',
                    style: GoogleFonts.montserrat(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Powered by your CGM data',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Scrollable content ────────────────────────
            Expanded(
              child: Builder(
                builder: (context) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.screenHorizontal, 0,
                      AppDimens.screenHorizontal, 108,
                    ),
                    children: [

                    // Score card — same intrinsic height as other cards
                    _ScoreCard(tir: tir, avg: avg, unit: unit, history: history, mgdl: mgdl),

                    const SizedBox(height: 12),

                    AnimatedRevealCard(
                      delay: const Duration(milliseconds: 0),
                      child: _WeeklyCard(history: history, unit: unit, targetLow: profile.targetLowMgdl, targetHigh: profile.targetHighMgdl),
                    ),

                    const SizedBox(height: 10),

                    AnimatedRevealCard(
                      delay: const Duration(milliseconds: 60),
                      child: _InsightCard(
                        icon: Icons.wb_sunny_rounded,
                        iconColor: const Color(0xFFFFB347),
                        tag: 'PATTERN',
                        title: 'Morning spikes detected',
                        body: 'Your glucose tends to rise between 7-9 AM, likely due to the dawn phenomenon. Consider adjusting your basal rate or morning meal timing.',
                        accentColor: const Color(0xFFFFB347),
                      ),
                    ),

                    const SizedBox(height: 10),

                    AnimatedRevealCard(
                      delay: const Duration(milliseconds: 120),
                      child: _InsightCard(
                        icon: Icons.restaurant_rounded,
                        iconColor: AppColors.accent,
                        tag: 'MEAL IMPACT',
                        title: 'Post-lunch control is strong',
                        body: 'Your glucose returns to target within 2h after lunch on most days. Your current bolus timing appears well matched to your meal composition.',
                        accentColor: AppColors.accent,
                        dark: true,
                      ),
                    ),

                    const SizedBox(height: 10),

                    AnimatedRevealCard(
                      delay: const Duration(milliseconds: 180),
                      child: _InsightCard(
                        icon: Icons.directions_walk_rounded,
                        iconColor: const Color(0xFF85B7EB),
                        tag: 'ACTIVITY',
                        title: 'Exercise lowers glucose effectively',
                        body: 'Physical activity consistently brings glucose down by 15-25 mg/dL within 30 minutes. Keep using movement as a glucose management tool.',
                        accentColor: const Color(0xFF85B7EB),
                      ),
                    ),

                    const SizedBox(height: 10),

                    AnimatedRevealCard(
                      delay: const Duration(milliseconds: 240),
                      child: _InsightCard(
                        icon: Icons.bedtime_rounded,
                        iconColor: AppColors.purpleCard,
                        tag: 'OVERNIGHT',
                        title: 'Stable nights - great control',
                        body: 'Overnight glucose stayed within your target range 92% of the time this week. No urgent lows or highs detected during sleep hours.',
                        accentColor: AppColors.purpleCard,
                        dark: true,
                      ),
                    ),

                    const SizedBox(height: 10),

                    AnimatedRevealCard(
                      delay: const Duration(milliseconds: 300),
                      child: _RecommendationCard(tir: tir),
                    ),
                  ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Score card ────────────────────────────────────────────────

class _ScoreCard extends StatelessWidget {
  final double tir, avg, mgdl;
  final GlucoseUnit unit;
  final List<double> history;

  const _ScoreCard({
    required this.tir,
    required this.avg,
    required this.unit,
    required this.history,
    required this.mgdl,
  });

  int get _score {
    final tirScore = (tir * 70).round();
    final avgScore = avg > 0 ? (30 - ((avg - 100).abs() / 10).clamp(0, 30)).round() : 15;
    return (tirScore + avgScore).clamp(0, 100);
  }

  String get _grade {
    final s = _score;
    if (s >= 85) return 'Excellent';
    if (s >= 70) return 'Good';
    if (s >= 55) return 'Fair';
    return 'Needs work';
  }

  Color get _gradeColor {
    final s = _score;
    if (s >= 85) return AppColors.accent;
    if (s >= 70) return const Color(0xFF85B7EB);
    if (s >= 55) return const Color(0xFFFFB347);
    return AppColors.glucoseUrgentLow;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Grade pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _gradeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              border: Border.all(color: _gradeColor.withOpacity(0.4)),
            ),
            child: Text(
              _grade,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _gradeColor),
            ),
          ),

          const SizedBox(height: 28),

          // Big score ring
          SizedBox(
            width: 140,
            height: 140,
            child: CustomPaint(
              painter: _ScoreRingPainter(score: _score / 100, color: _gradeColor),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_score',
                      style: GoogleFonts.montserrat(
                        fontSize: 44,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1,
                        letterSpacing: -2,
                      ),
                    ),
                    Text(
                      '/100',
                      style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Title
          Text(
            'Glucose health score',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Based on time-in-range and average glucose from your CGM session.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.45),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double score;
  final Color color;
  const _ScoreRingPainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 6;
    const stroke = 6.0;
    const startAngle = -pi / 2;

    // Background ring
    canvas.drawCircle(
      Offset(cx, cy), r,
      Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    // Score arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      startAngle,
      score * 2 * pi,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) => old.score != score;
}

// ── Insight card ──────────────────────────────────────────────

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String tag;
  final String title;
  final String body;
  final Color accentColor;
  final bool dark;

  const _InsightCard({
    required this.icon,
    required this.iconColor,
    required this.tag,
    required this.title,
    required this.body,
    required this.accentColor,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = dark ? AppColors.textPrimary : AppColors.backgroundPrimary;
    final titleColor = dark ? Colors.white : AppColors.textPrimary;
    final bodyColor = dark ? Colors.white.withOpacity(0.5) : AppColors.textSecondary;
    final tagColor = dark ? accentColor : accentColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: dark ? null : Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon box
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(dark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tag,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: tagColor,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12,
                    color: bodyColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Weekly mini-chart card ─────────────────────────────────────

class _WeeklyCard extends StatelessWidget {
  final List<double> history;
  final GlucoseUnit unit;
  final double targetLow, targetHigh;

  const _WeeklyCard({
    required this.history,
    required this.unit,
    required this.targetLow,
    required this.targetHigh,
  });

  @override
  Widget build(BuildContext context) {
    // Simulate 7-day avg bars from history
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final rng = Random(42);
    final avgs = List.generate(7, (i) {
      if (history.isEmpty) return 90 + rng.nextInt(60).toDouble();
      final base = history[i % history.length];
      return (base + rng.nextInt(20) - 10).clamp(60.0, 280.0);
    });

    // Custom palette
    const bgColor      = Color(0xFFA093FE);
    const barBgColor   = Color(0xFF836ED5);
    const barFillColor = Color(0xFF181818);
    const dayTextColor = Colors.white;
    const aboveColor   = Color(0xFFF9DA12);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded, size: 16, color: Color(0xFF181818)),
              const SizedBox(width: 8),
              Text(
                '7 DAY AVERAGE',
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF181818),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final val = avgs[i];
                final inRange = val >= targetLow && val <= targetHigh;
                final frac = ((val - 60) / (280 - 60)).clamp(0.0, 1.0);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: barBgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: frac,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: inRange ? barFillColor : aboveColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          days[i],
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: dayTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Legend(color: barFillColor, label: 'In range'),
              const SizedBox(width: 16),
              _Legend(color: aboveColor, label: 'Above range'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}

// ── Recommendation card ───────────────────────────────────────

class _RecommendationCard extends StatelessWidget {
  final double tir;
  const _RecommendationCard({required this.tir});

  String get _rec {
    if (tir >= 0.85) return 'Your control is excellent. Keep up your current routine and watch for any changes in your morning pattern.';
    if (tir >= 0.70) return 'You\'re doing well. Focus on reducing post-meal spikes by adjusting bolus timing 15 minutes earlier.';
    return 'Consider reviewing your basal rates with your care team. More frequent CGM checks around meals may help.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: const Icon(Icons.auto_awesome_rounded, size: 17, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI RECOMMENDATION',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary.withOpacity(0.55),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _rec,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '⚠︎ For informational purposes only. Always consult your care team.',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textPrimary.withOpacity(0.45),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
