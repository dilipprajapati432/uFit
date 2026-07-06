import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ufit/theme/app_theme.dart';
import 'package:ufit/theme/theme_ext.dart';
import 'package:ufit/widgets/common_widgets.dart';

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
      appBar: AppBar(title: const Text('About uFit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // App Logo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Text('💪', style: TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 24),
            
            // App Title & Version
            Text(
              'uFit',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 2.0.0',
              style: TextStyle(color: context.textSecondary, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            
            // Description
            Text(
              'Your ultimate AI-powered personal fitness companion. Track habits, log water intake, monitor sleep, and achieve your health goals with intelligent insights.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.textSecondary, height: 1.6),
            ),
            const SizedBox(height: 40),
            
            // Developer Info
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('DEVELOPED BY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: AppColors.primary)),
                  const SizedBox(height: 12),
                  const Text('Dilip Prajapati', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Made with ❤️ in Flutter', style: TextStyle(color: context.textSecondary, fontSize: 13)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialIcon(
                        icon: Icons.code_rounded,
                        onTap: () => _launchUrl('https://github.com/dilipprajapati432/uFit'),
                      ),
                      const SizedBox(width: 16),
                      _SocialIcon(
                        icon: Icons.mail_rounded,
                        onTap: () => _launchUrl('mailto:dilipkohar4320@gmail.com'),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Legal Links
            GlassCard(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Terms of Service', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                    onTap: () => context.push('/legal-terms'),
                  ),
                  Divider(height: 1, color: context.border.withOpacity(0.5)),
                  ListTile(
                    title: const Text('Privacy Policy', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                    onTap: () => context.push('/legal-privacy'),
                  ),
                  Divider(height: 1, color: context.border.withOpacity(0.5)),
                  ListTile(
                    title: const Text('Open Source Licenses', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: 'uFit',
                      applicationVersion: '2.0.0',
                      applicationIcon: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('💪', style: TextStyle(fontSize: 48)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            Text('© 2024 uFit. All rights reserved.', style: TextStyle(color: context.textMuted, fontSize: 12)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.card,
          shape: BoxShape.circle,
          border: Border.all(color: context.border),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }
}
