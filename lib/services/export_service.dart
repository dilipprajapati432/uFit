import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';

class ExportService {
  static Future<void> exportAllData({DateTimeRange? dateRange}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not logged in');

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final firestore = FirebaseFirestore.instance;
    final userDoc = firestore.collection('users').doc(uid);
    final userSnap = await userDoc.get();
    final userModel = userSnap.data() != null ? UserModel.fromMap(userSnap.data()!, userSnap.id) : null;
    
    String reportPeriod = 'All Time';
    if (dateRange != null) {
      reportPeriod = '${DateFormat('MMM d, yyyy').format(dateRange.start)} - ${DateFormat('MMM d, yyyy').format(dateRange.end)}';
    }

    final List<List<dynamic>> rows = [
      ['uFit Complete Data Export'],
      ['Generated on', DateFormat('MMMM d, yyyy - h:mm:ss a').format(DateTime.now())],
      ['Report Period', reportPeriod],
      ['User Name', userModel?.name ?? 'Unknown'],
      ['Email', userModel?.email ?? 'Unknown'],
      ['Age', userModel?.age ?? 'Not set'],
      ['Gender', userModel?.gender ?? 'Not set'],
      ['Height (cm)', userModel?.heightCm ?? 'Not set'],
      ['Weight (kg)', userModel?.weightKg ?? 'Not set'],
      [],
    ];

    Query workoutsQuery = userDoc.collection('workouts').orderBy('startTime', descending: true);
    Query weightQuery = userDoc.collection('weight_logs').orderBy('date', descending: true);
    Query sleepQuery = userDoc.collection('sleep_logs').orderBy('bedTime', descending: true);
    Query waterQuery = userDoc.collection('water_logs').orderBy('timestamp', descending: true);
    Query stepQuery = userDoc.collection('step_logs').orderBy('date', descending: true);
    Query moodQuery = userDoc.collection('mood_logs').orderBy('timestamp', descending: true);

    if (dateRange != null) {
      final startIso = dateRange.start.toIso8601String();
      final endIso = dateRange.end.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1)).toIso8601String();
      
      workoutsQuery = workoutsQuery.where('startTime', isGreaterThanOrEqualTo: startIso, isLessThanOrEqualTo: endIso);
      weightQuery = weightQuery.where('date', isGreaterThanOrEqualTo: startIso, isLessThanOrEqualTo: endIso);
      sleepQuery = sleepQuery.where('bedTime', isGreaterThanOrEqualTo: startIso, isLessThanOrEqualTo: endIso);
      waterQuery = waterQuery.where('timestamp', isGreaterThanOrEqualTo: startIso, isLessThanOrEqualTo: endIso);
      stepQuery = stepQuery.where('date', isGreaterThanOrEqualTo: startIso, isLessThanOrEqualTo: endIso);
      moodQuery = moodQuery.where('timestamp', isGreaterThanOrEqualTo: startIso, isLessThanOrEqualTo: endIso);
    }
    
    // 1. Export Habits
    final habitsSnap = await userDoc.collection('habits').get();
    if (habitsSnap.docs.isNotEmpty) {
      final habits = habitsSnap.docs.map((doc) => Habit.fromMap(doc.data(), doc.id)).toList();
      rows.addAll([
        ['--- HABITS ---'],
        ['ID', 'Name', 'Category', 'Created At', 'Current Streak', 'Longest Streak', 'Completed Dates Count']
      ]);
      for (final habit in habits) {
        rows.add([
          habit.id, habit.name, habit.category, habit.createdAt.toIso8601String(),
          habit.currentStreak, habit.longestStreak, habit.completedDates.length,
        ]);
      }
      rows.add([]);
    }

    // 2. Export Water Logs
    final waterSnap = await waterQuery.get();
    if (waterSnap.docs.isNotEmpty) {
      final waterLogs = waterSnap.docs.map((doc) => WaterLog.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      rows.addAll([
        ['--- WATER LOGS ---'],
        ['ID', 'Timestamp', 'Amount (ml)', 'Drink Type']
      ]);
      for (final log in waterLogs) {
        rows.add([
          log.id, log.timestamp.toIso8601String(), log.amountMl, log.drinkType,
        ]);
      }
      rows.add([]);
    }

    // 3. Export Workouts
    final workoutSnap = await workoutsQuery.get();
    if (workoutSnap.docs.isNotEmpty) {
      final workouts = workoutSnap.docs.map((doc) => WorkoutSession.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      rows.addAll([
        ['--- WORKOUTS ---'],
        ['ID', 'Name', 'Type', 'Start Time', 'Duration (min)', 'Calories', 'Rating', 'Muscle Groups']
      ]);
      for (final workout in workouts) {
        rows.add([
          workout.id, workout.name, workout.type, workout.startTime.toIso8601String(),
          workout.durationMinutes, workout.caloriesBurned, workout.ratingOutOf5, workout.muscleGroups,
        ]);
      }
      rows.add([]);
    }

    // 4. Export Weight Logs
    final weightSnap = await weightQuery.get();
    if (weightSnap.docs.isNotEmpty) {
      final weightLogs = weightSnap.docs.map((doc) => WeightLog.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      rows.addAll([
        ['--- WEIGHT LOGS ---'],
        ['ID', 'Date', 'Weight (kg)', 'Body Fat (%)', 'Muscle Mass (kg)', 'BMI']
      ]);
      for (final log in weightLogs) {
        rows.add([
          log.id, log.date.toIso8601String(), log.weightKg, log.bodyFatPercent, log.muscleMassKg, log.bmi,
        ]);
      }
      rows.add([]);
    }

    // 5. Export Sleep Logs
    final sleepSnap = await sleepQuery.get();
    if (sleepSnap.docs.isNotEmpty) {
      final sleepLogs = sleepSnap.docs.map((doc) => SleepLog.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      rows.addAll([
        ['--- SLEEP LOGS ---'],
        ['ID', 'Bed Time', 'Wake Time', 'Quality (/5)', 'Had Dreams', 'Mood']
      ]);
      for (final log in sleepLogs) {
        rows.add([
          log.id, log.bedTime.toIso8601String(), log.wakeTime.toIso8601String(),
          log.qualityOutOf5, log.hadDreams, log.mood,
        ]);
      }
      rows.add([]);
    }
    
    // 6. Export Mood Logs
    final moodSnap = await moodQuery.get();
    if (moodSnap.docs.isNotEmpty) {
      final moodLogs = moodSnap.docs.map((doc) => MoodLog.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      rows.addAll([
        ['--- MOOD LOGS ---'],
        ['ID', 'Timestamp', 'Score (/5)', 'Emoji']
      ]);
      for (final log in moodLogs) {
        rows.add([
          log.id, log.timestamp.toIso8601String(), log.moodScore, log.moodEmoji,
        ]);
      }
      rows.add([]);
    }
    
    // 7. Export Steps
    final stepSnap = await stepQuery.get();
    if (stepSnap.docs.isNotEmpty) {
      final stepLogs = stepSnap.docs.map((doc) => StepLog.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      rows.addAll([
        ['--- STEP LOGS ---'],
        ['ID', 'Date', 'Steps', 'Distance (km)', 'Calories Burned']
      ]);
      for (final step in stepLogs) {
        rows.add([
          step.id, step.date.toIso8601String(), step.steps,
          (step.distanceKm ?? 0.0).toStringAsFixed(2), step.caloriesBurned,
        ]);
      }
      rows.add([]);
    }

    if (rows.length > 3) {
      final StringBuffer sb = StringBuffer();
      for (final row in rows) {
        sb.writeln(row.map((e) => '"${e.toString().replaceAll('"', '""')}"').join(','));
      }
      final csvData = sb.toString();
      final file = File('${dir.path}/ufit_verified_data_export_$timestamp.csv');
      await file.writeAsString(csvData);
      await Share.shareXFiles([XFile(file.path)], text: 'Here is my complete exported CSV data from uFit!');
    } else {
      throw Exception('No data to export yet!');
    }
  }

  static Future<void> exportAllDataAsPDF({DateTimeRange? dateRange}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not logged in');

    final firestore = FirebaseFirestore.instance;
    final userDoc = firestore.collection('users').doc(uid);
    final userSnap = await userDoc.get();
    final userModel = userSnap.data() != null ? UserModel.fromMap(userSnap.data()!, userSnap.id) : null;

    final pdf = pw.Document();
    
    // Load wordmark image
    
    // Load wordmark image
    final ByteData wordmarkData = await rootBundle.load('assets/images/ufit_wordmark.png');
    final Uint8List wordmarkBytes = wordmarkData.buffer.asUint8List();
    final wordmarkImage = pw.MemoryImage(wordmarkBytes);
    
    Query workoutsQuery = userDoc.collection('workouts').orderBy('startTime', descending: true);
    Query weightQuery = userDoc.collection('weight_logs').orderBy('date', descending: true);
    Query sleepQuery = userDoc.collection('sleep_logs').orderBy('bedTime', descending: true);
    Query waterQuery = userDoc.collection('water_logs').orderBy('timestamp', descending: true);
    Query stepQuery = userDoc.collection('step_logs').orderBy('date', descending: true);
    Query moodQuery = userDoc.collection('mood_logs').orderBy('timestamp', descending: true);

    if (dateRange != null) {
      final startIso = dateRange.start.toIso8601String();
      final endIso = dateRange.end.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1)).toIso8601String();
      
      workoutsQuery = workoutsQuery.where('startTime', isGreaterThanOrEqualTo: startIso, isLessThanOrEqualTo: endIso);
      weightQuery = weightQuery.where('date', isGreaterThanOrEqualTo: startIso, isLessThanOrEqualTo: endIso);
      sleepQuery = sleepQuery.where('bedTime', isGreaterThanOrEqualTo: startIso, isLessThanOrEqualTo: endIso);
      waterQuery = waterQuery.where('timestamp', isGreaterThanOrEqualTo: startIso, isLessThanOrEqualTo: endIso);
      stepQuery = stepQuery.where('date', isGreaterThanOrEqualTo: startIso, isLessThanOrEqualTo: endIso);
      moodQuery = moodQuery.where('timestamp', isGreaterThanOrEqualTo: startIso, isLessThanOrEqualTo: endIso);
    }
    
    // Gather all stats
    final habitsSnap = await userDoc.collection('habits').get(); // all time definitions
    final workoutSnap = await workoutsQuery.get();
    final weightSnap = await weightQuery.get();
    final sleepSnap = await sleepQuery.get();
    final waterSnap = await waterQuery.get();
    final stepSnap = await stepQuery.get();
    final moodSnap = await moodQuery.get();
    
    final habits = habitsSnap.docs.map((doc) => Habit.fromMap(doc.data(), doc.id)).toList();
    final workouts = workoutSnap.docs.map((doc) => WorkoutSession.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    final weights = weightSnap.docs.map((doc) => WeightLog.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    final sleeps = sleepSnap.docs.map((doc) => SleepLog.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    final water = waterSnap.docs.map((doc) => WaterLog.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    final steps = stepSnap.docs.map((doc) => StepLog.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    final moods = moodSnap.docs.map((doc) => MoodLog.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    
    String reportPeriod = 'All Time';
    if (dateRange != null) {
      reportPeriod = '${DateFormat('MMM d, yyyy').format(dateRange.start)} - ${DateFormat('MMM d, yyyy').format(dateRange.end)}';
    }

    // --- Calculate Summary Metrics ---
    final int totalWorkouts = workouts.length;
    final int totalCalories = workouts.fold(0, (sum, w) => sum + (w.caloriesBurned ?? 0));
    final double avgSleep = sleeps.isEmpty ? 0 : sleeps.fold(0.0, (sum, s) => sum + s.durationHours) / sleeps.length;
    final int totalSteps = steps.fold(0, (sum, s) => sum + s.steps);
    final int avgSteps = steps.isEmpty ? 0 : totalSteps ~/ steps.length;
    final int totalWaterMl = water.fold(0, (sum, w) => sum + w.amountMl);
    final double totalWaterL = totalWaterMl / 1000.0;
    
    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Center(
              child: pw.Transform.rotateBox(
                angle: 0.7,
                child: pw.Text(
                  'VERIFIED BY uFit',
                  style: pw.TextStyle(
                    color: PdfColors.grey200,
                    fontSize: 80,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 20),
          padding: const pw.EdgeInsets.only(top: 10),
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 1)),
          ),
          child: pw.Text(
            'This report was securely generated by uFit and represents an authentic record of the user\'s fitness data.\nPage ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(color: PdfColors.grey, fontSize: 10),
            textAlign: pw.TextAlign.center,
          ),
        ),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Row(
                    children: [
                      pw.Image(wordmarkImage, height: 42),
                      pw.Text(' - My Fitness Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
                    ]
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green100,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                      border: pw.Border.all(color: PdfColors.green),
                    ),
                    child: pw.Text('VERIFIED BY uFIT', style: pw.TextStyle(color: PdfColors.green800, fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Text('Generated on: ${DateFormat('MMMM d, yyyy - h:mm:ss a').format(DateTime.now())}', style: const pw.TextStyle(color: PdfColors.grey700)),
            pw.Text('Report Period: $reportPeriod', style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 13)),
            pw.SizedBox(height: 15),
            pw.Text('User Details:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 5),
            pw.Text('Name: ${userModel?.name ?? 'Unknown'}', style: const pw.TextStyle(fontSize: 12)),
            pw.Text('Email: ${userModel?.email ?? 'Unknown'}', style: const pw.TextStyle(fontSize: 12)),
            pw.Text('Age: ${userModel?.age ?? 'Not set'} | Gender: ${userModel?.gender ?? 'Not set'}', style: const pw.TextStyle(fontSize: 12)),
            pw.Text('Height: ${userModel?.heightCm ?? '-'} cm | Weight: ${userModel?.weightKg ?? '-'} kg', style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 25),

            // --- EXECUTIVE SUMMARY DASHBOARD ---
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('EXECUTIVE SUMMARY', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryStat('Workouts', '$totalWorkouts', 'Calories: $totalCalories', PdfColors.deepPurple600),
                      _buildSummaryStat('Avg Sleep', '${avgSleep.toStringAsFixed(1)}h', 'Nights logged: ${sleeps.length}', PdfColors.indigo600),
                      _buildSummaryStat('Avg Steps', '$avgSteps', 'Total: $totalSteps', PdfColors.teal600),
                      _buildSummaryStat('Total Water', '${totalWaterL.toStringAsFixed(1)}L', 'Logs: ${water.length}', PdfColors.lightBlue600),
                    ]
                  )
                ]
              )
            ),
            pw.SizedBox(height: 30),
            
            // Habits Summary
            pw.Header(level: 1, text: 'Habits (${habits.length})'),
            if (habits.isNotEmpty)
              pw.TableHelper.fromTextArray(
                headers: ['Name', 'Category', 'Current Streak', 'Longest'],
                data: habits.map((h) => [h.name, h.category, h.currentStreak.toString(), h.longestStreak.toString()]).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                cellAlignment: pw.Alignment.centerLeft,
                oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
              )
            else
              _buildEmptyState('No habits tracked yet.'),
            pw.SizedBox(height: 20),
            
            // Workouts Summary
            pw.Header(level: 1, text: 'Workouts (${workouts.length})'),
            if (workouts.isNotEmpty)
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Name', 'Duration', 'Cals Burned'],
                data: workouts.map((w) => [DateFormat('MM/dd/yyyy').format(w.startTime), w.name, '${w.durationMinutes} min', '${w.caloriesBurned ?? 0}']).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
                cellAlignment: pw.Alignment.centerLeft,
                oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
              )
            else
              _buildEmptyState('No workouts logged during this period.'),
            pw.SizedBox(height: 20),
            
            // Weight Logs
            pw.Header(level: 1, text: 'Weight History (${weights.length})'),
            if (weights.isNotEmpty)
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Weight (kg)', 'Body Fat %', 'Chest (cm)'],
                data: weights.map((w) => [DateFormat('MM/dd/yyyy').format(w.date), w.weightKg.toString(), w.bodyFatPercent?.toString() ?? '-', w.chestCm?.toString() ?? '-']).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.deepPurple800),
                cellAlignment: pw.Alignment.centerLeft,
                oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
              )
            else
              _buildEmptyState('No weight logs recorded during this period.'),
            pw.SizedBox(height: 20),
            
            // Sleep Logs
            pw.Header(level: 1, text: 'Sleep History (${sleeps.length})'),
            if (sleeps.isNotEmpty)
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Duration', 'Quality (1-5)', 'Factors'],
                data: sleeps.map((s) => [DateFormat('MM/dd/yyyy').format(s.bedTime), s.durationFormatted, s.qualityOutOf5.toString(), s.factors.join(', ')]).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo800),
                cellAlignment: pw.Alignment.centerLeft,
                oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
              )
            else
              _buildEmptyState('No sleep logged during this period.'),
            pw.SizedBox(height: 20),
            
            // Step Logs
            pw.Header(level: 1, text: 'Step History (${steps.length})'),
            if (steps.isNotEmpty)
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Steps', 'Distance (km)', 'Calories'],
                data: steps.map((s) => [DateFormat('MM/dd/yyyy').format(s.date), s.steps.toString(), (s.distanceKm ?? 0.0).toStringAsFixed(2), s.caloriesBurned.toString()]).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.teal800),
                cellAlignment: pw.Alignment.centerLeft,
                oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
              )
            else
              _buildEmptyState('No steps recorded during this period.'),
            pw.SizedBox(height: 20),
            
            // Mood Logs
            pw.Header(level: 1, text: 'Mood History (${moods.length})'),
            if (moods.isNotEmpty)
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Score (1-5)', 'Emotions', 'Notes'],
                data: moods.map((m) => [DateFormat('MM/dd/yyyy').format(m.timestamp), m.moodScore.toString(), m.emotions.join(', '), m.notes]).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.orange800),
                cellAlignment: pw.Alignment.centerLeft,
                oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
              )
            else
              _buildEmptyState('No mood logs recorded during this period.'),
            pw.SizedBox(height: 20),
            
            // Water Logs
            pw.Header(level: 1, text: 'Water Logs (${water.length})'),
            if (water.isNotEmpty)
              pw.TableHelper.fromTextArray(
                headers: ['Date/Time', 'Amount (ml)', 'Drink Type'],
                data: water.map((w) => [DateFormat('MM/dd/yyyy h:mm a').format(w.timestamp), w.amountMl.toString(), w.drinkType]).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.lightBlue800),
                cellAlignment: pw.Alignment.centerLeft,
                oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
              )
            else
              _buildEmptyState('No water logs recorded during this period.'),
          ];
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/ufit_verified_report_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'Here is my officially verified PDF report from uFit!');
  }

  static pw.Widget _buildSummaryStat(String title, String mainStat, String subtext, PdfColor color) {
    return pw.Container(
      width: 110,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey300, width: 1.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(color: PdfColors.grey600, fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(mainStat, style: pw.TextStyle(color: color, fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(subtext, style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 9)),
        ]
      )
    );
  }

  static pw.Widget _buildEmptyState(String message) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey200, width: 1, style: pw.BorderStyle.dashed),
      ),
      child: pw.Text(message, style: pw.TextStyle(color: PdfColors.grey600, fontSize: 12, fontStyle: pw.FontStyle.italic)),
    );
  }
}
