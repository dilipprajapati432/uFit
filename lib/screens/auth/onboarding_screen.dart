// lib/screens/auth/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/models.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import 'package:ufit/theme/theme_ext.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  final _nameController = TextEditingController();
  double _weight = 70;
  double _height = 170;
  int _age = 25;
  String _gender = 'male';
  String _goal = 'maintain';

  final _pages = [
    _OnboardingPage(
      emoji: '🏋️',
      title: 'Welcome to uFit',
      subtitle: 'Your all-in-one health & fitness companion. Track habits, workouts, sleep, water, and more.',
      gradient: AppColors.habitGradient,
    ),
    _OnboardingPage(
      emoji: '💧',
      title: 'Track Everything',
      subtitle: 'Water intake, sleep quality, daily workouts, body weight, mood, and daily habits — all in one beautiful app.',
      gradient: AppColors.waterGradient,
    ),
    _OnboardingPage(
      emoji: '📊',
      title: 'Visualize Progress',
      subtitle: 'Beautiful charts and insights show your progress over time. Stay motivated with streaks and achievements.',
      gradient: AppColors.workoutGradient,
    ),
    _OnboardingPage(
      emoji: '🎯',
      title: 'Achieve Your Goals',
      subtitle: 'Set personal goals and get daily reminders. Your health journey starts with one small step.',
      gradient: AppColors.sleepGradient,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _currentPage < _pages.length
                    ? () => setState(() {
                          _currentPage = _pages.length;
                          _pageController.animateToPage(
                            _pages.length,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        })
                    : null,
                child: Text(
                  _currentPage < _pages.length ? 'Skip' : '',
                  style: TextStyle(color: context.textSecondary),
                ),
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  ..._pages.map((p) => _buildOnboardingPage(p)),
                  _buildProfilePage(),
                ],
              ),
            ),

            // Indicator + Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length + 1, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == i ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == i ? AppColors.primary : context.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleNext,
                      child: Text(
                        _currentPage < _pages.length ? 'Continue' : 'Get Started',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: page.gradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(page.emoji, style: const TextStyle(fontSize: 72)),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
          const SizedBox(height: 16),
          Text(
            page.subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: context.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
        ],
      ),
    );
  }

  Widget _buildProfilePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Tell us about you',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ).animate().fadeIn().slideX(begin: -0.2),
          const SizedBox(height: 8),
          Text(
            'This helps us personalize your experience',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.textSecondary,
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 28),

          // Name
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Your Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 20),

          // Gender
          Text('Gender', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _genderButton('male', '👨', 'Male')),
              const SizedBox(width: 12),
              Expanded(child: _genderButton('female', '👩', 'Female')),
              const SizedBox(width: 12),
              Expanded(child: _genderButton('other', '🧑', 'Other')),
            ],
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 20),

          // Age
          Text('Age: $_age', style: Theme.of(context).textTheme.titleMedium),
          Slider(
            value: _age.toDouble(),
            min: 13,
            max: 80,
            divisions: 67,
            activeColor: AppColors.primary,
            inactiveColor: context.border,
            onChanged: (v) => setState(() => _age = v.toInt()),
          ).animate().fadeIn(delay: 350.ms),

          // Weight
          Text(
            'Weight: ${_weight.toStringAsFixed(1)} kg',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            value: _weight,
            min: 30,
            max: 200,
            divisions: 170,
            activeColor: AppColors.weightColor,
            inactiveColor: context.border,
            onChanged: (v) => setState(() => _weight = double.parse(v.toStringAsFixed(1))),
          ).animate().fadeIn(delay: 400.ms),

          // Height
          Text(
            'Height: ${_height.toStringAsFixed(0)} cm',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            value: _height,
            min: 100,
            max: 230,
            divisions: 130,
            activeColor: AppColors.secondary,
            inactiveColor: context.border,
            onChanged: (v) => setState(() => _height = double.parse(v.toStringAsFixed(0))),
          ).animate().fadeIn(delay: 450.ms),

          const SizedBox(height: 8),
          // Fitness Goal
          Text('Your Goal', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _goalChip('lose_weight', '🔥 Lose Weight'),
              _goalChip('gain_muscle', '💪 Gain Muscle'),
              _goalChip('maintain', '⚖️ Stay Fit'),
              _goalChip('active_lifestyle', '🏃 Active Life'),
            ],
          ).animate().fadeIn(delay: 500.ms),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _genderButton(String value, String emoji, String label) {
    final isSelected = _gender == value;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.15) : context.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : context.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }

  Widget _goalChip(String value, String label) {
    final isSelected = _goal == value;
    return GestureDetector(
      onTap: () => setState(() => _goal = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.15) : context.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : context.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : context.text,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _handleNext() {
    if (_currentPage < _pages.length) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _createUser();
    }
  }

  Future<void> _createUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final name = _nameController.text.trim().isEmpty
        ? (firebaseUser?.displayName ?? 'Friend')
        : _nameController.text.trim();

    final user = UserModel(
      id: firebaseUser?.uid ?? const Uuid().v4(),
      name: name,
      email: firebaseUser?.email ?? '',
      createdAt: DateTime.now(),
      heightCm: _height,
      weightKg: _weight,
      age: _age,
      gender: _gender,
      fitnessGoal: _goal,
      targetWeightKg: _weight,
    );

    await ref.read(userProvider.notifier).saveUser(user);
    if (mounted) context.go('/dashboard');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}

class _OnboardingPage {
  final String emoji;
  final String title;
  final String subtitle;
  final Gradient gradient;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}
