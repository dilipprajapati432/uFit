// lib/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/app_providers.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/habits/habits_screen.dart';
import 'screens/main_scaffold.dart';
import 'screens/mood/mood_screen.dart';
import 'screens/more_screen.dart';
import 'screens/premium/premium_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/settings/edit_profile_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/legal_screen.dart';
import 'screens/settings/help_center_screen.dart';
import 'screens/sleep/sleep_screen.dart';
import 'screens/water/water_screen.dart';
import 'screens/weight/weight_screen.dart';
import 'screens/workout/workout_screen.dart';
import 'screens/coach/coach_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Notifier that triggers router refresh when auth state changes
  final authNotifier = _AuthStateNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = ref.read(firebaseAuthProvider);
      final loc = state.matchedLocation;
      final isAuthPage = loc == '/welcome' || loc == '/login' || loc == '/signup';

      // Still loading — don't redirect yet
      if (authState.isLoading) return null;

      final isLoggedIn = authState.maybeWhen(data: (u) => u != null, orElse: () => false);
      final hasProfile = ref.read(userProvider) != null;

      if (!isLoggedIn && !isAuthPage && loc != '/splash') return '/welcome';
      if (isLoggedIn && (isAuthPage || loc == '/splash')) return hasProfile ? '/dashboard' : '/onboarding';
      if (isLoggedIn && loc == '/onboarding' && hasProfile) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (c, s) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (c, s) => const SignupScreen()),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
      GoRoute(path: '/premium', builder: (c, s) => const PremiumScreen()),
      GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
      GoRoute(path: '/edit-profile', builder: (c, s) => const EditProfileScreen()),
      GoRoute(path: '/legal-terms', builder: (c, s) => const LegalScreen(isPrivacyPolicy: false)),
      GoRoute(path: '/legal-privacy', builder: (c, s) => const LegalScreen(isPrivacyPolicy: true)),
      GoRoute(path: '/help-center', builder: (c, s) => const HelpCenterScreen()),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(
          currentPath: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(path: '/dashboard', builder: (c, s) => const DashboardScreen()),
          GoRoute(path: '/habits', builder: (c, s) => const HabitsScreen()),
          GoRoute(path: '/workout', builder: (c, s) => const WorkoutScreen()),
          GoRoute(path: '/sleep', builder: (c, s) => const SleepScreen()),
          GoRoute(path: '/more', builder: (c, s) => const MoreScreen()),
          GoRoute(path: '/water', builder: (c, s) => const WaterScreen()),
          GoRoute(path: '/weight', builder: (c, s) => const WeightScreen()),
          GoRoute(path: '/mood', builder: (c, s) => const MoodScreen()),
          GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
          GoRoute(path: '/coach', builder: (c, s) => const CoachScreen()),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});

/// Notifies GoRouter to re-evaluate redirects when Firebase auth state changes
class _AuthStateNotifier extends ChangeNotifier {
  _AuthStateNotifier(Ref ref) {
    ref.listen(firebaseAuthProvider, (_, __) => notifyListeners());
  }
}
