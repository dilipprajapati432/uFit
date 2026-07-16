import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../services/ai_service.dart';
import '../../providers/auth_provider.dart';
import 'package:ufit/theme/theme_ext.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final habits = ref.watch(habitsProvider);
    final workouts = ref.watch(workoutProvider);
    final water = ref.watch(waterProvider);
    final sleep = ref.watch(sleepProvider);
    final weight = ref.watch(weightProvider);
    final mood = ref.watch(moodProvider);
    final isPremium = ref.watch(premiumProvider);
    final firebaseUser = ref.watch(currentFirebaseUserProvider);
    final steps = ref.watch(stepsProvider);

    List<_ActivityItem> recentActivities = [];
    for (var w in workouts) {
      recentActivities.add(_ActivityItem(title: w.name, subtitle: '${w.durationMinutes} min • ${w.caloriesBurned ?? 0} kcal', icon: '💪', color: AppColors.workoutColor, timestamp: w.startTime));
    }
    for (var w in water) {
      recentActivities.add(_ActivityItem(title: 'Hydration', subtitle: '${w.amountMl} ml', icon: '💧', color: AppColors.waterColor, timestamp: w.timestamp));
    }
    for (var s in sleep) {
      recentActivities.add(_ActivityItem(title: 'Sleep', subtitle: '${s.durationHours.toStringAsFixed(1)} hrs', icon: '🌙', color: AppColors.sleepColor, timestamp: s.bedTime));
    }
    for (var m in mood) {
      recentActivities.add(_ActivityItem(title: 'Mood', subtitle: MoodLog.emojiForScore(m.moodScore), icon: '😊', color: AppColors.moodColor, timestamp: m.timestamp));
    }
    for (var step in steps) {
      recentActivities.add(_ActivityItem(title: 'Steps', subtitle: '${step.steps} steps', icon: '🚶', color: Colors.blueAccent, timestamp: step.date));
    }
    recentActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final displayActivities = recentActivities.take(5).toList();

    final greeting = _getGreeting();
    final today = DateTime.now();

    final todayHabits = ref.read(habitsProvider.notifier).getHabitsForToday();
    final completedHabits = ref.read(habitsProvider.notifier).getTodayCompletedCount();
    final waterGoal = user?.dailyWaterGoalMl ?? 2500;
    final waterToday = water.fold<int>(0, (s, l) => s + l.amountMl);
    final stepsGoal = user?.dailyStepsGoal ?? 10000;
    final stepsToday = ref.read(stepsProvider.notifier).todayTotalSteps;

    return Scaffold(
      backgroundColor: context.bg,
      floatingActionButton: const _AiCoachFloatingButton(),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 0,
            toolbarHeight: 90,
            floating: true,
            pinned: false,
            backgroundColor: context.bg,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [

                Text(
                  greeting,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                Text(
                  user?.name ?? 'Welcome!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            actions: [
              GestureDetector(
                onTap: () => context.push('/analytics'),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.border),
                  ),
                  child: Icon(Icons.bar_chart_rounded, color: context.text, size: 20),
                ),
              ),
              if (!isPremium)
                GestureDetector(
                  onTap: () => context.push('/premium'),
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Text('✨', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 4),
                        Text(
                          'Pro',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: UserAvatar(
                    radius: 18,
                    photoUrl: firebaseUser?.photoURL,
                    initial: user?.name.isNotEmpty == true ? (user?.name[0].toUpperCase() ?? 'U') : 'U',
                    isPremium: isPremium,
                  ),
                ),
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Date
                Text(
                  DateFormat('EEEE, MMMM d').format(today),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                SizedBox(height: 24),

                // Daily Summary Card
                _DailySummaryCard(
                  habitsCompleted: completedHabits,
                  habitsTotal: todayHabits.length,
                  waterMl: waterToday,
                  waterGoalMl: waterGoal,
                  stepsToday: stepsToday,
                  stepsGoal: stepsGoal,
                  workoutsThisWeek: workouts.where((s) { final now = DateTime.now(); final weekStart = now.subtract(Duration(days: now.weekday - 1)); return s.startTime.isAfter(weekStart); }).length,
                ).animate().fadeIn().slideY(begin: 0.2),
                SizedBox(height: 24),

                // 1. Quick Log Row
                const SectionHeader(title: 'Quick Log'),
                SizedBox(height: 8),
                GridView.count(
                  padding: EdgeInsets.zero,
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.05,
                  children: [
                    _QuickLogButton(icon: '💧', label: 'Water', color: AppColors.waterColor, onTap: () => context.push('/water')),
                    _QuickLogButton(icon: '🥗', label: 'Meals', color: Colors.orange, onTap: () => context.push('/meals')),
                    _QuickLogButton(icon: '🚶', label: 'Steps', color: Colors.blueAccent, onTap: () => context.push('/steps')),
                    _QuickLogButton(icon: '😊', label: 'Mood', color: AppColors.moodColor, onTap: () => context.push('/mood')),
                    _QuickLogButton(icon: '⚖️', label: 'Weight', color: AppColors.weightColor, onTap: () => context.push('/weight')),
                    _QuickLogButton(icon: '💪', label: 'Workout', color: AppColors.workoutColor, onTap: () => context.push('/workout')),
                  ],
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                SizedBox(height: 24),

                // 2. Streak Showcase
                if (habits.any((h) => h.currentStreak > 2)) ...[
                  const SectionHeader(title: '🔥 Active Streaks'),
                  SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: habits
                          .where((h) => h.currentStreak > 0)
                          .take(5)
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) => Padding(
                                padding: EdgeInsets.only(
                                    right: entry.key < 4 ? 10 : 0),
                                child: _StreakCard(habit: entry.value)
                                    .animate()
                                    .fadeIn(delay: Duration(milliseconds: entry.key * 100)),
                              ))
                          .toList(),
                    ),
                  ),
                  SizedBox(height: 24),
                ],

                // 3. Stats Grid
                const SectionHeader(title: 'Today\'s Stats'),
                SizedBox(height: 8),
                GridView.count(
                  padding: EdgeInsets.zero,
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                  children: [
                    StatTile(
                      label: 'Sleep Last Night',
                      value: sleep.isEmpty ? '--' : sleep.first.durationHours.toStringAsFixed(1),
                      unit: 'hrs',
                      color: AppColors.sleepColor,
                      icon: Icons.bedtime_rounded,
                    ),
                    StatTile(
                      label: 'Current Weight',
                      value: weight.isEmpty ? '--' : weight.first.weightKg.toStringAsFixed(1),
                      unit: 'kg',
                      color: AppColors.weightColor,
                      icon: Icons.monitor_weight_rounded,
                    ),
                    StatTile(
                      label: "This Week's Workouts",
                      value: workouts.where((s) { final now = DateTime.now(); final todayStart = DateTime(now.year, now.month, now.day); final weekStart = todayStart.subtract(Duration(days: now.weekday - 1)); return s.startTime.isAfter(weekStart) || s.startTime.isAtSameMomentAs(weekStart); }).length.toString(),
                      unit: 'sessions',
                      color: AppColors.workoutColor,
                      icon: Icons.fitness_center_rounded,
                    ),
                    StatTile(
                      label: "Today's Mood",
                      value: mood.isEmpty ? '--' : MoodLog.emojiForScore(mood.first.moodScore),
                      color: AppColors.moodColor,
                      icon: Icons.sentiment_satisfied_rounded,
                    ),
                    StatTile(
                      label: 'Steps Today',
                      value: stepsToday.toString(),
                      unit: 'steps',
                      color: Colors.blueAccent,
                      icon: Icons.directions_walk_rounded,
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms),
                SizedBox(height: 12),

                // 4. AI Insights
                const _AiInsightsCard().animate().fadeIn(delay: 320.ms).slideY(begin: 0.2),
                SizedBox(height: 24),

                // 5. Today's Habits
                SectionHeader(
                  title: "Today's Habits",
                  action: 'See All',
                  onAction: () => context.push('/habits'),
                ),
                SizedBox(height: 8),
                if (todayHabits.isEmpty)
                  GlassCard(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('No habits for today. Add your first habit! 🌱',
                          style: TextStyle(color: context.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                else
                  ...todayHabits.take(4).toList().asMap().entries.map((entry) {
                    final habit = entry.value;
                    final isCompleted = habit.isCompletedOn(today);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _HabitTile(
                        habit: habit,
                        isCompleted: isCompleted,
                        onToggle: () => ref.read(habitsProvider.notifier)
                            .toggleHabitCompletion(habit.id, today),
                      ).animate().fadeIn(delay: Duration(milliseconds: 200 + entry.key * 80)).slideX(begin: 0.2),
                    );
                  }),
                SizedBox(height: 24),

                // 6. Recent Activities Timeline
                if (displayActivities.isNotEmpty) ...[
                  const SectionHeader(
                    title: 'Recent Activities',
                  ),
                  const SizedBox(height: 8),
                  _ActivityTimeline(activities: displayActivities)
                      .animate().fadeIn(delay: 350.ms).slideY(begin: 0.2),
                  const SizedBox(height: 24),
                ],

                SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    if (hour < 21) return 'Good evening,';
    return 'Good night,';
  }
}

class _AiInsightsCard extends StatefulWidget {
  const _AiInsightsCard();

  @override
  State<_AiInsightsCard> createState() => _AiInsightsCardState();
}

class _AiInsightsCardState extends State<_AiInsightsCard> {
  late Future<String> _insightsFuture;

  @override
  void initState() {
    super.initState();
    _insightsFuture = AiService.generateInsights();
  }

  void _refresh() {
    setState(() {
      _insightsFuture = AiService.generateInsights();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.headlineSmall,
                children: const [
                  TextSpan(text: 'u', style: TextStyle(color: Color(0xFFFF8552))),
                  TextSpan(text: 'Fit AI Insights ✨'),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.primary, size: 22),
              onPressed: _refresh,
              tooltip: 'Refresh Insights',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 8),
        FutureBuilder<String>(
          future: _insightsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return GlassCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 16),
                    Text('uFit AI is analyzing your data...', style: TextStyle(color: context.textSecondary)),
                  ],
                ),
              );
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            }
            return GlassCard(
              padding: const EdgeInsets.all(20),
              child: Text(
                snapshot.data!,
                style: TextStyle(color: context.text, height: 1.5, fontSize: 14),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DailySummaryCard extends StatelessWidget {
  final int habitsCompleted;
  final int habitsTotal;
  final int waterMl;
  final int waterGoalMl;
  final int workoutsThisWeek;
  final int stepsToday;
  final int stepsGoal;

  const _DailySummaryCard({
    required this.habitsCompleted,
    required this.habitsTotal,
    required this.waterMl,
    required this.waterGoalMl,
    required this.workoutsThisWeek,
    required this.stepsToday,
    required this.stepsGoal,
  });

  @override
  Widget build(BuildContext context) {
    final habitProgress = habitsTotal == 0 ? 0.0 : habitsCompleted / habitsTotal;
    final waterProgress = waterGoalMl == 0 ? 0.0 : waterMl / waterGoalMl;
    final stepProgress = stepsGoal == 0 ? 0.0 : stepsToday / stepsGoal;
    final overallProgress = (habitProgress + waterProgress.clamp(0.0, 1.0) + stepProgress.clamp(0.0, 1.0)) / 3;

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              CircularProgressWidget(
                progress: overallProgress,
                size: 80,
                color: Colors.white,
                strokeWidth: 6,
                child: Text(
                  '${(overallProgress * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Progress',
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 4),
                    Text(
                      overallProgress >= 1.0
                          ? 'Amazing! All done! 🎉'
                          : overallProgress >= 0.5
                              ? 'Doing great! Keep it up!'
                              : 'Let\'s get moving today!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _ProgressItem(
                icon: '✅',
                label: 'Habits',
                value: '$habitsCompleted/$habitsTotal',
                progress: habitProgress,
              ),
              SizedBox(width: 8),
              _ProgressItem(
                icon: '💧',
                label: 'Water',
                value: '${waterMl}ml',
                progress: waterProgress,
              ),
              SizedBox(width: 8),
              _ProgressItem(
                icon: '🚶',
                label: 'Steps',
                value: '$stepsToday',
                progress: stepProgress,
              ),
              SizedBox(width: 8),
              _ProgressItem(
                icon: '💪',
                label: 'Workouts',
                value: '$workoutsThisWeek /wk',
                progress: (workoutsThisWeek / 5).clamp(0.0, 1.0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final double progress;

  const _ProgressItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(label, style: TextStyle(color: Colors.white70, fontSize: 10)),
            ),
            SizedBox(height: 6),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 3,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickLogButton extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickLogButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: TextStyle(fontSize: 22)),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitTile extends StatelessWidget {
  final dynamic habit;
  final bool isCompleted;
  final VoidCallback onToggle;

  const _HabitTile({required this.habit, required this.isCompleted, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(habit.icon, style: TextStyle(fontSize: 28)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? context.textSecondary : null,
                  ),
                ),
                if (habit.currentStreak > 0)
                  Text(
                    '🔥 ${habit.currentStreak} day streak',
                    style: TextStyle(fontSize: 11, color: AppColors.accentOrange),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.success : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? AppColors.success : context.border,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentWorkoutCard extends StatelessWidget {
  final dynamic session;

  const _RecentWorkoutCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      gradient: AppColors.workoutGradient,
      child: Row(
        children: [
          Text('💪', style: TextStyle(fontSize: 36)),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.name,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  '${session.durationMinutes} min · ${session.exercises.length} exercises · ${session.caloriesBurned ?? 0} cal',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                session.type.toUpperCase(),
                style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < session.ratingOutOf5 ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final dynamic habit;

  const _StreakCard({required this.habit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border),
      ),
      child: Column(
        children: [
          Text(habit.icon, style: TextStyle(fontSize: 28)),
          SizedBox(height: 8),
          Text(
            '🔥 ${habit.currentStreak}',
            style: TextStyle(color: AppColors.accentOrange, fontWeight: FontWeight.w800, fontSize: 16),
          ),
          SizedBox(height: 2),
          Text(
            habit.name,
            style: TextStyle(color: context.textSecondary, fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AiCoachFloatingButton extends StatelessWidget {
  const _AiCoachFloatingButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/coach'),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF9D97FF), Color(0xFFFF9F43)],
            stops: [0.0, 0.7, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: const Color(0xFFFF9F43).withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(4, 4),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: const Center(
          child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 30),
        ),
      )
      .animate(onPlay: (c) => c.repeat(reverse: true))
      .moveY(begin: -4, end: 4, duration: 2500.ms, curve: Curves.easeInOutSine)
      .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1500.ms, curve: Curves.easeInOutSine)
      .animate(onPlay: (c) => c.repeat())
      .shimmer(delay: 3000.ms, duration: 1500.ms, color: Colors.white.withOpacity(0.4), angle: 1),
    );
  }
}

class _ActivityItem {
  final String title;
  final String subtitle;
  final String icon;
  final Color color;
  final DateTime timestamp;

  _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.timestamp,
  });
}

class _ActivityTimeline extends StatelessWidget {
  final List<_ActivityItem> activities;
  const _ActivityTimeline({required this.activities});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 4),
      child: Column(
        children: activities.asMap().entries.map((entry) {
          final isLast = entry.key == activities.length - 1;
          final activity = entry.value;
          
          // Use 'Today' if it's today, otherwise format
          final now = DateTime.now();
          final isToday = activity.timestamp.year == now.year && 
                          activity.timestamp.month == now.month && 
                          activity.timestamp.day == now.day;
          
          final dateStr = isToday ? 'Today' : DateFormat('MMM d').format(activity.timestamp);
          final timeStr = DateFormat('h:mm a').format(activity.timestamp);
          
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Timeline line & node
                SizedBox(
                  width: 40,
                  child: Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: activity.color.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: activity.color, width: 2),
                        ),
                        child: Center(
                          child: Text(activity.icon, style: const TextStyle(fontSize: 14)),
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: context.border,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                activity.title,
                                style: TextStyle(color: context.text, fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$dateStr, $timeStr',
                              style: TextStyle(color: context.textMuted, fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activity.subtitle,
                          style: TextStyle(color: activity.color, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
