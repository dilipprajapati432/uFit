// lib/screens/water/water_screen.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/confetti_overlay.dart';
import 'package:ufit/theme/theme_ext.dart';

class WaterScreen extends ConsumerStatefulWidget {
  const WaterScreen({super.key});

  @override
  ConsumerState<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends ConsumerState<WaterScreen> {
  final _quickAmounts = [150, 200, 250, 350, 500];
  final _drinkTypes = {'💧 Water': 'water', '☕ Coffee': 'coffee', '🍵 Tea': 'tea', '🧃 Juice': 'juice', '🥛 Milk': 'milk'};
  String _selectedDrink = 'water';

  Map<DateTime, int> _computeWeeklyData(List<WaterLog> logs) {
    final result = <DateTime, int>{};
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dayLogs = logs.where((l) =>
          l.timestamp.year == date.year &&
          l.timestamp.month == date.month &&
          l.timestamp.day == date.day);
      result[date] = dayLogs.fold(0, (s, l) => s + l.amountMl);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(waterProvider);
    final user = ref.watch(userProvider);
    final goal = user?.dailyWaterGoalMl ?? 2500;
    final total = logs.fold<int>(0, (s, l) => s + l.amountMl);
    final progress = (total / goal).clamp(0.0, 1.0);
    // Weekly data computed inline from all logs in the box
    final weeklyData = _computeWeeklyData(logs);
    final maxWeeklyValue = weeklyData.values.fold<int>(0, (max, v) => v > max ? v : max);
    final chartMaxY = maxWeeklyValue > goal ? (maxWeeklyValue * 1.2).toDouble() : (goal * 1.2).toDouble();

    return ConfettiOverlay(
      isGoalAchieved: total >= goal && goal > 0,
      child: Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
        title: Text('Water Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_rounded),
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
                SizedBox(height: 8),

                // Main progress card
                GradientCard(
                  gradient: AppColors.waterGradient,
                  child: Column(
                    children: [
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
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                                ),
                                Text('done', style: TextStyle(color: Colors.white70, fontSize: 10)),
                              ],
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${total}ml',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28),
                                ),
                                Text(
                                  'of ${goal}ml goal',
                                  style: TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  total >= goal
                                      ? '🎉 Goal achieved!'
                                      : '${goal - total}ml remaining',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // Wave-like progress bar
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
                SizedBox(height: 20),

                // Drink type selector
                Text('Drink Type', style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _drinkTypes.entries.map((e) {
                      final isSelected = _selectedDrink == e.value;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedDrink = e.value),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.waterColor.withOpacity(0.2) : context.card,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.waterColor : context.border,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Text(
                              e.key,
                              style: TextStyle(
                                color: isSelected ? AppColors.waterColor : context.textSecondary,
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 20),

                // Quick add buttons
                Text('Quick Add', style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 10),
                Row(
                  children: _quickAmounts.map((ml) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: _quickAmounts.last == ml ? 0 : 8),
                      child: GestureDetector(
                        onTap: () => _addWater(ml),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.waterColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.waterColor.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Text('💧', style: TextStyle(fontSize: 20)),
                              SizedBox(height: 4),
                              Text(
                                '${ml}ml',
                                style: TextStyle(
                                  color: AppColors.waterColor,
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
                SizedBox(height: 20),

                // Custom amount
                OutlinedButton.icon(
                  onPressed: () => _showCustomAmountSheet(context),
                  icon: Icon(Icons.add_rounded),
                  label: Text('Custom Amount'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.waterColor,
                    side: const BorderSide(color: AppColors.waterColor),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                SizedBox(height: 24),

                // Weekly chart
                const SectionHeader(title: 'This Week'),
                SizedBox(height: 12),
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
                          final water = entry.value.value.toDouble();
                          final isToday = i == 6;
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: water,
                                gradient: isToday ? AppColors.waterGradient : null,
                                color: isToday ? null : AppColors.waterColor.withOpacity(0.4),
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
                SizedBox(height: 24),

                // Today's logs
                const SectionHeader(title: "Today's Logs"),
                SizedBox(height: 12),
                if (logs.isEmpty)
                  GlassCard(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('No logs yet today. Stay hydrated! 💧',
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
                                color: AppColors.waterColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(child: Text('💧', style: TextStyle(fontSize: 20))),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${log.amountMl}ml ${log.drinkType}',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    _formatTime(log.timestamp),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded, size: 18, color: context.textMuted),
                              onPressed: () => ref.read(waterProvider.notifier).deleteWaterLog(log.id),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: entry.key * 50)),
                    );
                  }),
                SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    ));
  }

  void _addWater(int ml) {
    final log = WaterLog(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      amountMl: ml,
      drinkType: _selectedDrink,
    );
    ref.read(waterProvider.notifier).addWaterLog(log);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${ml}ml 💧'), duration: const Duration(seconds: 1)),
    );
  }

  void _showCustomAmountSheet(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surface,
        title: Text('Custom Amount'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Amount (ml)', suffixText: 'ml'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final ml = int.tryParse(ctrl.text.trim());
              if (ml != null && ml > 0) {
                _addWater(ml);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Water logged! 💧')));
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid number'), duration: Duration(seconds: 1)),
                );
              }
            },
            child: Text('Add'),
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
          title: Text('Daily Water Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${goal}ml', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.waterColor)),
              Slider(
                value: goal.toDouble(),
                min: 500,
                max: 5000,
                divisions: 90,
                activeColor: AppColors.waterColor,
                inactiveColor: context.border,
                onChanged: (v) => setState(() => goal = v.toInt()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final user = ref.read(userProvider);
                if (user != null) {
                  user.dailyWaterGoalMl = goal;
                  ref.read(userProvider.notifier).saveUser(user);
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Water goal updated! 💧')));
              },
              child: Text('Save'),
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
