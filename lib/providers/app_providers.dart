import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_provider.dart';
import '../models/models.dart';
import '../services/notification_service.dart';
import '../services/health_service.dart';
import '../services/widget_service.dart';
import 'package:pedometer/pedometer.dart';

// ─── THEME PROVIDER ──────────────────────────────────────────
final tabScrollEventProvider = StateProvider<String?>((ref) => null);

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(true) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('isDarkMode') ?? true;
  }

  void toggle() {
    state = !state;
    _saveTheme(state);
  }

  void setDark(bool isDark) {
    state = isDark;
    _saveTheme(state);
  }

  Future<void> _saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }
}

// ─── USER PROVIDER ───────────────────────────────────────────
final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier(ref);
});

class UserNotifier extends StateNotifier<UserModel?> {
  final Ref _ref;
  StreamSubscription? _sub;

  UserNotifier(this._ref) : super(null) {
    _listenToAuth();
  }

  void _listenToAuth() {
    _ref.listen<User?>(currentFirebaseUserProvider, (previous, next) async {
      _sub?.cancel();
      if (next == null) {
        state = null;
      } else {
        _sub = FirebaseFirestore.instance.collection('users').doc(next.uid).snapshots().listen((doc) async {
          if (doc.exists && doc.data() != null && doc.data()!['heightCm'] != null) {
            final data = doc.data()!;
            state = UserModel.fromMap(data, next.uid);
          } else {
             // User has not completed onboarding
             state = null;
          }
        });
      }
    }, fireImmediately: true);
  }

  Future<void> saveUser(UserModel user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.id).set(user.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> updateUser(UserModel user) async {
    await saveUser(user);
  }

  Future<void> setPremium(bool isPremium, {DateTime? expiry, String? plan}) async {
    if (state == null) return;
    final updated = state!
      ..isPremium = isPremium
      ..premiumExpiry = expiry
      ..premiumPlan = plan;
    await saveUser(updated);
  }

  Future<void> recordAppOpen() async {
    final currentUser = state;
    if (currentUser == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    bool needsUpdate = false;
    int streak = currentUser.currentAppStreak;
    int longest = currentUser.longestAppStreak;

    if (currentUser.lastActiveDate == null) {
      streak = 1;
      needsUpdate = true;
    } else {
      final lastDate = currentUser.lastActiveDate!;
      final lastActiveDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
      
      final difference = today.difference(lastActiveDay).inDays;
      
      if (difference == 1) {
        streak += 1;
        needsUpdate = true;
      } else if (difference > 1) {
        streak = 1;
        needsUpdate = true;
      }
    }

    if (needsUpdate) {
      if (streak > longest) {
        longest = streak;
      }
      currentUser.currentAppStreak = streak;
      currentUser.longestAppStreak = longest;
      currentUser.lastActiveDate = now;
      
      state = UserModel.fromMap(currentUser.toMap(), currentUser.id);
      await saveUser(currentUser);
    }
  }

  void logout() {
    state = null;
  }
  
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

// ─── HABITS PROVIDER ─────────────────────────────────────────
final habitsProvider = StateNotifierProvider<HabitsNotifier, List<Habit>>((ref) {
  return HabitsNotifier(ref);
});

class HabitsNotifier extends StateNotifier<List<Habit>> {
  final Ref _ref;
  StreamSubscription? _sub;

  HabitsNotifier(this._ref) : super([]) {
    _ref.listen<User?>(currentFirebaseUserProvider, (prev, next) {
      _sub?.cancel();
      if (next == null) {
        state = [];
      } else {
        _sub = FirebaseFirestore.instance.collection('users').doc(next.uid).collection('habits')
            .where('isArchived', isEqualTo: false)
            .snapshots().listen((snapshot) {
          final items = snapshot.docs.map((doc) => Habit.fromMap(doc.data(), doc.id)).toList();
          items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          state = items;
        });
      }
    }, fireImmediately: true);
  }

  Future<void> addHabit(Habit habit) async {
    final user = _ref.read(currentFirebaseUserProvider);
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('habits').doc(habit.id).set(habit.toMap());
  }

  Future<void> updateHabit(Habit habit) async {
    final user = _ref.read(currentFirebaseUserProvider);
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('habits').doc(habit.id).set(habit.toMap(), SetOptions(merge: true));
  }

  Future<void> toggleHabitCompletion(String habitId, DateTime date) async {
    final habit = state.firstWhere((h) => h.id == habitId);
    final isCompleted = habit.isCompletedOn(date);
    
    final mutableDates = List<DateTime>.from(habit.completedDates);
    if (isCompleted) {
      mutableDates.removeWhere(
        (d) => d.year == date.year && d.month == date.month && d.day == date.day,
      );
    } else {
      mutableDates.add(date);
    }
    habit.completedDates = mutableDates;

    _recalculateStreak(habit);
    await updateHabit(habit);
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
    final user = _ref.read(currentFirebaseUserProvider);
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('habits').doc(habitId).delete();
    try {
      await NotificationService.cancelHabitReminders(habitId.hashCode);
    } catch (_) {}
  }

  Future<void> archiveHabit(String habitId) async {
    final habit = state.firstWhere((h) => h.id == habitId);
    habit.isArchived = true;
    await updateHabit(habit);
  }

  List<Habit> getHabitsForToday() {
    final today = DateTime.now().weekday;
    return state.where((h) => h.weekDays.contains(today)).toList();
  }

  int getTodayCompletedCount() {
    final today = DateTime.now();
    return getHabitsForToday().where((h) => h.isCompletedOn(today)).length;
  }
  
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

// ─── WATER PROVIDER ──────────────────────────────────────────
final waterProvider = StateNotifierProvider<WaterNotifier, List<WaterLog>>((ref) {
  return WaterNotifier(ref);
});

class WaterNotifier extends StateNotifier<List<WaterLog>> {
  final Ref _ref;
  StreamSubscription? _sub;
  List<WaterLog> _allLogs = [];

  WaterNotifier(this._ref) : super([]) {
    _ref.listen<User?>(currentFirebaseUserProvider, (prev, next) {
      _sub?.cancel();
      if (next == null) {
        _allLogs = [];
        state = [];
      } else {
        _sub = FirebaseFirestore.instance.collection('users').doc(next.uid).collection('water_logs')
            .snapshots().listen((snapshot) {
          _allLogs = snapshot.docs.map((doc) => WaterLog.fromMap(doc.data(), doc.id)).toList();
          final today = DateTime.now();
          final todayLogs = _allLogs.where((l) =>
              l.timestamp.year == today.year &&
              l.timestamp.month == today.month &&
              l.timestamp.day == today.day).toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
          state = todayLogs;
          _updateWidget();
        });
      }
    }, fireImmediately: true);
  }

  void _updateWidget() {
    final user = _ref.read(userProvider);
    final goal = user?.dailyWaterGoalMl ?? 2500;
    WidgetService.updateWaterWidget(todayTotalMl, goal);
  }

  Future<void> addWaterLog(WaterLog log) async {
    final user = _ref.read(currentFirebaseUserProvider);
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('water_logs').doc(log.id).set(log.toMap());
    _updateWidget();
  }

  Future<void> deleteWaterLog(String id) async {
    final user = _ref.read(currentFirebaseUserProvider);
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('water_logs').doc(id).delete();
    _updateWidget();
  }

  int get todayTotalMl => state.fold(0, (sum, log) => sum + log.amountMl);

  List<WaterLog> getLogsForDate(DateTime date) {
    return _allLogs.where((l) =>
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
  
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

// ─── WORKOUT PROVIDER ────────────────────────────────────────
final workoutProvider = StateNotifierProvider<WorkoutNotifier, List<WorkoutSession>>((ref) {
  return WorkoutNotifier(ref);
});

class WorkoutNotifier extends StateNotifier<List<WorkoutSession>> {
  final Ref _ref;
  StreamSubscription? _sub;

  WorkoutNotifier(this._ref) : super([]) {
    _ref.listen<User?>(currentFirebaseUserProvider, (prev, next) {
      _sub?.cancel();
      if (next == null) {
        state = [];
      } else {
        _sub = FirebaseFirestore.instance.collection('users').doc(next.uid).collection('workouts')
            .snapshots().listen((snapshot) {
          final items = snapshot.docs.map((doc) => WorkoutSession.fromMap(doc.data(), doc.id)).toList();
          items.sort((a, b) => b.startTime.compareTo(a.startTime));
          state = items;
        });
      }
    }, fireImmediately: true);
  }

  Future<void> addSession(WorkoutSession session) async {
    final user = _ref.read(currentFirebaseUserProvider);
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('workouts').doc(session.id).set(session.toMap());
  }

  Future<void> updateSession(WorkoutSession session) async {
    final user = _ref.read(currentFirebaseUserProvider);
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('workouts').doc(session.id).set(session.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteSession(String id) async {
    final user = _ref.read(currentFirebaseUserProvider);
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('workouts').doc(id).delete();
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
  
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

// ─── SLEEP PROVIDER ──────────────────────────────────────────
final sleepProvider = StateNotifierProvider<SleepNotifier, List<SleepLog>>((ref) {
  return SleepNotifier(ref);
});

class SleepNotifier extends StateNotifier<List<SleepLog>> {
  final Ref _ref;
  StreamSubscription? _sub;

  SleepNotifier(this._ref) : super([]) {
    _ref.listen<User?>(currentFirebaseUserProvider, (prev, next) {
      _sub?.cancel();
      if (next == null) {
        state = [];
      } else {
        _sub = FirebaseFirestore.instance.collection('users').doc(next.uid).collection('sleep_logs')
            .snapshots().listen((snapshot) {
          final items = snapshot.docs.map((doc) => SleepLog.fromMap(doc.data(), doc.id)).toList();
          items.sort((a, b) => b.bedTime.compareTo(a.bedTime));
          state = items;
        });
      }
    }, fireImmediately: true);
  }

  Future<void> addLog(SleepLog log) async {
    final user = _ref.read(currentFirebaseUserProvider);
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('sleep_logs').doc(log.id).set(log.toMap());
  }

  Future<void> deleteLog(String id) async {
    final user = _ref.read(currentFirebaseUserProvider);
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('sleep_logs').doc(id).delete();
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
  
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

// ─── WEIGHT PROVIDER ─────────────────────────────────────────
final weightProvider = StateNotifierProvider<WeightNotifier, List<WeightLog>>((ref) {
  return WeightNotifier(ref);
});

class WeightNotifier extends StateNotifier<List<WeightLog>> {
  final Ref _ref;
  StreamSubscription? _sub;

  WeightNotifier(this._ref) : super([]) {
    _ref.listen<User?>(currentFirebaseUserProvider, (prev, next) {
      _sub?.cancel();
      if (next == null) {
        state = [];
      } else {
        _sub = FirebaseFirestore.instance.collection('users').doc(next.uid).collection('weight_logs')
            .snapshots().listen((snapshot) {
          final items = snapshot.docs.map((doc) => WeightLog.fromMap(doc.data(), doc.id)).toList();
          items.sort((a, b) => b.date.compareTo(a.date));
          state = items;
        });
      }
    }, fireImmediately: true);
  }

  Future<void> addLog(WeightLog log) async {
    final user = _ref.read(currentFirebaseUserProvider);
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('weight_logs').doc(log.id).set(log.toMap());
  }

  Future<void> deleteLog(String id) async {
    final user = _ref.read(currentFirebaseUserProvider);
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('weight_logs').doc(id).delete();
  }

  WeightLog? get latestLog => state.isEmpty ? null : state.first;

  double? get changeFromStart {
    if (state.length < 2) return null;
    return state.first.weightKg - state.last.weightKg;
  }
  
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

// ─── MOOD PROVIDER ───────────────────────────────────────────
final moodProvider = StateNotifierProvider<MoodNotifier, List<MoodLog>>((ref) {
  return MoodNotifier(ref);
});

class MoodNotifier extends StateNotifier<List<MoodLog>> {
  final Ref _ref;
  StreamSubscription? _sub;

  MoodNotifier(this._ref) : super([]) {
    _ref.listen<User?>(currentFirebaseUserProvider, (prev, next) {
      _sub?.cancel();
      if (next == null) {
        state = [];
      } else {
        _sub = FirebaseFirestore.instance.collection('users').doc(next.uid).collection('mood_logs')
            .snapshots().listen((snapshot) {
          final items = snapshot.docs.map((doc) => MoodLog.fromMap(doc.data(), doc.id)).toList();
          items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          state = items;
        });
      }
    }, fireImmediately: true);
  }

  Future<void> addLog(MoodLog log) async {
    final user = _ref.read(currentFirebaseUserProvider);
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('mood_logs').doc(log.id).set(log.toMap());
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
  
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

// ─── PREMIUM PROVIDER ────────────────────────────────────────
final premiumProvider = StateNotifierProvider<PremiumNotifier, bool>((ref) {
  final user = ref.watch(userProvider);
  return PremiumNotifier(user?.isPremium ?? false);
});

class PremiumNotifier extends StateNotifier<bool> {
  PremiumNotifier(super.initial);
  void setPremium(bool value) => state = value;
}

// ─── WORKOUT TEMPLATES PROVIDER ──────────────────────────────
final workoutTemplatesProvider = StateNotifierProvider<WorkoutTemplatesNotifier, List<WorkoutTemplate>>((ref) {
  return WorkoutTemplatesNotifier(ref);
});

class WorkoutTemplatesNotifier extends StateNotifier<List<WorkoutTemplate>> {
  final Ref _ref;
  StreamSubscription? _sub;

  WorkoutTemplatesNotifier(this._ref) : super([]) {
    _ref.listen<User?>(currentFirebaseUserProvider, (prev, next) {
      _sub?.cancel();
      if (next == null) {
        state = [];
      } else {
        _sub = FirebaseFirestore.instance.collection('users').doc(next.uid).collection('workout_templates')
            .snapshots().listen((snapshot) async {
          if (snapshot.docs.isEmpty) {
            // Initialize default templates if empty
            await _initDefaultTemplates(next.uid);
          } else {
            state = snapshot.docs.map((doc) => WorkoutTemplate.fromMap(doc.data(), doc.id)).toList();
          }
        });
      }
    }, fireImmediately: true);
  }

  Future<void> _initDefaultTemplates(String uid) async {
    final defaults = [
      WorkoutTemplate(
        id: 't1',
        name: 'Push Day (Chest, Shoulders, Triceps)',
        type: 'strength',
        exercises: [
          ExerciseSet(exerciseName: 'Bench Press', exerciseType: 'reps', sets: [SetEntry(reps: 10, weightKg: 40)], muscleGroup: 'Chest'),
          ExerciseSet(exerciseName: 'Overhead Press', exerciseType: 'reps', sets: [SetEntry(reps: 12, weightKg: 20)], muscleGroup: 'Shoulders'),
          ExerciseSet(exerciseName: 'Tricep Pushdown', exerciseType: 'reps', sets: [SetEntry(reps: 15, weightKg: 15)], muscleGroup: 'Triceps'),
        ],
      ),
      WorkoutTemplate(
        id: 't2',
        name: 'Pull Day (Back & Biceps)',
        type: 'strength',
        exercises: [
          ExerciseSet(exerciseName: 'Pull-ups', exerciseType: 'reps', sets: [SetEntry(reps: 8)], muscleGroup: 'Back'),
          ExerciseSet(exerciseName: 'Barbell Row', exerciseType: 'reps', sets: [SetEntry(reps: 10, weightKg: 40)], muscleGroup: 'Back'),
          ExerciseSet(exerciseName: 'Bicep Curls', exerciseType: 'reps', sets: [SetEntry(reps: 15, weightKg: 10)], muscleGroup: 'Biceps'),
        ],
      ),
      WorkoutTemplate(
        id: 't3',
        name: 'Leg Day',
        type: 'strength',
        exercises: [
          ExerciseSet(exerciseName: 'Squats', exerciseType: 'reps', sets: [SetEntry(reps: 10, weightKg: 60)], muscleGroup: 'Legs'),
          ExerciseSet(exerciseName: 'Leg Press', exerciseType: 'reps', sets: [SetEntry(reps: 12, weightKg: 100)], muscleGroup: 'Legs'),
          ExerciseSet(exerciseName: 'Calf Raises', exerciseType: 'reps', sets: [SetEntry(reps: 20, weightKg: 40)], muscleGroup: 'Legs'),
        ],
      ),
      WorkoutTemplate(
        id: 't4',
        name: 'Full Body HIIT',
        type: 'hiit',
        exercises: [
          ExerciseSet(exerciseName: 'Burpees', exerciseType: 'reps', sets: [SetEntry(reps: 20)], muscleGroup: 'Full Body'),
          ExerciseSet(exerciseName: 'Mountain Climbers', exerciseType: 'duration', sets: [SetEntry(durationSeconds: 60)], muscleGroup: 'Core'),
          ExerciseSet(exerciseName: 'Jump Squats', exerciseType: 'reps', sets: [SetEntry(reps: 15)], muscleGroup: 'Legs'),
        ],
      ),
    ];
    
    for (var t in defaults) {
      await FirebaseFirestore.instance.collection('users').doc(uid).collection('workout_templates').doc(t.id).set(t.toMap());
    }
  }

  Future<void> addTemplate(WorkoutTemplate template) async {
    final user = _ref.read(currentFirebaseUserProvider);
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('workout_templates').doc(template.id).set(template.toMap());
  }

  Future<void> deleteTemplate(String id) async {
    final user = _ref.read(currentFirebaseUserProvider);
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('workout_templates').doc(id).delete();
  }
  
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

// ─── STEPS PROVIDER ──────────────────────────────────────────

final stepsProvider = StateNotifierProvider<StepsNotifier, List<StepLog>>((ref) {
  return StepsNotifier(ref);
});

class StepsNotifier extends StateNotifier<List<StepLog>> {
  final Ref _ref;
  StreamSubscription? _sub;
  StreamSubscription? _pedometerSub;
  Timer? _walkingTimer;
  
  int _baseHealthSteps = 0;
  int _bootStepsAtInit = -1;
  int _liveDelta = 0;
  String pedestrianStatus = 'stopped';

  StepsNotifier(this._ref) : super([]) {
    _ref.listen<User?>(currentFirebaseUserProvider, (prev, next) {
      _sub?.cancel();
      if (next == null) {
        state = [];
      } else {
        _sub = FirebaseFirestore.instance.collection('users').doc(next.uid).collection('step_logs')
            .snapshots().listen((snapshot) {
          final items = snapshot.docs.map((doc) => StepLog.fromMap(doc.data(), doc.id)).toList();
          final today = DateTime.now();
          final todayLogs = items.where((l) =>
              l.date.year == today.year &&
              l.date.month == today.month &&
              l.date.day == today.day).toList()
            ..sort((a, b) => b.date.compareTo(a.date));
          state = todayLogs;
        });
      }
    }, fireImmediately: true);
    
    _initHealthAndPedometer();
  }

  Future<void> _initHealthAndPedometer() async {
    // 1. Get base steps for today from Health Connect
    _baseHealthSteps = await HealthService.getTodaySteps();
    state = [...state]; // Force UI update
    
    // 2. Request permission and listen to live steps
    final status = await Permission.activityRecognition.request();
    if (status.isGranted) {
      try {
        _pedometerSub = Pedometer.stepCountStream.listen((event) {
          if (_bootStepsAtInit == -1) {
            _bootStepsAtInit = event.steps;
          } else {
            int newDelta = event.steps - _bootStepsAtInit;
            if (newDelta < 0) newDelta = 0; 
            
            if (newDelta > _liveDelta) {
              _liveDelta = newDelta;
              pedestrianStatus = 'walking';
              state = [...state]; // Force UI update on new steps
              
              _walkingTimer?.cancel();
              _walkingTimer = Timer(const Duration(seconds: 10), () {
                pedestrianStatus = 'stopped';
                state = [...state];
              });
            }
          }
        });
      } catch (e) {
        print('Pedometer stream error: $e');
      }
    }
  }

  Future<void> addStepLog(StepLog log) async {
    final user = _ref.read(currentFirebaseUserProvider);
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('step_logs').doc(log.id).set(log.toMap());
  }

  Future<void> deleteStepLog(String id) async {
    final user = _ref.read(currentFirebaseUserProvider);
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('step_logs').doc(id).delete();
  }

  int get todayTotalSteps {
    final manualSteps = state.fold(0, (sum, log) => sum + log.steps);
    return manualSteps + _baseHealthSteps + _liveDelta;
  }
  
  int get todayTotalCalories {
    final manualCals = state.fold(0, (sum, log) => sum + (log.caloriesBurned ?? 0));
    final sensorCals = ((_baseHealthSteps + _liveDelta) * 0.04).toInt(); 
    return manualCals + sensorCals;
  }
  
  double get todayTotalDistanceKm {
    final manualDist = state.fold(0.0, (sum, log) => sum + (log.distanceKm ?? 0.0));
    final sensorDist = (_baseHealthSteps + _liveDelta) * 0.000762; 
    return manualDist + sensorDist;
  }
  
  int get todayTotalActiveMinutes => state.fold(0, (sum, log) => sum + (log.activeMinutes ?? 0));

  @override
  void dispose() {
    _walkingTimer?.cancel();
    _sub?.cancel();
    _pedometerSub?.cancel();
    super.dispose();
  }
}

// ─── NUTRITION PROVIDER ──────────────────────────────────────
final nutritionProvider = StateNotifierProvider<NutritionNotifier, List<NutritionLog>>((ref) {
  return NutritionNotifier(ref);
});

class NutritionNotifier extends StateNotifier<List<NutritionLog>> {
  final Ref _ref;
  StreamSubscription? _sub;

  NutritionNotifier(this._ref) : super([]) {
    _ref.listen<User?>(currentFirebaseUserProvider, (prev, next) {
      _sub?.cancel();
      if (next == null) {
        state = [];
      } else {
        _sub = FirebaseFirestore.instance.collection('users').doc(next.uid).collection('nutrition_logs')
            .snapshots().listen((snapshot) {
          final items = snapshot.docs.map((doc) => NutritionLog.fromMap(doc.data(), doc.id)).toList();
          final today = DateTime.now();
          final todayLogs = items.where((l) =>
              l.date.year == today.year &&
              l.date.month == today.month &&
              l.date.day == today.day).toList()
            ..sort((a, b) => b.date.compareTo(a.date));
          state = todayLogs;
        });
      }
    }, fireImmediately: true);
  }

  Future<void> addNutritionLog(NutritionLog log) async {
    final user = _ref.read(currentFirebaseUserProvider);
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('nutrition_logs').doc(log.id).set(log.toMap());
  }

  Future<void> updateNutritionLog(NutritionLog log) async {
    final user = _ref.read(currentFirebaseUserProvider);
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('nutrition_logs').doc(log.id).update(log.toMap());
  }

  Future<void> deleteNutritionLog(String id) async {
    final user = _ref.read(currentFirebaseUserProvider);
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('nutrition_logs').doc(id).delete();
  }

  double get todayTotalCalories => state.fold(0.0, (sum, log) => sum + log.calories);
  double get todayTotalProtein => state.fold(0.0, (sum, log) => sum + (log.proteinG ?? 0));
  double get todayTotalCarbs => state.fold(0.0, (sum, log) => sum + (log.carbsG ?? 0));
  double get todayTotalFat => state.fold(0.0, (sum, log) => sum + (log.fatG ?? 0));
  
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
