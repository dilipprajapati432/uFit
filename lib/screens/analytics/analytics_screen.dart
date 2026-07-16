import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import 'package:ufit/theme/theme_ext.dart';
import 'dart:math';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  bool _isMonthly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        title: const Text('History & Analytics'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _isMonthly = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 110,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !_isMonthly ? Colors.orange : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text('7 Days', style: TextStyle(color: !_isMonthly ? Colors.white : context.textSecondary, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isMonthly = true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 110,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _isMonthly ? Colors.orange : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text('30 Days', style: TextStyle(color: _isMonthly ? Colors.white : context.textSecondary, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 20),
        children: [
          _buildStepsChart(context),
          const SizedBox(height: 24),
          _buildCaloriesChart(context),
          const SizedBox(height: 24),
          _buildSleepChart(context),
          const SizedBox(height: 24),
          _buildWaterChart(context),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildStepsChart(BuildContext context) {
    final logs = ref.watch(stepsProvider);
    final data = _aggregateData(logs, _isMonthly ? 30 : 7, (l) => l.date, (l) => l.steps.toDouble());
    final avg = data.where((d) => d > 0).isEmpty ? 0.0 : data.where((d) => d > 0).reduce((a, b) => a + b) / data.where((d) => d > 0).length;

    return _ChartCard(
      title: 'Steps',
      icon: '🚶',
      average: '${avg.toInt()} / day',
      chart: _buildBarChart(data, const LinearGradient(colors: [Colors.blueAccent, Colors.lightBlue])),
    );
  }

  Widget _buildCaloriesChart(BuildContext context) {
    final logs = ref.watch(nutritionProvider);
    final data = _aggregateData(logs, _isMonthly ? 30 : 7, (l) => l.date, (l) => l.calories);
    final avg = data.where((d) => d > 0).isEmpty ? 0.0 : data.where((d) => d > 0).reduce((a, b) => a + b) / data.where((d) => d > 0).length;

    return _ChartCard(
      title: 'Calories Consumed',
      icon: '🍕',
      average: '${avg.toInt()} kcal / day',
      chart: _buildBarChart(data, const LinearGradient(colors: [Colors.orange, Colors.deepOrangeAccent])),
    );
  }

  Widget _buildSleepChart(BuildContext context) {
    final logs = ref.watch(sleepProvider);
    final data = _aggregateData(logs, _isMonthly ? 30 : 7, (l) => l.bedTime, (l) => l.durationHours);
    final avg = data.where((d) => d > 0).isEmpty ? 0.0 : data.where((d) => d > 0).reduce((a, b) => a + b) / data.where((d) => d > 0).length;

    return _ChartCard(
      title: 'Sleep (Hours)',
      icon: '🌙',
      average: '${avg.toStringAsFixed(1)} hrs / day',
      chart: _buildLineChart(data, Colors.indigoAccent),
    );
  }

  Widget _buildWaterChart(BuildContext context) {
    final logs = ref.watch(waterProvider);
    final data = _aggregateData(logs, _isMonthly ? 30 : 7, (l) => l.timestamp, (l) => l.amountMl.toDouble());
    final avg = data.where((d) => d > 0).isEmpty ? 0.0 : data.where((d) => d > 0).reduce((a, b) => a + b) / data.where((d) => d > 0).length;

    return _ChartCard(
      title: 'Water (ml)',
      icon: '💧',
      average: '${avg.toInt()} ml / day',
      chart: _buildBarChart(data, const LinearGradient(colors: [Colors.cyan, Colors.blue])),
    );
  }

  // Helper to group and sum data by day going back N days
  List<double> _aggregateData<T>(List<T> items, int daysBack, DateTime Function(T) getDate, double Function(T) getValue) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    List<double> result = List.filled(daysBack, 0.0);

    for (var item in items) {
      final date = getDate(item);
      final itemDate = DateTime(date.year, date.month, date.day);
      final diff = today.difference(itemDate).inDays;
      if (diff >= 0 && diff < daysBack) {
        // diff 0 is today (last index). diff daysBack-1 is earliest day (first index)
        final index = (daysBack - 1) - diff;
        result[index] += getValue(item);
      }
    }
    return result;
  }

  Widget _buildBarChart(List<double> data, LinearGradient gradient) {
    final maxVal = data.isEmpty ? 1.0 : data.reduce(max);
    final yMax = maxVal == 0 ? 1.0 : maxVal * 1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: yMax,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => context.cardElevated,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.toInt().toString(),
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (data.length == 30 && value.toInt() % 5 != 0) return const SizedBox.shrink();
                final daysAgo = (data.length - 1) - value.toInt();
                final date = DateTime.now().subtract(Duration(days: daysAgo));
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(DateFormat('d MMM').format(date), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(data.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data[index],
                gradient: gradient,
                width: data.length == 30 ? 4 : 12,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              )
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLineChart(List<double> data, Color color) {
    final maxVal = data.isEmpty ? 1.0 : data.reduce(max);
    final yMax = maxVal == 0 ? 1.0 : maxVal * 1.2;

    return LineChart(
      LineChartData(
        maxY: yMax,
        minY: 0,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => context.cardElevated,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  spot.y.toStringAsFixed(1),
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < 0 || value.toInt() >= data.length) return const SizedBox.shrink();
                if (data.length == 30 && value.toInt() % 5 != 0) return const SizedBox.shrink();
                final daysAgo = (data.length - 1) - value.toInt();
                final date = DateTime.now().subtract(Duration(days: daysAgo));
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(DateFormat('d MMM').format(date), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(data.length, (index) => FlSpot(index.toDouble(), data[index])),
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: data.length == 7),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String icon;
  final String average;
  final Widget chart;

  const _ChartCard({required this.title, required this.icon, required this.average, required this.chart});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.border.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Avg: $average', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: context.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(child: chart),
        ],
      ),
    );
  }
}
