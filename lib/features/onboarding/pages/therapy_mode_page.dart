import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_widgets.dart';

class TherapyModePage extends ConsumerWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const TherapyModePage({super.key, required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingFlowProvider);
    final notifier = ref.read(onboardingFlowProvider.notifier);

    return OnboardingShell(
      showBack: true,
      onBack: onBack,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            const OnboardingHeading(
              title: 'How do you\nmanage insulin?',
              subtitle: 'We tailor your experience and calculations to your therapy.',
            ),

            const SizedBox(height: 20),

            // Therapy chips — expand to fill space evenly
            ...TherapyMode.values.map(
              (mode) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TherapyChip(
                  label: mode.label,
                  description: mode.description,
                  selected: state.therapyMode == mode,
                  onTap: () => notifier.setTherapyMode(mode),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Info note
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This setting affects your alert defaults. You can change it anytime in Settings.',
                      style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.45), height: 1.5),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            const OnboardingDots(current: 2, total: 4),
            const SizedBox(height: 20),
            OnboardingCta(label: 'Set my targets', onTap: onNext),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
