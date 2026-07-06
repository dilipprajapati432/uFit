// lib/screens/auth/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'package:ufit/theme/theme_ext.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(),

              // Logo + branding
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 12))],
                ),
                child: Center(child: Text('💪', style: TextStyle(fontSize: 48))),
              ).animate().scale(duration: 700.ms, curve: Curves.elasticOut),
              SizedBox(height: 24),

              Text(
                'uFit',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
              SizedBox(height: 8),
              Text(
                'Your all-in-one health\n& fitness companion',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: context.textSecondary, height: 1.5),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),

              SizedBox(height: 48),

              // Feature pills
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: const [
                  _FeaturePill('✅ Habits'),
                  _FeaturePill('💧 Water'),
                  _FeaturePill('💪 Workout'),
                  _FeaturePill('🌙 Sleep'),
                  _FeaturePill('⚖️ Weight'),
                  _FeaturePill('😊 Mood'),
                ],
              ).animate().fadeIn(delay: 400.ms),

              const Spacer(),

              // Get Started
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.go('/signup'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Get Started', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
              SizedBox(height: 14),

              // Google Sign-In shortcut
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () async {
                    try {
                      await AuthService.signInWithGoogle();
                    } catch (_) {}
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('G', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                      SizedBox(width: 10),
                      Text('Continue with Google', style: TextStyle(color: context.text, fontSize: 15, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.3),
              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account? ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.textSecondary)),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text('Sign In', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ),
                ],
              ).animate().fadeIn(delay: 600.ms),

              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final String label;
  const _FeaturePill(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.border),
      ),
      child: Text(label, style: TextStyle(fontSize: 13, color: context.text, fontWeight: FontWeight.w500)),
    );
  }
}
