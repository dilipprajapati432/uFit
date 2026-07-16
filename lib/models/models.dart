// lib/models/models.dart

// ─── USER ────────────────────────────────────────────────────
class UserModel {
  String id;
  String name;
  String email;
  String? photoUrl;
  DateTime createdAt;
  bool isPremium;
  DateTime? premiumExpiry;
  String? premiumPlan;
  double? heightCm;
  double? weightKg;
  int? age;
  String? gender;
  String? fitnessGoal; // lose_weight, gain_muscle, maintain, active_lifestyle
  String? dietaryPreference;
  int dailyWaterGoalMl;
  int dailyStepsGoal;
  int dailyCalorieGoal;
  double targetWeightKg;
  int sleepGoalHours;
  String? geminiApiKey;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    this.isPremium = false,
    this.premiumExpiry,
    this.premiumPlan,
    this.heightCm,
    this.weightKg,
    this.age,
    this.gender,
    this.fitnessGoal,
    this.dietaryPreference,
    this.dailyWaterGoalMl = 2500,
    this.dailyStepsGoal = 10000,
    this.dailyCalorieGoal = 2000,
    this.targetWeightKg = 70,
    this.sleepGoalHours = 8,
    this.geminiApiKey,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'isPremium': isPremium,
      'premiumExpiry': premiumExpiry?.toIso8601String(),
      'premiumPlan': premiumPlan,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'age': age,
      'gender': gender,
      'fitnessGoal': fitnessGoal,
      'dietaryPreference': dietaryPreference,
      'dailyWaterGoalMl': dailyWaterGoalMl,
      'dailyStepsGoal': dailyStepsGoal,
      'dailyCalorieGoal': dailyCalorieGoal,
      'targetWeightKg': targetWeightKg,
      'sleepGoalHours': sleepGoalHours,
      'geminiApiKey': geminiApiKey,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      isPremium: map['isPremium'] ?? false,
      premiumExpiry: map['premiumExpiry'] != null ? DateTime.parse(map['premiumExpiry']) : null,
      premiumPlan: map['premiumPlan'],
      heightCm: map['heightCm']?.toDouble(),
      weightKg: map['weightKg']?.toDouble(),
      age: map['age']?.toInt(),
      gender: map['gender'],
      fitnessGoal: map['fitnessGoal'],
      dietaryPreference: map['dietaryPreference'],
      dailyWaterGoalMl: map['dailyWaterGoalMl']?.toInt() ?? 2500,
      dailyStepsGoal: map['dailyStepsGoal']?.toInt() ?? 10000,
      dailyCalorieGoal: map['dailyCalorieGoal']?.toInt() ?? 2000,
      targetWeightKg: map['targetWeightKg']?.toDouble() ?? 70.0,
      sleepGoalHours: map['sleepGoalHours']?.toInt() ?? 8,
      geminiApiKey: map['geminiApiKey'],
    );
  }
}

// ─── HABIT ───────────────────────────────────────────────────
class Habit {
  String id;
  String name;
  String description;
  String icon;
  int colorIndex;
  String frequency; // daily, weekdays, weekends, custom
  List<int> weekDays; // 1=Mon ... 7=Sun
  String? reminderTime; // "HH:mm"
  bool reminderEnabled;
  DateTime createdAt;
  List<DateTime> completedDates;
  int currentStreak;
  int longestStreak;
  bool isArchived;
  String category; // health, fitness, mindfulness, productivity, social, learning

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'colorIndex': colorIndex,
      'frequency': frequency,
      'weekDays': weekDays,
      'reminderTime': reminderTime,
      'reminderEnabled': reminderEnabled,
      'createdAt': createdAt.toIso8601String(),
      'completedDates': completedDates.map((d) => d.toIso8601String()).toList(),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'isArchived': isArchived,
      'category': category,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map, String id) {
    return Habit(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '',
      colorIndex: map['colorIndex']?.toInt() ?? 0,
      frequency: map['frequency'] ?? 'daily',
      weekDays: List<int>.from(map['weekDays'] ?? [1, 2, 3, 4, 5, 6, 7]),
      reminderTime: map['reminderTime'],
      reminderEnabled: map['reminderEnabled'] ?? false,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      completedDates: (map['completedDates'] as List<dynamic>?)?.map((d) => DateTime.parse(d)).toList() ?? [],
      currentStreak: map['currentStreak']?.toInt() ?? 0,
      longestStreak: map['longestStreak']?.toInt() ?? 0,
      isArchived: map['isArchived'] ?? false,
      category: map['category'] ?? 'health',
    );
  }
}

// ─── WATER ───────────────────────────────────────────────────
class WaterLog {
  String id;
  DateTime timestamp;
  int amountMl;
  String drinkType; // water, tea, coffee, juice, etc.

  WaterLog({
    required this.id,
    required this.timestamp,
    required this.amountMl,
    this.drinkType = 'water',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'amountMl': amountMl,
      'drinkType': drinkType,
    };
  }

  factory WaterLog.fromMap(Map<String, dynamic> map, String id) {
    return WaterLog(
      id: id,
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
      amountMl: map['amountMl']?.toInt() ?? 0,
      drinkType: map['drinkType'] ?? 'water',
    );
  }
}

// ─── WORKOUT ─────────────────────────────────────────────────
class WorkoutSession {
  String id;
  String name;
  String type; // strength, cardio, hiit, yoga, flexibility, sports
  DateTime startTime;
  DateTime? endTime;
  int durationMinutes;
  int? caloriesBurned;
  List<ExerciseSet> exercises;
  String? notes;
  int ratingOutOf5;
  String? muscleGroups; // comma-separated

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'notes': notes,
      'ratingOutOf5': ratingOutOf5,
      'muscleGroups': muscleGroups,
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map, String id) {
    return WorkoutSession(
      id: id,
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      startTime: map['startTime'] != null ? DateTime.parse(map['startTime']) : DateTime.now(),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      durationMinutes: map['durationMinutes']?.toInt() ?? 0,
      caloriesBurned: map['caloriesBurned']?.toInt(),
      exercises: (map['exercises'] as List<dynamic>?)?.map((e) => ExerciseSet.fromMap(e)).toList() ?? [],
      notes: map['notes'],
      ratingOutOf5: map['ratingOutOf5']?.toInt() ?? 0,
      muscleGroups: map['muscleGroups'],
    );
  }
}

class ExerciseSet {
  String exerciseName;
  String exerciseType; // reps, duration, distance
  List<SetEntry> sets;
  String? notes;
  String muscleGroup;

  ExerciseSet({
    required this.exerciseName,
    required this.exerciseType,
    this.sets = const [],
    this.notes,
    this.muscleGroup = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'exerciseName': exerciseName,
      'exerciseType': exerciseType,
      'sets': sets.map((s) => s.toMap()).toList(),
      'notes': notes,
      'muscleGroup': muscleGroup,
    };
  }

  factory ExerciseSet.fromMap(Map<String, dynamic> map) {
    return ExerciseSet(
      exerciseName: map['exerciseName'] ?? '',
      exerciseType: map['exerciseType'] ?? '',
      sets: (map['sets'] as List<dynamic>?)?.map((s) => SetEntry.fromMap(s)).toList() ?? [],
      notes: map['notes'],
      muscleGroup: map['muscleGroup'] ?? '',
    );
  }
}

class SetEntry {
  int? reps;
  double? weightKg;
  int? durationSeconds;
  double? distanceKm;
  bool isCompleted;

  SetEntry({
    this.reps,
    this.weightKg,
    this.durationSeconds,
    this.distanceKm,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'reps': reps,
      'weightKg': weightKg,
      'durationSeconds': durationSeconds,
      'distanceKm': distanceKm,
      'isCompleted': isCompleted,
    };
  }

  factory SetEntry.fromMap(Map<String, dynamic> map) {
    return SetEntry(
      reps: map['reps']?.toInt(),
      weightKg: map['weightKg']?.toDouble(),
      durationSeconds: map['durationSeconds']?.toInt(),
      distanceKm: map['distanceKm']?.toDouble(),
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

// ─── SLEEP ───────────────────────────────────────────────────
class SleepLog {
  String id;
  DateTime bedTime;
  DateTime wakeTime;
  int qualityOutOf5;
  String? notes;
  List<String> factors; // alcohol, caffeine, exercise, stress, etc.
  bool hadDreams;
  String? mood; // morning mood

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bedTime': bedTime.toIso8601String(),
      'wakeTime': wakeTime.toIso8601String(),
      'qualityOutOf5': qualityOutOf5,
      'notes': notes,
      'factors': factors,
      'hadDreams': hadDreams,
      'mood': mood,
    };
  }

  factory SleepLog.fromMap(Map<String, dynamic> map, String id) {
    return SleepLog(
      id: id,
      bedTime: map['bedTime'] != null ? DateTime.parse(map['bedTime']) : DateTime.now(),
      wakeTime: map['wakeTime'] != null ? DateTime.parse(map['wakeTime']) : DateTime.now(),
      qualityOutOf5: map['qualityOutOf5']?.toInt() ?? 3,
      notes: map['notes'],
      factors: List<String>.from(map['factors'] ?? []),
      hadDreams: map['hadDreams'] ?? false,
      mood: map['mood'],
    );
  }
}

// ─── WEIGHT ──────────────────────────────────────────────────
class WeightLog {
  String id;
  DateTime date;
  double weightKg;
  double? bodyFatPercent;
  double? muscleMassKg;
  double? bmi;
  String? notes;
  String? photoPath;
  double? chestCm;
  double? waistCm;
  double? armCm;
  double? legCm;

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'weightKg': weightKg,
      'bodyFatPercent': bodyFatPercent,
      'muscleMassKg': muscleMassKg,
      'bmi': bmi,
      'notes': notes,
      'photoPath': photoPath,
      'chestCm': chestCm,
      'waistCm': waistCm,
      'armCm': armCm,
      'legCm': legCm,
    };
  }

  factory WeightLog.fromMap(Map<String, dynamic> map, String id) {
    return WeightLog(
      id: id,
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      weightKg: map['weightKg']?.toDouble() ?? 0.0,
      bodyFatPercent: map['bodyFatPercent']?.toDouble(),
      muscleMassKg: map['muscleMassKg']?.toDouble(),
      bmi: map['bmi']?.toDouble(),
      notes: map['notes'],
      photoPath: map['photoPath'],
      chestCm: map['chestCm']?.toDouble(),
      waistCm: map['waistCm']?.toDouble(),
      armCm: map['armCm']?.toDouble(),
      legCm: map['legCm']?.toDouble(),
    );
  }
}

// ─── MOOD ────────────────────────────────────────────────────
class MoodLog {
  String id;
  DateTime timestamp;
  int moodScore; // 1-5 (terrible to excellent)
  String moodEmoji;
  List<String> emotions; // tags: happy, anxious, calm, etc.
  String? notes;
  List<String> activities; // what you were doing

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'moodScore': moodScore,
      'moodEmoji': moodEmoji,
      'emotions': emotions,
      'notes': notes,
      'activities': activities,
    };
  }

  factory MoodLog.fromMap(Map<String, dynamic> map, String id) {
    return MoodLog(
      id: id,
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
      moodScore: map['moodScore']?.toInt() ?? 3,
      moodEmoji: map['moodEmoji'] ?? '😐',
      emotions: List<String>.from(map['emotions'] ?? []),
      notes: map['notes'],
      activities: List<String>.from(map['activities'] ?? []),
    );
  }
}

// ─── CALORIE / NUTRITION ────────────────────────────────────
class NutritionLog {
  String id;
  DateTime date;
  String mealType; // breakfast, lunch, dinner, snack
  String foodName;
  double calories;
  double? proteinG;
  double? carbsG;
  double? fatG;
  double servingSize;
  String servingUnit; // g, ml, piece, cup

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mealType': mealType,
      'foodName': foodName,
      'calories': calories,
      'proteinG': proteinG,
      'carbsG': carbsG,
      'fatG': fatG,
      'servingSize': servingSize,
      'servingUnit': servingUnit,
    };
  }

  factory NutritionLog.fromMap(Map<String, dynamic> map, String id) {
    return NutritionLog(
      id: id,
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      mealType: map['mealType'] ?? 'snack',
      foodName: map['foodName'] ?? '',
      calories: map['calories']?.toDouble() ?? 0.0,
      proteinG: map['proteinG']?.toDouble(),
      carbsG: map['carbsG']?.toDouble(),
      fatG: map['fatG']?.toDouble(),
      servingSize: map['servingSize']?.toDouble() ?? 100.0,
      servingUnit: map['servingUnit'] ?? 'g',
    );
  }
}

// ─── STEP / ACTIVITY ─────────────────────────────────────────
class StepLog {
  String id;
  DateTime date;
  int steps;
  double? distanceKm;
  int? caloriesBurned;
  int? activeMinutes;

  StepLog({
    required this.id,
    required this.date,
    required this.steps,
    this.distanceKm,
    this.caloriesBurned,
    this.activeMinutes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'steps': steps,
      'distanceKm': distanceKm,
      'caloriesBurned': caloriesBurned,
      'activeMinutes': activeMinutes,
    };
  }

  factory StepLog.fromMap(Map<String, dynamic> map, String id) {
    return StepLog(
      id: id,
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      steps: map['steps']?.toInt() ?? 0,
      distanceKm: map['distanceKm']?.toDouble(),
      caloriesBurned: map['caloriesBurned']?.toInt(),
      activeMinutes: map['activeMinutes']?.toInt(),
    );
  }
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
class WorkoutTemplate {
  String id;
  String name;
  String type;
  List<ExerciseSet> exercises;
  String? notes;

  WorkoutTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.exercises,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'notes': notes,
    };
  }

  factory WorkoutTemplate.fromMap(Map<String, dynamic> map, String id) {
    return WorkoutTemplate(
      id: id,
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      exercises: (map['exercises'] as List<dynamic>?)?.map((e) => ExerciseSet.fromMap(e)).toList() ?? [],
      notes: map['notes'],
    );
  }
}
