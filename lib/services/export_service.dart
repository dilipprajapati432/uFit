import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/models.dart';

class ExportService {
  static Future<void> exportAllData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not logged in');

    final List<XFile> filesToShare = [];
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final firestore = FirebaseFirestore.instance;
    final userDoc = firestore.collection('users').doc(uid);
    
    // 1. Export Habits
    final habitsSnap = await userDoc.collection('habits').get();
    if (habitsSnap.docs.isNotEmpty) {
      final habits = habitsSnap.docs.map((doc) => Habit.fromMap(doc.data(), doc.id)).toList();
      final List<List<dynamic>> rows = [
        ['ID', 'Name', 'Category', 'Created At', 'Current Streak', 'Longest Streak', 'Completed Dates Count']
      ];
      for (final habit in habits) {
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
      final csvData = Csv().encode(rows);
      final file = File('${dir.path}/ufit_habits_$timestamp.csv');
      await file.writeAsString(csvData);
      filesToShare.add(XFile(file.path));
    }

    // 2. Export Water Logs
    final waterSnap = await userDoc.collection('water_logs').get();
    if (waterSnap.docs.isNotEmpty) {
      final waterLogs = waterSnap.docs.map((doc) => WaterLog.fromMap(doc.data(), doc.id)).toList();
      final List<List<dynamic>> rows = [
        ['ID', 'Timestamp', 'Amount (ml)', 'Drink Type']
      ];
      for (final log in waterLogs) {
        rows.add([
          log.id,
          log.timestamp.toIso8601String(),
          log.amountMl,
          log.drinkType,
        ]);
      }
      final csvData = Csv().encode(rows);
      final file = File('${dir.path}/ufit_water_$timestamp.csv');
      await file.writeAsString(csvData);
      filesToShare.add(XFile(file.path));
    }

    // 3. Export Workouts
    final workoutSnap = await userDoc.collection('workouts').get();
    if (workoutSnap.docs.isNotEmpty) {
      final workouts = workoutSnap.docs.map((doc) => WorkoutSession.fromMap(doc.data(), doc.id)).toList();
      final List<List<dynamic>> rows = [
        ['ID', 'Name', 'Type', 'Start Time', 'Duration (min)', 'Calories Burned', 'Rating']
      ];
      for (final session in workouts) {
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
      final csvData = Csv().encode(rows);
      final file = File('${dir.path}/ufit_workouts_$timestamp.csv');
      await file.writeAsString(csvData);
      filesToShare.add(XFile(file.path));
    }

    // 4. Export Weight Logs
    final weightSnap = await userDoc.collection('weight_logs').get();
    if (weightSnap.docs.isNotEmpty) {
      final weights = weightSnap.docs.map((doc) => WeightLog.fromMap(doc.data(), doc.id)).toList();
      final List<List<dynamic>> rows = [
        ['ID', 'Date', 'Weight (kg)', 'Body Fat %', 'Muscle Mass (kg)', 'BMI']
      ];
      for (final log in weights) {
        rows.add([
          log.id,
          log.date.toIso8601String(),
          log.weightKg,
          log.bodyFatPercent ?? '',
          log.muscleMassKg ?? '',
          log.bmi ?? '',
        ]);
      }
      final csvData = Csv().encode(rows);
      final file = File('${dir.path}/ufit_weight_$timestamp.csv');
      await file.writeAsString(csvData);
      filesToShare.add(XFile(file.path));
    }

    // 5. Export Sleep Logs
    final sleepSnap = await userDoc.collection('sleep_logs').get();
    if (sleepSnap.docs.isNotEmpty) {
      final sleeps = sleepSnap.docs.map((doc) => SleepLog.fromMap(doc.data(), doc.id)).toList();
      final List<List<dynamic>> rows = [
        ['ID', 'Bed Time', 'Wake Time', 'Duration (hours)', 'Quality (1-5)']
      ];
      for (final log in sleeps) {
        rows.add([
          log.id,
          log.bedTime.toIso8601String(),
          log.wakeTime.toIso8601String(),
          log.durationHours.toStringAsFixed(2),
          log.qualityOutOf5,
        ]);
      }
      final csvData = Csv().encode(rows);
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
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not logged in');

    final firestore = FirebaseFirestore.instance;
    final userDoc = firestore.collection('users').doc(uid);

    final pdf = pw.Document();
    
    // Gather stats
    final habitsSnap = await userDoc.collection('habits').get();
    final workoutSnap = await userDoc.collection('workouts').orderBy('startTime', descending: true).get();
    final weightSnap = await userDoc.collection('weight_logs').orderBy('date', descending: true).get();
    
    final habits = habitsSnap.docs.map((doc) => Habit.fromMap(doc.data(), doc.id)).toList();
    final workouts = workoutSnap.docs.map((doc) => WorkoutSession.fromMap(doc.data(), doc.id)).toList();
    final weights = weightSnap.docs.map((doc) => WeightLog.fromMap(doc.data(), doc.id)).toList();
    
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
            pw.Header(level: 1, child: pw.Text('Habits (${habits.length})')),
            if (habits.isNotEmpty)
              pw.TableHelper.fromTextArray(
                headers: ['Name', 'Category', 'Current Streak', 'Longest'],
                data: habits.map((h) => [h.name, h.category, h.currentStreak.toString(), h.longestStreak.toString()]).toList(),
              )
            else
              pw.Text('No habits tracked yet.'),
            pw.SizedBox(height: 20),
            
            // Workouts Summary
            pw.Header(level: 1, child: pw.Text('Recent Workouts (${workouts.length})')),
            if (workouts.isNotEmpty)
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Name', 'Duration', 'Cals Burned'],
                data: workouts.take(15).map((w) => [DateFormat('MM/dd').format(w.startTime), w.name, '${w.durationMinutes} min', '${w.caloriesBurned ?? 0}']).toList(),
              )
            else
              pw.Text('No workouts logged yet.'),
            pw.SizedBox(height: 20),
            
            // Weight Logs
            pw.Header(level: 1, child: pw.Text('Weight History (${weights.length})')),
            if (weights.isNotEmpty)
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Weight (kg)', 'Body Fat %', 'Chest (cm)'],
                data: weights.take(15).map((w) => [DateFormat('MM/dd').format(w.date), w.weightKg.toString(), w.bodyFatPercent?.toString() ?? '-', w.chestCm?.toString() ?? '-']).toList(),
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
