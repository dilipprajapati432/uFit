import 'package:health/health.dart';

class HealthService {
  static final Health _health = Health();

  static Future<bool> requestPermissions() async {
    final types = [HealthDataType.STEPS, HealthDataType.SLEEP_IN_BED];
    final permissions = [HealthDataAccess.READ, HealthDataAccess.READ];
    
    try {
      final hasPermissions = await _health.hasPermissions(types, permissions: permissions) ?? false;
      if (hasPermissions) return true;
      
      final requested = await _health.requestAuthorization(types, permissions: permissions);
      return requested;
    } catch (e) {
      print('Health permission error: $e');
      return false;
    }
  }

  static Future<int> getTodaySteps() async {
    final hasPerms = await requestPermissions();
    if (!hasPerms) return 0;

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    
    try {
      final steps = await _health.getTotalStepsInInterval(midnight, now);
      return steps ?? 0;
    } catch (e) {
      print('Health fetching steps error: $e');
      return 0;
    }
  }
}
