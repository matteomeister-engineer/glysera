import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_widgets.dart';
import '../../../shared/widgets/avatar_widget.dart';

class ProfilePage extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const ProfilePage({super.key, required this.onNext, required this.onBack});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 30),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 1),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            onPrimary: AppColors.black,
            surface: Color(0xFF2A2A2A),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) ref.read(onboardingFlowProvider.notifier).setDateOfBirth(picked);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingFlowProvider);
    final notifier = ref.read(onboardingFlowProvider.notifier);

    return OnboardingShell(
      showBack: true,
      onBack: widget.onBack,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            const OnboardingHeading(
              title: 'Tell us\nabout you',
              subtitle: 'This helps us personalise your experience.',
            ),

            const SizedBox(height: 20),

            // Avatar
            Center(child: AvatarWidget(assetPath: state.avatarShape, size: 68)),

            const SizedBox(height: 18),

            // Name input
            LimeCard(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your first name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0x88000000))),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.black, letterSpacing: -0.5),
                    decoration: InputDecoration(
                      hintText: 'e.g. Sarah',
                      hintStyle: TextStyle(color: AppColors.black.withOpacity(0.25), fontSize: 20, fontWeight: FontWeight.w700),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.08),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMd), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onChanged: notifier.setName,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Date of birth
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(AppDimens.radiusXl + 4),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: Colors.white54, size: 18),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Date of birth', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4))),
                      Text(
                        state.dateOfBirth != null ? DateFormat('MMMM d, yyyy').format(state.dateOfBirth!) : 'Select date',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ]),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.3)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Unit selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(AppDimens.radiusXl + 4),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Text('Glucose unit', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w500)),
                  const Spacer(),
                  UnitChip(label: 'mg/dL', selected: state.glucoseUnit == GlucoseUnit.mgdl, onTap: () => notifier.setGlucoseUnit(GlucoseUnit.mgdl)),
                  const SizedBox(width: 8),
                  UnitChip(label: 'mmol/L', selected: state.glucoseUnit == GlucoseUnit.mmoll, onTap: () => notifier.setGlucoseUnit(GlucoseUnit.mmoll)),
                ],
              ),
            ),

            const Spacer(),

            const OnboardingDots(current: 1, total: 4),
            const SizedBox(height: 20),
            OnboardingCta(label: 'Continue', enabled: state.canProceedFromStep0, onTap: widget.onNext),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
