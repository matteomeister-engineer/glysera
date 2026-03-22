import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/trends/screens/trends_screen.dart';
import '../../features/logbook/screens/logbook_screen.dart';
import '../../features/insights/screens/insights_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../shared/widgets/main_shell.dart';

abstract class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String trends = '/trends';
  static const String logbook = '/logbook';
  static const String insights = '/insights';
  static const String settings = '/settings';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(onboardingCompleteProvider.notifier);
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) async {
      await notifier.check();
      final done = ref.read(onboardingCompleteProvider);
      if (!done && state.matchedLocation != AppRoutes.onboarding) return AppRoutes.onboarding;
      if (done && state.matchedLocation == AppRoutes.onboarding) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.onboarding, builder: (_, __) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: AppRoutes.dashboard, builder: (_, __) => const DashboardScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: AppRoutes.trends, builder: (_, __) => const TrendsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: AppRoutes.logbook, builder: (_, __) => const LogbookScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: AppRoutes.insights, builder: (_, __) => const InsightsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: AppRoutes.settings, builder: (_, __) => const SettingsScreen())]),
        ],
      ),
    ],
  );
});
