// lib/models/models.dart
import 'package:hive/hive.dart';

part 'models.g.dart';

// ─── USER ────────────────────────────────────────────────────
@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String name;
  @HiveField(2) String email;
  @HiveField(3) String? photoUrl;
  @HiveField(4) DateTime createdAt;
  @HiveField(5) bool isPremium;
  @HiveField(6) DateTime? premiumExpiry;
  @HiveField(7) double? heightCm;
  @HiveField(8) double? weightKg;
  @HiveField(9) int? age;
  @HiveField(10) String? gender;
  @HiveField(11) String? fitnessGoal; // lose_weight, gain_muscle, maintain, active_lifestyle
  @HiveField(12) int dailyWaterGoalMl;
  @HiveField(13) int dailyStepsGoal;
  @HiveField(14) int dailyCalorieGoal;
  @HiveField(15) double targetWeightKg;
  @HiveField(16) int sleepGoalHours;
  @HiveField(17) String? geminiApiKey;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    this.isPremium = false,
    this.premiumExpiry,
    this.heightCm,
    this.weightKg,
    this.age,
    this.gender,
    this.fitnessGoal,
    this.dailyWaterGoalMl = 2500,
    this.dailyStepsGoal = 10000,
    this.dailyCalorieGoal = 2000,
    this.targetWeightKg = 70,
    this.sleepGoalHours = 8,
    this.geminiApiKey,
  });
}

// ─── HABIT ───────────────────────────────────────────────────
@HiveType(typeId: 1)
class Habit extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String name;
  @HiveField(2) String description;
  @HiveField(3) String icon;
  @HiveField(4) int colorIndex;
  @HiveField(5) String frequency; // daily, weekdays, weekends, custom
  @HiveField(6) List<int> weekDays; // 1=Mon ... 7=Sun
  @HiveField(7) String? reminderTime; // "HH:mm"
  @HiveField(8) bool reminderEnabled;
  @HiveField(9) DateTime createdAt;
  @HiveField(10) List<DateTime> completedDates;
  @HiveField(11) int currentStreak;
  @HiveField(12) int longestStreak;
  @HiveField(13) bool isArchived;
  @HiveField(14) String category; // health, fitness, mindfulness, productivity, social, learning

  Habit({
    required this.id,
    required this.name,
    this.description = '',
    required this.icon,
    this.colorIndex = 0,
    this.frequency = 'daily',
    this.weekDays = const [1, 2, 3, 4, 5, 6, 7],
    this.reminderTime,
    this.reminderEnabled = false,
    required this.createdAt,
    this.completedDates = const [],
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.isArchived = false,
    this.category = 'health',
  });

  bool isCompletedOn(DateTime date) {
    return completedDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
  }

  double getCompletionRate({int days = 30}) {
    final now = DateTime.now();
    int completed = 0;
    int total = 0;
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      if (weekDays.contains(date.weekday)) {
        total++;
        if (isCompletedOn(date)) completed++;
      }
    }
    return total == 0 ? 0 : completed / total;
  }
}

// ─── WATER ───────────────────────────────────────────────────
@HiveType(typeId: 2)
class WaterLog extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) DateTime timestamp;
  @HiveField(2) int amountMl;
  @HiveField(3) String drinkType; // water, tea, coffee, juice, etc.

  WaterLog({
    required this.id,
    required this.timestamp,
    required this.amountMl,
    this.drinkType = 'water',
  });
}

// ─── WORKOUT ─────────────────────────────────────────────────
@HiveType(typeId: 3)
class WorkoutSession extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String name;
  @HiveField(2) String type; // strength, cardio, hiit, yoga, flexibility, sports
  @HiveField(3) DateTime startTime;
  @HiveField(4) DateTime? endTime;
  @HiveField(5) int durationMinutes;
  @HiveField(6) int? caloriesBurned;
  @HiveField(7) List<ExerciseSet> exercises;
  @HiveField(8) String? notes;
  @HiveField(9) int ratingOutOf5;
  @HiveField(10) String? muscleGroups; // comma-separated

  WorkoutSession({
    required this.id,
    required this.name,
    required this.type,
    required this.startTime,
    this.endTime,
    this.durationMinutes = 0,
    this.caloriesBurned,
    this.exercises = const [],
    this.notes,
    this.ratingOutOf5 = 0,
    this.muscleGroups,
  });
}

@HiveType(typeId: 4)
class ExerciseSet extends HiveObject {
  @HiveField(0) String exerciseName;
  @HiveField(1) String exerciseType; // reps, duration, distance
  @HiveField(2) List<SetEntry> sets;
  @HiveField(3) String? notes;
  @HiveField(4) String muscleGroup;

  ExerciseSet({
    required this.exerciseName,
    required this.exerciseType,
    this.sets = const [],
    this.notes,
    this.muscleGroup = '',
  });
}

@HiveType(typeId: 5)
class SetEntry extends HiveObject {
  @HiveField(0) int? reps;
  @HiveField(1) double? weightKg;
  @HiveField(2) int? durationSeconds;
  @HiveField(3) double? distanceKm;
  @HiveField(4) bool isCompleted;

  SetEntry({
    this.reps,
    this.weightKg,
    this.durationSeconds,
    this.distanceKm,
    this.isCompleted = false,
  });
}

// ─── SLEEP ───────────────────────────────────────────────────
@HiveType(typeId: 6)
class SleepLog extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) DateTime bedTime;
  @HiveField(2) DateTime wakeTime;
  @HiveField(3) int qualityOutOf5;
  @HiveField(4) String? notes;
  @HiveField(5) List<String> factors; // alcohol, caffeine, exercise, stress, etc.
  @HiveField(6) bool hadDreams;
  @HiveField(7) String? mood; // morning mood

  SleepLog({
    required this.id,
    required this.bedTime,
    required this.wakeTime,
    this.qualityOutOf5 = 3,
    this.notes,
    this.factors = const [],
    this.hadDreams = false,
    this.mood,
  });

  double get durationHours {
    return wakeTime.difference(bedTime).inMinutes / 60.0;
  }

  String get durationFormatted {
    final mins = wakeTime.difference(bedTime).inMinutes;
    return '${mins ~/ 60}h ${mins % 60}m';
  }
}

// ─── WEIGHT ──────────────────────────────────────────────────
@HiveType(typeId: 7)
class WeightLog extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) DateTime date;
  @HiveField(2) double weightKg;
  @HiveField(3) double? bodyFatPercent;
  @HiveField(4) double? muscleMassKg;
  @HiveField(5) double? bmi;
  @HiveField(6) String? notes;
  @HiveField(7) String? photoPath;
  @HiveField(8) double? chestCm;
  @HiveField(9) double? waistCm;
  @HiveField(10) double? armCm;
  @HiveField(11) double? legCm;

  WeightLog({
    required this.id,
    required this.date,
    required this.weightKg,
    this.bodyFatPercent,
    this.muscleMassKg,
    this.bmi,
    this.notes,
    this.photoPath,
    this.chestCm,
    this.waistCm,
    this.armCm,
    this.legCm,
  });
}

// ─── MOOD ────────────────────────────────────────────────────
@HiveType(typeId: 8)
class MoodLog extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) DateTime timestamp;
  @HiveField(2) int moodScore; // 1-5 (terrible to excellent)
  @HiveField(3) String moodEmoji;
  @HiveField(4) List<String> emotions; // tags: happy, anxious, calm, etc.
  @HiveField(5) String? notes;
  @HiveField(6) List<String> activities; // what you were doing

  MoodLog({
    required this.id,
    required this.timestamp,
    required this.moodScore,
    required this.moodEmoji,
    this.emotions = const [],
    this.notes,
    this.activities = const [],
  });

  static String emojiForScore(int score) {
    switch (score) {
      case 1: return '😞';
      case 2: return '😕';
      case 3: return '😐';
      case 4: return '😊';
      case 5: return '😄';
      default: return '😐';
    }
  }

  static String labelForScore(int score) {
    switch (score) {
      case 1: return 'Terrible';
      case 2: return 'Bad';
      case 3: return 'Okay';
      case 4: return 'Good';
      case 5: return 'Excellent';
      default: return 'Okay';
    }
  }
}

// ─── CALORIE / NUTRITION ────────────────────────────────────
@HiveType(typeId: 9)
class NutritionLog extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) DateTime date;
  @HiveField(2) String mealType; // breakfast, lunch, dinner, snack
  @HiveField(3) String foodName;
  @HiveField(4) double calories;
  @HiveField(5) double? proteinG;
  @HiveField(6) double? carbsG;
  @HiveField(7) double? fatG;
  @HiveField(8) double servingSize;
  @HiveField(9) String servingUnit; // g, ml, piece, cup

  NutritionLog({
    required this.id,
    required this.date,
    required this.mealType,
    required this.foodName,
    required this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.servingSize = 100,
    this.servingUnit = 'g',
  });
}

// ─── STEP / ACTIVITY ─────────────────────────────────────────
@HiveType(typeId: 10)
class StepLog extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) DateTime date;
  @HiveField(2) int steps;
  @HiveField(3) double? distanceKm;
  @HiveField(4) int? caloriesBurned;
  @HiveField(5) int? activeMinutes;

  StepLog({
    required this.id,
    required this.date,
    required this.steps,
    this.distanceKm,
    this.caloriesBurned,
    this.activeMinutes,
  });
}

// ─── SUBSCRIPTION ────────────────────────────────────────────
class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double priceINR;
  final double priceUSD;
  final String period; // monthly, yearly, lifetime
  final List<String> features;
  final bool isPopular;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.priceINR,
    required this.priceUSD,
    required this.period,
    required this.features,
    this.isPopular = false,
  });

  static const plans = [
    SubscriptionPlan(
      id: 'ufit_pro_monthly',
      name: 'Pro Monthly',
      description: 'Full access, billed monthly',
      priceINR: 299,
      priceUSD: 3.99,
      period: 'monthly',
      features: [
        'Unlimited habits',
        'Advanced analytics & charts',
        'AI-powered insights',
        'Progress photos',
        'Custom workout builder',
        'Export data (CSV/PDF)',
        'No ads',
        'Priority support',
      ],
    ),
    SubscriptionPlan(
      id: 'ufit_pro_yearly',
      name: 'Pro Yearly',
      description: 'Save 58% — best value!',
      priceINR: 1499,
      priceUSD: 19.99,
      period: 'yearly',
      features: [
        'Everything in Monthly',
        '58% savings vs monthly',
        'Advanced sleep analysis',
        'Nutrition tracking',
        'Workout templates library',
        'Streak protection (2x/year)',
        'Family sharing (up to 5)',
        'Dedicated support',
      ],
      isPopular: true,
    ),
    SubscriptionPlan(
      id: 'ufit_pro_lifetime',
      name: 'Lifetime',
      description: 'One-time purchase, forever',
      priceINR: 2999,
      priceUSD: 39.99,
      period: 'lifetime',
      features: [
        'Everything in Yearly',
        'Pay once, use forever',
        'All future features',
        'Lifetime updates',
        'Beta access to new features',
        'Premium badge',
      ],
    ),
  ];
}

// ─── WORKOUT TEMPLATE ────────────────────────────────────────
@HiveType(typeId: 12)
class WorkoutTemplate extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String name;
  @HiveField(2) String type;
  @HiveField(3) List<ExerciseSet> exercises;
  @HiveField(4) String? notes;

  WorkoutTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.exercises,
    this.notes,
  });
}
