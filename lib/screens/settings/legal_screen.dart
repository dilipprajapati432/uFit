import 'package:flutter/material.dart';
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
              'Last Updated: July 2026',
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
        _Section('1. Data Collection & Usage', 'We collect personal information that you voluntarily provide when you register, express interest in our services, or use the uFit app. This includes your name, email, age, height, weight, and fitness goals. We use this data strictly to provide and improve the services, track your fitness journey, and offer personalized insights.'),
        _Section('2. Local Storage & Cloud Sync', 'Your privacy is our priority. By default, most fitness data (habits, water intake, sleep logs, workouts) is stored locally on your device in an encrypted format. If you choose to create an account, your data is securely synced to Firebase servers to allow access across multiple devices.'),
        _Section('3. AI Insights & Third Parties', 'To provide personalized coaching, anonymized subsets of your fitness metrics may be processed by AI providers (such as Gemini). We never share personally identifiable information (PII) with third parties for marketing purposes. Your data is never sold.'),
        _Section('4. Data Deletion & Rights', 'You have full control over your data. You can delete your account and all associated cloud data at any time from the Settings screen. Choosing "Clear Local Data" will also permanently wipe your device storage.'),
        _Section('5. Children\'s Privacy', 'uFit is not intended for children under 13. We do not knowingly collect personal information from children. If we discover that a child has provided us with personal information, we will delete it immediately.'),
        _Section('6. Contact Us', 'If you have questions or comments about this Privacy Policy, please contact us at: support.ufit@gmail.com.'),
      ],
    );
  }

  Widget _buildTermsOfService(BuildContext context) {
    return _LegalContent(
      sections: [
        _Section('1. Agreement to Terms', 'By accessing or using uFit, you agree to be bound by these Terms of Service and all applicable laws and regulations. If you disagree with any part of the terms, you may not access the service.'),
        _Section('2. Medical Disclaimer', 'uFit is a fitness tracking and coaching application designed for informational purposes only. It does not provide medical advice, diagnosis, or treatment. Always consult with a qualified healthcare provider before starting any diet or exercise program.'),
        _Section('3. Subscriptions & Billing', 'Certain premium features are locked behind a uFit Pro subscription. Subscriptions are billed through your platform\'s app store (Google Play Billing or Apple In-App Purchases). Subscriptions automatically renew unless canceled at least 24 hours before the end of the current period.'),
        _Section('4. User Conduct', 'You agree not to use the app for any illegal purposes or to violate any local, state, national, or international law. We reserve the right to terminate or suspend access to our service immediately, without prior notice, for conduct that we believe violates these Terms.'),
        _Section('5. Limitation of Liability', 'In no event shall uFit or its developers be liable for any indirect, incidental, special, consequential, or punitive damages arising out of or relating to your use of the app.'),
        _Section('6. Governing Law', 'These Terms shall be governed and construed in accordance with the laws of your jurisdiction, without regard to its conflict of law provisions.'),
        _Section('7. Contact Us', 'If you have any questions about these Terms, please contact us at: support.ufit@gmail.com.'),
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
