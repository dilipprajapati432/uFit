// lib/models/fasting_session.dart

class FastingSession {
  String id;
  DateTime startTime;
  DateTime? endTime;
  int targetDurationHours; // e.g., 16 for 16:8 fasting
  bool isCompleted;

  FastingSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.targetDurationHours,
    this.isCompleted = false,
  });

  // Calculate elapsed duration
  Duration get elapsed => (endTime ?? DateTime.now()).difference(startTime);

  // Calculate remaining duration based on target
  Duration get remaining {
    final target = Duration(hours: targetDurationHours);
    final diff = target - elapsed;
    return diff.isNegative ? Duration.zero : diff;
  }

  // Calculate progress percentage 0.0 to 1.0
  double get progress {
    final targetMs = Duration(hours: targetDurationHours).inMilliseconds;
    if (targetMs == 0) return 0.0;
    final progress = elapsed.inMilliseconds / targetMs;
    return progress > 1.0 ? 1.0 : progress;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'targetDurationHours': targetDurationHours,
      'isCompleted': isCompleted,
    };
  }

  factory FastingSession.fromMap(Map<String, dynamic> map, String id) {
    return FastingSession(
      id: id,
      startTime: map['startTime'] != null ? DateTime.parse(map['startTime']) : DateTime.now(),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      targetDurationHours: map['targetDurationHours']?.toInt() ?? 16,
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
