import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate away after a short delay
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        // The router's redirect logic will automatically send them to 
        // /dashboard if logged in, or /welcome if not.
        context.go('/welcome');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The main animated icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/ufit_icon_new.png',
                width: 80,
                height: 80,
              ),
            )
            .animate()
            .scale(duration: 600.ms, curve: Curves.easeOutBack)
            .fadeIn(duration: 400.ms),
            
            const SizedBox(height: 32),
            
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
                children: [
                  TextSpan(
                    text: 'u',
                    style: TextStyle(color: AppColors.primary),
                  ),
                  TextSpan(
                    text: 'Fit',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(delay: 400.ms, duration: 600.ms)
            .slideY(begin: 0.5, end: 0, delay: 400.ms, duration: 600.ms, curve: Curves.easeOutCubic),
          ],
        ),
      ),
    );
  }
}
