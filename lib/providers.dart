import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/models/glucose_reading.dart';
import 'data/simulator/glucose_simulator.dart';
import 'data/repositories/glucose_repository.dart';
import 'core/constants/constants.dart';
import 'shared/widgets/avatar_widget.dart'; // ← import catalogue

final glucoseSimulatorProvider = Provider<GlucoseSimulator>((ref) {
  final s = GlucoseSimulator();
  s.start();
  ref.onDispose(s.stop);
  return s;
});

final glucoseStreamProvider = StreamProvider<GlucoseReading>((ref) {
  final sim = ref.watch(glucoseSimulatorProvider);
  final repo = ref.read(glucoseRepositoryProvider);
  return sim.stream.asyncMap((r) async {
    await repo.save(r);
    return r;
  });
});

final latestGlucoseProvider = Provider<GlucoseReading?>(
  (ref) => ref.watch(glucoseStreamProvider).valueOrNull,
);

final glucoseRepositoryProvider = Provider<InMemoryGlucoseRepository>(
  (_) => InMemoryGlucoseRepository(),
);

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>(
  (_) => UserProfileNotifier(),
);

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier()
      : super(UserProfile(
          id: 'default-user',
          name: 'Sarah',
          glucoseUnit: GlucoseUnit.mgdl,
          therapyMode: TherapyMode.pump,
          targetLowMgdl: AppConstants.defaultTargetLow,
          targetHighMgdl: AppConstants.defaultTargetHigh,
          alertUrgentLow: true,
          alertLow: true,
          alertHigh: true,
          alertUrgentHigh: true,
          // Pick a stable shape for the demo user based on id hash.
          avatarShape: randomAvatarShape(seed: 'default-user'.hashCode),
        ));

  Future<void> updateName(String v) async {
    state = state.copyWith(name: v);
    final p = await SharedPreferences.getInstance();
    await p.setString(AppConstants.prefPatientName, v);
  }

  Future<void> updateGlucoseUnit(GlucoseUnit v) async {
    state = state.copyWith(glucoseUnit: v);
    final p = await SharedPreferences.getInstance();
    await p.setString(AppConstants.prefGlucoseUnit, v.name);
  }

  Future<void> updateTherapyMode(TherapyMode v) async {
    state = state.copyWith(therapyMode: v);
    final p = await SharedPreferences.getInstance();
    await p.setString(AppConstants.prefTherapyMode, v.name);
  }

  Future<void> updateTargetRange(double low, double high) async {
    state = state.copyWith(targetLowMgdl: low, targetHighMgdl: high);
    final p = await SharedPreferences.getInstance();
    await p.setDouble(AppConstants.prefTargetLow, low);
    await p.setDouble(AppConstants.prefTargetHigh, high);
  }

  Future<void> updateAlerts({
    bool? urgentLow,
    bool? low,
    bool? high,
    bool? urgentHigh,
  }) async {
    state = state.copyWith(
      alertUrgentLow: urgentLow,
      alertLow: low,
      alertHigh: high,
      alertUrgentHigh: urgentHigh,
    );
    final p = await SharedPreferences.getInstance();
    if (urgentLow != null) await p.setBool(AppConstants.prefAlertUrgentLow, urgentLow);
    if (low != null) await p.setBool(AppConstants.prefAlertLow, low);
    if (high != null) await p.setBool(AppConstants.prefAlertHigh, high);
    if (urgentHigh != null) await p.setBool(AppConstants.prefAlertUrgentHigh, urgentHigh);
  }

  /// Called at the end of onboarding to stamp the chosen shape onto the profile.
  Future<void> updateAvatarShape(String shape) async {
    state = state.copyWith(avatarShape: shape);
    final p = await SharedPreferences.getInstance();
    await p.setString('avatarShape', shape);
  }
}

final onboardingCompleteProvider =
    StateNotifierProvider<OnboardingNotifier, bool>(
  (_) => OnboardingNotifier(),
);

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier() : super(true);

  Future<void> check() async {
    state = true;
  }

  Future<void> complete() async {
    state = true;
    final p = await SharedPreferences.getInstance();
    await p.setBool(AppConstants.prefOnboardingComplete, true);
  }
}
