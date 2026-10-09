import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/providers.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/auth/auth_screens.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/profile_edit_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/settings/notification_settings_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/tracker/tracker_screen.dart';
import '../../features/workout_session/combat_session_screen.dart';
import '../../features/workout_session/workout_session_screen.dart';
import '../../features/workouts/ai_generator_screen.dart';
import '../../features/workouts/combat_screen.dart';
import '../../features/workouts/exercise_detail_screen.dart';
import '../../features/workouts/nutrition_screen.dart';
import '../../features/workouts/social_screen.dart';
import '../../features/workouts/workouts_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authNotifierProvider);
  final prefs = ref.watch(appPrefsProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isSplash = loc == '/';
      final isOnboarding = loc == '/onboarding';
      final isAuth = loc == '/login' || loc == '/signup';

      if (isSplash) return null;

      if (!prefs.onboardingComplete && !isOnboarding) {
        return '/onboarding';
      }

      if (prefs.onboardingComplete && isOnboarding) {
        return auth.canAccessApp ? '/home' : '/login';
      }

      if (!auth.canAccessApp && !isAuth && !isOnboarding) {
        return '/login';
      }

      if (auth.canAccessApp && isAuth) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
              transitionsBuilder: _fadeTransition,
            ),
            routes: [
              GoRoute(
                path: 'workouts',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const WorkoutsScreen(),
                  transitionsBuilder: _fadeTransition,
                ),
              ),
              GoRoute(
                path: 'tracker',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const TrackerScreen(),
                  transitionsBuilder: _fadeTransition,
                ),
              ),
              GoRoute(
                path: 'analytics',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const AnalyticsScreen(),
                  transitionsBuilder: _fadeTransition,
                ),
              ),
              GoRoute(
                path: 'profile',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const ProfileScreen(),
                  transitionsBuilder: _fadeTransition,
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/ai-generator',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AiGeneratorScreen(),
          transitionsBuilder: _slideUpTransition,
        ),
      ),
      GoRoute(
        path: '/combat',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CombatScreen(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: '/combat/:id',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: CombatSessionScreen(lessonId: id),
            transitionsBuilder: _slideTransition,
          );
        },
      ),
      GoRoute(
        path: '/nutrition',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const NutritionScreen(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: '/social',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SocialScreen(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: '/exercise/:id',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ExerciseDetailScreen(exerciseId: id),
            transitionsBuilder: _slideTransition,
          );
        },
      ),
      GoRoute(
        path: '/workout/session',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final ids = state.uri.queryParameters['ids']?.split(',') ?? [];
          final title = state.uri.queryParameters['title'] ?? 'Workout';
          return CustomTransitionPage(
            key: state.pageKey,
            child: WorkoutSessionScreen(
              exerciseIds: ids,
              title: Uri.decodeComponent(title),
            ),
            transitionsBuilder: _slideUpTransition,
          );
        },
      ),
      GoRoute(
        path: '/profile/edit',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProfileEditScreen(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: '/settings/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const NotificationSettingsScreen(),
          transitionsBuilder: _slideTransition,
        ),
      ),
    ],
  );
});

Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) =>
    FadeTransition(opacity: animation, child: child);

Widget _slideTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final tween = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
      .chain(CurveTween(curve: Curves.easeOutCubic));
  return SlideTransition(position: animation.drive(tween), child: child);
}

Widget _slideUpTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final tween = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
      .chain(CurveTween(curve: Curves.easeOutCubic));
  return SlideTransition(position: animation.drive(tween), child: child);
}

/// Navigate to a workout session with exercise IDs.
void startWorkoutSession(
  BuildContext context, {
  required List<String> exerciseIds,
  String title = 'Workout',
}) {
  final query =
      'ids=${exerciseIds.join(',')}&title=${Uri.encodeComponent(title)}';
  context.push('/workout/session?$query');
}
