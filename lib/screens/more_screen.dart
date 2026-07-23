// lib/screens/more_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'package:ufit/theme/theme_ext.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(premiumProvider);
    final user = ref.watch(userProvider);
    final firebaseUser = ref.watch(currentFirebaseUserProvider);

    final modules = [
      (FontAwesomeIcons.hourglassHalf, 'Fasting', Colors.teal, '/fasting'),
      (FontAwesomeIcons.droplet, 'Water', AppColors.waterColor, '/water'),
      (FontAwesomeIcons.utensils, 'Meals', Colors.orange, '/meals'),
      (FontAwesomeIcons.dumbbell, 'Workout', AppColors.workoutColor, '/workout'),
      (FontAwesomeIcons.moon, 'Sleep', AppColors.sleepColor, '/sleep'),
      (FontAwesomeIcons.squareCheck, 'Habits', AppColors.habitColor, '/habits'),
      (FontAwesomeIcons.personWalking, 'Steps', Colors.blueAccent, '/steps'),
      (FontAwesomeIcons.scaleBalanced, 'Weight', AppColors.weightColor, '/weight'),
      (FontAwesomeIcons.faceSmile, 'Mood', AppColors.moodColor, '/mood'),
      (FontAwesomeIcons.userLarge, 'Profile', AppColors.primary, '/profile'),
      (FontAwesomeIcons.gear, 'Settings', context.textSecondary, '/settings'),
      (FontAwesomeIcons.wandMagicSparkles, 'Go Pro', AppColors.accentYellow, '/premium'),
    ];

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        title: const Text('More'),
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
          // User mini-card
          GlassCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  backgroundImage: firebaseUser?.photoURL != null ? NetworkImage(firebaseUser!.photoURL!) : null,
                  child: firebaseUser?.photoURL == null
                      ? Text(user?.name.isNotEmpty == true ? (user?.name[0].toUpperCase() ?? 'U') : 'U',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? 'User', style: Theme.of(context).textTheme.titleMedium),
                      Text(firebaseUser?.email ?? '', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                if (isPremium) const FaIcon(FontAwesomeIcons.wandMagicSparkles, color: AppColors.accentYellow, size: 20),
              ],
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 16),

          if (!isPremium)
            GestureDetector(
              onTap: () => context.push('/premium'),
              child: const GradientCard(
                gradient: AppColors.primaryGradient,
                child: Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.wandMagicSparkles, size: 28, color: AppColors.accentYellow),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Upgrade to uFit Pro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                          SizedBox(height: 2),
                          Text('Unlimited habits, analytics & more', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    FaIcon(FontAwesomeIcons.chevronRight, color: Colors.white, size: 19),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 60.ms),
          const SizedBox(height: 20),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: modules.asMap().entries.map((entry) {
              final (iconData, label, color, route) = entry.value;
              // Hide Pro tile if already premium
              if (label == 'Go Pro' && isPremium) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () => context.push(route),
                child: GlassCard(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                        child: Center(child: FaIcon(iconData, color: color, size: 24)),
                      ),
                      const SizedBox(height: 10),
                      Text(label, style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: entry.key * 60)).scale(begin: const Offset(0.9, 0.9));
            }).toList(),
          ),
        ],
      ),
    );
  }
}
