// lib/screens/auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ufit/theme/app_theme.dart';
import 'package:ufit/theme/theme_ext.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _isSent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await AuthService.sendPasswordReset(_emailCtrl.text.trim());
      setState(() {
        _isSent = true;
      });
    } on FirebaseAuthException catch (e) {
      setState(() => _error = AuthService.friendlyError(e));
    } catch (e) {
      setState(() => _error = 'Failed to send reset email. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
                const SizedBox(height: 8),

                // Back button
                IconButton(
                  onPressed: () => context.canPop() ? context.pop() : context.go('/login'),
                  icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 19),
                  style: IconButton.styleFrom(
                    backgroundColor: context.card,
                    padding: const EdgeInsets.all(10),
                  ),
                ).animate().fadeIn(),
                const SizedBox(height: 4),

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

                // Header
                Center(
                  child: Text(
                    'Reset Password',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _isSent
                        ? 'Check your inbox for the reset link'
                        : 'Enter your email address to receive a secure password reset link',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: context.textSecondary),
                  ),
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 24),

                // Error banner
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
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

                if (_isSent) ...[
                  // Success State
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mark_email_read_rounded,
                            color: AppColors.primary,
                            size: 64,
                          ),
                        ).animate().scale(delay: 200.ms, curve: Curves.elasticOut, duration: 600.ms),
                        const SizedBox(height: 24),
                        Text(
                          'We have sent a password reset link to:\n${_emailCtrl.text.trim()}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.text, fontSize: 15, height: 1.5),
                        ).animate().fadeIn(delay: 300.ms),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => context.go('/login'),
                            child: const Text('Back to Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          ),
                        ).animate().fadeIn(delay: 400.ms),
                      ],
                    ),
                  ),
                ] else ...[
                  // Input Form
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _sendResetLink(),
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email is required';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) return 'Enter a valid email';
                      return null;
                    },
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                  const SizedBox(height: 24),

                  // Send Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendResetLink,
                      child: _isLoading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Send Reset Link', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
