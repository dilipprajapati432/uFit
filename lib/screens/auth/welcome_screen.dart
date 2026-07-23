import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

import 'package:ufit/theme/theme_ext.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(firebaseAuthProvider);

    // Show a blank black screen while Firebase Auth resolves.
    // This prevents the Welcome Screen layout from flashing on app startup for logged-in users.
    if (authState.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.shrink(),
      );
    }

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(),

              // Logo + branding
              Image.asset(
                'assets/images/ufit_icon_new.png',
                width: 100,
                height: 100,
              ).animate().scale(duration: 700.ms, curve: Curves.elasticOut),
              const SizedBox(height: 24),

              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2,
                  ),
                  children: const [
                    TextSpan(text: 'u', style: TextStyle(color: AppColors.accentOrange)),
                    TextSpan(text: 'Fit'),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
              const SizedBox(height: 8),
              Text(
                'Your all-in-one health\n& fitness companion',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: context.textSecondary, height: 1.5),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 48),

              // Feature pills
              const Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _FeaturePill(label: 'Habits', icon: FontAwesomeIcons.squareCheck),
                  _FeaturePill(label: 'Water', icon: FontAwesomeIcons.droplet),
                  _FeaturePill(label: 'Workout', icon: FontAwesomeIcons.dumbbell),
                  _FeaturePill(label: 'Sleep', icon: FontAwesomeIcons.moon),
                  _FeaturePill(label: 'Weight', icon: FontAwesomeIcons.scaleBalanced),
                  _FeaturePill(label: 'Mood', icon: FontAwesomeIcons.faceSmile),
                ],
              ).animate().fadeIn(delay: 400.ms),

              const Spacer(),

              // Get Started
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.push('/signup'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Get Started', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
              const SizedBox(height: 14),

              // Google Sign-In shortcut
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () async {
                    try {
                      await AuthService.signInWithGoogle(isSignUp: true);
                    } catch (_) {}
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('G', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(width: 10),
                      Text('Continue with Google', style: TextStyle(color: context.text, fontSize: 15, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.3),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account? ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.textSecondary)),
                  GestureDetector(
                    onTap: () => context.push('/login'),
                    child: const Text('Sign In', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ),
                ],
              ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final String label;
  final IconData icon;
  const _FeaturePill({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 13, color: context.text, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
