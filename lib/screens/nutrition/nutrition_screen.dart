import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/confetti_overlay.dart';
import '../../services/ai_service.dart';
import 'package:ufit/theme/theme_ext.dart';

class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> {
  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(nutritionProvider);
    final user = ref.watch(userProvider);
    
    final calorieGoal = user?.dailyCalorieGoal ?? 2000;
    final totalCalories = ref.read(nutritionProvider.notifier).todayTotalCalories;
    final progress = (totalCalories / calorieGoal).clamp(0.0, 1.0);

    final totalProtein = ref.read(nutritionProvider.notifier).todayTotalProtein;
    final totalCarbs = ref.read(nutritionProvider.notifier).todayTotalCarbs;
    final totalFat = ref.read(nutritionProvider.notifier).todayTotalFat;

    // Approximate macros goal based on 30% protein, 40% carbs, 30% fat
    final proteinGoal = (calorieGoal * 0.3) / 4;
    final carbsGoal = (calorieGoal * 0.4) / 4;
    final fatGoal = (calorieGoal * 0.3) / 9;

    // Celebrate if they are within 10% of their calorie goal
    final isGoalAchieved = totalCalories >= (calorieGoal * 0.9) && totalCalories <= (calorieGoal * 1.1);

    return ConfettiOverlay(
      isGoalAchieved: isGoalAchieved,
      child: Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
        title: const Text('Meals & Nutrition'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => _showGoalSheet(context, calorieGoal),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                // Main progress card
                GradientCard(
                  gradient: const LinearGradient(
                    colors: [Colors.orange, Colors.deepOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircularProgressWidget(
                            progress: progress,
                            size: 100,
                            color: Colors.white,
                            strokeWidth: 8,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${totalCalories.toInt()}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                                ),
                                const Text('kcal', style: TextStyle(color: Colors.white70, fontSize: 10)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Daily Budget',
                                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  totalCalories >= calorieGoal
                                      ? 'Over goal by ${(totalCalories - calorieGoal).toInt()} kcal'
                                      : '${(calorieGoal - totalCalories).toInt()} kcal remaining',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _MacroSummary(label: 'Protein', value: totalProtein, goal: proteinGoal),
                                    _MacroSummary(label: 'Carbs', value: totalCarbs, goal: carbsGoal),
                                    _MacroSummary(label: 'Fat', value: totalFat, goal: fatGoal),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
                const SizedBox(height: 24),

                // AI Auto Plan Button
                OutlinedButton.icon(
                  onPressed: () => _autoPlanDay(context, ref, calorieGoal),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('✨ Auto-Plan My Day'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.purple,
                    side: const BorderSide(color: Colors.purple),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                const SizedBox(height: 24),

                // Meal Categories
                _MealCategory(title: 'Breakfast', icon: '🍳', logs: logs.where((l) => l.mealType == 'breakfast').toList()),
                _MealCategory(title: 'Lunch', icon: '🥗', logs: logs.where((l) => l.mealType == 'lunch').toList()),
                _MealCategory(title: 'Snacks', icon: '🍎', logs: logs.where((l) => l.mealType == 'snack').toList()),
                _MealCategory(title: 'Dinner', icon: '🍝', logs: logs.where((l) => l.mealType == 'dinner').toList()),

                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    ));
  }

  void _showGoalSheet(BuildContext context, int currentGoal) {
    int goal = currentGoal;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: context.surface,
          title: const Text('Daily Calorie Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$goal kcal', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.orange)),
              Slider(
                value: goal.toDouble(),
                min: 1200,
                max: 5000,
                divisions: 38,
                activeColor: Colors.orange,
                inactiveColor: context.border,
                onChanged: (v) => setState(() => goal = v.toInt()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final user = ref.read(userProvider);
                if (user != null) {
                  user.dailyCalorieGoal = goal;
                  ref.read(userProvider.notifier).saveUser(user);
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _autoPlanDay(BuildContext context, WidgetRef ref, int targetCalories) async {
    final user = ref.read(userProvider);
    String? dietPref = user?.dietaryPreference;

    if (dietPref == null) {
      // First time setup
      dietPref = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: context.bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('How do you eat?', style: Theme.of(ctx).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('Set your dietary preference so the AI can craft the perfect daily meals for you.', style: TextStyle(color: context.textSecondary)),
              const SizedBox(height: 24),
              ...['Any', 'Vegetarian', 'Vegan', 'Keto', 'Paleo'].map((pref) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.surface,
                      foregroundColor: context.text,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      alignment: Alignment.centerLeft,
                      elevation: 0,
                      side: BorderSide(color: context.border),
                    ),
                    onPressed: () {
                      if (user != null) {
                        user.dietaryPreference = pref;
                        ref.read(userProvider.notifier).saveUser(user);
                      }
                      Navigator.pop(ctx, pref);
                    },
                    child: Row(
                      children: [
                        Text(pref == 'Any' ? '🍽️' : pref == 'Vegetarian' ? '🥦' : pref == 'Vegan' ? '🌱' : pref == 'Keto' ? '🥑' : '🥩', style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 16),
                        Text(pref, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      ],
                    ),
                  ),
                )
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
      
      if (dietPref == null) return; // User dismissed sheet
    }

    if (!context.mounted) return;

    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: context.surface,
        content: Row(
          children: [
            const CircularProgressIndicator(color: Colors.purple),
            const SizedBox(width: 20),
            Text('AI is planning your meals...', style: Theme.of(context).textTheme.bodyMedium),
          ],
        )
      )
    );

    final plan = await AiService.generateMealPlan(targetCalories, dietaryPreference: dietPref);
    
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (plan != null) {
      final now = DateTime.now();
      for (final meal in ['breakfast', 'lunch', 'snack', 'dinner']) {
        if (plan.containsKey(meal)) {
          final data = plan[meal];
          final log = NutritionLog(
            id: const Uuid().v4(),
            date: now,
            mealType: meal,
            foodName: data['name'] ?? 'Unknown',
            calories: (data['calories'] as num?)?.toDouble() ?? 0,
            proteinG: (data['protein'] as num?)?.toDouble(),
            carbsG: (data['carbs'] as num?)?.toDouble(),
            fatG: (data['fat'] as num?)?.toDouble(),
          );
          ref.read(nutritionProvider.notifier).addNutritionLog(log);
        }
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meal plan added successfully! ✨')));
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to generate meal plan. Please try again.')));
      }
    }
  }
}

class _MacroSummary extends StatelessWidget {
  final String label;
  final double value;
  final double goal;

  const _MacroSummary({required this.label, required this.value, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        Text('${value.toInt()}/${goal.toInt()}g', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _MealCategory extends ConsumerWidget {
  final String title;
  final String icon;
  final List<NutritionLog> logs;

  const _MealCategory({required this.title, required this.icon, required this.logs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalCals = logs.fold(0.0, (sum, log) => sum + log.calories);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '${totalCals.toInt()} kcal',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: context.textSecondary),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle_rounded, color: Colors.orange),
                  onPressed: () => _showAddMealSheet(context, ref, title.toLowerCase()),
                ),
              ],
            ),
          ),
          if (logs.isNotEmpty) ...[
            const Divider(height: 1),
            ...logs.map((log) => Dismissible(
              key: Key(log.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.redAccent.withOpacity(0.8),
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
              onDismissed: (_) {
                ref.read(nutritionProvider.notifier).deleteNutritionLog(log.id);
              },
              child: ListTile(
                title: Text(log.foodName, style: Theme.of(context).textTheme.bodyMedium),
                subtitle: Text(
                  '${log.servingSize.toInt()} ${log.servingUnit} • P:${log.proteinG?.toInt()??0} C:${log.carbsG?.toInt()??0} F:${log.fatG?.toInt()??0}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: Text('${log.calories.toInt()} kcal', style: Theme.of(context).textTheme.bodyMedium),
                onTap: () => _showAddMealSheet(context, ref, title.toLowerCase(), existingLog: log),
                onLongPress: () {
                  ref.read(nutritionProvider.notifier).deleteNutritionLog(log.id);
                },
              ),
            )),
          ]
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  void _showAddMealSheet(BuildContext context, WidgetRef ref, String mealType, {NutritionLog? existingLog}) {
    final nameCtrl = TextEditingController(text: existingLog?.foodName ?? '');
    final calCtrl = TextEditingController(text: existingLog?.calories.toInt().toString() ?? '');
    final pCtrl = TextEditingController(text: existingLog?.proteinG?.toInt().toString() ?? '');
    final cCtrl = TextEditingController(text: existingLog?.carbsG?.toInt().toString() ?? '');
    final fCtrl = TextEditingController(text: existingLog?.fatG?.toInt().toString() ?? '');
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.bg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(existingLog != null ? 'Edit Meal' : 'Log $title', style: Theme.of(context).textTheme.headlineSmall),
                    if (isLoading)
                      const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    else
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.withOpacity(0.1),
                          foregroundColor: Colors.purple,
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.auto_awesome, size: 16),
                        label: const Text('AI Auto-Fill'),
                        onPressed: () async {
                          if (nameCtrl.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a food name first!')));
                            return;
                          }
                          setState(() => isLoading = true);
                          final data = await AiService.estimateNutrition(nameCtrl.text);
                          setState(() => isLoading = false);
                          
                          if (data != null) {
                            calCtrl.text = data['calories']?.toString() ?? '';
                            pCtrl.text = data['protein']?.toString() ?? '';
                            cCtrl.text = data['carbs']?.toString() ?? '';
                            fCtrl.text = data['fat']?.toString() ?? '';
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI failed to estimate. Try again!')));
                          }
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Food Name (e.g. 1 bowl of rice and dal)'),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: calCtrl,
                  decoration: const InputDecoration(labelText: 'Calories (kcal)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: TextField(controller: pCtrl, decoration: const InputDecoration(labelText: 'Protein (g)'), keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: cCtrl, decoration: const InputDecoration(labelText: 'Carbs (g)'), keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: fCtrl, decoration: const InputDecoration(labelText: 'Fat (g)'), keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty && calCtrl.text.isNotEmpty) {
                      final log = NutritionLog(
                        id: existingLog?.id ?? const Uuid().v4(),
                        date: existingLog?.date ?? DateTime.now(),
                        mealType: mealType == 'snacks' ? 'snack' : mealType,
                        foodName: nameCtrl.text,
                        calories: double.tryParse(calCtrl.text) ?? 0,
                        proteinG: double.tryParse(pCtrl.text),
                        carbsG: double.tryParse(cCtrl.text),
                        fatG: double.tryParse(fCtrl.text),
                      );
                      if (existingLog != null) {
                        ref.read(nutritionProvider.notifier).updateNutritionLog(log);
                      } else {
                        ref.read(nutritionProvider.notifier).addNutritionLog(log);
                      }
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meal logged successfully! 🍽️')));
                    }
                  },
                  child: Text(existingLog != null ? 'Save Changes' : 'Add Food'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
