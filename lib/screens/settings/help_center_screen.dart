import 'package:flutter/material.dart';
import 'package:ufit/theme/app_theme.dart';
import 'package:ufit/theme/theme_ext.dart';
import 'package:ufit/widgets/common_widgets.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(title: const Text('Help Center')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Frequently Asked Questions'),
            const SizedBox(height: 16),
            _buildFaqItem(
              context,
              'How do I cancel my uFit Pro subscription?',
              'Subscriptions are managed through your device\'s app store. Go to your phone\'s settings, tap your Apple ID or Google account, and select "Subscriptions" to cancel.',
            ),
            _buildFaqItem(
              context,
              'Can I sync my data across multiple devices?',
              'Yes! As long as you create an account and sign in with the same email on your other devices, your habits, workouts, and settings will automatically sync.',
            ),
            _buildFaqItem(
              context,
              'How is my AI Coach data generated?',
              'uFit uses your recent logs (sleep, mood, water, workouts, and habits) to generate personalized coaching tips. We do not share your personal identity with our AI partners.',
            ),
            _buildFaqItem(
              context,
              'Why aren\'t my notifications working?',
              'Please ensure you have granted uFit permission to send notifications. You can check this in your phone\'s global settings under Apps > uFit > Notifications.',
            ),
            const SizedBox(height: 40),
            
            const SectionHeader(title: 'Contact Support'),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.support_agent_rounded, size: 48, color: AppColors.primary),
                  const SizedBox(height: 16),
                  const Text('Still need help?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    'Our support team is available Monday through Friday to help you with any issues.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Support email copied to clipboard!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Email Support (support@ufit.app)'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassCard(
        child: ExpansionTile(
          title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          iconColor: AppColors.primary,
          collapsedIconColor: context.textSecondary,
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          children: [
            Text(answer, style: TextStyle(color: context.textSecondary, height: 1.5, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
