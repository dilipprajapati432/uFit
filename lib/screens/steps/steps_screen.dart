// lib/screens/steps/steps_screen.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/confetti_overlay.dart';

import 'package:ufit/theme/theme_ext.dart';

class StepsScreen extends ConsumerStatefulWidget {
  const StepsScreen({super.key});

  @override
  ConsumerState<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends ConsumerState<StepsScreen> {
  final _quickAmounts = [500, 1000, 2000, 5000];

  Map<DateTime, int> _computeWeeklyData(List<StepLog> logs) {
    final result = <DateTime, int>{};
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dayLogs = logs.where((l) =>
          l.date.year == date.year &&
          l.date.month == date.month &&
          l.date.day == date.day);
      result[date] = dayLogs.fold(0, (s, l) => s + l.steps);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(stepsProvider);
    final user = ref.watch(userProvider);
    final goal = user?.dailyStepsGoal ?? 10000;
    final total = ref.read(stepsProvider.notifier).todayTotalSteps;
    final progress = (total / goal).clamp(0.0, 1.0);
    final pedStatus = ref.read(stepsProvider.notifier).pedestrianStatus;
    final weeklyData = _computeWeeklyData(logs);
    final maxWeeklyValue = weeklyData.values.fold<int>(0, (max, v) => v > max ? v : max);
    final chartMaxY = maxWeeklyValue > goal ? (maxWeeklyValue * 1.2).toDouble() : (goal * 1.5).toDouble();

    return ConfettiOverlay(
      isGoalAchieved: total >= goal && goal > 0,
      child: Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
        title: const Text('Steps Tracker'),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.gear, size: 19),
            onPressed: () => _showGoalSheet(context, goal),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                // Main progress card
                GradientCard(
                  gradient: const LinearGradient(
                    colors: [Colors.blueAccent, Colors.lightBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  pedStatus == 'walking' 
                                      ? FontAwesomeIcons.personWalking 
                                      : (pedStatus == 'stopped' ? FontAwesomeIcons.person : FontAwesomeIcons.personRunning),
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  pedStatus.toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CircularProgressWidget(
                            progress: progress,
                            size: 100,
                            color: Colors.white,
                            strokeWidth: 8,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                                ),
                                const Text('done', style: TextStyle(color: Colors.white70, fontSize: 10)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$total steps',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24),
                                ),
                                Text(
                                  'of $goal steps goal',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  total >= goal
                                      ? 'Goal achieved!'
                                      : '${goal - total} steps remaining',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
                const SizedBox(height: 20),

                // Quick add buttons
                Text('Quick Add Steps', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Row(
                  children: _quickAmounts.map((stepsCount) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: _quickAmounts.last == stepsCount ? 0 : 8),
                      child: GestureDetector(
                        onTap: () => _addSteps(stepsCount),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              const FaIcon(FontAwesomeIcons.personWalking, size: 16, color: Colors.blueAccent),
                              const SizedBox(height: 4),
                              Text(
                                '+$stepsCount',
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )).toList(),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                const SizedBox(height: 20),

                // Custom amount
                OutlinedButton.icon(
                  onPressed: () => _showCustomAmountSheet(context),
                  icon: const FaIcon(FontAwesomeIcons.plus, size: 19),
                  label: const Text('Custom Entry'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                    side: const BorderSide(color: Colors.blueAccent),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                const SizedBox(height: 24),

                // Weekly chart
                const SectionHeader(title: 'This Week'),
                const SizedBox(height: 12),
                GlassCard(
                  child: SizedBox(
                    height: 140,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: chartMaxY,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                                return Text(
                                  days[value.toInt() % 7],
                                  style: TextStyle(color: context.textSecondary, fontSize: 11),
                                );
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: weeklyData.entries.toList().asMap().entries.map((entry) {
                          final i = entry.key;
                          final steps = entry.value.value.toDouble();
                          final isToday = i == 6;
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: steps,
                                gradient: isToday ? const LinearGradient(colors: [Colors.blueAccent, Colors.lightBlue]) : null,
                                color: isToday ? null : Colors.blueAccent.withOpacity(0.4),
                                width: 24,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 24),

                // Today's logs
                const SectionHeader(title: "Today's Logs"),
                const SizedBox(height: 12),
                if (logs.isEmpty)
                  GlassCard(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text('No steps logged yet today. Let\'s get moving!',
                          style: TextStyle(color: context.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                else
                  ...logs.asMap().entries.map((entry) {
                    final log = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GlassCard(
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(child: FaIcon(FontAwesomeIcons.personWalking, size: 16, color: Colors.blueAccent)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${log.steps} steps',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    'Logged at ${_formatTime(log.date)}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: FaIcon(FontAwesomeIcons.trash, size: 14, color: context.textMuted),
                              onPressed: () => ref.read(stepsProvider.notifier).deleteStepLog(log.id),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: entry.key * 50)),
                    );
                  }),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    ));
  }

  void _addSteps(int steps) {
    final log = StepLog(
      id: const Uuid().v4(),
      date: DateTime.now(),
      steps: steps,
      caloriesBurned: (steps * 0.04).toInt(), // Roughly 40 cals per 1000 steps
      distanceKm: steps * 0.000762, // Roughly 0.76 km per 1000 steps
    );
    ref.read(stepsProvider.notifier).addStepLog(log);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged $steps steps'), duration: const Duration(seconds: 1)),
    );
  }

  void _showCustomAmountSheet(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surface,
        title: const Text('Custom Entry'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Steps Count', suffixText: 'steps'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final steps = int.tryParse(ctrl.text.trim());
              if (steps != null && steps > 0) {
                _addSteps(steps);
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid number'), duration: Duration(seconds: 1)),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showGoalSheet(BuildContext context, int currentGoal) {
    int goal = currentGoal;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: context.surface,
          title: const Text('Daily Steps Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$goal', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.blueAccent)),
              Slider(
                value: goal.toDouble(),
                min: 1000,
                max: 30000,
                divisions: 29,
                activeColor: Colors.blueAccent,
                inactiveColor: context.border,
                onChanged: (v) => setState(() => goal = v.toInt()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final user = ref.read(userProvider);
                if (user != null) {
                  user.dailyStepsGoal = goal;
                  ref.read(userProvider.notifier).saveUser(user);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min';
  }
}
