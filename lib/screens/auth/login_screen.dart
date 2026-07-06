// lib/screens/auth/login_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'package:ufit/theme/theme_ext.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Back button
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: context.card,
                    padding: const EdgeInsets.all(10),
                  ),
                ).animate().fadeIn(),
                const SizedBox(height: 32),

                // Header
                Text('Welcome back', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800))
                    .animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
                const SizedBox(height: 8),
                Text('Sign in to continue your journey', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: context.textSecondary))
                    .animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 40),

                // Error banner
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
                      ],
                    ),
                  ).animate().fadeIn().shake(),

                // Email
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) return 'Enter a valid email';
                    return null;
                  },
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _signIn(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    return null;
                  },
                ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2),
                const SizedBox(height: 12),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: const Text('Forgot password?', style: TextStyle(color: AppColors.primary)),
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 24),

                // Sign In button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    child: _isLoading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2),
                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: context.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('or continue with', style: Theme.of(context).textTheme.bodySmall),
                    ),
                    Expanded(child: Divider(color: context.border)),
                  ],
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 20),

                // Google Sign-In
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: context.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Google G logo using text (replace with SVG asset if you have one)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(shape: BoxShape.circle),
                          child: const Text('G', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                        ),
                        const SizedBox(width: 12),
                        Text('Continue with Google', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.text)),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.2),
                const SizedBox(height: 36),

                // Sign up redirect
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.textSecondary)),
                    GestureDetector(
                      onTap: () => context.go('/signup'),
                      child: const Text('Sign Up', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ).animate().fadeIn(delay: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      await AuthService.signInWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      // Router redirect handles navigation automatically
    } on FirebaseAuthException catch (e) {
      setState(() => _error = AuthService.friendlyError(e));
    } catch (e) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      await AuthService.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      setState(() => _error = AuthService.friendlyError(e));
    } catch (e) {
      setState(() => _error = 'Google Sign-In failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter your email above first, then tap Forgot Password.');
      return;
    }
    try {
      await AuthService.sendPasswordReset(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset link sent to $email'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = AuthService.friendlyError(e));
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }
}
