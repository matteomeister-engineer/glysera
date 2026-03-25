import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';
import '../../../providers.dart';
import '../../../data/models/glucose_reading.dart';
import '../../../shared/widgets/avatar_widget.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundSurface,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.screenHorizontal, 16,
                AppDimens.screenHorizontal, 0,
              ),
              child: Text(
                'Settings',
                style: GoogleFonts.montserrat(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.8,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.screenHorizontal, 0,
                  AppDimens.screenHorizontal, 0,
                ),
                children: [

                  // ── Profile ───────────────────────────
                  _SectionLabel('Profile'),
                  _SettingsGroup(children: [
                    _ProfileRow(profile: profile),
                    const _Divider(),
                    _NavRow(
                      icon: Icons.medical_services_rounded,
                      iconColor: AppColors.purpleCard,
                      label: 'Therapy mode',
                      value: profile.therapyMode.label,
                      onTap: () => _showTherapyPicker(context, ref),
                    ),
                    const _Divider(),
                    _NavRow(
                      icon: Icons.cake_rounded,
                      iconColor: const Color(0xFFFF8C42),
                      label: 'Date of birth',
                      value: profile.dateOfBirth != null
                          ? DateFormat('d MMM yyyy').format(profile.dateOfBirth!)
                          : 'Not set',
                      onTap: () => _showDatePicker(context, ref, profile),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // ── Glucose ───────────────────────────
                  _SectionLabel('Glucose'),
                  _SettingsGroup(children: [
                    _ToggleRow(
                      icon: Icons.straighten_rounded,
                      iconColor: AppColors.accent,
                      label: 'Unit',
                      trailing: _UnitToggle(
                        unit: profile.glucoseUnit,
                        onChanged: (u) => ref.read(userProfileProvider.notifier).updateGlucoseUnit(u),
                      ),
                    ),
                    const _Divider(),
                    _InlineRangeSlider(
                      lowMgdl: profile.targetLowMgdl,
                      highMgdl: profile.targetHighMgdl,
                      unit: profile.glucoseUnit,
                      onChanged: (low, high) => ref
                          .read(userProfileProvider.notifier)
                          .updateTargetRange(low, high),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // ── Alerts ────────────────────────────
                  _SectionLabel('Alerts'),
                  _SettingsGroup(children: [
                    _AlertRow(
                      icon: Icons.arrow_downward_rounded,
                      iconColor: AppColors.glucoseUrgentLow,
                      label: 'Urgent low',
                      sublabel: '< ${GlucoseConverter.format(AppConstants.urgentLowThreshold, profile.glucoseUnit)} ${profile.glucoseUnit.label}',
                      value: profile.alertUrgentLow,
                      locked: true,
                      onChanged: (_) {},
                    ),
                    const _Divider(),
                    _AlertRow(
                      icon: Icons.arrow_downward_rounded,
                      iconColor: AppColors.glucoseLow,
                      label: 'Low alert',
                      sublabel: '< ${GlucoseConverter.format(profile.targetLowMgdl, profile.glucoseUnit)} ${profile.glucoseUnit.label}',
                      value: profile.alertLow,
                      onChanged: (v) => ref.read(userProfileProvider.notifier).updateAlerts(low: v),
                    ),
                    const _Divider(),
                    _AlertRow(
                      icon: Icons.arrow_upward_rounded,
                      iconColor: AppColors.glucoseHigh,
                      label: 'High alert',
                      sublabel: '> ${GlucoseConverter.format(profile.targetHighMgdl, profile.glucoseUnit)} ${profile.glucoseUnit.label}',
                      value: profile.alertHigh,
                      onChanged: (v) => ref.read(userProfileProvider.notifier).updateAlerts(high: v),
                    ),
                    const _Divider(),
                    _AlertRow(
                      icon: Icons.arrow_upward_rounded,
                      iconColor: AppColors.glucoseUrgentHigh,
                      label: 'Urgent high',
                      sublabel: '> ${GlucoseConverter.format(AppConstants.urgentHighThreshold, profile.glucoseUnit)} ${profile.glucoseUnit.label}',
                      value: profile.alertUrgentHigh,
                      locked: true,
                      onChanged: (_) {},
                    ),
                  ]),

                  const SizedBox(height: 8),

                  // ISO note — constrained width
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.lock_rounded, size: 10, color: AppColors.textTertiary),
                      SizedBox(width: 5),
                      Text(
                        'Urgent alerts are mandatory per ISO 14971.',
                        style: TextStyle(fontSize: 10, color: AppColors.textTertiary, height: 1.3),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Notifications ─────────────────────
                  _SectionLabel('Notifications'),
                  _SettingsGroup(children: [
                    _SwitchRow(
                      icon: Icons.notifications_rounded,
                      iconColor: AppColors.purpleCard,
                      label: 'Glucose alerts',
                      sublabel: 'Push notifications for threshold events',
                      initialValue: true,
                    ),
                    const _Divider(),
                    _SwitchRow(
                      icon: Icons.auto_awesome_rounded,
                      iconColor: AppColors.accent,
                      label: 'AI predictions',
                      sublabel: 'Predictive warnings before threshold',
                      initialValue: true,
                    ),
                    const _Divider(),
                    _SwitchRow(
                      icon: Icons.schedule_rounded,
                      iconColor: const Color(0xFF85B7EB),
                      label: 'Reminders',
                      sublabel: 'Daily check-in and meal log reminders',
                      initialValue: false,
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // ── About ─────────────────────────────
                  _SectionLabel('About & Legal'),
                  _SettingsGroup(children: [
                    _InfoRow('App', 'Glysera'),
                    const _Divider(),
                    _InfoRow('Version', '1.0.0-MVP'),
                    const _Divider(),
                    _InfoRow('Software class', 'IEC 62304 — Class B'),
                    const _Divider(),
                    _InfoRow('Risk standard', 'ISO 14971:2019'),
                    const _Divider(),
                    _InfoRow('Usability', 'IEC 62366-1'),
                    const _Divider(),
                    _InfoRow('CGM standard', 'ISO 15197'),
                    const _Divider(),
                    _NavRow(
                      icon: Icons.description_outlined,
                      iconColor: AppColors.textTertiary,
                      label: 'Privacy policy',
                      onTap: () {},
                    ),
                    const _Divider(),
                    _NavRow(
                      icon: Icons.gavel_rounded,
                      iconColor: AppColors.textTertiary,
                      label: 'Terms of use',
                      onTap: () {},
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // ── Danger ────────────────────────────
                  _SettingsGroup(children: [
                    _DangerRow(
                      label: 'Reset all data',
                      onTap: () => _showResetDialog(context),
                    ),
                  ]),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom sheets — useRootNavigator: true floats above nav bar ──

  void _showTherapyPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _PickerSheet(
        title: 'Therapy mode',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: TherapyMode.values.map((m) {
            final selected = ref.read(userProfileProvider).therapyMode == m;
            return GestureDetector(
              onTap: () {
                ref.read(userProfileProvider.notifier).updateTherapyMode(m);
                Navigator.of(sheetContext).pop();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: selected ? AppColors.accent.withOpacity(0.1) : Colors.transparent,
                  border: Border(bottom: BorderSide(color: AppColors.cardBorder, width: 0.5)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.label, style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          Text(m.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    if (selected)
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded, size: 16, color: Color(0xFF084432)),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context, WidgetRef ref, UserProfile profile) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: profile.dateOfBirth ?? DateTime(now.year - 30),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 1),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.textPrimary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    // DateOfBirth update will be wired in future sprint
  }

  void _showTargetRangePicker(BuildContext context, WidgetRef ref, UserProfile profile) {
    double low = profile.targetLowMgdl;
    double high = profile.targetHighMgdl;
    final isMmol = profile.glucoseUnit == GlucoseUnit.mmoll;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,   // ← floats above the nav bar
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (ctx, setModal) => _PickerSheet(
          title: 'Target range',
          child: Padding(
            padding: EdgeInsets.only(
              left: 20, right: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SliderRow(
                  label: 'Low limit',
                  value: isMmol ? GlucoseConverter.toMmol(low) : low,
                  min: isMmol ? 3.3 : 60,
                  max: isMmol ? 5.6 : 100,
                  unit: profile.glucoseUnit.label,
                  color: AppColors.glucoseLow,
                  onChanged: (v) => setModal(() => low = isMmol ? GlucoseConverter.toMgdl(v) : v),
                ),
                const SizedBox(height: 16),
                _SliderRow(
                  label: 'High limit',
                  value: isMmol ? GlucoseConverter.toMmol(high) : high,
                  min: isMmol ? 7.8 : 140,
                  max: isMmol ? 16.7 : 300,
                  unit: profile.glucoseUnit.label,
                  color: AppColors.glucoseHigh,
                  onChanged: (v) => setModal(() => high = isMmol ? GlucoseConverter.toMgdl(v) : v),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: AppDimens.buttonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(userProfileProvider.notifier).updateTargetRange(low, high);
                      Navigator.of(sheetContext).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusFull)),
                    ),
                    child: Text('Save', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.backgroundPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusXl)),
        title: Text('Reset all data', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        content: const Text('This will clear all glucose readings, logbook entries and settings. This cannot be undone.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Reset', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: AppColors.glucoseUrgentLow)),
          ),
        ],
      ),
    );
  }
}

// ── Shared row components ─────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textTertiary, letterSpacing: 0.8),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 0.5, thickness: 0.5, indent: 52, color: AppColors.divider);
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBox({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    // Accent (lime) icons were invisible on white — use solid lime bg + dark green icon
    final isAccent = color == AppColors.accent;
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: isAccent ? AppColors.accent : color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      ),
      child: Icon(icon, size: 16, color: isAccent ? const Color(0xFF084432) : color),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final UserProfile profile;
  const _ProfileRow({required this.profile});

  @override
  Widget build(BuildContext context) {
    final name = profile.name.isNotEmpty ? profile.name : 'Set your name';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          AvatarWidget(
            assetPath: profile.avatarShape.isNotEmpty
                ? profile.avatarShape
                : kAvatarShapes[0],
            size: 44,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(profile.therapyMode.label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String label;
  final String? value;
  final VoidCallback onTap;
  const _NavRow({this.icon, this.iconColor, required this.label, this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (icon != null) ...[
              _IconBox(icon: icon!, color: iconColor ?? AppColors.textTertiary),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary)),
            ),
            if (value != null) ...[
              const SizedBox(width: 8),
              Text(
                value!,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget trailing;
  const _ToggleRow({required this.icon, required this.iconColor, required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _IconBox(icon: icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary))),
          trailing,
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label, sublabel;
  final bool value, locked;
  final ValueChanged<bool> onChanged;
  const _AlertRow({required this.icon, required this.iconColor, required this.label, required this.sublabel, required this.value, required this.onChanged, this.locked = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _IconBox(icon: icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(label, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary)),
                  if (locked) ...[const SizedBox(width: 6), const Icon(Icons.lock_rounded, size: 11, color: AppColors.textTertiary)],
                ]),
                const SizedBox(height: 2),
                Text(sublabel, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeColor: locked ? AppColors.textTertiary : AppColors.textPrimary,
            thumbColor: Colors.white,
            onChanged: locked ? null : onChanged,
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String label, sublabel;
  final bool initialValue;
  const _SwitchRow({required this.icon, required this.iconColor, required this.label, required this.sublabel, required this.initialValue});

  @override
  State<_SwitchRow> createState() => _SwitchRowState();
}

class _SwitchRowState extends State<_SwitchRow> {
  late bool _val;
  @override
  void initState() { super.initState(); _val = widget.initialValue; }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _IconBox(icon: widget.icon, color: widget.iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.label, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(widget.sublabel, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              ],
            ),
          ),
          CupertinoSwitch(
            value: _val,
            activeColor: AppColors.textPrimary,
            thumbColor: Colors.white,
            onChanged: (v) => setState(() => _val = v),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary))),
          const SizedBox(width: 8),
          Flexible(
            child: Text(value, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary), textAlign: TextAlign.right, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _DangerRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DangerRow({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Center(
          child: Text(label, style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.glucoseUrgentLow)),
        ),
      ),
    );
  }
}

class _UnitToggle extends StatelessWidget {
  final GlucoseUnit unit;
  final ValueChanged<GlucoseUnit> onChanged;
  const _UnitToggle({required this.unit, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: GlucoseUnit.values.map((u) {
          final sel = u == unit;
          return GestureDetector(
            onTap: () => onChanged(u),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? AppColors.textPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              ),
              child: Text(u.label, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w700, color: sel ? AppColors.accent : AppColors.textSecondary)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Inline dual-handle range slider ──────────────────────────

class _InlineRangeSlider extends StatefulWidget {
  final double lowMgdl;
  final double highMgdl;
  final GlucoseUnit unit;
  final void Function(double low, double high) onChanged;

  const _InlineRangeSlider({
    required this.lowMgdl,
    required this.highMgdl,
    required this.unit,
    required this.onChanged,
  });

  @override
  State<_InlineRangeSlider> createState() => _InlineRangeSliderState();
}

class _InlineRangeSliderState extends State<_InlineRangeSlider> {
  late double _low;
  late double _high;

  // Fixed bounds in mg/dL
  static const double _minMgdl = 60.0;
  static const double _maxMgdl = 300.0;

  @override
  void initState() {
    super.initState();
    _low = widget.lowMgdl;
    _high = widget.highMgdl;
  }

  @override
  void didUpdateWidget(_InlineRangeSlider old) {
    super.didUpdateWidget(old);
    if (old.lowMgdl != widget.lowMgdl) _low = widget.lowMgdl;
    if (old.highMgdl != widget.highMgdl) _high = widget.highMgdl;
  }

  String _fmt(double mgdl) => GlucoseConverter.format(mgdl, widget.unit);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              _IconBox(icon: Icons.track_changes_rounded, color: AppColors.accent),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Target range', style: TextStyle(fontSize: 15, color: AppColors.textPrimary)),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Value labels
          Row(
            children: [
              // Low label
              _RangeLabel(
                title: 'Low',
                value: _fmt(_low),
                unit: widget.unit.label,
                color: AppColors.glucoseLow,
              ),
              const Spacer(),
              // Range between
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                ),
                child: Text(
                  '${_fmt(_low)} – ${_fmt(_high)}',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Spacer(),
              // High label
              _RangeLabel(
                title: 'High',
                value: _fmt(_high),
                unit: widget.unit.label,
                color: AppColors.glucoseHigh,
                alignRight: true,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Custom dual-handle track
          _DualTrack(
            low: _low,
            high: _high,
            min: _minMgdl,
            max: _maxMgdl,
            onLowChanged: (v) {
              setState(() => _low = v.clamp(_minMgdl, _high - 10));
              widget.onChanged(_low, _high);
            },
            onHighChanged: (v) {
              setState(() => _high = v.clamp(_low + 10, _maxMgdl));
              widget.onChanged(_low, _high);
            },
          ),

          const SizedBox(height: 6),

          // Min/max labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                GlucoseConverter.format(_minMgdl, widget.unit),
                style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
              ),
              Text(
                GlucoseConverter.format(_maxMgdl, widget.unit),
                style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RangeLabel extends StatelessWidget {
  final String title, value, unit;
  final Color color;
  final bool alignRight;

  const _RangeLabel({
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
        Text(
          value,
          style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.5, height: 1),
        ),
        Text(unit, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
      ],
    );
  }
}

class _DualTrack extends StatelessWidget {
  final double low, high, min, max;
  final ValueChanged<double> onLowChanged;
  final ValueChanged<double> onHighChanged;

  const _DualTrack({
    required this.low,
    required this.high,
    required this.min,
    required this.max,
    required this.onLowChanged,
    required this.onHighChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final lowFrac = (low - min) / (max - min);
        final highFrac = (high - min) / (max - min);
        const handleW = 28.0;
        const trackH = 6.0;
        const totalH = 44.0;

        return SizedBox(
          height: totalH,
          width: width,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Full track background
              Positioned(
                left: 0, right: 0,
                child: Container(
                  height: trackH,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSurface,
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  ),
                ),
              ),

              // Active range fill (lime)
              Positioned(
                left: lowFrac * (width - handleW) + handleW / 2,
                width: (highFrac - lowFrac) * (width - handleW),
                child: Container(
                  height: trackH,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  ),
                ),
              ),

              // Low handle
              Positioned(
                left: lowFrac * (width - handleW),
                child: GestureDetector(
                  onHorizontalDragUpdate: (d) {
                    final delta = d.delta.dx / (width - handleW);
                    onLowChanged(low + delta * (max - min));
                  },
                  child: _Handle(color: AppColors.glucoseLow),
                ),
              ),

              // High handle
              Positioned(
                left: highFrac * (width - handleW),
                child: GestureDetector(
                  onHorizontalDragUpdate: (d) {
                    final delta = d.delta.dx / (width - handleW);
                    onHighChanged(high + delta * (max - min));
                  },
                  child: _Handle(color: AppColors.glucoseHigh),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Handle extends StatelessWidget {
  final Color color;
  const _Handle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

// ── Bottom sheet wrapper ──────────────────────────────────────

class _PickerSheet extends StatelessWidget {
  final String title;
  final Widget child;
  const _PickerSheet({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: AppColors.cardBorder, borderRadius: BorderRadius.circular(99)),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(title, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32, height: 32,
                    decoration: const BoxDecoration(color: AppColors.backgroundSurface, shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          child,
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

// ── Slider row ────────────────────────────────────────────────

class _SliderRow extends StatefulWidget {
  final String label, unit;
  final double value, min, max;
  final Color color;
  final ValueChanged<double> onChanged;
  const _SliderRow({required this.label, required this.value, required this.min, required this.max, required this.unit, required this.color, required this.onChanged});

  @override
  State<_SliderRow> createState() => _SliderRowState();
}

class _SliderRowState extends State<_SliderRow> {
  late double _val;
  @override
  void initState() { super.initState(); _val = widget.value.clamp(widget.min, widget.max); }

  @override
  Widget build(BuildContext context) {
    final isMmol = widget.unit == 'mmol/L';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            const Spacer(),
            Text(
              '${_val.toStringAsFixed(isMmol ? 1 : 0)} ${widget.unit}',
              style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700, color: widget.color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: widget.color,
            inactiveTrackColor: AppColors.backgroundSurface,
            thumbColor: widget.color,
            overlayColor: widget.color.withOpacity(0.1),
            trackHeight: 4,
          ),
          child: Slider(
            value: _val,
            min: widget.min,
            max: widget.max,
            divisions: isMmol ? ((widget.max - widget.min) * 10).round() : (widget.max - widget.min).round(),
            onChanged: (v) { setState(() => _val = v); widget.onChanged(v); },
          ),
        ),
      ],
    );
  }
}
