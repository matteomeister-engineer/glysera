import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';
import '../../../providers.dart';
import '../../../data/models/glucose_reading.dart';
import '../../../shared/widgets/animated_reveal_card.dart';

// ── Entry model ───────────────────────────────────────────────

enum _EntryType { glucose, meal, insulin, activity, note }

class _LogEntry {
  final _EntryType type;
  final String title;
  final String subtitle;
  final double? glucoseMgdl;
  final DateTime time;

  _LogEntry({
    required this.type,
    required this.title,
    required this.subtitle,
    this.glucoseMgdl,
    required this.time,
  });

  IconData get icon {
    switch (type) {
      case _EntryType.glucose:  return Icons.water_drop_outlined;
      case _EntryType.meal:     return Icons.restaurant_rounded;
      case _EntryType.insulin:  return Icons.medication_rounded;
      case _EntryType.activity: return Icons.directions_walk_rounded;
      case _EntryType.note:     return Icons.notes_rounded;
    }
  }

  String get typeLabel {
    switch (type) {
      case _EntryType.glucose:  return 'Glucose';
      case _EntryType.meal:     return 'Meal';
      case _EntryType.insulin:  return 'Insulin';
      case _EntryType.activity: return 'Activity';
      case _EntryType.note:     return 'Note';
    }
  }
}

// ── Screen ────────────────────────────────────────────────────

class LogbookScreen extends ConsumerStatefulWidget {
  const LogbookScreen({super.key});

  @override
  ConsumerState<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends ConsumerState<LogbookScreen> {
  late List<_LogEntry> _entries;
  final _pageController = PageController();
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _entries = _buildSampleEntries();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  static List<_LogEntry> _buildSampleEntries() {
    final now = DateTime.now();
    return [
      _LogEntry(type: _EntryType.glucose,  title: 'CGM reading',     subtitle: 'Automatic · stable',    glucoseMgdl: 118, time: now.subtract(const Duration(minutes: 5))),
      _LogEntry(type: _EntryType.meal,     title: 'Lunch',           subtitle: '60g carbs · medium GI',                   time: now.subtract(const Duration(hours: 1, minutes: 15))),
      _LogEntry(type: _EntryType.glucose,  title: 'CGM reading',     subtitle: 'Post-meal · rising',     glucoseMgdl: 162, time: now.subtract(const Duration(hours: 1))),
      _LogEntry(type: _EntryType.insulin,  title: 'Bolus insulin',   subtitle: '4 units rapid-acting',                    time: now.subtract(const Duration(hours: 1, minutes: 20))),
      _LogEntry(type: _EntryType.activity, title: 'Walked to office', subtitle: '25 min · moderate',                      time: now.subtract(const Duration(hours: 2, minutes: 30))),
      _LogEntry(type: _EntryType.glucose,  title: 'CGM reading',     subtitle: 'Pre-meal · in range',    glucoseMgdl: 104, time: now.subtract(const Duration(hours: 2, minutes: 45))),
      _LogEntry(type: _EntryType.meal,     title: 'Breakfast',       subtitle: '45g carbs · low GI',                      time: now.subtract(const Duration(hours: 4))),
      _LogEntry(type: _EntryType.glucose,  title: 'CGM reading',     subtitle: 'Fasting · stable',       glucoseMgdl: 92,  time: now.subtract(const Duration(hours: 5))),
      _LogEntry(type: _EntryType.note,     title: 'Feeling tired',   subtitle: 'Slept 6h · stressful',                    time: now.subtract(const Duration(hours: 6))),
      _LogEntry(type: _EntryType.insulin,  title: 'Basal insulin',   subtitle: '12 units long-acting',                    time: now.subtract(const Duration(hours: 8))),
    ];
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddEntrySheet(
        onAdd: (e) => setState(() => _entries.insert(0, e)),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final unit = profile.glucoseUnit;
    final today = DateTime.now();

    // Group entries
    final todayEntries = _entries.where((e) => _isSameDay(e.time, today)).toList();
    final olderEntries = _entries.where((e) => !_isSameDay(e.time, today)).toList();

    // Pages: Page 1 = Today, Page 2 = History
    return Scaffold(
      backgroundColor: AppColors.backgroundSurface,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: GestureDetector(
          onTap: _showAddSheet,
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withOpacity(0.55),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.18),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add_rounded, color: AppColors.accent, size: 28),
              ),
            ),
          ),
        ),
      ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Logbook',
                            style: GoogleFonts.montserrat(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.8),
                          ),
                          Text(
                            DateFormat('EEEE, d MMMM').format(today),
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _PageDots(current: _pageIndex, total: 2, dark: true),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Summary strip
                  _SummaryStrip(unit: unit),
                  const SizedBox(height: 14),
                  // Page tabs
                  Row(
                    children: [
                      _TabChip(label: 'Today', selected: _pageIndex == 0, onTap: () { _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); setState(() => _pageIndex = 0); }),
                      const SizedBox(width: 8),
                      _TabChip(label: 'History', selected: _pageIndex == 1, onTap: () { _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); setState(() => _pageIndex = 1); }),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // ── Swipeable entry pages ─────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _pageIndex = i),
                children: [
                  // Page 1 — Today
                  _EntryList(entries: todayEntries, unit: unit, emptyMessage: 'No entries today yet.\nTap + to add one.'),
                  // Page 2 — History
                  _EntryList(entries: olderEntries, unit: unit, emptyMessage: 'No older entries.'),
                ],
              ),
            ),

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
  final bool dark;
  const _PageDots({required this.current, required this.total, this.dark = false});

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
            color: active
                ? AppColors.textPrimary
                : (dark ? AppColors.textTertiary : Colors.white24),
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          ),
        );
      }),
    );
  }
}

// ── Tab chip ──────────────────────────────────────────────────

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.textPrimary : AppColors.backgroundPrimary,
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          border: Border.all(color: selected ? Colors.transparent : AppColors.cardBorder, width: 0.5),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── Summary strip ─────────────────────────────────────────────

class _SummaryStrip extends ConsumerWidget {
  final GlucoseUnit unit;
  const _SummaryStrip({required this.unit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(glucoseStreamProvider);
    final repo = ref.read(glucoseRepositoryProvider);
    final profile = ref.read(userProfileProvider);
    final tir = repo.timeInRange(low: profile.targetLowMgdl, high: profile.targetHighMgdl);
    final avg = repo.average();
    final total = repo.totalReadings;

    return Row(
      children: [
        Expanded(child: _SummaryChip(label: 'Avg today', value: avg > 0 ? GlucoseConverter.format(avg, unit) : '--', sub: unit.label)),
        const SizedBox(width: 8),
        Expanded(child: _SummaryChip(label: 'In range', value: '${(tir * 100).round()}%', sub: 'last 24h', accent: true)),
        const SizedBox(width: 8),
        Expanded(child: _SummaryChip(label: 'Readings', value: total.toString(), sub: 'total')),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label, value, sub;
  final bool accent;
  const _SummaryChip({required this.label, required this.value, required this.sub, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent ? AppColors.textPrimary : AppColors.backgroundPrimary,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: accent ? Colors.transparent : AppColors.cardBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: accent ? Colors.white54 : AppColors.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 3),
          Text(value, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700, color: accent ? AppColors.accent : AppColors.textPrimary, letterSpacing: -0.5, height: 1)),
          Text(sub, style: TextStyle(fontSize: 9, color: accent ? Colors.white38 : AppColors.textTertiary)),
        ],
      ),
    );
  }
}

// ── Entry list ────────────────────────────────────────────────

class _EntryList extends StatelessWidget {
  final List<_LogEntry> entries;
  final GlucoseUnit unit;
  final String emptyMessage;

  const _EntryList({required this.entries, required this.unit, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.textTertiary, height: 1.6),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenHorizontal),
      itemCount: entries.length,
      itemExtent: 83.0,
      itemBuilder: (_, i) => AnimatedRevealCard(
        delay: Duration(milliseconds: i * 50),
        child: _EntryCard(entry: entries[i], index: i, unit: unit),
      ),
    );
  }
}

// ── Entry card ────────────────────────────────────────────────

class _EntryCard extends StatelessWidget {
  final _LogEntry entry;
  final int index;
  final GlucoseUnit unit;
  const _EntryCard({required this.entry, required this.index, required this.unit});

  _CardStyle get _style {
    switch (index % 3) {
      case 0: return _CardStyle.white;
      case 1: return _CardStyle.dark;
      case 2: return _CardStyle.lime;
      default: return _CardStyle.white;
    }
  }

  Color get _bg {
    switch (_style) {
      case _CardStyle.white: return AppColors.backgroundPrimary;
      case _CardStyle.dark:  return AppColors.textPrimary;
      case _CardStyle.lime:  return AppColors.accent;
    }
  }

  Color get _text {
    switch (_style) {
      case _CardStyle.white: return AppColors.textPrimary;
      case _CardStyle.dark:  return Colors.white;
      case _CardStyle.lime:  return AppColors.textPrimary;
    }
  }

  Color get _sub {
    switch (_style) {
      case _CardStyle.white: return AppColors.textSecondary;
      case _CardStyle.dark:  return Colors.white54;
      case _CardStyle.lime:  return AppColors.textPrimary.withOpacity(0.5);
    }
  }

  Color get _iconBg {
    switch (_style) {
      case _CardStyle.white: return AppColors.backgroundSurface;
      case _CardStyle.dark:  return Colors.white.withOpacity(0.1);
      case _CardStyle.lime:  return AppColors.textPrimary.withOpacity(0.1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: _iconBg, borderRadius: BorderRadius.circular(AppDimens.radiusMd)),
              child: Icon(entry.icon, size: 17, color: _text),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.title, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: _text)),
                  const SizedBox(height: 2),
                  Text(entry.subtitle, style: TextStyle(fontSize: 11, color: _sub)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (entry.glucoseMgdl != null) ...[
                  Text(
                    GlucoseConverter.format(entry.glucoseMgdl!, unit),
                    style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w700, color: _text, letterSpacing: -0.8, height: 1),
                  ),
                  Text(unit.label, style: TextStyle(fontSize: 10, color: _sub)),
                ] else ...[
                  Text(
                    DateFormat('HH:mm').format(entry.time),
                    style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: _text),
                  ),
                  Text(_timeAgo(entry.time), style: TextStyle(fontSize: 10, color: _sub)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

enum _CardStyle { white, dark, lime }

// ── Add entry bottom sheet ────────────────────────────────────

class _AddEntrySheet extends StatefulWidget {
  final Function(_LogEntry) onAdd;
  const _AddEntrySheet({required this.onAdd});

  @override
  State<_AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<_AddEntrySheet> {
  _EntryType _type = _EntryType.meal;
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void dispose() { _titleCtrl.dispose(); _noteCtrl.dispose(); super.dispose(); }

  static IconData _icon(_EntryType t) {
    switch (t) {
      case _EntryType.glucose:  return Icons.water_drop_outlined;
      case _EntryType.meal:     return Icons.restaurant_rounded;
      case _EntryType.insulin:  return Icons.medication_rounded;
      case _EntryType.activity: return Icons.directions_walk_rounded;
      case _EntryType.note:     return Icons.notes_rounded;
    }
  }

  static String _label(_EntryType t) {
    switch (t) {
      case _EntryType.glucose:  return 'Glucose';
      case _EntryType.meal:     return 'Meal';
      case _EntryType.insulin:  return 'Insulin';
      case _EntryType.activity: return 'Activity';
      case _EntryType.note:     return 'Note';
    }
  }

  static String _hint(_EntryType t) {
    switch (t) {
      case _EntryType.glucose:  return 'e.g. 118 mg/dL';
      case _EntryType.meal:     return 'e.g. Lunch — 60g carbs';
      case _EntryType.insulin:  return 'e.g. 4 units rapid';
      case _EntryType.activity: return 'e.g. 30 min walk';
      case _EntryType.note:     return 'e.g. Feeling tired today';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: AppColors.backgroundPrimary.withOpacity(0.96),
          padding: EdgeInsets.only(
            left: AppDimens.screenHorizontal,
            right: AppDimens.screenHorizontal,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(color: AppColors.cardBorder, borderRadius: BorderRadius.circular(99)),
                ),
              ),
              const SizedBox(height: 18),
              Text('Add entry', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.5)),
              const SizedBox(height: 18),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _EntryType.values.map((t) {
                    final sel = t == _type;
                    return GestureDetector(
                      onTap: () => setState(() => _type = t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.textPrimary : AppColors.backgroundSurface,
                          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                        ),
                        child: Row(
                          children: [
                            Icon(_icon(t), size: 14, color: sel ? AppColors.accent : AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(_label(t), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(hintText: _hint(_type), filled: true, fillColor: AppColors.backgroundSurface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMd), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _noteCtrl,
                decoration: InputDecoration(hintText: 'Notes (optional)', filled: true, fillColor: AppColors.backgroundSurface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMd), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: AppDimens.buttonHeight,
                child: ElevatedButton(
                  onPressed: () {
                    if (_titleCtrl.text.trim().isEmpty) return;
                    widget.onAdd(_LogEntry(
                      type: _type,
                      title: _titleCtrl.text.trim(),
                      subtitle: _noteCtrl.text.trim().isEmpty ? _label(_type) : _noteCtrl.text.trim(),
                      time: DateTime.now(),
                    ));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusFull)),
                  ),
                  child: Text('Save entry', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
