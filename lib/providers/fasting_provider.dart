import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/fasting_session.dart';
import 'auth_provider.dart';

final fastingProvider = StateNotifierProvider<FastingNotifier, FastingSession?>((ref) {
  return FastingNotifier(ref);
});

class FastingNotifier extends StateNotifier<FastingSession?> {
  final Ref _ref;
  StreamSubscription? _sub;

  FastingNotifier(this._ref) : super(null) {
    _ref.listen<User?>(currentFirebaseUserProvider, (prev, next) {
      _sub?.cancel();
      if (next == null) {
        state = null;
      } else {
        _sub = FirebaseFirestore.instance
            .collection('users')
            .doc(next.uid)
            .collection('fasting_sessions')
            .where('isCompleted', isEqualTo: false)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            // Sort by start time manually just in case, though there should only be 1
            final sessions = snapshot.docs.map((doc) => FastingSession.fromMap(doc.data(), doc.id)).toList();
            sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
            state = sessions.first;
          } else {
            state = null;
          }
        });
      }
    }, fireImmediately: true);
  }

  Future<void> startFast(int targetHours) async {
    final user = _ref.read(currentFirebaseUserProvider);
    if (user == null || state != null) return; // already fasting
    
    final session = FastingSession(
      id: const Uuid().v4(),
      startTime: DateTime.now(),
      targetDurationHours: targetHours,
    );
    
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('fasting_sessions')
        .doc(session.id)
        .set(session.toMap());
  }

  Future<void> endFast() async {
    final user = _ref.read(currentFirebaseUserProvider);
    if (user == null || state == null) return;
    
    state!.endTime = DateTime.now();
    state!.isCompleted = true;
    
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('fasting_sessions')
        .doc(state!.id)
        .set(state!.toMap(), SetOptions(merge: true));
        
    // State will automatically update to null via the snapshot stream (since isCompleted = true)
  }
  
  Future<void> editTarget(int newTargetHours) async {
    final user = _ref.read(currentFirebaseUserProvider);
    if (user == null || state == null) return;
    
    state!.targetDurationHours = newTargetHours;
    
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('fasting_sessions')
        .doc(state!.id)
        .set(state!.toMap(), SetOptions(merge: true));
  }
  
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
