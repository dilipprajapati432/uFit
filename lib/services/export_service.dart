import 'dart:io';
import 'package:csv/csv.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/models.dart';

class ExportService {
  static Future<void> exportAllData() async {
    final List<XFile> filesToShare = [];
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    
    // 1. Export Habits
    final habitsBox = Hive.box<Habit>('habits');
    if (habitsBox.isNotEmpty) {
      final List<List<dynamic>> rows = [
        ['ID', 'Name', 'Category', 'Created At', 'Current Streak', 'Longest Streak', 'Completed Dates Count']
      ];
      for (final habit in habitsBox.values) {
        rows.add([
          habit.id,
          habit.name,
          habit.category,
          habit.createdAt.toIso8601String(),
          habit.currentStreak,
          habit.longestStreak,
          habit.completedDates.length,
        ]);
      }
      final csvData = csv.encode(rows);
      final file = File('${dir.path}/ufit_habits_$timestamp.csv');
      await file.writeAsString(csvData);
      filesToShare.add(XFile(file.path));
    }

    // 2. Export Water Logs
    final waterBox = Hive.box<WaterLog>('water_logs');
    if (waterBox.isNotEmpty) {
      final List<List<dynamic>> rows = [
        ['ID', 'Timestamp', 'Amount (ml)', 'Drink Type']
      ];
      for (final log in waterBox.values) {
        rows.add([
          log.id,
          log.timestamp.toIso8601String(),
          log.amountMl,
          log.drinkType,
        ]);
      }
      final csvData = csv.encode(rows);
      final file = File('${dir.path}/ufit_water_$timestamp.csv');
      await file.writeAsString(csvData);
      filesToShare.add(XFile(file.path));
    }

    // 3. Export Workouts
    final workoutBox = Hive.box<WorkoutSession>('workouts');
    if (workoutBox.isNotEmpty) {
      final List<List<dynamic>> rows = [
        ['ID', 'Name', 'Type', 'Start Time', 'Duration (min)', 'Calories Burned', 'Rating']
      ];
      for (final session in workoutBox.values) {
        rows.add([
          session.id,
          session.name,
          session.type,
          session.startTime.toIso8601String(),
          session.durationMinutes,
          session.caloriesBurned ?? '',
          session.ratingOutOf5,
        ]);
      }
      final csvData = csv.encode(rows);
      final file = File('${dir.path}/ufit_workouts_$timestamp.csv');
      await file.writeAsString(csvData);
      filesToShare.add(XFile(file.path));
    }

    // 4. Export Weight Logs
    final weightBox = Hive.box<WeightLog>('weight_logs');
    if (weightBox.isNotEmpty) {
      final List<List<dynamic>> rows = [
        ['ID', 'Date', 'Weight (kg)', 'Body Fat %', 'Muscle Mass (kg)', 'BMI']
      ];
      for (final log in weightBox.values) {
        rows.add([
          log.id,
          log.date.toIso8601String(),
          log.weightKg,
          log.bodyFatPercent ?? '',
          log.muscleMassKg ?? '',
          log.bmi ?? '',
        ]);
      }
      final csvData = csv.encode(rows);
      final file = File('${dir.path}/ufit_weight_$timestamp.csv');
      await file.writeAsString(csvData);
      filesToShare.add(XFile(file.path));
    }

    // 5. Export Sleep Logs
    final sleepBox = Hive.box<SleepLog>('sleep_logs');
    if (sleepBox.isNotEmpty) {
      final List<List<dynamic>> rows = [
        ['ID', 'Bed Time', 'Wake Time', 'Duration (hours)', 'Quality (1-5)']
      ];
      for (final log in sleepBox.values) {
        rows.add([
          log.id,
          log.bedTime.toIso8601String(),
          log.wakeTime.toIso8601String(),
          log.durationHours.toStringAsFixed(2),
          log.qualityOutOf5,
        ]);
      }
      final csvData = csv.encode(rows);
      final file = File('${dir.path}/ufit_sleep_$timestamp.csv');
      await file.writeAsString(csvData);
      filesToShare.add(XFile(file.path));
    }

    if (filesToShare.isNotEmpty) {
      await Share.shareXFiles(filesToShare, text: 'Here is my exported CSV data from uFit!');
    } else {
      throw Exception('No data to export yet!');
    }
  }

  static Future<void> exportAllDataAsPDF() async {
    final pdf = pw.Document();
    
    // Gather stats
    final habitsBox = Hive.box<Habit>('habits');
    final workoutBox = Hive.box<WorkoutSession>('workouts');
    final weightBox = Hive.box<WeightLog>('weight_logs');
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('uFit - My Fitness Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Generated on: ${DateFormat('MMMM d, yyyy - h:mm a').format(DateTime.now())}', style: const pw.TextStyle(color: PdfColors.grey)),
            pw.SizedBox(height: 20),
            
            // Habits Summary
            pw.Header(level: 1, child: pw.Text('Habits (${habitsBox.length})')),
            if (habitsBox.isNotEmpty)
              pw.TableHelper.fromTextArray(
                headers: ['Name', 'Category', 'Current Streak', 'Longest'],
                data: habitsBox.values.map((h) => [h.name, h.category, h.currentStreak.toString(), h.longestStreak.toString()]).toList(),
              )
            else
              pw.Text('No habits tracked yet.'),
            pw.SizedBox(height: 20),
            
            // Workouts Summary
            pw.Header(level: 1, child: pw.Text('Recent Workouts (${workoutBox.length})')),
            if (workoutBox.isNotEmpty)
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Name', 'Duration', 'Cals Burned'],
                data: workoutBox.values.take(15).map((w) => [DateFormat('MM/dd').format(w.startTime), w.name, '${w.durationMinutes} min', '${w.caloriesBurned ?? 0}']).toList(),
              )
            else
              pw.Text('No workouts logged yet.'),
            pw.SizedBox(height: 20),
            
            // Weight Logs
            pw.Header(level: 1, child: pw.Text('Weight History (${weightBox.length})')),
            if (weightBox.isNotEmpty)
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Weight (kg)', 'Body Fat %', 'Chest (cm)'],
                data: weightBox.values.take(15).map((w) => [DateFormat('MM/dd').format(w.date), w.weightKg.toString(), w.bodyFatPercent?.toString() ?? '-', w.chestCm?.toString() ?? '-']).toList(),
              )
            else
              pw.Text('No weight logs yet.'),
          ];
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/ufit_report_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'Here is my exported PDF report from uFit!');
  }
}
