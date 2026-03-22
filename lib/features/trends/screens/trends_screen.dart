import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';
import '../../../providers.dart';
import '../../../data/models/glucose_reading.dart';

class TrendsScreen extends ConsumerStatefulWidget {
  const TrendsScreen({super.key});

  @override
  ConsumerState<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends ConsumerState<TrendsScreen> {
  _Range _range = _Range.h3;
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<double> _points(List<double> history, double latest) {
    final all = [...history, latest];
    if (all.isEmpty) return [latest];
    switch (_range) {
      case _Range.h3: return all.length > 18 ? all.sublist(all.length - 18) : all;
      case _Range.h6: return all.length > 36 ? all.sublist(all.length - 36) : all;
      case _Range.h24: return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(glucoseStreamProvider);
    final latest = ref.watch(latestGlucoseProvider);
    final profile = ref.watch(userProfileProvider);
    final repo = ref.read(glucoseRepositoryProvider);
    final history = ref.read(glucoseSimulatorProvider).recentHistory;
    final unit = profile.glucoseUnit;
    final mgdl = latest?.valueMgdl ?? 100.0;
    final trend = latest?.trend ?? GlucoseTrend.stable;
    final tir = repo.timeInRange(low: profile.targetLowMgdl, high: profile.targetHighMgdl);
    final avg = repo.average();
    final points = _points(history, mgdl);
    final tirPct = (tir * 100).round().clamp(0, 100);
    final remaining = 100 - tirPct;
    final lowPct = (remaining * 0.4).round().clamp(0, remaining);
    final highPct = (remaining - lowPct).clamp(0, remaining);

    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Fixed header ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.screenHorizontal, 16,
                AppDimens.screenHorizontal, 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Trends',
                        style: GoogleFonts.montserrat(
                          fontSize: 26, fontWeight: FontWeight.w700,
                          color: Colors.white, letterSpacing: -0.8,
                        ),
                      ),
                      const Spacer(),
                      _StatusPill(mgdl: mgdl),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        GlucoseConverter.format(mgdl, unit),
                        style: GoogleFonts.montserrat(
                          fontSize: 52, fontWeight: FontWeight.w700,
                          color: Colors.white, letterSpacing: -2, height: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(unit.label, style: const TextStyle(fontSize: 13, color: Colors.white54)),
                      const SizedBox(width: 6),
                      Text(trend.arrow, style: TextStyle(fontSize: 20, color: AppColors.accent, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Range + page dots row
                  Row(
                    children: [
                      _RangeSelector(selected: _range, onChanged: (r) => setState(() => _range = r)),
                      const Spacer(),
                      _PageDots(current: _pageIndex, total: 2),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // ── Swipeable pages ───────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _pageIndex = i),
                children: [
                  // Page 1 — Chart
                  _ChartPage(
                    points: points,
                    targetLow: profile.targetLowMgdl,
                    targetHigh: profile.targetHighMgdl,
                    rangeLabel: _range.label,
                  ),
                  // Page 2 — Stats
                  _StatsPage(
                    tirPct: tirPct,
                    lowPct: lowPct,
                    highPct: highPct,
                    avg: avg,
                    unit: unit,
                    targetLow: profile.targetLowMgdl,
                    targetHigh: profile.targetHighMgdl,
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

// ── Enums ─────────────────────────────────────────────────────

enum _Range {
  h3('3h'), h6('6h'), h24('24h');
  final String label;
  const _Range(this.label);
}

// ── Page dots ─────────────────────────────────────────────────

class _PageDots extends StatelessWidget {
  final int current, total;
  const _PageDots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(left: 4),
          width: i == current ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: i == current ? AppColors.accent : Colors.white24,
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          ),
        );
      }),
    );
  }
}

// ── Range selector ────────────────────────────────────────────

class _RangeSelector extends StatelessWidget {
  final _Range selected;
  final ValueChanged<_Range> onChanged;
  const _RangeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _Range.values.map((r) {
              final sel = r == selected;
              return GestureDetector(
                onTap: () => onChanged(r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  ),
                  child: Text(
                    r.label,
                    style: GoogleFonts.montserrat(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: sel ? AppColors.textPrimary : Colors.white54,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ── Status pill ───────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final double mgdl;
  const _StatusPill({required this.mgdl});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forGlucose(mgdl);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        AppColors.statusLabel(mgdl),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

// ── Page 1: Chart ─────────────────────────────────────────────

class _ChartPage extends StatelessWidget {
  final List<double> points;
  final double targetLow, targetHigh;
  final String rangeLabel;

  const _ChartPage({
    required this.points,
    required this.targetLow,
    required this.targetHigh,
    required this.rangeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenHorizontal),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.5),
              ),
              padding: const EdgeInsets.all(AppDimens.xxl),
              child: Column(
                children: [
                  Expanded(
                    child: CustomPaint(
                      painter: _ChartPainter(
                        values: points,
                        targetLow: targetLow,
                        targetHigh: targetHigh,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$rangeLabel ago', style: const TextStyle(fontSize: 10, color: Colors.white24)),
                      Row(children: [
                        Container(width: 10, height: 2, color: AppColors.accent.withOpacity(0.5)),
                        const SizedBox(width: 4),
                        const Text('Target', style: TextStyle(fontSize: 10, color: Colors.white24)),
                      ]),
                      const Text('Now', style: TextStyle(fontSize: 10, color: Colors.white24)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 32,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Swipe for stats', style: TextStyle(fontSize: 11, color: Colors.white24)),
                  Icon(Icons.chevron_right_rounded, size: 14, color: Colors.white24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> values;
  final double targetLow, targetHigh;
  const _ChartPainter({required this.values, required this.targetLow, required this.targetHigh});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    const minV = 40.0, maxV = 300.0;
    double toY(double v) => size.height - ((v - minV) / (maxV - minV)) * size.height;
    double toX(int i) => (i / (values.length - 1)) * size.width;

    final lowY = toY(targetLow);
    final highY = toY(targetHigh);

    // Grid lines + labels
    for (final v in [50.0, 100.0, 150.0, 200.0, 250.0]) {
      final y = toY(v);
      if (y < 0 || y > size.height) continue;
      canvas.drawLine(Offset(0, y), Offset(size.width, y),
          Paint()..color = Colors.white.withOpacity(0.06)..strokeWidth = 0.5);
      final tp = TextPainter(
        text: TextSpan(text: v.toInt().toString(), style: const TextStyle(color: Colors.white24, fontSize: 9)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(2, y - tp.height - 2));
    }

    // Target band
    canvas.drawRect(Rect.fromLTRB(0, highY, size.width, lowY),
        Paint()..color = AppColors.accent.withOpacity(0.07));
    final dash = Paint()..color = AppColors.accent.withOpacity(0.3)..strokeWidth = 0.5;
    for (final y in [highY, lowY]) {
      double x = 0;
      while (x < size.width) { canvas.drawLine(Offset(x, y), Offset(x + 4, y), dash); x += 8; }
    }

    // Colored segments
    for (int i = 1; i < values.length; i++) {
      final mid = (values[i - 1] + values[i]) / 2;
      final inRange = mid >= targetLow && mid <= targetHigh;
      canvas.drawLine(
        Offset(toX(i - 1), toY(values[i - 1])),
        Offset(toX(i), toY(values[i])),
        Paint()
          ..color = inRange ? AppColors.accent : AppColors.forGlucose(mid)
          ..strokeWidth = 2.5..strokeCap = StrokeCap.round,
      );
    }

    // End dot
    final lx = toX(values.length - 1);
    final ly = toY(values.last);
    canvas.drawCircle(Offset(lx, ly), 9, Paint()..color = AppColors.accent.withOpacity(0.2));
    canvas.drawCircle(Offset(lx, ly), 5, Paint()..color = AppColors.accent);
  }

  @override
  bool shouldRepaint(_ChartPainter old) => old.values != values;
}

// ── Page 2: Stats ─────────────────────────────────────────────

class _StatsPage extends StatelessWidget {
  final int tirPct, lowPct, highPct;
  final double avg, targetLow, targetHigh;
  final GlucoseUnit unit;

  const _StatsPage({
    required this.tirPct,
    required this.lowPct,
    required this.highPct,
    required this.avg,
    required this.unit,
    required this.targetLow,
    required this.targetHigh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenHorizontal),
      child: Column(
        children: [
          // Stats row
          Row(
            children: [
              Expanded(child: _StatCard(label: 'Time in range', value: '$tirPct%', sub: '${GlucoseConverter.format(targetLow, unit)}–${GlucoseConverter.format(targetHigh, unit)} ${unit.label}', valueColor: AppColors.accent)),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(label: 'Average', value: avg > 0 ? GlucoseConverter.format(avg, unit) : '--', sub: unit.label, valueColor: Colors.white)),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(label: 'Above range', value: '$highPct%', sub: '> ${GlucoseConverter.format(targetHigh, unit)}', valueColor: AppColors.glucoseHigh)),
            ],
          ),
          const SizedBox(height: 12),

          // Distribution
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimens.xxl),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Glucose distribution', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: -0.3)),
                  const SizedBox(height: 20),

                  // Big donut-style display
                  Center(
                    child: SizedBox(
                      width: 140,
                      height: 140,
                      child: CustomPaint(
                        painter: _DonutPainter(tirPct: tirPct, lowPct: lowPct, highPct: highPct),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('$tirPct%', style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.accent, letterSpacing: -1, height: 1)),
                              const Text('in range', style: TextStyle(fontSize: 10, color: Colors.white38)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Legend row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LegendDot(color: AppColors.glucoseLow, label: 'Low', value: '$lowPct%'),
                      const SizedBox(width: 24),
                      _LegendDot(color: AppColors.accent, label: 'In range', value: '$tirPct%'),
                      const SizedBox(width: 24),
                      _LegendDot(color: AppColors.glucoseHigh, label: 'High', value: '$highPct%'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Stacked bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                    child: Row(
                      children: [
                        if (lowPct > 0) Expanded(flex: lowPct.clamp(1, 100), child: Container(height: 8, color: AppColors.glucoseLow)),
                        if (tirPct > 0) Expanded(flex: tirPct.clamp(1, 100), child: Container(height: 8, color: AppColors.accent)),
                        if (highPct > 0) Expanded(flex: highPct.clamp(1, 100), child: Container(height: 8, color: AppColors.glucoseHigh)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(
            height: 32,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.chevron_left_rounded, size: 14, color: Colors.white24),
                  Text('Swipe for chart', style: TextStyle(fontSize: 11, color: Colors.white24)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final int tirPct, lowPct, highPct;
  const _DonutPainter({required this.tirPct, required this.lowPct, required this.highPct});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 10;
    const stroke = 14.0;
    const start = -1.5708; // -90 degrees

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    // Background
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = Colors.white.withOpacity(0.06)..style = PaintingStyle.stroke..strokeWidth = stroke);

    double angle = start;
    void drawArc(Color color, int pct) {
      if (pct <= 0) return;
      final sweep = (pct / 100) * 3.14159 * 2;
      paint.color = color;
      canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), angle, sweep, false, paint);
      angle += sweep;
    }

    drawArc(AppColors.glucoseLow, lowPct);
    drawArc(AppColors.accent, tirPct);
    drawArc(AppColors.glucoseHigh, highPct);
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.tirPct != tirPct;
}

class _StatCard extends StatelessWidget {
  final String label, value, sub;
  final Color valueColor;
  const _StatCard({required this.label, required this.value, required this.sub, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38, height: 1.3)),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w700, color: valueColor, letterSpacing: -0.8, height: 1)),
          const SizedBox(height: 3),
          Text(sub, style: const TextStyle(fontSize: 9, color: Colors.white24)),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label, value;
  const _LegendDot({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38)),
          ],
        ),
      ],
    );
  }
}
