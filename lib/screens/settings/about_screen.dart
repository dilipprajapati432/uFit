import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ufit/theme/app_theme.dart';
import 'package:ufit/theme/theme_ext.dart';


class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        title: const Text('About', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: context.bg,
        foregroundColor: context.text,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Minimalist Logo
            Center(
              child: Image.asset(
                'assets/images/ufit_wordmark.png',
                height: 80,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const FaIcon(FontAwesomeIcons.dumbbell, size: 64, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            
            // App Title & Version
            Text(
              'uFit',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: context.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: context.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'uFit is an intelligent, all-in-one health ecosystem designed to elevate your daily routine. Seamlessly track your workouts, hydrate optimally, monitor sleep cycles, and build lasting habits—all guided by personalized AI coaching tailored specifically to your goals.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.textSecondary, fontSize: 14, height: 1.6),
              ),
            ),
            const SizedBox(height: 40),
            
            // Edge-to-edge Menu List
            _buildSection(context, [
              const _ListTile(
                title: 'Developer',
                trailingText: 'Dilip Prajapati',
              ),
              _ListTile(
                title: 'Contact Support',
                trailingIcon: FontAwesomeIcons.envelope,
                onTap: () => _launchUrl('mailto:support.ufit@gmail.com'),
              ),
            ]),
            
            const SizedBox(height: 24),
            
            _buildSection(context, [
              _ListTile(
                title: 'Terms of Service',
                trailingIcon: FontAwesomeIcons.chevronRight,
                onTap: () => context.push('/legal-terms'),
              ),
              _ListTile(
                title: 'Privacy Policy',
                trailingIcon: FontAwesomeIcons.chevronRight,
                onTap: () => context.push('/legal-privacy'),
              ),
              _ListTile(
                title: 'Open Source Licenses',
                trailingIcon: FontAwesomeIcons.chevronRight,
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'uFit',
                  applicationVersion: '1.0.0',
                  applicationIcon: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Image.asset('assets/images/ufit_wordmark.png', height: 80),
                  ),
                ),
              ),
            ]),
            
            const SizedBox(height: 48),
            Text(
              'Made with ❤️ for your health',
              style: TextStyle(color: context.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              '© 2024 uFit. All rights reserved.',
              style: TextStyle(color: context.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border.withOpacity(0.5)),
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          if (index == children.length - 1) return children[index];
          return Column(
            children: [
              children[index],
              Divider(height: 1, indent: 16, endIndent: 16, color: context.border.withOpacity(0.3)),
            ],
          );
        }),
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  final String title;
  final String? trailingText;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  const _ListTile({
    required this.title,
    this.trailingText,
    this.trailingIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 16, color: context.text, fontWeight: FontWeight.w400),
                ),
              ),
              if (trailingText != null)
                Text(
                  trailingText!,
                  style: TextStyle(fontSize: 16, color: context.textSecondary),
                ),
              if (trailingIcon != null)
                Icon(trailingIcon, size: 20, color: context.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
