// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _google = GoogleSignIn();
  static final _db = FirebaseFirestore.instance;

  // ── Stream ────────────────────────────────────────────────
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  static User? get currentUser => _auth.currentUser;
  static bool get isLoggedIn => _auth.currentUser != null;

  // ── Email / Password ──────────────────────────────────────
  static Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(name);
    await _saveUserToFirestore(cred.user!, name: name, email: email);
    await cred.user?.sendEmailVerification();
    return cred;
  }

  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ── Google Sign-In ────────────────────────────────────────
  static Future<UserCredential?> signInWithGoogle({bool isSignUp = false}) async {
    try {
      final googleUser = await _google.signIn();
      if (googleUser == null) return null; // user cancelled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);

      // Block registration if they are trying to SIGN IN
      if (cred.additionalUserInfo?.isNewUser == true && !isSignUp) {
        await cred.user?.delete();
        await _google.signOut().catchError((_) => null);
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No account found. Please register first.',
        );
      }

      // Save to Firestore if new user registering
      if (cred.additionalUserInfo?.isNewUser == true && isSignUp) {
        await _saveUserToFirestore(
          cred.user!,
          name: googleUser.displayName ?? 'User',
          email: googleUser.email,
          photoUrl: googleUser.photoUrl,
        );
      }
      return cred;
    } catch (e) {
      rethrow;
    }
  }

  // ── Password Reset ────────────────────────────────────────
  static Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ── Update Profile ────────────────────────────────────────
  static Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    await _auth.currentUser?.updateDisplayName(displayName);
    await _auth.currentUser?.updatePhotoURL(photoUrl);

    // Update Firestore too
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _db.collection('users').doc(uid).update({
        if (displayName != null) 'name': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<void> updatePassword(String newPassword) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }

  // ── Sign Out ──────────────────────────────────────────────
  static Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }

  // ── Delete Account ────────────────────────────────────────
  static Future<void> deleteAccount() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      // Delete Auth account first. If it fails (e.g. requires re-authentication), 
      // it throws here and Firestore profile is safely preserved.
      await _auth.currentUser?.delete();
      
      // Delete Firestore document only after successful Auth deletion
      await _db.collection('users').doc(uid).delete();

      // Clear Google Sign-In cache if they were signed in with Google
      await _google.signOut().catchError((_) => null);
    }
  }

  // ── Firestore ─────────────────────────────────────────────
  static Future<void> _saveUserToFirestore(
    User user, {
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl ?? user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
      'isPremium': false,
    }, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  // ── Helpers ───────────────────────────────────────────────
  static String friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'No account found with this email. Please register first.';
      case 'invalid-credential': return 'Invalid credentials. Please verify your details or register first.';
      case 'wrong-password': return 'Incorrect password. Try again.';
      case 'email-already-in-use': return 'An account with this email already exists.';
      case 'weak-password': return 'Password must be at least 6 characters.';
      case 'invalid-email': return 'Please enter a valid email address.';
      case 'user-disabled': return 'This account has been disabled.';
      case 'too-many-requests': return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed': return 'No internet connection. Check your network.';
      case 'requires-recent-login': return 'Please sign in again to continue.';
      default: return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}
