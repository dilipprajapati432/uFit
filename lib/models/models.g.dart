// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      photoUrl: fields[3] as String?,
      createdAt: fields[4] as DateTime,
      isPremium: fields[5] as bool,
      premiumExpiry: fields[6] as DateTime?,
      heightCm: fields[7] as double?,
      weightKg: fields[8] as double?,
      age: fields[9] as int?,
      gender: fields[10] as String?,
      fitnessGoal: fields[11] as String?,
      dailyWaterGoalMl: fields[12] as int,
      dailyStepsGoal: fields[13] as int,
      dailyCalorieGoal: fields[14] as int,
      targetWeightKg: fields[15] as double,
      sleepGoalHours: fields[16] as int,
      geminiApiKey: fields[17] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.photoUrl)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.isPremium)
      ..writeByte(6)
      ..write(obj.premiumExpiry)
      ..writeByte(7)
      ..write(obj.heightCm)
      ..writeByte(8)
      ..write(obj.weightKg)
      ..writeByte(9)
      ..write(obj.age)
      ..writeByte(10)
      ..write(obj.gender)
      ..writeByte(11)
      ..write(obj.fitnessGoal)
      ..writeByte(12)
      ..write(obj.dailyWaterGoalMl)
      ..writeByte(13)
      ..write(obj.dailyStepsGoal)
      ..writeByte(14)
      ..write(obj.dailyCalorieGoal)
      ..writeByte(15)
      ..write(obj.targetWeightKg)
      ..writeByte(16)
      ..write(obj.sleepGoalHours)
      ..writeByte(17)
      ..write(obj.geminiApiKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 1;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      icon: fields[3] as String,
      colorIndex: fields[4] as int,
      frequency: fields[5] as String,
      weekDays: (fields[6] as List).cast<int>(),
      reminderTime: fields[7] as String?,
      reminderEnabled: fields[8] as bool,
      createdAt: fields[9] as DateTime,
      completedDates: (fields[10] as List).cast<DateTime>(),
      currentStreak: fields[11] as int,
      longestStreak: fields[12] as int,
      isArchived: fields[13] as bool,
      category: fields[14] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.icon)
      ..writeByte(4)
      ..write(obj.colorIndex)
      ..writeByte(5)
      ..write(obj.frequency)
      ..writeByte(6)
      ..write(obj.weekDays)
      ..writeByte(7)
      ..write(obj.reminderTime)
      ..writeByte(8)
      ..write(obj.reminderEnabled)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.completedDates)
      ..writeByte(11)
      ..write(obj.currentStreak)
      ..writeByte(12)
      ..write(obj.longestStreak)
      ..writeByte(13)
      ..write(obj.isArchived)
      ..writeByte(14)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WaterLogAdapter extends TypeAdapter<WaterLog> {
  @override
  final int typeId = 2;

  @override
  WaterLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WaterLog(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      amountMl: fields[2] as int,
      drinkType: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WaterLog obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.amountMl)
      ..writeByte(3)
      ..write(obj.drinkType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WaterLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WorkoutSessionAdapter extends TypeAdapter<WorkoutSession> {
  @override
  final int typeId = 3;

  @override
  WorkoutSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutSession(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as String,
      startTime: fields[3] as DateTime,
      endTime: fields[4] as DateTime?,
      durationMinutes: fields[5] as int,
      caloriesBurned: fields[6] as int?,
      exercises: (fields[7] as List).cast<ExerciseSet>(),
      notes: fields[8] as String?,
      ratingOutOf5: fields[9] as int,
      muscleGroups: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSession obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.startTime)
      ..writeByte(4)
      ..write(obj.endTime)
      ..writeByte(5)
      ..write(obj.durationMinutes)
      ..writeByte(6)
      ..write(obj.caloriesBurned)
      ..writeByte(7)
      ..write(obj.exercises)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.ratingOutOf5)
      ..writeByte(10)
      ..write(obj.muscleGroups);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExerciseSetAdapter extends TypeAdapter<ExerciseSet> {
  @override
  final int typeId = 4;

  @override
  ExerciseSet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseSet(
      exerciseName: fields[0] as String,
      exerciseType: fields[1] as String,
      sets: (fields[2] as List).cast<SetEntry>(),
      notes: fields[3] as String?,
      muscleGroup: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseSet obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.exerciseName)
      ..writeByte(1)
      ..write(obj.exerciseType)
      ..writeByte(2)
      ..write(obj.sets)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.muscleGroup);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseSetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SetEntryAdapter extends TypeAdapter<SetEntry> {
  @override
  final int typeId = 5;

  @override
  SetEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SetEntry(
      reps: fields[0] as int?,
      weightKg: fields[1] as double?,
      durationSeconds: fields[2] as int?,
      distanceKm: fields[3] as double?,
      isCompleted: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SetEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.reps)
      ..writeByte(1)
      ..write(obj.weightKg)
      ..writeByte(2)
      ..write(obj.durationSeconds)
      ..writeByte(3)
      ..write(obj.distanceKm)
      ..writeByte(4)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SleepLogAdapter extends TypeAdapter<SleepLog> {
  @override
  final int typeId = 6;

  @override
  SleepLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SleepLog(
      id: fields[0] as String,
      bedTime: fields[1] as DateTime,
      wakeTime: fields[2] as DateTime,
      qualityOutOf5: fields[3] as int,
      notes: fields[4] as String?,
      factors: (fields[5] as List).cast<String>(),
      hadDreams: fields[6] as bool,
      mood: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SleepLog obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.bedTime)
      ..writeByte(2)
      ..write(obj.wakeTime)
      ..writeByte(3)
      ..write(obj.qualityOutOf5)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.factors)
      ..writeByte(6)
      ..write(obj.hadDreams)
      ..writeByte(7)
      ..write(obj.mood);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WeightLogAdapter extends TypeAdapter<WeightLog> {
  @override
  final int typeId = 7;

  @override
  WeightLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeightLog(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      weightKg: fields[2] as double,
      bodyFatPercent: fields[3] as double?,
      muscleMassKg: fields[4] as double?,
      bmi: fields[5] as double?,
      notes: fields[6] as String?,
      photoPath: fields[7] as String?,
      chestCm: fields[8] as double?,
      waistCm: fields[9] as double?,
      armCm: fields[10] as double?,
      legCm: fields[11] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, WeightLog obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.weightKg)
      ..writeByte(3)
      ..write(obj.bodyFatPercent)
      ..writeByte(4)
      ..write(obj.muscleMassKg)
      ..writeByte(5)
      ..write(obj.bmi)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.photoPath)
      ..writeByte(8)
      ..write(obj.chestCm)
      ..writeByte(9)
      ..write(obj.waistCm)
      ..writeByte(10)
      ..write(obj.armCm)
      ..writeByte(11)
      ..write(obj.legCm);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MoodLogAdapter extends TypeAdapter<MoodLog> {
  @override
  final int typeId = 8;

  @override
  MoodLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MoodLog(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      moodScore: fields[2] as int,
      moodEmoji: fields[3] as String,
      emotions: (fields[4] as List).cast<String>(),
      notes: fields[5] as String?,
      activities: (fields[6] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, MoodLog obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.moodScore)
      ..writeByte(3)
      ..write(obj.moodEmoji)
      ..writeByte(4)
      ..write(obj.emotions)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.activities);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NutritionLogAdapter extends TypeAdapter<NutritionLog> {
  @override
  final int typeId = 9;

  @override
  NutritionLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NutritionLog(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      mealType: fields[2] as String,
      foodName: fields[3] as String,
      calories: fields[4] as double,
      proteinG: fields[5] as double?,
      carbsG: fields[6] as double?,
      fatG: fields[7] as double?,
      servingSize: fields[8] as double,
      servingUnit: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NutritionLog obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.mealType)
      ..writeByte(3)
      ..write(obj.foodName)
      ..writeByte(4)
      ..write(obj.calories)
      ..writeByte(5)
      ..write(obj.proteinG)
      ..writeByte(6)
      ..write(obj.carbsG)
      ..writeByte(7)
      ..write(obj.fatG)
      ..writeByte(8)
      ..write(obj.servingSize)
      ..writeByte(9)
      ..write(obj.servingUnit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StepLogAdapter extends TypeAdapter<StepLog> {
  @override
  final int typeId = 10;

  @override
  StepLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StepLog(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      steps: fields[2] as int,
      distanceKm: fields[3] as double?,
      caloriesBurned: fields[4] as int?,
      activeMinutes: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, StepLog obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.steps)
      ..writeByte(3)
      ..write(obj.distanceKm)
      ..writeByte(4)
      ..write(obj.caloriesBurned)
      ..writeByte(5)
      ..write(obj.activeMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StepLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WorkoutTemplateAdapter extends TypeAdapter<WorkoutTemplate> {
  @override
  final int typeId = 12;

  @override
  WorkoutTemplate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutTemplate(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as String,
      exercises: (fields[3] as List).cast<ExerciseSet>(),
      notes: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutTemplate obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.exercises)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutTemplateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
