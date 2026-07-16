// lib/screens/sleep/sleep_screen.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'package:ufit/theme/theme_ext.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/notification_service.dart';

class SleepScreen extends ConsumerWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(sleepProvider);
    final last = ref.read(sleepProvider.notifier).lastNightSleep;
    final avgDuration = ref.read(sleepProvider.notifier).avgDurationLast7Days;
    final user = ref.watch(userProvider);
    final goal = user?.sleepGoalHours ?? 8;

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(title: Text('Sleep Tracker')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAppBottomSheet(context: context, child: const _LogSleepForm()),
        backgroundColor: AppColors.sleepColor,
        icon: Icon(Icons.add_rounded),
        label: Text('Log Sleep'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(height: 8),

                // Last night card
                GradientCard(
                  gradient: AppColors.sleepGradient,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text('🌙', style: TextStyle(fontSize: 28)),
                          SizedBox(width: 8),
                          Text('Last Night', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      SizedBox(height: 12),
                      if (last != null) ...[
                        Text(
                          last.durationFormatted,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 36),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${DateFormat('h:mm a').format(last.bedTime)} → ${DateFormat('h:mm a').format(last.wakeTime)}',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            ...List.generate(5, (i) => Icon(
                              i < last.qualityOutOf5 ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: Colors.white,
                              size: 20,
                            )),
                            SizedBox(width: 8),
                            Text(
                              _qualityLabel(last.qualityOutOf5),
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ] else
                        Text(
                          'No sleep logged yet. Tap below to log!',
                          style: TextStyle(color: Colors.white70),
                        ),
                    ],
                  ),
                ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
                SizedBox(height: 20),

                // Weekly stats
                SizedBox(
                  height: 130,
                  child: Row(
                    children: [
                      Expanded(
                        child: StatTile(
                          label: '7-Day Avg Sleep',
                          value: avgDuration.toStringAsFixed(1),
                          unit: 'hrs',
                          color: AppColors.sleepColor,
                          icon: Icons.bedtime_rounded,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: StatTile(
                          label: 'Sleep Goal',
                          value: '$goal',
                          unit: 'hrs',
                          color: AppColors.primary,
                          icon: Icons.flag_rounded,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms),
                SizedBox(height: 24),

                // Weekly chart
                const SectionHeader(title: 'Sleep Trend'),
                SizedBox(height: 12),
                GlassCard(
                  child: SizedBox(
                    height: 160,
                    child: logs.isEmpty
                        ? Center(
                            child: Text('Log your sleep to see trends', style: TextStyle(color: context.textSecondary)),
                          )
                        : LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: false),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final idx = value.toInt();
                                      final recentLogs = logs.take(7).toList().reversed.toList();
                                      if (idx < 0 || idx >= recentLogs.length) return SizedBox();
                                      return Text(
                                        DateFormat('E').format(recentLogs[idx].bedTime)[0],
                                        style: TextStyle(color: context.textSecondary, fontSize: 10),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: logs.take(7).toList().reversed.toList().asMap().entries.map((e) {
                                    return FlSpot(e.key.toDouble(), e.value.durationHours);
                                  }).toList(),
                                  isCurved: true,
                                  gradient: AppColors.sleepGradient,
                                  barWidth: 3,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [AppColors.sleepColor.withOpacity(0.3), AppColors.sleepColor.withOpacity(0.0)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ).animate().fadeIn(delay: 200.ms),
                SizedBox(height: 24),

                const SectionHeader(title: 'Sleep History'),
                SizedBox(height: 12),
              ]),
            ),
          ),
          if (logs.isEmpty)
            const SliverToBoxAdapter(child: SizedBox())
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final log = logs[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GlassCard(
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.sleepColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(child: Text('🌙', style: TextStyle(fontSize: 22))),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(DateFormat('EEE, MMM d').format(log.bedTime), style: Theme.of(context).textTheme.titleMedium),
                                  Text(log.durationFormatted, style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                            Row(
                              children: List.generate(5, (i) => Icon(
                                i < log.qualityOutOf5 ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: AppColors.accentYellow,
                                size: 14,
                              )),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: i * 50)),
                    );
                  },
                  childCount: logs.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  String _qualityLabel(int q) {
    switch (q) {
      case 1: return 'Poor';
      case 2: return 'Fair';
      case 3: return 'Okay';
      case 4: return 'Good';
      case 5: return 'Excellent';
      default: return 'Okay';
    }
  }
}

class _LogSleepForm extends ConsumerStatefulWidget {
  const _LogSleepForm();

  @override
  ConsumerState<_LogSleepForm> createState() => _LogSleepFormState();
}

class _LogSleepFormState extends ConsumerState<_LogSleepForm> {
  TimeOfDay _bedTime = const TimeOfDay(hour: 22, minute: 30);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 6, minute: 30);
  int _quality = 3;
  final _factors = <String>[];
  final _allFactors = ['Caffeine', 'Alcohol', 'Exercise', 'Stress', 'Screen time', 'Late meal'];

  @override
  void initState() {
    super.initState();
    _loadInitialTimes();
  }

  Future<void> _loadInitialTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final h = prefs.getInt('sleep_reminder_hour') ?? 22;
      final m = prefs.getInt('sleep_reminder_minute') ?? 30;
      if (mounted) {
        setState(() {
          _bedTime = TimeOfDay(hour: h, minute: m);
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final duration = _calculateDuration();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Text('Log Sleep', style: Theme.of(context).textTheme.headlineSmall),
        SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: _TimePickerCard(
                label: 'Bed Time',
                time: _bedTime,
                icon: '🛏️',
                onTap: () async {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: _bedTime,
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.dark(
                            primary: AppColors.sleepColor,
                            onPrimary: Colors.white,
                            surface: context.card,
                            onSurface: context.text,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (t != null) setState(() => _bedTime = t);
                },
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _TimePickerCard(
                label: 'Wake Time',
                time: _wakeTime,
                icon: '☀️',
                onTap: () async {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: _wakeTime,
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.dark(
                            primary: AppColors.sleepColor,
                            onPrimary: Colors.white,
                            surface: context.card,
                            onSurface: context.text,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (t != null) setState(() => _wakeTime = t);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        GlassCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bedtime_rounded, color: AppColors.sleepColor),
              SizedBox(width: 8),
              Text(
                'Total: ${duration.toStringAsFixed(1)} hours',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.sleepColor),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),

        Text('Sleep Quality', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (i) {
            final score = i + 1;
            return GestureDetector(
              onTap: () => setState(() => _quality = score),
              child: Column(
                children: [
                  Text(_sleepQualityEmoji(score), style: TextStyle(fontSize: _quality == score ? 32 : 24)),
                  SizedBox(height: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _quality == score ? AppColors.sleepColor : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        SizedBox(height: 20),

        Text('What affected your sleep? (optional)', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allFactors.map((f) {
            final isSelected = _factors.contains(f);
            return GestureDetector(
              onTap: () => setState(() => isSelected ? _factors.remove(f) : _factors.add(f)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.sleepColor.withOpacity(0.15) : context.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? AppColors.sleepColor : context.border),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    color: isSelected ? AppColors.sleepColor : context.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.sleepColor),
            child: Text('Save Sleep Log'),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  double _calculateDuration() {
    final now = DateTime.now();
    var bed = DateTime(now.year, now.month, now.day, _bedTime.hour, _bedTime.minute);
    var wake = DateTime(now.year, now.month, now.day, _wakeTime.hour, _wakeTime.minute);
    if (wake.isBefore(bed)) wake = wake.add(const Duration(days: 1));
    return wake.difference(bed).inMinutes / 60.0;
  }

  String _sleepQualityEmoji(int q) {
    switch (q) {
      case 1: return '😫';
      case 2: return '🥱';
      case 3: return '😐';
      case 4: return '🙂';
      case 5: return '🤩';
      default: return '😐';
    }
  }

  void _save() async {
    final now = DateTime.now();
    var bed = DateTime(now.year, now.month, now.day, _bedTime.hour, _bedTime.minute).subtract(const Duration(days: 1));
    var wake = DateTime(now.year, now.month, now.day, _wakeTime.hour, _wakeTime.minute);

    final log = SleepLog(
      id: const Uuid().v4(),
      bedTime: bed,
      wakeTime: wake,
      qualityOutOf5: _quality,
      factors: _factors,
    );
    ref.read(sleepProvider.notifier).addLog(log);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('sleep_reminder_hour', _bedTime.hour);
      await prefs.setInt('sleep_reminder_minute', _bedTime.minute);

      final remindersOn = prefs.getBool('sleep_reminders_on') ?? false;
      if (remindersOn) {
        await NotificationService.scheduleSleepReminder(_bedTime.hour, _bedTime.minute);
      }
    } catch (_) {}

    if (mounted) Navigator.pop(context);
  }
}

class _TimePickerCard extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final String icon;
  final VoidCallback onTap;

  const _TimePickerCard({required this.label, required this.time, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        child: Column(
          children: [
            Text(icon, style: TextStyle(fontSize: 24)),
            SizedBox(height: 6),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            SizedBox(height: 4),
            Text(
              time.format(context),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.sleepColor),
            ),
          ],
        ),
      ),
    );
  }
}
