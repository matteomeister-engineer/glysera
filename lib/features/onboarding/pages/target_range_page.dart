import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_widgets.dart';

class TargetRangePage extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final String? ctaLabel;

  const TargetRangePage({super.key, required this.onNext, required this.onBack, this.ctaLabel});

  @override
  ConsumerState<TargetRangePage> createState() => _TargetRangePageState();
}

class _TargetRangePageState extends ConsumerState<TargetRangePage> {
  bool _alertLow = true;
  bool _alertHigh = true;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingFlowProvider);
    final notifier = ref.read(onboardingFlowProvider.notifier);
    final isMmol = state.glucoseUnit == GlucoseUnit.mmoll;

    return OnboardingShell(
      showBack: true,
      onBack: widget.onBack,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            const OnboardingHeading(
              title: 'Set your\ntarget range',
              subtitle: "We'll alert you when glucose goes outside these limits.",
            ),

            const SizedBox(height: 10),

            // Target range card
            LimeCard(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Low limit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0x88000000))),
                  const SizedBox(height: 6),
                  LimeStepper(
                    value: isMmol ? GlucoseConverter.toMmol(state.targetLowMgdl).round() : state.targetLowMgdl.round(),
                    min: isMmol ? 33 : 60,
                    max: isMmol ? 55 : 100,
                    unit: state.glucoseUnit.label,
                    onChanged: (v) => notifier.setTargetLow(isMmol ? GlucoseConverter.toMgdl(v.toDouble()) : v.toDouble()),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Color(0x22000000), thickness: 1),
                  const SizedBox(height: 10),
                  const Text('High limit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0x88000000))),
                  const SizedBox(height: 6),
                  LimeStepper(
                    value: isMmol ? GlucoseConverter.toMmol(state.targetHighMgdl).round() : state.targetHighMgdl.round(),
                    min: isMmol ? 72 : 130,
                    max: isMmol ? 167 : 300,
                    unit: state.glucoseUnit.label,
                    onChanged: (v) => notifier.setTargetHigh(isMmol ? GlucoseConverter.toMgdl(v.toDouble()) : v.toDouble()),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Alert toggles
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(AppDimens.radiusXl + 4),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.notifications_rounded, color: AppColors.accent, size: 16),
                    const SizedBox(width: 8),
                    Text('Alert settings', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9))),
                  ]),
                  const SizedBox(height: 8),
                  _AlertRow(label: 'Urgent low', sublabel: '< ${isMmol ? '3.0' : '54'} ${state.glucoseUnit.label}', value: true, locked: true, onChanged: (_) {}),
                  _AlertRow(label: 'Low alert', sublabel: '< ${isMmol ? '3.9' : '70'} ${state.glucoseUnit.label}', value: _alertLow, onChanged: (v) => setState(() => _alertLow = v)),
                  _AlertRow(label: 'High alert', sublabel: '> ${isMmol ? '10.0' : '180'} ${state.glucoseUnit.label}', value: _alertHigh, onChanged: (v) => setState(() => _alertHigh = v)),
                  _AlertRow(label: 'Urgent high', sublabel: '> ${isMmol ? '13.9' : '250'} ${state.glucoseUnit.label}', value: true, locked: true, onChanged: (_) {}, isLast: true),
                ],
              ),
            ),

            const Spacer(),

            const OnboardingDots(current: 3, total: 4),
            const SizedBox(height: 14),
            OnboardingCta(label: widget.ctaLabel ?? 'Start tracking', onTap: widget.onNext),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool value;
  final bool locked;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const _AlertRow({required this.label, required this.sublabel, required this.value, required this.onChanged, this.locked = false, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                    if (locked) ...[const SizedBox(width: 6), const Icon(Icons.lock_rounded, size: 11, color: AppColors.accent)],
                  ]),
                  const SizedBox(height: 1),
                  Text(sublabel, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.35))),
                ],
              )),
              BigToggle(value: value, onChanged: locked ? (_) {} : onChanged),
            ],
          ),
        ),
        if (!isLast) Divider(color: Colors.white.withOpacity(0.08), thickness: 0.5),
      ],
    );
  }
}
