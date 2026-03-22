import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/constants.dart';
import '../../../shared/widgets/avatar_widget.dart';

class OnboardingState {
  final int currentStep;
  final String name;
  final DateTime? dateOfBirth;
  final GlucoseUnit glucoseUnit;
  final TherapyMode therapyMode;
  final double targetLowMgdl;
  final double targetHighMgdl;
  final String avatarShape;
  final bool isEditMode; // true when launched from Settings

  const OnboardingState({
    this.currentStep = 0,
    this.name = '',
    this.dateOfBirth,
    this.glucoseUnit = GlucoseUnit.mgdl,
    this.therapyMode = TherapyMode.type2,
    this.targetLowMgdl = AppConstants.defaultTargetLow,
    this.targetHighMgdl = AppConstants.defaultTargetHigh,
    this.avatarShape = '',
    this.isEditMode = false,
  });

  OnboardingState copyWith({
    int? currentStep,
    String? name,
    DateTime? dateOfBirth,
    GlucoseUnit? glucoseUnit,
    TherapyMode? therapyMode,
    double? targetLowMgdl,
    double? targetHighMgdl,
    String? avatarShape,
    bool? isEditMode,
  }) =>
      OnboardingState(
        currentStep: currentStep ?? this.currentStep,
        name: name ?? this.name,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        glucoseUnit: glucoseUnit ?? this.glucoseUnit,
        therapyMode: therapyMode ?? this.therapyMode,
        targetLowMgdl: targetLowMgdl ?? this.targetLowMgdl,
        targetHighMgdl: targetHighMgdl ?? this.targetHighMgdl,
        avatarShape: avatarShape ?? this.avatarShape,
        isEditMode: isEditMode ?? this.isEditMode,
      );

  bool get canProceedFromStep0 => name.trim().length >= 2;
}

class OnboardingFlowNotifier extends StateNotifier<OnboardingState> {
  OnboardingFlowNotifier()
      : super(OnboardingState(avatarShape: randomAvatarShape()));

  void setName(String v) => state = state.copyWith(name: v);
  void setDateOfBirth(DateTime v) => state = state.copyWith(dateOfBirth: v);
  void setGlucoseUnit(GlucoseUnit v) => state = state.copyWith(glucoseUnit: v);
  void setTherapyMode(TherapyMode v) => state = state.copyWith(therapyMode: v);
  void setTargetLow(double v) => state = state.copyWith(targetLowMgdl: v);
  void setTargetHigh(double v) => state = state.copyWith(targetHighMgdl: v);

  void nextStep() =>
      state = state.copyWith(currentStep: state.currentStep + 1);

  void prevStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  /// Pre-fills the flow from an existing UserProfile and jumps to
  /// step 1 (Profile page), skipping the Welcome page entirely.
  void startEditMode({
    required String name,
    required DateTime? dateOfBirth,
    required GlucoseUnit glucoseUnit,
    required TherapyMode therapyMode,
    required double targetLowMgdl,
    required double targetHighMgdl,
    required String avatarShape,
  }) {
    state = OnboardingState(
      currentStep: 1,
      name: name,
      dateOfBirth: dateOfBirth,
      glucoseUnit: glucoseUnit,
      therapyMode: therapyMode,
      targetLowMgdl: targetLowMgdl,
      targetHighMgdl: targetHighMgdl,
      avatarShape: avatarShape,
      isEditMode: true,
    );
  }

  /// Picks a fresh random shape.
  void rerollAvatar() =>
      state = state.copyWith(avatarShape: randomAvatarShape());
}

final onboardingFlowProvider =
    StateNotifierProvider<OnboardingFlowNotifier, OnboardingState>(
  (_) => OnboardingFlowNotifier(),
);
