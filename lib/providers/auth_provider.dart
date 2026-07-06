// lib/providers/auth_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

// Real-time Firebase auth state
final firebaseAuthProvider = StreamProvider<User?>((ref) {
  return AuthService.authStateChanges;
});

// Simple bool: is the user logged in?
final isLoggedInProvider = Provider<bool>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.maybeWhen(data: (u) => u != null, orElse: () => false);
});

// Current Firebase User
final currentFirebaseUserProvider = Provider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).maybeWhen(
    data: (u) => u,
    orElse: () => null,
  );
});

// Auth loading state
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Auth error message
final authErrorProvider = StateProvider<String?>((ref) => null);
