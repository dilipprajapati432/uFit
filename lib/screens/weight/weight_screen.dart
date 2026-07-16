import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'package:ufit/theme/theme_ext.dart';

class WeightScreen extends ConsumerWidget {
  const WeightScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(weightProvider);
    final latest = ref.read(weightProvider.notifier).latestLog;
    final change = ref.read(weightProvider.notifier).changeFromStart;
    final user = ref.watch(userProvider);
    final target = user?.targetWeightKg ?? 70;
    final height = user?.heightCm ?? 170;

    final bmi = latest != null ? latest.weightKg / ((height / 100) * (height / 100)) : null;

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(title: Text('Weight Tracker')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAppBottomSheet(context: context, child: const _LogWeightForm()),
        backgroundColor: AppColors.weightColor,
        icon: Icon(Icons.add_rounded),
        label: Text('Log Weight'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(height: 8),

                // Current weight card
                GradientCard(
                  gradient: AppColors.weightGradient,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Current Weight', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
                            SizedBox(height: 4),
                            Text(
                              latest != null ? '${latest.weightKg.toStringAsFixed(1)} kg' : '--',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 32),
                            ),
                            if (change != null) ...[
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    change > 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  Text(
                                    '${change.abs().toStringAsFixed(1)} kg from start',
                                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text('🎯', style: TextStyle(fontSize: 20)),
                            SizedBox(height: 4),
                            Text(
                              '${target.toStringAsFixed(1)} kg',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            Text('Goal', style: TextStyle(color: Colors.white70, fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
                SizedBox(height: 16),

                // BMI card
                if (bmi != null)
                  GlassCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Body Mass Index (BMI)', style: Theme.of(context).textTheme.bodySmall),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    bmi.toStringAsFixed(1),
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: _bmiColor(bmi)),
                                  ),
                                  SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _bmiColor(bmi).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _bmiCategory(bmi),
                                      style: TextStyle(color: _bmiColor(bmi), fontSize: 11, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                SizedBox(height: 24),

                // Chart
                const SectionHeader(title: 'Weight Trend'),
                SizedBox(height: 12),
                GlassCard(
                  child: SizedBox(
                    height: 180,
                    child: logs.length < 2
                        ? Center(
                            child: Text('Log at least 2 entries to see your trend', style: TextStyle(color: context.textSecondary)),
                          )
                        : LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 2,
                                getDrawingHorizontalLine: (v) => FlLine(color: context.border, strokeWidth: 1),
                              ),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      final recent = logs.take(10).toList().reversed.toList();
                                      final idx = value.toInt();
                                      if (idx < 0 || idx >= recent.length) return SizedBox();
                                      return Text(
                                        DateFormat('d/M').format(recent[idx].date),
                                        style: TextStyle(color: context.textSecondary, fontSize: 9),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 36,
                                    getTitlesWidget: (value, meta) => Text(
                                      value.toInt().toString(),
                                      style: TextStyle(color: context.textSecondary, fontSize: 10),
                                    ),
                                  ),
                                ),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: logs.take(10).toList().reversed.toList().asMap().entries.map((e) {
                                    return FlSpot(e.key.toDouble(), e.value.weightKg);
                                  }).toList(),
                                  isCurved: true,
                                  gradient: AppColors.weightGradient,
                                  barWidth: 3,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [AppColors.weightColor.withOpacity(0.3), AppColors.weightColor.withOpacity(0.0)],
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

                const SectionHeader(title: 'History'),
                SizedBox(height: 12),
              ]),
            ),
          ),
          if (logs.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: EmptyState(
                  emoji: '⚖️',
                  title: 'No weight logs yet',
                  subtitle: 'Start tracking your weight to see your progress over time',
                ),
              ),
            )
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
                            GestureDetector(
                              onTap: () {
                                if (log.photoPath != null) {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => Dialog(
                                      backgroundColor: Colors.transparent,
                                      child: Stack(
                                        alignment: Alignment.topRight,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(16),
                                            child: Image.file(File(log.photoPath!), fit: BoxFit.contain),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.close, color: Colors.white),
                                            onPressed: () => Navigator.pop(ctx),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.weightColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  image: log.photoPath != null
                                      ? DecorationImage(
                                          image: FileImage(File(log.photoPath!)),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: log.photoPath == null ? Center(child: Text('⚖️', style: TextStyle(fontSize: 20))) : null,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${log.weightKg.toStringAsFixed(1)} kg', style: Theme.of(context).textTheme.titleMedium),
                                  Text(DateFormat('EEE, MMM d').format(log.date), style: Theme.of(context).textTheme.bodySmall),
                                  if (log.chestCm != null || log.waistCm != null || log.armCm != null || log.legCm != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        [
                                          if (log.chestCm != null) 'Chest: ${log.chestCm}',
                                          if (log.waistCm != null) 'Waist: ${log.waistCm}',
                                          if (log.armCm != null) 'Arms: ${log.armCm}',
                                          if (log.legCm != null) 'Legs: ${log.legCm}',
                                        ].join(' • '),
                                        style: TextStyle(color: context.textSecondary, fontSize: 10),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded, size: 18, color: context.textMuted),
                              onPressed: () => ref.read(weightProvider.notifier).deleteLog(log.id),
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

  Color _bmiColor(double bmi) {
    if (bmi < 18.5) return AppColors.accentOrange;
    if (bmi < 25) return AppColors.success;
    if (bmi < 30) return AppColors.accentOrange;
    return AppColors.error;
  }

  String _bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}

class _LogWeightForm extends ConsumerStatefulWidget {
  const _LogWeightForm();

  @override
  ConsumerState<_LogWeightForm> createState() => _LogWeightFormState();
}

class _LogWeightFormState extends ConsumerState<_LogWeightForm> {
  double _weight = 70;
  final _notesCtrl = TextEditingController();
  final _chestCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  final _armCtrl = TextEditingController();
  final _legCtrl = TextEditingController();
  String? _photoPath;
  bool _isSavingImage = false;

  @override
  void initState() {
    super.initState();
    // Read user weight once on init, not on every build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userProvider);
      if (mounted && user != null && user.weightKg != null) {
        setState(() => _weight = user.weightKg!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          Text('Log Weight', style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 24),

          Center(
            child: Text(
              '${_weight.toStringAsFixed(1)} kg',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.weightColor),
            ),
          ),
          SizedBox(height: 16),
          Slider(
            value: _weight,
            min: 30,
            max: 200,
            divisions: 1700,
            activeColor: AppColors.weightColor,
            inactiveColor: context.border,
            onChanged: (v) => setState(() => _weight = double.parse(v.toStringAsFixed(1))),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filled(
                onPressed: () => setState(() => _weight = double.parse((_weight - 0.1).toStringAsFixed(1))),
                icon: Icon(Icons.remove),
                style: IconButton.styleFrom(backgroundColor: context.card),
              ),
              SizedBox(width: 20),
              IconButton.filled(
                onPressed: () => setState(() => _weight = double.parse((_weight + 0.1).toStringAsFixed(1))),
                icon: Icon(Icons.add),
                style: IconButton.styleFrom(backgroundColor: context.card),
              ),
            ],
          ),
          SizedBox(height: 20),

          TextField(
            controller: _notesCtrl,
            decoration: const InputDecoration(labelText: 'Notes (optional)'),
          ),
          SizedBox(height: 20),
          
          Text('Body Measurements (optional)', style: Theme.of(context).textTheme.titleSmall),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: TextField(controller: _chestCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Chest (cm)', filled: true))),
              SizedBox(width: 12),
              Expanded(child: TextField(controller: _waistCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Waist (cm)', filled: true))),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextField(controller: _armCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Arms (cm)', filled: true))),
              SizedBox(width: 12),
              Expanded(child: TextField(controller: _legCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Legs (cm)', filled: true))),
            ],
          ),
          SizedBox(height: 20),

          // Progress Photo Section
          if (_photoPath != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(_photoPath!), height: 120, width: double.infinity, fit: BoxFit.cover),
            ),
            SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => setState(() => _photoPath = null),
              icon: Icon(Icons.delete_outline, color: AppColors.error),
              label: Text('Remove Photo', style: TextStyle(color: AppColors.error)),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isSavingImage ? null : _pickImage,
                icon: _isSavingImage 
                    ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(Icons.camera_alt_outlined),
                label: Text('Add Progress Photo'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: context.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
          
          SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _save(),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.weightColor),
              child: Text('Save Weight'),
            ),
          ),
          SizedBox(height: 20),
        ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _isSavingImage = true);
      try {
        final dir = await getApplicationDocumentsDirectory();
        final fileName = '${const Uuid().v4()}.jpg';
        final savedImage = await File(pickedFile.path).copy('${dir.path}/$fileName');
        setState(() => _photoPath = savedImage.path);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save image')));
        }
      } finally {
        if (mounted) setState(() => _isSavingImage = false);
      }
    }
  }

  void _save() {
    final log = WeightLog(
      id: const Uuid().v4(),
      date: DateTime.now(),
      weightKg: _weight,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      photoPath: _photoPath,
      chestCm: double.tryParse(_chestCtrl.text),
      waistCm: double.tryParse(_waistCtrl.text),
      armCm: double.tryParse(_armCtrl.text),
      legCm: double.tryParse(_legCtrl.text),
    );
    ref.read(weightProvider.notifier).addLog(log);

    // Update user's current weight too
    final user = ref.read(userProvider);
    if (user != null) {
      user.weightKg = _weight;
      ref.read(userProvider.notifier).saveUser(user);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Weight logged! ⚖️')));
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _chestCtrl.dispose();
    _waistCtrl.dispose();
    _armCtrl.dispose();
    _legCtrl.dispose();
    super.dispose();
  }
}
