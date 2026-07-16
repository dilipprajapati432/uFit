// lib/screens/auth/signup_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'package:ufit/theme/theme_ext.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;
  String? _error;
  bool _agreeToTerms = false;

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
                SizedBox(height: 8),

                // Back button
                IconButton(
                  onPressed: () => context.canPop() ? context.pop() : context.go('/welcome'),
                  icon: Icon(Icons.arrow_back_rounded),
                  style: IconButton.styleFrom(backgroundColor: context.card, padding: EdgeInsets.all(10)),
                ).animate().fadeIn(),
                SizedBox(height: 4),

                // Branded Header (Logo + App Name)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/ufit_icon_new.png',
                        width: 48,
                        height: 48,
                      ),
                    ),
                    const SizedBox(width: 12),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5,
                          color: context.text,
                        ),
                        children: const [
                          TextSpan(text: 'u', style: TextStyle(color: AppColors.accentOrange)),
                          TextSpan(text: 'Fit'),
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 50.ms),
                const SizedBox(height: 8),

                Center(
                  child: Text(
                    'Create account',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
                SizedBox(height: 8),
                Center(
                  child: Text(
                    'Start your health journey today',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: context.textSecondary),
                  ),
                ).animate().fadeIn(delay: 150.ms),
                SizedBox(height: 24),

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
                        Icon(Icons.error_outline, color: AppColors.error, size: 18),
                        SizedBox(width: 8),
                        Expanded(child: Text(_error!, style: TextStyle(color: AppColors.error, fontSize: 13))),
                      ],
                    ),
                  ).animate().fadeIn().shake(),

                // Name
                TextFormField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline_rounded)),
                  validator: (v) => (v == null || v.trim().length < 2) ? 'Enter your name' : null,
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                SizedBox(height: 14),

                // Email
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline_rounded)),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) return 'Enter a valid email';
                    return null;
                  },
                ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2),
                SizedBox(height: 14),

                // Password
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    ),
                    hintText: 'At least 8 characters',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 8) return 'At least 8 characters required';
                    return null;
                  },
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                SizedBox(height: 14),

                // Confirm password
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _signUp(),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    ),
                  ),
                  validator: (v) {
                    if (v != _passCtrl.text) return 'Passwords do not match';
                    return null;
                  },
                ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2),
                SizedBox(height: 20),

                // Terms agreement
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.textSecondary),
                          children: const [
                            TextSpan(text: 'I agree to the '),
                            TextSpan(text: 'Terms of Service', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                            TextSpan(text: ' and '),
                            TextSpan(text: 'Privacy Policy', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms),
                SizedBox(height: 24),

                // Sign Up button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_isEmailLoading || _isGoogleLoading) ? null : _signUp,
                    child: _isEmailLoading
                        ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.2),
                SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: context.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('or', style: Theme.of(context).textTheme.bodySmall),
                    ),
                    Expanded(child: Divider(color: context.border)),
                  ],
                ).animate().fadeIn(delay: 500.ms),
                SizedBox(height: 20),

                // Google
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: (_isEmailLoading || _isGoogleLoading) ? null : _signUpWithGoogle,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: context.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isGoogleLoading
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: context.text, strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('G', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                              SizedBox(width: 12),
                              Text('Continue with Google', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.text)),
                            ],
                          ),
                  ),
                ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.2),
                SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.textSecondary)),
                    GestureDetector(
                      onTap: () => context.replace('/login'),
                      child: Text('Sign In', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      setState(() => _error = 'Please agree to the Terms of Service and Privacy Policy.');
      return;
    }
    setState(() { _isEmailLoading = true; _error = null; });
    try {
      await AuthService.signUpWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        name: _nameCtrl.text.trim(),
      );
      // Router redirect handles navigation
      if (mounted) context.go('/onboarding');
    } on FirebaseAuthException catch (e) {
      setState(() => _error = AuthService.friendlyError(e));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isEmailLoading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    if (!_agreeToTerms) {
      setState(() => _error = 'Please agree to the Terms of Service and Privacy Policy.');
      return;
    }
    setState(() { _isGoogleLoading = true; _error = null; });
    try {
      final cred = await AuthService.signInWithGoogle(isSignUp: true);
      if (cred == null) {
        setState(() => _error = 'Google Sign-In was cancelled or failed. Please try again.');
        return;
      }
      if (mounted) {
        if (cred.additionalUserInfo?.isNewUser == true) {
          context.go('/onboarding');
        } else {
          context.go('/dashboard');
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = AuthService.friendlyError(e));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }
}
