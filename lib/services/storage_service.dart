// lib/services/storage_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

class StorageService {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(UserModelAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(HabitAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(WaterLogAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(WorkoutSessionAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(ExerciseSetAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(SetEntryAdapter());
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(SleepLogAdapter());
    if (!Hive.isAdapterRegistered(7)) Hive.registerAdapter(WeightLogAdapter());
    if (!Hive.isAdapterRegistered(8)) Hive.registerAdapter(MoodLogAdapter());
    if (!Hive.isAdapterRegistered(9)) Hive.registerAdapter(NutritionLogAdapter());
    if (!Hive.isAdapterRegistered(10)) Hive.registerAdapter(StepLogAdapter());
    if (!Hive.isAdapterRegistered(12)) Hive.registerAdapter(WorkoutTemplateAdapter());

    // Open boxes
    await Hive.openBox<UserModel>('users');
    await Hive.openBox<Habit>('habits');
    await Hive.openBox<WaterLog>('water_logs');
    await Hive.openBox<WorkoutSession>('workouts');
    await Hive.openBox<SleepLog>('sleep_logs');
    await Hive.openBox<WeightLog>('weight_logs');
    await Hive.openBox<MoodLog>('mood_logs');
    await Hive.openBox<NutritionLog>('nutrition_logs');
    await Hive.openBox<StepLog>('step_logs');
    await Hive.openBox('settings');
    await _initTemplates();
  }

  static Future<void> clearAll() async {
    await Hive.box<UserModel>('users').clear();
    await Hive.box<Habit>('habits').clear();
    await Hive.box<WaterLog>('water_logs').clear();
    await Hive.box<WorkoutSession>('workouts').clear();
    await Hive.box<SleepLog>('sleep_logs').clear();
    await Hive.box<WeightLog>('weight_logs').clear();
    await Hive.box<MoodLog>('mood_logs').clear();
    await Hive.box<NutritionLog>('nutrition_logs').clear();
    await Hive.box<NutritionLog>('nutrition_logs').clear();
    await Hive.box<StepLog>('step_logs').clear();
    await Hive.box<WorkoutTemplate>('workout_templates').clear();
  }

  static Future<void> _initTemplates() async {
    final box = await Hive.openBox<WorkoutTemplate>('workout_templates');
    if (box.isEmpty) {
      await box.put('t1', WorkoutTemplate(
        id: 't1',
        name: 'Push Day (Chest, Shoulders, Triceps)',
        type: 'strength',
        exercises: [
          ExerciseSet(exerciseName: 'Bench Press', exerciseType: 'reps', sets: [SetEntry(reps: 10, weightKg: 40)], muscleGroup: 'Chest'),
          ExerciseSet(exerciseName: 'Overhead Press', exerciseType: 'reps', sets: [SetEntry(reps: 12, weightKg: 20)], muscleGroup: 'Shoulders'),
          ExerciseSet(exerciseName: 'Tricep Pushdown', exerciseType: 'reps', sets: [SetEntry(reps: 15, weightKg: 15)], muscleGroup: 'Triceps'),
        ],
      ));
      await box.put('t2', WorkoutTemplate(
        id: 't2',
        name: 'Pull Day (Back & Biceps)',
        type: 'strength',
        exercises: [
          ExerciseSet(exerciseName: 'Pull-ups', exerciseType: 'reps', sets: [SetEntry(reps: 8)], muscleGroup: 'Back'),
          ExerciseSet(exerciseName: 'Barbell Row', exerciseType: 'reps', sets: [SetEntry(reps: 10, weightKg: 40)], muscleGroup: 'Back'),
          ExerciseSet(exerciseName: 'Bicep Curls', exerciseType: 'reps', sets: [SetEntry(reps: 15, weightKg: 10)], muscleGroup: 'Biceps'),
        ],
      ));
      await box.put('t3', WorkoutTemplate(
        id: 't3',
        name: 'Leg Day',
        type: 'strength',
        exercises: [
          ExerciseSet(exerciseName: 'Squats', exerciseType: 'reps', sets: [SetEntry(reps: 10, weightKg: 60)], muscleGroup: 'Legs'),
          ExerciseSet(exerciseName: 'Leg Press', exerciseType: 'reps', sets: [SetEntry(reps: 12, weightKg: 100)], muscleGroup: 'Legs'),
          ExerciseSet(exerciseName: 'Calf Raises', exerciseType: 'reps', sets: [SetEntry(reps: 20, weightKg: 40)], muscleGroup: 'Legs'),
        ],
      ));
      await box.put('t4', WorkoutTemplate(
        id: 't4',
        name: 'Full Body HIIT',
        type: 'hiit',
        exercises: [
          ExerciseSet(exerciseName: 'Burpees', exerciseType: 'reps', sets: [SetEntry(reps: 20)], muscleGroup: 'Full Body'),
          ExerciseSet(exerciseName: 'Mountain Climbers', exerciseType: 'duration', sets: [SetEntry(durationSeconds: 60)], muscleGroup: 'Core'),
          ExerciseSet(exerciseName: 'Jump Squats', exerciseType: 'reps', sets: [SetEntry(reps: 15)], muscleGroup: 'Legs'),
        ],
      ));
    }
  }
}
