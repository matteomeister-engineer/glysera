import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../providers.dart';
import '../providers/onboarding_provider.dart';
import '../pages/welcome_page.dart';
import '../pages/profile_page.dart';
import '../pages/therapy_mode_page.dart';
import '../pages/target_range_page.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // If edit mode was set before navigation, jump the PageView to step 1.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final step = ref.read(onboardingFlowProvider).currentStep;
      if (step > 0) {
        _pageController.jumpToPage(step);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    final state = ref.read(onboardingFlowProvider);
    if (state.currentStep < 3) {
      ref.read(onboardingFlowProvider.notifier).nextStep();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _back() {
    final state = ref.read(onboardingFlowProvider);
    // In edit mode, step 1 is the first real page — back goes to dashboard.
    if (state.isEditMode && state.currentStep <= 1) {
      // In edit mode we got here via Navigator.push, so pop back.
      Navigator.of(context).pop();
      return;
    }
    ref.read(onboardingFlowProvider.notifier).prevStep();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    final ob = ref.read(onboardingFlowProvider);
    final profile = ref.read(userProfileProvider.notifier);
    await profile.updateName(ob.name);
    await profile.updateGlucoseUnit(ob.glucoseUnit);
    await profile.updateTherapyMode(ob.therapyMode);
    await profile.updateTargetRange(ob.targetLowMgdl, ob.targetHighMgdl);
    await profile.updateAvatarShape(ob.avatarShape);
    await ref.read(onboardingCompleteProvider.notifier).complete();
    if (mounted) {
      // If launched via Navigator.push (edit mode), pop back to settings.
      // If launched normally via go_router, navigate to dashboard.
      if (ob.isEditMode) {
        Navigator.of(context).pop();
      } else {
        context.go(AppRoutes.dashboard);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = ref.watch(onboardingFlowProvider).isEditMode;

    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Step 0 — Welcome (hidden/skipped in edit mode)
        WelcomePage(onNext: _next),
        // Step 1 — Profile
        ProfilePage(onNext: _next, onBack: _back),
        // Step 2 — Therapy mode
        TherapyModePage(onNext: _next, onBack: _back),
        // Step 3 — Target range
        TargetRangePage(
          onNext: _next,
          onBack: _back,
          // In edit mode, the final CTA says "Save changes" instead of "Start tracking"
          ctaLabel: isEditMode ? 'Save changes' : null,
        ),
      ],
    );
  }
}
