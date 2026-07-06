// lib/providers/app_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

// ─── THEME PROVIDER ──────────────────────────────────────────
final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(true); // true = dark mode default
  void toggle() => state = !state;
  void setDark(bool isDark) => state = isDark;
}

// ─── USER PROVIDER ───────────────────────────────────────────
final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null) {
    _loadUser();
  }

  void _loadUser() {
    final box = Hive.box<UserModel>('users');
    if (box.isNotEmpty) state = box.values.first;
  }

  Future<void> saveUser(UserModel user) async {
    final box = Hive.box<UserModel>('users');
    await box.put(user.id, user);
    state = user;
  }

  Future<void> updateUser(UserModel user) async {
    final box = Hive.box<UserModel>('users');
    await box.put(user.id, user);
    state = user;
  }

  Future<void> setPremium(bool isPremium, {DateTime? expiry}) async {
    if (state == null) return;
    final updated = state!
      ..isPremium = isPremium
      ..premiumExpiry = expiry;
    await saveUser(updated);
  }

  void logout() {
    state = null;
  }
}

// ─── HABITS PROVIDER ─────────────────────────────────────────
final habitsProvider = StateNotifierProvider<HabitsNotifier, List<Habit>>((ref) {
  return HabitsNotifier();
});

class HabitsNotifier extends StateNotifier<List<Habit>> {
  HabitsNotifier() : super([]) {
    _loadHabits();
  }

  void _loadHabits() {
    final box = Hive.box<Habit>('habits');
    state = box.values.where((h) => !h.isArchived).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addHabit(Habit habit) async {
    final box = Hive.box<Habit>('habits');
    await box.put(habit.id, habit);
    _loadHabits();
  }

  Future<void> updateHabit(Habit habit) async {
    final box = Hive.box<Habit>('habits');
    await box.put(habit.id, habit);
    _loadHabits();
  }

  Future<void> toggleHabitCompletion(String habitId, DateTime date) async {
    final box = Hive.box<Habit>('habits');
    final habit = box.get(habitId);
    if (habit == null) return;

    final isCompleted = habit.isCompletedOn(date);
    // Ensure the list is mutable (Hive may return a const/fixed-length list)
    final mutableDates = List<DateTime>.from(habit.completedDates);
    if (isCompleted) {
      mutableDates.removeWhere(
        (d) => d.year == date.year && d.month == date.month && d.day == date.day,
      );
    } else {
      mutableDates.add(date);
    }
    habit.completedDates = mutableDates;

    // Recalculate streak
    _recalculateStreak(habit);
    await habit.save();
    _loadHabits();
  }

  void _recalculateStreak(Habit habit) {
    int streak = 0;
    DateTime date = DateTime.now();
    while (habit.isCompletedOn(date)) {
      streak++;
      date = date.subtract(const Duration(days: 1));
    }
    habit.currentStreak = streak;
    if (streak > habit.longestStreak) habit.longestStreak = streak;
  }

  Future<void> deleteHabit(String habitId) async {
    final box = Hive.box<Habit>('habits');
    await box.delete(habitId);
    _loadHabits();
  }

  Future<void> archiveHabit(String habitId) async {
    final box = Hive.box<Habit>('habits');
    final habit = box.get(habitId);
    if (habit == null) return;
    habit.isArchived = true;
    await habit.save();
    _loadHabits();
  }

  List<Habit> getHabitsForToday() {
    final today = DateTime.now().weekday;
    return state.where((h) => h.weekDays.contains(today)).toList();
  }

  int getTodayCompletedCount() {
    final today = DateTime.now();
    return getHabitsForToday().where((h) => h.isCompletedOn(today)).length;
  }
}

// ─── WATER PROVIDER ──────────────────────────────────────────
final waterProvider = StateNotifierProvider<WaterNotifier, List<WaterLog>>((ref) {
  return WaterNotifier();
});

class WaterNotifier extends StateNotifier<List<WaterLog>> {
  WaterNotifier() : super([]) {
    _loadTodayLogs();
  }

  void _loadTodayLogs() {
    final box = Hive.box<WaterLog>('water_logs');
    final today = DateTime.now();
    state = box.values.where((l) =>
        l.timestamp.year == today.year &&
        l.timestamp.month == today.month &&
        l.timestamp.day == today.day).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> addWaterLog(WaterLog log) async {
    final box = Hive.box<WaterLog>('water_logs');
    await box.put(log.id, log);
    _loadTodayLogs();
  }

  Future<void> deleteWaterLog(String id) async {
    final box = Hive.box<WaterLog>('water_logs');
    await box.delete(id);
    _loadTodayLogs();
  }

  int get todayTotalMl => state.fold(0, (sum, log) => sum + log.amountMl);

  List<WaterLog> getLogsForDate(DateTime date) {
    final box = Hive.box<WaterLog>('water_logs');
    return box.values.where((l) =>
        l.timestamp.year == date.year &&
        l.timestamp.month == date.month &&
        l.timestamp.day == date.day).toList();
  }

  Map<DateTime, int> getWeeklyData() {
    final result = <DateTime, int>{};
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final logs = getLogsForDate(date);
      result[date] = logs.fold(0, (sum, l) => sum + l.amountMl);
    }
    return result;
  }
}

// ─── WORKOUT PROVIDER ────────────────────────────────────────
final workoutProvider = StateNotifierProvider<WorkoutNotifier, List<WorkoutSession>>((ref) {
  return WorkoutNotifier();
});

class WorkoutNotifier extends StateNotifier<List<WorkoutSession>> {
  WorkoutNotifier() : super([]) {
    _loadSessions();
  }

  void _loadSessions() {
    final box = Hive.box<WorkoutSession>('workouts');
    state = box.values.toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  Future<void> addSession(WorkoutSession session) async {
    final box = Hive.box<WorkoutSession>('workouts');
    await box.put(session.id, session);
    _loadSessions();
  }

  Future<void> updateSession(WorkoutSession session) async {
    final box = Hive.box<WorkoutSession>('workouts');
    await box.put(session.id, session);
    _loadSessions();
  }

  Future<void> deleteSession(String id) async {
    final box = Hive.box<WorkoutSession>('workouts');
    await box.delete(id);
    _loadSessions();
  }

  List<WorkoutSession> getThisWeekSessions() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));
    return state.where((s) => s.startTime.isAfter(weekStart) || s.startTime.isAtSameMomentAs(weekStart)).toList();
  }

  int getThisWeekWorkouts() => getThisWeekSessions().length;
  int getThisWeekMinutes() => getThisWeekSessions().fold(0, (s, w) => s + w.durationMinutes);
  int getThisWeekCalories() => getThisWeekSessions().fold(0, (s, w) => s + (w.caloriesBurned ?? 0));
}

// ─── SLEEP PROVIDER ──────────────────────────────────────────
final sleepProvider = StateNotifierProvider<SleepNotifier, List<SleepLog>>((ref) {
  return SleepNotifier();
});

class SleepNotifier extends StateNotifier<List<SleepLog>> {
  SleepNotifier() : super([]) {
    _loadLogs();
  }

  void _loadLogs() {
    final box = Hive.box<SleepLog>('sleep_logs');
    state = box.values.toList()
      ..sort((a, b) => b.bedTime.compareTo(a.bedTime));
  }

  Future<void> addLog(SleepLog log) async {
    final box = Hive.box<SleepLog>('sleep_logs');
    await box.put(log.id, log);
    _loadLogs();
  }

  Future<void> deleteLog(String id) async {
    final box = Hive.box<SleepLog>('sleep_logs');
    await box.delete(id);
    _loadLogs();
  }

  SleepLog? get lastNightSleep => state.isEmpty ? null : state.first;

  double get avgDurationLast7Days {
    if (state.isEmpty) return 0;
    final recent = state.take(7).toList();
    return recent.fold(0.0, (s, l) => s + l.durationHours) / recent.length;
  }

  double get avgQualityLast7Days {
    if (state.isEmpty) return 0;
    final recent = state.take(7).toList();
    return recent.fold(0.0, (s, l) => s + l.qualityOutOf5) / recent.length;
  }
}

// ─── WEIGHT PROVIDER ─────────────────────────────────────────
final weightProvider = StateNotifierProvider<WeightNotifier, List<WeightLog>>((ref) {
  return WeightNotifier();
});

class WeightNotifier extends StateNotifier<List<WeightLog>> {
  WeightNotifier() : super([]) {
    _loadLogs();
  }

  void _loadLogs() {
    final box = Hive.box<WeightLog>('weight_logs');
    state = box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addLog(WeightLog log) async {
    final box = Hive.box<WeightLog>('weight_logs');
    await box.put(log.id, log);
    _loadLogs();
  }

  Future<void> deleteLog(String id) async {
    final box = Hive.box<WeightLog>('weight_logs');
    await box.delete(id);
    _loadLogs();
  }

  WeightLog? get latestLog => state.isEmpty ? null : state.first;

  double? get changeFromStart {
    if (state.length < 2) return null;
    return state.first.weightKg - state.last.weightKg;
  }
}

// ─── MOOD PROVIDER ───────────────────────────────────────────
final moodProvider = StateNotifierProvider<MoodNotifier, List<MoodLog>>((ref) {
  return MoodNotifier();
});

class MoodNotifier extends StateNotifier<List<MoodLog>> {
  MoodNotifier() : super([]) {
    _loadLogs();
  }

  void _loadLogs() {
    final box = Hive.box<MoodLog>('mood_logs');
    state = box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> addLog(MoodLog log) async {
    final box = Hive.box<MoodLog>('mood_logs');
    await box.put(log.id, log);
    _loadLogs();
  }

  MoodLog? get todayMood {
    final today = DateTime.now();
    try {
      return state.firstWhere((m) =>
          m.timestamp.year == today.year &&
          m.timestamp.month == today.month &&
          m.timestamp.day == today.day);
    } catch (_) {
      return null;
    }
  }

  double get avgMoodLast7Days {
    if (state.isEmpty) return 3;
    final recent = state.take(7).toList();
    return recent.fold(0.0, (s, l) => s + l.moodScore) / recent.length;
  }
}

// ─── PREMIUM PROVIDER ────────────────────────────────────────
final premiumProvider = StateNotifierProvider<PremiumNotifier, bool>((ref) {
  final user = ref.watch(userProvider);
  return PremiumNotifier(user?.isPremium ?? false);
});

class PremiumNotifier extends StateNotifier<bool> {
  PremiumNotifier(bool initial) : super(initial);

  void setPremium(bool value) => state = value;
}

// ─── WORKOUT TEMPLATES PROVIDER ──────────────────────────────
final workoutTemplatesProvider = StateNotifierProvider<WorkoutTemplatesNotifier, List<WorkoutTemplate>>((ref) {
  return WorkoutTemplatesNotifier();
});

class WorkoutTemplatesNotifier extends StateNotifier<List<WorkoutTemplate>> {
  WorkoutTemplatesNotifier() : super([]) {
    _loadTemplates();
  }

  void _loadTemplates() {
    final box = Hive.box<WorkoutTemplate>('workout_templates');
    state = box.values.toList();
  }

  Future<void> addTemplate(WorkoutTemplate template) async {
    final box = Hive.box<WorkoutTemplate>('workout_templates');
    await box.put(template.id, template);
    _loadTemplates();
  }

  Future<void> deleteTemplate(String id) async {
    final box = Hive.box<WorkoutTemplate>('workout_templates');
    await box.delete(id);
    _loadTemplates();
  }
}
