// lib/screens/mood/mood_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'package:ufit/theme/theme_ext.dart';

class MoodScreen extends ConsumerWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(moodProvider);
    final todayMood = ref.read(moodProvider.notifier).todayMood;
    final avgMood = ref.read(moodProvider.notifier).avgMoodLast7Days;

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(title: const Text('Mood Tracker')),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                if (todayMood == null) ...[
                  Text('How are you feeling today?', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  _MoodPicker(
                    onSelected: (score, emotions, notes) {
                      final log = MoodLog(
                        id: const Uuid().v4(),
                        timestamp: DateTime.now(),
                        moodScore: score,
                        moodEmoji: MoodLog.emojiForScore(score),
                        emotions: emotions,
                        notes: notes,
                      );
                      ref.read(moodProvider.notifier).addLog(log);
                    },
                  ).animate().fadeIn().slideY(begin: 0.2),
                ] else
                  GradientCard(
                    gradient: AppColors.moodGradient,
                    child: Column(
                      children: [
                        Text(todayMood.moodEmoji, style: const TextStyle(fontSize: 56)),
                        const SizedBox(height: 8),
                        Text(
                          MoodLog.labelForScore(todayMood.moodScore),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        const Text('Today\'s mood logged ✓', style: TextStyle(color: Colors.white70)),
                        if (todayMood.emotions.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            alignment: WrapAlignment.center,
                            children: todayMood.emotions.map((e) => Chip(
                              label: Text(e, style: const TextStyle(color: Colors.white, fontSize: 11)),
                              backgroundColor: Colors.white.withOpacity(0.2),
                              side: BorderSide.none,
                            )).toList(),
                          ),
                        ],
                      ],
                    ),
                  ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
                const SizedBox(height: 24),

                SizedBox(
                  height: 130,
                  child: Row(
                    children: [
                      Expanded(
                        child: StatTile(
                          label: '7-Day Avg Mood',
                          value: avgMood.toStringAsFixed(1),
                          unit: '/5',
                          color: AppColors.moodColor,
                          icon: Icons.sentiment_satisfied_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatTile(
                          label: 'Entries Logged',
                          value: '${logs.length}',
                          color: AppColors.primary,
                          icon: FontAwesomeIcons.calendar,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 24),

                const SectionHeader(title: 'Mood History'),
                const SizedBox(height: 12),
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
                            Text(log.moodEmoji, style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(MoodLog.labelForScore(log.moodScore), style: Theme.of(context).textTheme.titleMedium),
                                  Text(
                                    DateFormat('EEE, MMM d · h:mm a').format(log.timestamp),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
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
}

class _MoodPicker extends StatefulWidget {
  final Function(int score, List<String> emotions, String? notes) onSelected;
  const _MoodPicker({required this.onSelected});

  @override
  State<_MoodPicker> createState() => _MoodPickerState();
}

class _MoodPickerState extends State<_MoodPicker> {
  int? _score;
  final _emotions = <String>[];
  final _notesCtrl = TextEditingController();
  final _allEmotions = ['Happy', 'Anxious', 'Calm', 'Stressed', 'Excited', 'Tired', 'Grateful', 'Lonely', 'Energetic', 'Sad'];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (i) {
              final score = i + 1;
              final isSelected = _score == score;
              return GestureDetector(
                onTap: () => setState(() => _score = score),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.moodColor.withOpacity(0.2) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    MoodLog.emojiForScore(score),
                    style: TextStyle(fontSize: isSelected ? 36 : 28),
                  ),
                ),
              );
            }),
          ),
          if (_score != null) ...[
            const SizedBox(height: 20),
            Text(MoodLog.labelForScore(_score!), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.moodColor)),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('What\'s contributing to this?', style: Theme.of(context).textTheme.bodySmall),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allEmotions.map((e) {
                final isSelected = _emotions.contains(e);
                return GestureDetector(
                  onTap: () => setState(() => isSelected ? _emotions.remove(e) : _emotions.add(e)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.moodColor.withOpacity(0.2) : context.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? AppColors.moodColor : context.border),
                    ),
                    child: Text(
                      e,
                      style: TextStyle(
                        color: isSelected ? AppColors.moodColor : context.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(hintText: 'Add a note (optional)'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSelected(_score!, _emotions, _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim());
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.moodColor, foregroundColor: Colors.black87),
                child: const Text('Save Mood'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }
}
