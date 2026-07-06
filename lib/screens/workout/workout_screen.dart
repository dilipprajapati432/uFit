// lib/screens/workout/workout_screen.dart
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

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(workoutProvider);
    final weekSessions = ref.read(workoutProvider.notifier).getThisWeekSessions();
    final weekMinutes = ref.read(workoutProvider.notifier).getThisWeekMinutes();
    final weekCalories = ref.read(workoutProvider.notifier).getThisWeekCalories();

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(title: const Text('Workouts')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewWorkoutSheet(context),
        backgroundColor: AppColors.workoutColor,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Workout'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                // Weekly summary
                GradientCard(
                  gradient: AppColors.workoutGradient,
                  child: Row(
                    children: [
                      _WeekStatItem(value: '${weekSessions.length}', label: 'Workouts'),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _WeekStatItem(value: '$weekMinutes', label: 'Minutes'),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _WeekStatItem(value: '$weekCalories', label: 'Calories'),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.2),
                const SizedBox(height: 24),

                // Quick start templates
                Text('Quick Start', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    children: [
                      _QuickStartCard(emoji: '🏋️', label: 'Strength', type: 'strength', onTap: () => _showNewWorkoutSheet(context, prefilType: 'strength')),
                      _QuickStartCard(emoji: '🏃', label: 'Cardio', type: 'cardio', onTap: () => _showNewWorkoutSheet(context, prefilType: 'cardio')),
                      _QuickStartCard(emoji: '🔥', label: 'HIIT', type: 'hiit', onTap: () => _showNewWorkoutSheet(context, prefilType: 'hiit')),
                      _QuickStartCard(emoji: '🧘', label: 'Yoga', type: 'yoga', onTap: () => _showNewWorkoutSheet(context, prefilType: 'yoga')),
                      _QuickStartCard(emoji: '⚽', label: 'Sports', type: 'sports', onTap: () => _showNewWorkoutSheet(context, prefilType: 'sports')),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 24),

                const SectionHeader(title: 'History'),
                const SizedBox(height: 8),
              ]),
            ),
          ),
          if (sessions.isEmpty)
            const SliverFillRemaining(
              child: EmptyState(
                emoji: '💪',
                title: 'No workouts yet',
                subtitle: 'Start your first workout to begin tracking your fitness journey',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final session = sessions[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _WorkoutHistoryCard(
                        session: session,
                        onDelete: () => ref.read(workoutProvider.notifier).deleteSession(session.id),
                      ).animate().fadeIn(delay: Duration(milliseconds: i * 60)),
                    );
                  },
                  childCount: sessions.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showNewWorkoutSheet(BuildContext context, {String? prefilType, WorkoutSession? existingSession}) {
    showAppBottomSheet(
      context: context,
      child: _NewWorkoutForm(initialType: prefilType, existingSession: existingSession),
    );
  }
}

class _WeekStatItem extends StatelessWidget {
  final String value;
  final String label;
  const _WeekStatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _QuickStartCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String type;
  final VoidCallback onTap;

  const _QuickStartCard({required this.emoji, required this.label, required this.type, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _WorkoutHistoryCard extends StatelessWidget {
  final WorkoutSession session;
  final VoidCallback onDelete;

  const _WorkoutHistoryCard({required this.session, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.workoutColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(_emojiForType(session.type), style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.name, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      DateFormat('MMM d, h:mm a').format(session.startTime),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: Icon(Icons.more_vert_rounded, color: context.textMuted, size: 20),
                color: context.surface,
                itemBuilder: (_) => [
                  PopupMenuItem(
                    onTap: () {
                      // pop the menu first
                      Future.delayed(Duration.zero, () {
                        if (context.mounted) {
                          showAppBottomSheet(
                            context: context,
                            child: _NewWorkoutForm(existingSession: session),
                          );
                        }
                      });
                    },
                    child: const Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Edit')]),
                  ),
                  PopupMenuItem(
                    onTap: onDelete,
                    child: const Row(children: [Icon(Icons.delete_outline, color: AppColors.error, size: 18), SizedBox(width: 8), Text('Delete')]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MiniStat(icon: Icons.timer_outlined, value: '${session.durationMinutes} min'),
              const SizedBox(width: 16),
              _MiniStat(icon: Icons.local_fire_department_outlined, value: '${session.caloriesBurned ?? 0} cal'),
              const SizedBox(width: 16),
              _MiniStat(icon: Icons.fitness_center, value: '${session.exercises.length} exercises'),
            ],
          ),
        ],
      ),
    );
  }

  String _emojiForType(String type) {
    switch (type) {
      case 'strength': return '🏋️';
      case 'cardio': return '🏃';
      case 'hiit': return '🔥';
      case 'yoga': return '🧘';
      case 'sports': return '⚽';
      default: return '💪';
    }
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  const _MiniStat({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: context.textSecondary),
        const SizedBox(width: 4),
        Text(value, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _NewWorkoutForm extends ConsumerStatefulWidget {
  final String? initialType;
  final WorkoutSession? existingSession;
  const _NewWorkoutForm({this.initialType, this.existingSession});

  @override
  ConsumerState<_NewWorkoutForm> createState() => _NewWorkoutFormState();
}

class _NewWorkoutFormState extends ConsumerState<_NewWorkoutForm> {
  final _nameCtrl = TextEditingController();
  final _exerciseCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();
  late String _type;
  int _duration = 30;
  int _rating = 0;
  List<ExerciseSet> _exercises = [];

  final _types = ['strength', 'cardio', 'hiit', 'yoga', 'flexibility', 'sports'];

  @override
  void initState() {
    super.initState();
    if (widget.existingSession != null) {
      final s = widget.existingSession!;
      _type = s.type;
      _nameCtrl.text = s.name;
      _duration = s.durationMinutes;
      _caloriesCtrl.text = s.caloriesBurned?.toString() ?? '';
      _rating = s.ratingOutOf5;
      _exercises = List.from(s.exercises);
    } else {
      _type = widget.initialType ?? 'strength';
      _nameCtrl.text = _defaultName(_type);
    }
  }

  String _defaultName(String type) {
    switch (type) {
      case 'strength': return 'Strength Training';
      case 'cardio': return 'Cardio Session';
      case 'hiit': return 'HIIT Workout';
      case 'yoga': return 'Yoga Session';
      case 'sports': return 'Sports Activity';
      default: return 'Workout';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Log Workout', style: Theme.of(context).textTheme.headlineSmall),
            TextButton.icon(
              onPressed: _showTemplates,
              icon: const Icon(Icons.file_copy_outlined, size: 18),
              label: const Text('Templates'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Type selector
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _types.map((t) {
            final isSelected = _type == t;
            return GestureDetector(
              onTap: () => setState(() { _type = t; _nameCtrl.text = _defaultName(t); }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.workoutColor.withOpacity(0.15) : context.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? AppColors.workoutColor : context.border),
                ),
                child: Text(
                  t[0].toUpperCase() + t.substring(1),
                  style: TextStyle(
                    color: isSelected ? AppColors.workoutColor : context.textSecondary,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Workout Name')),
        const SizedBox(height: 16),

        Text('Duration: $_duration min', style: Theme.of(context).textTheme.titleMedium),
        Slider(
          value: _duration.toDouble(),
          min: 5,
          max: 180,
          divisions: 35,
          activeColor: AppColors.workoutColor,
          inactiveColor: context.border,
          onChanged: (v) => setState(() => _duration = v.toInt()),
        ),

        TextField(
          controller: _caloriesCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Calories Burned (optional)'),
        ),
        const SizedBox(height: 16),

        // Rating
        Text('How did it feel?', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (i) => GestureDetector(
            onTap: () => setState(() => _rating = i + 1),
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(
                i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: AppColors.accentYellow,
                size: 32,
              ),
            ),
          )),
        ),
        const SizedBox(height: 20),

        // Exercises (if strength type)
        if (_type == 'strength') ...[
          Text('Exercises', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          ..._exercises.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Expanded(child: Text(e.exerciseName, style: Theme.of(context).textTheme.bodyMedium)),
                  IconButton(
                    icon: Icon(Icons.close, size: 16, color: context.textMuted),
                    onPressed: () => setState(() => _exercises.remove(e)),
                  ),
                ],
              ),
            ),
          )),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _exerciseCtrl,
                  decoration: const InputDecoration(hintText: 'Add exercise (e.g. Bench Press)'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () {
                  if (_exerciseCtrl.text.trim().isEmpty) return;
                  setState(() {
                    _exercises.add(ExerciseSet(
                      exerciseName: _exerciseCtrl.text.trim(),
                      exerciseType: 'reps',
                      muscleGroup: 'general',
                    ));
                    _exerciseCtrl.clear();
                  });
                },
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(backgroundColor: AppColors.workoutColor),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _saveAsTemplate,
                style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.workoutColor)),
                child: const Text('Save Template', style: TextStyle(color: AppColors.workoutColor)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.workoutColor),
                child: const Text('Save Workout'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _showTemplates() {
    final templates = ref.read(workoutTemplatesProvider);
    if (templates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No templates saved yet.')));
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: context.bg,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Saved Templates', style: Theme.of(context).textTheme.titleLarge),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: templates.length,
              itemBuilder: (ctx, i) {
                final t = templates[i];
                return ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: Text(t.name),
                  subtitle: Text('${t.exercises.length} exercises'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () {
                      ref.read(workoutTemplatesProvider.notifier).deleteTemplate(t.id);
                      Navigator.pop(ctx);
                    },
                  ),
                  onTap: () {
                    setState(() {
                      _type = t.type;
                      _nameCtrl.text = t.name;
                      _exercises = t.exercises.map((e) => ExerciseSet(
                        exerciseName: e.exerciseName,
                        exerciseType: e.exerciseType,
                        muscleGroup: e.muscleGroup,
                        sets: e.sets.map((s) => SetEntry(
                          reps: s.reps, weightKg: s.weightKg, durationSeconds: s.durationSeconds, distanceKm: s.distanceKm
                        )).toList(),
                        notes: e.notes,
                      )).toList();
                    });
                    Navigator.pop(ctx);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _saveAsTemplate() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a name for the template')));
      return;
    }
    
    final clonedExercises = _exercises.map((e) => ExerciseSet(
      exerciseName: e.exerciseName,
      exerciseType: e.exerciseType,
      muscleGroup: e.muscleGroup,
      sets: e.sets.map((s) => SetEntry(
        reps: s.reps, weightKg: s.weightKg, durationSeconds: s.durationSeconds, distanceKm: s.distanceKm
      )).toList(),
      notes: e.notes,
    )).toList();

    final template = WorkoutTemplate(
      id: const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      type: _type,
      exercises: clonedExercises,
    );
    ref.read(workoutTemplatesProvider.notifier).addTemplate(template);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Template saved successfully!')));
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) return;
    
    final session = WorkoutSession(
      id: widget.existingSession?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      type: _type,
      startTime: widget.existingSession?.startTime ?? DateTime.now(),
      endTime: widget.existingSession?.startTime.add(Duration(minutes: _duration)) ?? DateTime.now().add(Duration(minutes: _duration)),
      durationMinutes: _duration,
      caloriesBurned: int.tryParse(_caloriesCtrl.text),
      exercises: _exercises,
      ratingOutOf5: _rating,
    );
    
    ref.read(workoutProvider.notifier).addSession(session);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _exerciseCtrl.dispose();
    _caloriesCtrl.dispose();
    super.dispose();
  }
}
