import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../models/models.dart';

class AiService {
  static const String _groqApiKey = 'YOUR_GROQ_API_KEY_HERE';
  static const String _groqUrl = 'https://api.groq.com/openai/v1/chat/completions';

  static Future<String> generateInsights() async {

    // Collect last 7 days of data
    final now = DateTime.now();
    final aWeekAgo = now.subtract(const Duration(days: 7));
    
    final habits = Hive.box<Habit>('habits').values.toList();
    final workouts = Hive.box<WorkoutSession>('workouts').values
        .where((w) => w.startTime.isAfter(aWeekAgo))
        .toList();
    final water = Hive.box<WaterLog>('water_logs').values
        .where((w) => w.timestamp.isAfter(aWeekAgo))
        .toList();
    final sleep = Hive.box<SleepLog>('sleep_logs').values
        .where((s) => s.bedTime.isAfter(aWeekAgo))
        .toList();

    // Build the prompt context
    int totalWorkouts = workouts.length;
    int totalWaterMl = water.fold(0, (sum, w) => sum + w.amountMl);
    double avgSleep = sleep.isEmpty ? 0 : sleep.fold(0.0, (sum, s) => sum + s.durationHours) / sleep.length;
    int activeHabits = habits.where((h) => h.currentStreak > 0).length;

    final prompt = """
You are a highly motivating AI fitness and wellness coach analyzing a user's recent activity in the uFit app.
Over the last 7 days, the user has:
- Completed $totalWorkouts workout sessions
- Logged a total of $totalWaterMl ml of water
- Averaged ${avgSleep.toStringAsFixed(1)} hours of sleep per night
- Maintained active streaks on $activeHabits habits

Based on this data, provide 2 short, punchy, and highly motivating insights or actionable tips. 
Keep each insight to one sentence. Use emojis. Format as a bulleted list.
Do not include any pleasantries or conversational filler, just the bullet points.
""";

    try {
      final response = await http.post(
        Uri.parse(_groqUrl),
        headers: {
          'Authorization': 'Bearer $_groqApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "llama-3.1-8b-instant",
          "messages": [
            {
              "role": "user",
              "content": prompt,
            }
          ],
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String;
        return reply.trim();
      } else {
        return "Keep up the great work! Consistency is key. 🔥";
      }
    } catch (e) {
      return "Unable to connect to AI right now. Keep pushing towards your goals! 💪";
    }
  }

  static Future<String> chatWithCoach(List<Map<String, String>> conversationHistory) async {
    // Collect user stats for context
    final now = DateTime.now();
    final aWeekAgo = now.subtract(const Duration(days: 7));
    
    final habits = Hive.box<Habit>('habits').values.toList();
    final workouts = Hive.box<WorkoutSession>('workouts').values
        .where((w) => w.startTime.isAfter(aWeekAgo))
        .toList();
    final water = Hive.box<WaterLog>('water_logs').values
        .where((w) => w.timestamp.isAfter(aWeekAgo))
        .toList();
    final sleep = Hive.box<SleepLog>('sleep_logs').values
        .where((s) => s.bedTime.isAfter(aWeekAgo))
        .toList();

    int totalWorkouts = workouts.length;
    int totalWaterMl = water.fold(0, (sum, w) => sum + w.amountMl);
    double avgSleep = sleep.isEmpty ? 0 : sleep.fold(0.0, (sum, s) => sum + s.durationHours) / sleep.length;
    int activeHabits = habits.where((h) => h.currentStreak > 0).length;

    final systemPrompt = """
You are 'uFit AI', a friendly, highly motivating, and knowledgeable AI fitness coach built into the uFit app.
You provide concise, actionable, and encouraging fitness, nutrition, and wellness advice.
Keep your responses relatively brief (1-3 short paragraphs) as the user is reading on a mobile device. Use emojis occasionally.

USER'S RECENT 7-DAY STATS:
- Workouts completed: $totalWorkouts
- Total Water: $totalWaterMl ml
- Avg Sleep: ${avgSleep.toStringAsFixed(1)} hours/night
- Active Habits: $activeHabits

Use this context subtly if it helps answer their question, but do not just list their stats back to them. Be helpful and conversational!
""";

    final messages = [
      {"role": "system", "content": systemPrompt},
      ...conversationHistory.map((m) => {
        "role": m["role"]!,
        "content": m["content"]!
      }),
    ];

    try {
      final response = await http.post(
        Uri.parse(_groqUrl),
        headers: {
          'Authorization': 'Bearer $_groqApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "llama-3.1-8b-instant",
          "messages": messages,
          "temperature": 0.7,
          "max_tokens": 512,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String;
        return reply.trim();
      } else {
        return "Error ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      return "Whoops, there's a connection issue. Keep pushing towards your goals while I get back online!";
    }
  }
}
