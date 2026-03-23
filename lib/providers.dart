import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'data/models/glucose_reading.dart';
import 'data/models/glucose_repository_hive.dart';
import 'data/simulator/glucose_simulator.dart';
import 'core/constants/constants.dart';
import 'services/hive_service.dart';

// ─────────────────────────────────────────────────────────────
// Repository — Hive-backed, singleton per app lifetime
// ─────────────────────────────────────────────────────────────

final glucoseRepositoryProvider = Provider<HiveGlucoseRepository>((ref) {
  return HiveGlucoseRepository();
});

// ─────────────────────────────────────────────────────────────
// Simulator
// ─────────────────────────────────────────────────────────────

final glucoseSimulatorProvider = Provider<GlucoseSimulator>((ref) {
  final s = GlucoseSimulator();
  s.start();
  ref.onDispose(s.stop);
  return s;
});

// ─────────────────────────────────────────────────────────────
// Glucose stream — saves every reading to Hive automatically
// ─────────────────────────────────────────────────────────────

final glucoseStreamProvider = StreamProvider<GlucoseReading>((ref) {
  final sim  = ref.watch(glucoseSimulatorProvider);
  final repo = ref.read(glucoseRepositoryProvider);
  return sim.stream.asyncMap((r) async {
    await repo.save(r);
    return r;
  });
});

final latestGlucoseProvider = Provider<GlucoseReading?>((ref) {
  // Returns the live stream value, or falls back to the last
  // persisted reading from Hive (so the dashboard is never blank).
  return ref.watch(glucoseStreamProvider).valueOrNull
      ?? HiveService.loadLatestReading();
});

// ─────────────────────────────────────────────────────────────
// Glucose history — loaded from Hive + live updates appended
// ─────────────────────────────────────────────────────────────

final glucoseHistoryProvider = Provider<List<GlucoseReading>>((ref) {
  // Watch the stream so this rebuilds on every new reading
  ref.watch(glucoseStreamProvider);
  return ref.read(glucoseRepositoryProvider).getAll();
});

// ─────────────────────────────────────────────────────────────
// User profile — persisted via Hive + SharedPreferences
// ─────────────────────────────────────────────────────────────

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>(
  (_) => UserProfileNotifier(),
);

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(_loadFromHive());

  /// Restore profile from Hive on startup.
  static UserProfile _loadFromHive() {
    final name = HiveService.loadProfileField<String>('name') ?? 'Sarah';
    final unitName = HiveService.loadProfileField<String>('glucoseUnit');
    final unit = unitName != null
        ? GlucoseUnit.values.byName(unitName)
        : GlucoseUnit.mgdl;
    final therapyName = HiveService.loadProfileField<String>('therapyMode');
    final therapy = therapyName != null
        ? TherapyMode.values.byName(therapyName)
        : TherapyMode.pump;
    final targetLow = HiveService.loadProfileField<double>('targetLow')
        ?? AppConstants.defaultTargetLow;
    final targetHigh = HiveService.loadProfileField<double>('targetHigh')
        ?? AppConstants.defaultTargetHigh;
    final avatarShape =
        HiveService.loadProfileField<String>('avatarShape') ?? '';

    return UserProfile(
      id: 'default-user',
      name: name,
      glucoseUnit: unit,
      therapyMode: therapy,
      targetLowMgdl: targetLow,
      targetHighMgdl: targetHigh,
      alertUrgentLow: true,
      alertLow: HiveService.loadProfileField<bool>('alertLow') ?? true,
      alertHigh: HiveService.loadProfileField<bool>('alertHigh') ?? true,
      alertUrgentHigh: true,
    );
  }

  Future<void> updateName(String v) async {
    state = state.copyWith(name: v);
    await HiveService.saveProfileField('name', v);
  }

  Future<void> updateGlucoseUnit(GlucoseUnit v) async {
    state = state.copyWith(glucoseUnit: v);
    await HiveService.saveProfileField('glucoseUnit', v.name);
  }

  Future<void> updateTherapyMode(TherapyMode v) async {
    state = state.copyWith(therapyMode: v);
    await HiveService.saveProfileField('therapyMode', v.name);
  }

  Future<void> updateTargetRange(double low, double high) async {
    state = state.copyWith(targetLowMgdl: low, targetHighMgdl: high);
    await HiveService.saveProfileField('targetLow', low);
    await HiveService.saveProfileField('targetHigh', high);
  }

  Future<void> updateAlerts({
    bool? urgentLow, bool? low, bool? high, bool? urgentHigh,
  }) async {
    state = state.copyWith(
      alertUrgentLow: urgentLow,
      alertLow: low,
      alertHigh: high,
      alertUrgentHigh: urgentHigh,
    );
    if (low != null) await HiveService.saveProfileField('alertLow', low);
    if (high != null) await HiveService.saveProfileField('alertHigh', high);
  }

  Future<void> updateAvatarShape(String shape) async {
    state = state.copyWith(avatarShape: shape);
    await HiveService.saveProfileField('avatarShape', shape);
  }
}

// ─────────────────────────────────────────────────────────────
// Onboarding
// ─────────────────────────────────────────────────────────────

final onboardingCompleteProvider =
    StateNotifierProvider<OnboardingNotifier, bool>(
  (_) => OnboardingNotifier(),
);

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier() : super(true);

  /// Called by app_router on startup — always returns true (demo mode).
  Future<void> check() async {
    state = true;
  }

  Future<void> complete() async {
    state = true;
    await HiveService.saveProfileField(
        AppConstants.prefOnboardingComplete, true);
  }
}
