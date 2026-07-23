// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'package:ufit/theme/theme_ext.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final firebaseUser = ref.watch(currentFirebaseUserProvider);
    final isPremium = ref.watch(premiumProvider);
    final habits = ref.watch(habitsProvider);
    final workouts = ref.watch(workoutProvider);
    final sleep = ref.watch(sleepProvider);
    final weight = ref.watch(weightProvider);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.gear, size: 19),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile header card
          GradientCard(
            gradient: AppColors.primaryGradient,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage: firebaseUser?.photoURL != null ? NetworkImage(firebaseUser!.photoURL!) : null,
                  child: firebaseUser?.photoURL == null
                      ? Text(
                          user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 26),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? firebaseUser?.displayName ?? 'Friend',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(firebaseUser?.email ?? '',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isPremium)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: const Text('✨ Pro Member', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                        )
                      else
                        Text(
                          'Member since ${user != null ? DateFormat('MMM yyyy').format(user.createdAt) : ''}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.pen, color: Colors.white70, size: 19),
                  onPressed: () => context.push('/edit-profile'),
                ),
              ],
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 20),

          if (!isPremium)
            GestureDetector(
              onTap: () => context.push('/premium'),
              child: GradientCard(
                gradient: const LinearGradient(colors: [Color(0xFF1C1C27), Color(0xFF252535)]),
                child: Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.wandMagicSparkles, size: 24, color: AppColors.accentYellow),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Upgrade to Pro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                          Text('Unlimited habits, analytics & more', style: TextStyle(color: context.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(20)),
                      child: const Text('Upgrade', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 80.ms),
          const SizedBox(height: 20),

          // Body stats
          if (user != null && (user.weightKg != null || user.heightCm != null)) ...[
            const SectionHeader(title: 'Body Stats'),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              child: Row(
                children: [
                  if (user.weightKg != null)
                    Expanded(child: StatTile(label: 'Weight', value: user.weightKg!.toStringAsFixed(1), unit: 'kg', color: AppColors.weightColor, icon: Icons.monitor_weight_outlined)),
                  if (user.heightCm != null) ...[
                    const SizedBox(width: 12),
                    Expanded(child: StatTile(label: 'Height', value: user.heightCm!.toStringAsFixed(0), unit: 'cm', color: AppColors.secondary, icon: Icons.height_rounded)),
                  ],
                  if (user.weightKg != null && user.heightCm != null) ...[
                    const SizedBox(width: 12),
                    Expanded(child: StatTile(
                      label: 'BMI',
                      value: (user.weightKg != null && user.heightCm != null) ? (user.weightKg! / ((user.heightCm! / 100) * (user.heightCm! / 100))).toStringAsFixed(1) : '--',
                      color: AppColors.accentYellow,
                      icon: Icons.favorite_outline,
                    )),
                  ],
                ],
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 20),
          ],

          // Activity summary
          const SectionHeader(title: 'Activity Summary'),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              StatTile(label: 'Active Habits', value: '${habits.length}', color: AppColors.habitColor, icon: Icons.check_circle_outline),
              StatTile(label: 'Total Workouts', value: '${workouts.length}', color: AppColors.workoutColor, icon: Icons.fitness_center),
              StatTile(label: 'Sleep Logs', value: '${sleep.length}', color: AppColors.sleepColor, icon: Icons.bedtime_outlined),
              StatTile(label: 'Weight Logs', value: '${weight.length}', color: AppColors.weightColor, icon: Icons.monitor_weight_outlined),
            ],
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 20),

          // Achievements
          const SectionHeader(title: 'Achievements'),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                AchievementBadge(icon: FontAwesomeIcons.fire, title: '3-Day Starter', isUnlocked: (user?.currentAppStreak ?? 0) >= 3),
                const SizedBox(width: 12),
                AchievementBadge(icon: FontAwesomeIcons.bolt, title: '7-Day Warrior', isUnlocked: (user?.currentAppStreak ?? 0) >= 7),
                const SizedBox(width: 12),
                AchievementBadge(icon: FontAwesomeIcons.crown, title: '30-Day Legend', isUnlocked: (user?.currentAppStreak ?? 0) >= 30),
                const SizedBox(width: 12),
                AchievementBadge(icon: FontAwesomeIcons.bullseye, title: 'First Habit', isUnlocked: habits.any((h) => h.currentStreak >= 1)),
                const SizedBox(width: 12),
                const AchievementBadge(icon: FontAwesomeIcons.droplet, title: 'Hydrated', isUnlocked: true),
                const SizedBox(width: 12),
                AchievementBadge(icon: FontAwesomeIcons.dumbbell, title: '5 Workouts', isUnlocked: workouts.length >= 5),
                const SizedBox(width: 12),
                AchievementBadge(icon: FontAwesomeIcons.moon, title: '7 Nights', isUnlocked: sleep.length >= 7),
                const SizedBox(width: 12),
                AchievementBadge(icon: FontAwesomeIcons.scaleBalanced, title: 'Weight Tracker', isUnlocked: weight.isNotEmpty),
                const SizedBox(width: 12),
                AchievementBadge(icon: FontAwesomeIcons.flag, title: 'Goal Setter', isUnlocked: user?.fitnessGoal != null),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 24),

          // Quick links
          const SectionHeader(title: 'Quick Links'),
          const SizedBox(height: 12),
          _QuickLink(icon: FontAwesomeIcons.gear, label: 'Settings', onTap: () => context.push('/settings')),
          _QuickLink(icon: FontAwesomeIcons.wandMagicSparkles, label: 'Upgrade to Pro', onTap: () => context.push('/premium'), highlight: true),
          _QuickLink(icon: FontAwesomeIcons.arrowRightFromBracket, label: 'Sign Out', onTap: () => _confirmSignOut(context, ref), isDestructive: true),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.surface,
        title: const Text('Sign Out?'),
        content: const Text('You can sign back in anytime.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context, rootNavigator: true).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await AuthService.signOut();
              ref.read(userProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool highlight;

  const _QuickLink({required this.icon, required this.label, required this.onTap, this.isDestructive = false, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : highlight ? AppColors.primary : context.text;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color.withOpacity(0.8)),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600))),
            FaIcon(FontAwesomeIcons.chevronRight, color: color.withOpacity(0.4), size: 18),
          ],
        ),
      ),
    );
  }
}
