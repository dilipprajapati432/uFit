// lib/screens/habits/habits_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'package:ufit/theme/theme_ext.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/notification_service.dart';

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsProvider);
    final isPremium = ref.watch(premiumProvider);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        title: Text('Habits'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded),
            onPressed: () => _showAddHabitSheet(context, isPremium, habits.length),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: context.textSecondary,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'All Habits'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TodayTab(
            selectedDay: _selectedDay,
            onDayChanged: (day) => setState(() => _selectedDay = day),
          ),
          _AllHabitsTab(isPremium: isPremium),
        ],
      ),
    );
  }

  void _showAddHabitSheet(BuildContext context, bool isPremium, int habitCount) {
    if (!isPremium && habitCount >= 3) {
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          backgroundColor: context.surface,
          title: const Text('Free Limit Reached'),
          content: const Text('You can track up to 3 habits for free. Upgrade to Pro for unlimited habits!'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Later')),
            ElevatedButton(
              onPressed: () { 
                Navigator.pop(dialogCtx);
                context.push('/premium'); 
              },
              child: const Text('Upgrade to Pro'),
            ),
          ],
        ),
      );
      return;
    }
    showAppBottomSheet(context: context, child: const _AddHabitForm());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _TodayTab extends ConsumerWidget {
  final DateTime selectedDay;
  final Function(DateTime) onDayChanged;

  const _TodayTab({required this.selectedDay, required this.onDayChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allHabits = ref.watch(habitsProvider);
    final isPremium = ref.watch(premiumProvider);
    final weekday = selectedDay.weekday;
    final todayHabits = allHabits.where((h) => h.weekDays.contains(weekday)).toList();
    final completed = todayHabits.where((h) => h.isCompletedOn(selectedDay)).length;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              children: [
                // Calendar week strip
                TableCalendar(
                  firstDay: DateTime.utc(2024),
                  lastDay: DateTime.utc(2027),
                  focusedDay: selectedDay,
                  calendarFormat: CalendarFormat.week,
                  selectedDayPredicate: (d) => isSameDay(d, selectedDay),
                  onDaySelected: (selected, focused) => onDayChanged(selected),
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: TextStyle(color: context.text),
                    weekendTextStyle: TextStyle(color: context.text),
                    todayDecoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    outsideDaysVisible: false,
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(color: context.text, fontWeight: FontWeight.w600),
                    leftChevronIcon: Icon(Icons.chevron_left, color: context.text),
                    rightChevronIcon: Icon(Icons.chevron_right, color: context.text),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: context.textSecondary, fontSize: 11),
                    weekendStyle: TextStyle(color: context.textSecondary, fontSize: 11),
                  ),
                ),
                SizedBox(height: 16),

                // Progress summary
                if (todayHabits.isNotEmpty)
                  GlassCard(
                    child: Row(
                      children: [
                        CircularProgressWidget(
                          progress: todayHabits.isEmpty ? 0 : completed / todayHabits.length,
                          size: 56,
                          color: AppColors.habitColor,
                          strokeWidth: 5,
                          child: Text(
                            '$completed',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$completed of ${todayHabits.length} completed',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: todayHabits.isEmpty ? 0 : completed / todayHabits.length,
                                backgroundColor: context.border,
                                valueColor: const AlwaysStoppedAnimation(AppColors.habitColor),
                                borderRadius: BorderRadius.circular(3),
                                minHeight: 6,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: todayHabits.isEmpty
              ? SliverToBoxAdapter(
                  child: EmptyState(
                    emoji: '🌱',
                    title: 'No habits today',
                    subtitle: 'Add your first habit to start building positive routines',
                    actionLabel: 'Add a Habit',
                    onAction: () {
                      if (!isPremium && allHabits.length >= 3) {
                        showDialog(
                          context: context,
                          builder: (dialogCtx) => AlertDialog(
                            backgroundColor: context.surface,
                            title: const Text('Free Limit Reached'),
                            content: const Text('You can track up to 3 habits for free. Upgrade to Pro for unlimited habits!'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Later')),
                              ElevatedButton(
                                onPressed: () { 
                                  Navigator.pop(dialogCtx);
                                  context.push('/premium'); 
                                },
                                child: const Text('Upgrade to Pro'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        showAppBottomSheet(context: context, child: const _AddHabitForm());
                      }
                    },
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final habit = todayHabits[i];
                      final isCompleted = habit.isCompletedOn(selectedDay);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _HabitCard(
                          habit: habit,
                          isCompleted: isCompleted,
                          onToggle: () => ref.read(habitsProvider.notifier)
                              .toggleHabitCompletion(habit.id, selectedDay),
                          onEdit: () => showAppBottomSheet(context: context, child: _AddHabitForm(existingHabit: habit)),
                          onDelete: () => ref.read(habitsProvider.notifier).deleteHabit(habit.id),
                        ).animate().fadeIn(delay: Duration(milliseconds: i * 60)).slideX(begin: 0.2),
                      );
                    },
                    childCount: todayHabits.length,
                  ),
                ),
        ),
      ],
    );
  }
}

class _AllHabitsTab extends ConsumerWidget {
  final bool isPremium;
  const _AllHabitsTab({required this.isPremium});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    if (habits.isEmpty) {
      return EmptyState(
        emoji: '🎯',
        title: 'No habits yet',
        subtitle: 'Create habits to track your daily routines and build a healthier life',
        actionLabel: 'Add a Habit',
        onAction: () {
          if (!isPremium && habits.length >= 3) {
            showDialog(
              context: context,
              builder: (dialogCtx) => AlertDialog(
                backgroundColor: context.surface,
                title: const Text('Free Limit Reached'),
                content: const Text('You can track up to 3 habits for free. Upgrade to Pro for unlimited habits!'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Later')),
                  ElevatedButton(
                    onPressed: () { 
                      Navigator.pop(dialogCtx);
                      context.push('/premium'); 
                    },
                    child: const Text('Upgrade to Pro'),
                  ),
                ],
              ),
            );
          } else {
            showAppBottomSheet(context: context, child: const _AddHabitForm());
          }
        },
      );
    }

    // Group habits by category
    final Map<String, List<Habit>> grouped = {};
    for (final h in habits) {
      grouped.putIfAbsent(h.category, () => []).add(h);
    }
    
    final sortedCategories = grouped.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        for (final category in sortedCategories) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 12),
            child: Text(
              category[0].toUpperCase() + category.substring(1),
              style: TextStyle(color: context.textSecondary, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
            ),
          ),
          for (final habit in grouped[category]!)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _HabitCard(
                habit: habit,
                isCompleted: false,
                onToggle: () {},
                onEdit: () => showAppBottomSheet(context: context, child: _AddHabitForm(existingHabit: habit)),
                onDelete: () => ref.read(habitsProvider.notifier).deleteHabit(habit.id),
                showStats: true,
              ),
            ),
        ],
        if (!isPremium)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: PremiumGateBanner(
              onUpgrade: () => context.push('/premium'),
              featureName: 'Unlimited Habits',
            ),
          ),
      ],
    );
  }
}

class _HabitCard extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool showStats;

  const _HabitCard({
    required this.habit,
    required this.isCompleted,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.showStats = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.habitColor, AppColors.waterColor, AppColors.workoutColor,
      AppColors.sleepColor, AppColors.weightColor, AppColors.moodColor,
    ];
    final color = colors[habit.colorIndex % colors.length];

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: Icons.edit_rounded,
            label: 'Edit',
            borderRadius: BorderRadius.circular(16),
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            label: 'Delete',
            borderRadius: BorderRadius.circular(16),
          ),
        ],
      ),
      child: GlassCard(
        onTap: showStats ? null : onToggle,
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(habit.icon, style: TextStyle(fontSize: 24)),
              ),
            ),
            SizedBox(width: 14),
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
                  SizedBox(height: 2),
                  if (showStats)
                    Row(
                      children: [
                        Text(
                          '🔥 ${habit.currentStreak} streak',
                          style: TextStyle(fontSize: 11, color: AppColors.accentOrange),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${(habit.getCompletionRate() * 100).toInt()}% rate',
                          style: TextStyle(fontSize: 11, color: context.textSecondary),
                        ),
                      ],
                    )
                  else
                    Text(
                      habit.description.isEmpty ? habit.category : habit.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                    ),
                ],
              ),
            ),
            if (!showStats)
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.success : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted ? AppColors.success : color,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : null,
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  habit.frequency,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),

            // direct Edit/Delete menu button
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: context.textSecondary, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 100),
              color: context.card,
              surfaceTintColor: Colors.transparent,
              onSelected: (val) {
                if (val == 'edit') {
                  onEdit();
                } else if (val == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_rounded, size: 16, color: context.textSecondary),
                      const SizedBox(width: 8),
                      Text('Edit', style: TextStyle(color: context.text, fontSize: 13)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_rounded, size: 16, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text('Delete', style: const TextStyle(color: AppColors.error, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddHabitForm extends ConsumerStatefulWidget {
  final Habit? existingHabit;
  const _AddHabitForm({this.existingHabit});

  @override
  ConsumerState<_AddHabitForm> createState() => _AddHabitFormState();
}

class _AddHabitFormState extends ConsumerState<_AddHabitForm> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _selectedIcon = '⭐';
  int _colorIndex = 0;
  String _frequency = 'daily';
  List<int> _weekDays = [1, 2, 3, 4, 5, 6, 7];
  String _category = 'health';
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);

  String _formatTime(TimeOfDay time) {
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final hourStr = time.hourOfPeriod == 0 ? '12' : time.hourOfPeriod.toString();
    final minStr = time.minute.toString().padLeft(2, '0');
    return '$hourStr:$minStr $period';
  }

  final _icons = ['⭐', '💪', '🧘', '📚', '💧', '🏃', '🥗', '😴', '🎯', '🧠', '❤️', '🌿', '☀️', '🎵', '✍️', '🏊'];

  @override
  void initState() {
    super.initState();
    if (widget.existingHabit != null) {
      final h = widget.existingHabit!;
      _nameCtrl.text = h.name;
      _descCtrl.text = h.description;
      _selectedIcon = h.icon;
      _colorIndex = h.colorIndex;
      _frequency = h.frequency;
      _weekDays = List.from(h.weekDays);
      _category = h.category;
      _reminderEnabled = h.reminderEnabled;
      if (h.reminderTime != null) {
        try {
          final parts = h.reminderTime!.split(':');
          _reminderTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        } catch (_) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Text(widget.existingHabit == null ? 'Create New Habit' : 'Edit Habit', style: Theme.of(context).textTheme.headlineSmall),
        SizedBox(height: 24),

        // Icon picker
        Text('Choose Icon', style: Theme.of(context).textTheme.titleSmall),
        SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _icons.map((icon) => GestureDetector(
            onTap: () => setState(() => _selectedIcon = icon),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _selectedIcon == icon ? AppColors.primary.withOpacity(0.2) : context.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _selectedIcon == icon ? AppColors.primary : context.border,
                ),
              ),
              child: Center(child: Text(icon, style: TextStyle(fontSize: 22))),
            ),
          )).toList(),
        ),
        SizedBox(height: 20),

        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: 'Habit Name *', hintText: 'e.g. Drink Water'),
        ),
        SizedBox(height: 14),
        TextField(
          controller: _descCtrl,
          decoration: const InputDecoration(labelText: 'Description (optional)'),
        ),
        SizedBox(height: 20),

        // Frequency
        Text('Frequency', style: Theme.of(context).textTheme.titleSmall),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FreqChip('Daily', 'daily', _frequency, (v) => setState(() { _frequency = v; _weekDays = [1,2,3,4,5,6,7]; })),
            _FreqChip('Weekdays', 'weekdays', _frequency, (v) => setState(() { _frequency = v; _weekDays = [1,2,3,4,5]; })),
            _FreqChip('Weekends', 'weekends', _frequency, (v) => setState(() { _frequency = v; _weekDays = [6,7]; })),
            _FreqChip('Custom', 'custom', _frequency, (v) => setState(() { _frequency = v; })),
          ],
        ),
        if (_frequency == 'custom') ...[
          SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _DayChip(1, 'Mon', _weekDays, (days) => setState(() => _weekDays = days)),
              _DayChip(2, 'Tue', _weekDays, (days) => setState(() => _weekDays = days)),
              _DayChip(3, 'Wed', _weekDays, (days) => setState(() => _weekDays = days)),
              _DayChip(4, 'Thu', _weekDays, (days) => setState(() => _weekDays = days)),
              _DayChip(5, 'Fri', _weekDays, (days) => setState(() => _weekDays = days)),
              _DayChip(6, 'Sat', _weekDays, (days) => setState(() => _weekDays = days)),
              _DayChip(7, 'Sun', _weekDays, (days) => setState(() => _weekDays = days)),
            ],
          ),
        ],
        SizedBox(height: 20),

        // Category
        Text('Category', style: Theme.of(context).textTheme.titleSmall),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: ['health', 'fitness', 'mindfulness', 'productivity', 'social', 'learning']
              .map((c) => GestureDetector(
                    onTap: () => setState(() => _category = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _category == c ? AppColors.primary.withOpacity(0.15) : context.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _category == c ? AppColors.primary : context.border),
                      ),
                      child: Text(
                        c[0].toUpperCase() + c.substring(1),
                        style: TextStyle(
                          color: _category == c ? AppColors.primary : context.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 20),

        // Habit Reminder
        Text('Reminder', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _reminderEnabled
                  ? 'Remind me at ${_formatTime(_reminderTime)}'
                  : 'No reminder set',
              style: TextStyle(color: context.textSecondary, fontSize: 13),
            ),
            Switch(
              value: _reminderEnabled,
              onChanged: (v) async {
                if (v) {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: _reminderTime,
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.dark(
                            primary: AppColors.primary,
                            onPrimary: Colors.white,
                            surface: context.card,
                            onSurface: context.text,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (t != null) {
                    setState(() {
                      _reminderTime = t;
                      _reminderEnabled = true;
                    });
                  } else {
                    setState(() => _reminderEnabled = false);
                  }
                } else {
                  setState(() => _reminderEnabled = false);
                }
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
        SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _save,
            child: Text(widget.existingHabit == null ? 'Create Habit' : 'Save Changes'),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  void _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    final timeStr = '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}';

    final habit = Habit(
      id: widget.existingHabit?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      icon: _selectedIcon,
      colorIndex: _colorIndex,
      frequency: _frequency,
      weekDays: _weekDays,
      createdAt: widget.existingHabit?.createdAt ?? DateTime.now(),
      category: _category,
      reminderEnabled: _reminderEnabled,
      reminderTime: _reminderEnabled ? timeStr : null,
    );

    // Save habit locally
    ref.read(habitsProvider.notifier).addHabit(habit);

    // Sync notification reminders based on global user settings
    try {
      final prefs = await SharedPreferences.getInstance();
      final globalOn = prefs.getBool('habit_reminders_on') ?? false;
      debugPrint("HABIT REMINDER SAVE DIALOG: reminderEnabled=$_reminderEnabled, globalOn=$globalOn");

      // Clean up previous notification registration to prevent multiple active alarms
      await NotificationService.cancelHabitReminders(habit.id.hashCode);

      if (_reminderEnabled && globalOn) {
        await NotificationService.scheduleHabitReminder(
          id: habit.id.hashCode,
          habitName: habit.name,
          time: timeStr,
          weekDays: habit.weekDays,
        );
        debugPrint("HABIT REMINDER SUCCESSFULLY SCHEDULED");
      }
    } catch (e, stack) {
      debugPrint("ERROR SCHEDULING HABIT REMINDER FROM DIALOG: $e\n$stack");
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }
}

class _FreqChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final Function(String) onSelect;

  const _FreqChip(this.label, this.value, this.selected, this.onSelect);

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.15) : context.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : context.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : context.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final int day;
  final String label;
  final List<int> selected;
  final Function(List<int>) onChanged;

  const _DayChip(this.day, this.label, this.selected, this.onChanged);

  @override
  Widget build(BuildContext context) {
    final isSelected = selected.contains(day);
    return GestureDetector(
      onTap: () {
        final updated = List<int>.from(selected);
        if (isSelected) { updated.remove(day); } else { updated.add(day); }
        if (updated.isNotEmpty) onChanged(updated);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.2) : context.card,
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? AppColors.primary : context.border, width: isSelected ? 1.5 : 1),
        ),
        child: Center(
          child: Text(label, style: TextStyle(fontSize: 11, color: isSelected ? AppColors.primary : context.textSecondary, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400)),
        ),
      ),
    );
  }
}
