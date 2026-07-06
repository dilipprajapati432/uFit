import 'package:flutter/material.dart';
import 'package:ufit/theme/app_theme.dart';
import 'package:ufit/theme/theme_ext.dart';

class LegalScreen extends StatelessWidget {
  final bool isPrivacyPolicy;

  const LegalScreen({super.key, required this.isPrivacyPolicy});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        title: Text(isPrivacyPolicy ? 'Privacy Policy' : 'Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Updated: October 2023',
              style: TextStyle(color: context.textSecondary, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),
            isPrivacyPolicy ? _buildPrivacyPolicy(context) : _buildTermsOfService(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicy(BuildContext context) {
    return _LegalContent(
      sections: [
        _Section('1. Data Collection', 'We collect personal information that you voluntarily provide to us when you register on the uFit app, express an interest in obtaining information about us or our products, or when you participate in activities on the app. This includes your name, email, age, height, weight, and fitness goals.'),
        _Section('2. Local Storage & Health Data', 'Most of your fitness data (habits, water intake, sleep logs, workouts) is stored locally on your device using encrypted storage to prioritize your privacy. Cloud backups are optionally available via Firebase if you create an account.'),
        _Section('3. AI Insights', 'To provide you with personalized coaching, some of your anonymized fitness data is sent securely to our AI providers (such as Gemini). We do not send personally identifiable information (PII) during this process.'),
        _Section('4. Data Deletion', 'You can delete your account and all associated data at any time from the Settings screen. Choosing "Clear Everything" will wipe your local device storage permanently.'),
      ],
    );
  }

  Widget _buildTermsOfService(BuildContext context) {
    return _LegalContent(
      sections: [
        _Section('1. Agreement to Terms', 'By accessing or using uFit, you agree to be bound by these Terms of Service and all applicable laws and regulations.'),
        _Section('2. Medical Disclaimer', 'uFit is a fitness tracking and coaching application. It does not provide medical advice. Always consult with a qualified healthcare provider before starting any diet or exercise program.'),
        _Section('3. Subscription & Pro Features', 'Some features of the app are locked behind a uFit Pro subscription. Subscriptions automatically renew unless canceled. You can manage your subscription through your platform\'s app store.'),
        _Section('4. User Conduct', 'You agree not to use the app for any illegal purpose or to violate any local, state, national, or international law. We reserve the right to terminate accounts that violate these terms.'),
      ],
    );
  }
}

class _LegalContent extends StatelessWidget {
  final List<_Section> sections;
  const _LegalContent({required this.sections});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text(s.content, style: TextStyle(color: context.textSecondary, height: 1.6, fontSize: 14)),
          ],
        ),
      )).toList(),
    );
  }
}

class _Section {
  final String title;
  final String content;
  _Section(this.title, this.content);
}
