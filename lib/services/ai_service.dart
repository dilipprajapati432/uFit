import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  static String get _groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static const String _groqUrl = 'https://api.groq.com/openai/v1/chat/completions';
  
  // Cache for nutrition estimates to ensure consistent data for the same query
  static final Map<String, Map<String, dynamic>> _nutritionCache = {};

  static Future<String> generateInsights() async {

    // Collect last 7 days of data
    final now = DateTime.now();
    final aWeekAgo = now.subtract(const Duration(days: 7));
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return "Keep up the great work! Consistency is key. 🔥";
    final uid = user.uid;
    
    final habitsSnap = await FirebaseFirestore.instance.collection('users').doc(uid).collection('habits').get();
    final habits = habitsSnap.docs.map((d) => Habit.fromMap(d.data(), d.id)).toList();
    
    final workoutsSnap = await FirebaseFirestore.instance.collection('users').doc(uid).collection('workouts').get();
    final workouts = workoutsSnap.docs.map((d) => WorkoutSession.fromMap(d.data(), d.id))
        .where((w) => w.startTime.isAfter(aWeekAgo))
        .toList();
        
    final waterSnap = await FirebaseFirestore.instance.collection('users').doc(uid).collection('water_logs').get();
    final water = waterSnap.docs.map((d) => WaterLog.fromMap(d.data(), d.id))
        .where((w) => w.timestamp.isAfter(aWeekAgo))
        .toList();
        
    final sleepSnap = await FirebaseFirestore.instance.collection('users').doc(uid).collection('sleep_logs').get();
    final sleep = sleepSnap.docs.map((d) => SleepLog.fromMap(d.data(), d.id))
        .where((s) => s.bedTime.isAfter(aWeekAgo))
        .toList();

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    int calorieGoal = 2000;
    if (userDoc.exists && userDoc.data() != null) {
      calorieGoal = userDoc.data()!['dailyCalorieGoal'] ?? 2000;
    }

    final nutritionSnap = await FirebaseFirestore.instance.collection('users').doc(uid).collection('nutrition_logs').get();
    final today = DateTime.now();
    final todayNutrition = nutritionSnap.docs.map((d) => NutritionLog.fromMap(d.data(), d.id))
        .where((n) => n.date.year == today.year && n.date.month == today.month && n.date.day == today.day)
        .toList();
    
    double todayCalories = todayNutrition.fold(0.0, (sum, n) => sum + n.calories);

    // Build the prompt context
    int totalWorkouts = workouts.length;
    int totalWaterMl = water.fold<int>(0, (sum, w) => sum + w.amountMl);
    double avgSleep = sleep.isEmpty ? 0 : sleep.fold(0.0, (sum, s) => sum + s.durationHours) / sleep.length;
    int activeHabits = habits.where((h) => h.currentStreak > 0).length;

    final prompt = """
You are an analytical, constructive, and highly motivating AI fitness coach analyzing a user's recent activity in the uFit app.
Over the last 7 days, the user has:
- Completed $totalWorkouts workout sessions
- Logged a total of $totalWaterMl ml of water
- Averaged ${avgSleep.toStringAsFixed(1)} hours of sleep per night
- Maintained active streaks on $activeHabits habits

TODAY'S NUTRITION:
- Consumed: ${todayCalories.toInt()} kcal
- Goal: $calorieGoal kcal

Based on ALL of this data, provide 2 short, punchy, and constructive insights or actionable tips. 
Focus on the most important areas where they need improvement or deserve praise (e.g., maybe their sleep is terrible, maybe they missed their water goal, maybe they are crushing their workouts, or maybe they ate too many calories). 
Do not just be mindlessly positive. If they are slacking in any area, gently but firmly point it out and tell them how to fix it! If they are doing great across the board, praise them.
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
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return "Please log in to chat with uFit AI!";
    final uid = user.uid;
    
    final habitsSnap = await FirebaseFirestore.instance.collection('users').doc(uid).collection('habits').get();
    final habits = habitsSnap.docs.map((d) => Habit.fromMap(d.data(), d.id)).toList();
    
    final workoutsSnap = await FirebaseFirestore.instance.collection('users').doc(uid).collection('workouts').get();
    final workouts = workoutsSnap.docs.map((d) => WorkoutSession.fromMap(d.data(), d.id))
        .where((w) => w.startTime.isAfter(aWeekAgo))
        .toList();
        
    final waterSnap = await FirebaseFirestore.instance.collection('users').doc(uid).collection('water_logs').get();
    final water = waterSnap.docs.map((d) => WaterLog.fromMap(d.data(), d.id))
        .where((w) => w.timestamp.isAfter(aWeekAgo))
        .toList();
        
    final sleepSnap = await FirebaseFirestore.instance.collection('users').doc(uid).collection('sleep_logs').get();
    final sleep = sleepSnap.docs.map((d) => SleepLog.fromMap(d.data(), d.id))
        .where((s) => s.bedTime.isAfter(aWeekAgo))
        .toList();

    int totalWorkouts = workouts.length;
    int totalWaterMl = water.fold<int>(0, (sum, w) => sum + w.amountMl);
    double avgSleep = sleep.isEmpty ? 0 : sleep.fold(0.0, (sum, s) => sum + s.durationHours) / sleep.length;
    int activeHabits = habits.where((h) => h.currentStreak > 0).length;

    final systemPrompt = """
You are 'uFit AI', a friendly, highly motivating, and knowledgeable AI fitness coach built into the uFit app.

RULES FOR SPEAKING:
1. For general chat, keep your responses extremely brief (1-2 short paragraphs maximum) and conversational. Never speak like a long speech or lecture. Use emojis occasionally.
2. If the user asks for a WORKOUT PLAN or MEAL PLAN, you are allowed to give a longer, structured response. Use bullet points and clear headings (e.g., Day 1, Day 2) so it is easy to read on a mobile screen.

APP KNOWLEDGE & FAQ (Answer these directly and concisely if asked):
- "How do I delete my account?": You can delete your account by going to Settings (gear icon) > Account Settings > Delete Account.
- "What is uFit Pro?" or "Subscription": uFit Pro is our premium subscription. It gives you Unlimited Habits, Ad-Free unlimited AI Coaching, Ad-Free PDF Reports, and All-Time History charts. Free users are limited to 3 habits and a 7-day history view.
- "How do I export my data or get a PDF?": Go to Settings (gear icon) > Export Data. (Note: Free users must watch a short ad to generate it).
- "How do I log my water, weight, or sleep?": Use the Quick Log buttons on the Home tab, or tap the specific icons at the bottom of the screen.
- "How do I change my units (kg/lbs) or update my profile?": Go to Settings (gear icon) > Edit Profile to update your height, weight, and units.
- "I have a bug or need help": Please contact the developer directly through the Settings screen.
- If asked an app question NOT in this list: Say "I'm mostly here to help you with fitness and nutrition! For technical app questions, please check the Settings tab."

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

  static Future<Map<String, dynamic>?> estimateNutrition(String foodQuery) async {
    final queryKey = foodQuery.toLowerCase().trim();
    if (_nutritionCache.containsKey(queryKey)) {
      return Map<String, dynamic>.from(_nutritionCache[queryKey]!);
    }

    final prompt = """
You are a highly accurate nutrition database AI.
The user ate: "$foodQuery"

Estimate the nutritional value of this meal. 
Return ONLY a valid JSON object with no markdown formatting, no code blocks, and no extra text.
The JSON must have the following keys:
- "calories" (number)
- "protein" (number, in grams)
- "carbs" (number, in grams)
- "fat" (number, in grams)

Example response:
{"calories": 350, "protein": 15, "carbs": 45, "fat": 12}
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
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.0, // Strict 0.0 for deterministic factual accuracy
          "response_format": {"type": "json_object"}
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String;
        final Map<String, dynamic> parsed = jsonDecode(reply);
        
        // Enforce mathematical accuracy for calories
        final double p = (parsed['protein'] as num?)?.toDouble() ?? 0.0;
        final double c = (parsed['carbs'] as num?)?.toDouble() ?? 0.0;
        final double f = (parsed['fat'] as num?)?.toDouble() ?? 0.0;
        
        // (Protein * 4) + (Carbs * 4) + (Fat * 9)
        final calculatedCalories = (p * 4) + (c * 4) + (f * 9);
        parsed['calories'] = calculatedCalories.round();

        // Cache the result
        _nutritionCache[queryKey] = Map<String, dynamic>.from(parsed);

        return parsed;
      }
    } catch (e) {
      print('AI Nutrition Error: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> generateMealPlan(int targetCalories, {String? dietaryPreference}) async {
    final prefText = dietaryPreference != null && dietaryPreference != 'Any' ? dietaryPreference : 'Any standard balanced diet';
    final prompt = """
You are a highly accurate nutrition AI. 
Generate a 1-day meal plan (Breakfast, Lunch, Snack, Dinner) that totals approximately $targetCalories calories.
The user's dietary preference is: $prefText.
Return ONLY a valid JSON object with no markdown formatting, no code blocks, and no extra text.
The JSON must have the keys: "breakfast", "lunch", "snack", "dinner".
Each key must contain an object with:
- "name" (string, description of the food)
- "calories" (number)
- "protein" (number, in grams)
- "carbs" (number, in grams)
- "fat" (number, in grams)

Example:
{
  "breakfast": {"name": "Oatmeal with berries", "calories": 350, "protein": 15, "carbs": 50, "fat": 8},
  "lunch": {"name": "Chicken salad", "calories": 500, "protein": 40, "carbs": 20, "fat": 15},
  "snack": {"name": "Almonds", "calories": 200, "protein": 6, "carbs": 6, "fat": 14},
  "dinner": {"name": "Salmon and rice", "calories": 600, "protein": 35, "carbs": 45, "fat": 20}
}
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
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.5,
          "response_format": {"type": "json_object"}
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String;
        final Map<String, dynamic> parsed = jsonDecode(reply);
        
        // Enforce mathematical accuracy for each meal's calories
        for (final mealKey in ['breakfast', 'lunch', 'snack', 'dinner']) {
          if (parsed.containsKey(mealKey)) {
            final meal = parsed[mealKey];
            final double p = (meal['protein'] as num?)?.toDouble() ?? 0.0;
            final double c = (meal['carbs'] as num?)?.toDouble() ?? 0.0;
            final double f = (meal['fat'] as num?)?.toDouble() ?? 0.0;
            
            final calculatedCalories = (p * 4) + (c * 4) + (f * 9);
            meal['calories'] = calculatedCalories.round();
          }
        }

        return parsed;
      } else {
        print('AI Meal Plan Error ${response.statusCode}: ${response.body}');
        return _getMockPlan(prefText);
      }
    } catch (e) {
      print('AI Meal Plan Error: $e');
      return _getMockPlan(prefText);
    }
  }

  static Map<String, dynamic> _getMockPlan(String preference) {
    if (preference.toLowerCase().contains('veg')) {
      return {
        "breakfast": {"name": "Mock Avocado Toast (Veg)", "calories": 350, "protein": 12, "carbs": 40, "fat": 15},
        "lunch": {"name": "Mock Tofu Stir Fry (Veg)", "calories": 500, "protein": 30, "carbs": 45, "fat": 20},
        "snack": {"name": "Mock Apple & Peanut Butter (Veg)", "calories": 200, "protein": 6, "carbs": 25, "fat": 10},
        "dinner": {"name": "Mock Lentil Soup (Veg)", "calories": 600, "protein": 35, "carbs": 60, "fat": 15}
      };
    } else {
      return {
        "breakfast": {"name": "Mock Oatmeal with Berries", "calories": 350, "protein": 15, "carbs": 50, "fat": 8},
        "lunch": {"name": "Mock Grilled Chicken Salad", "calories": 500, "protein": 40, "carbs": 20, "fat": 15},
        "snack": {"name": "Mock Handful of Almonds", "calories": 200, "protein": 6, "carbs": 6, "fat": 14},
        "dinner": {"name": "Mock Baked Salmon and Rice", "calories": 600, "protein": 35, "carbs": 45, "fat": 20}
      };
    }
  }
}

