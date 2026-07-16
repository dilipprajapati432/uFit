import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../providers/fasting_provider.dart';
import 'package:ufit/theme/theme_ext.dart';
import '../../widgets/common_widgets.dart';

class FastingScreen extends ConsumerStatefulWidget {
  const FastingScreen({super.key});

  @override
  ConsumerState<FastingScreen> createState() => _FastingScreenState();
}

class _FastingScreenState extends ConsumerState<FastingScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _getFastingStage(int hoursElapsed) {
    if (hoursElapsed < 2) return "Blood Sugar Normalizing 🩸";
    if (hoursElapsed < 8) return "Digestion & Absorption 🍽️";
    if (hoursElapsed < 12) return "Fat Burning Prep 🔥";
    if (hoursElapsed < 16) return "Fat Burning (Ketosis) ⚡";
    if (hoursElapsed < 24) return "Autophagy (Cell Repair) 🧬";
    return "Deep Ketosis 🧘";
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(fastingProvider);
    final isFasting = session != null;
    
    final progress = session?.progress ?? 0.0;
    final elapsed = session?.elapsed ?? Duration.zero;
    final remaining = session?.remaining ?? Duration.zero;
    
    final elapsedStr = '${elapsed.inHours.toString().padLeft(2, '0')}:${(elapsed.inMinutes % 60).toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
    final remainingStr = '${remaining.inHours.toString().padLeft(2, '0')}h ${(remaining.inMinutes % 60).toString().padLeft(2, '0')}m left';

    final stageText = isFasting ? _getFastingStage(elapsed.inHours) : "Ready to start your journey?";

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        title: const Text('Intermittent Fasting', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Fasting Stage Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isFasting ? Colors.orange.withOpacity(0.1) : context.surface,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: isFasting ? Colors.orange.withOpacity(0.3) : context.border),
                ),
                child: Text(
                  stageText,
                  style: TextStyle(
                    color: isFasting ? Colors.orangeAccent : context.textMuted,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ).animate().fadeIn().slideY(begin: -0.2),

              const SizedBox(height: 40),

              // Premium Glowing Circular Timer
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: CustomPaint(
                      painter: FastingTimerPainter(
                        progress: isFasting ? progress : 1.0,
                        backgroundColor: context.surface,
                        glowColor: Colors.orangeAccent,
                        isFasting: isFasting,
                      ),
                    ),
                  ).animate(onPlay: (c) => isFasting ? c.repeat(reverse: true) : null)
                   .scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02), duration: 2.seconds, curve: Curves.easeInOutSine),
                  
                  if (isFasting)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('ELAPSED TIME', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                        const SizedBox(height: 8),
                        Text(
                          elapsedStr,
                          style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w900, fontFamily: 'monospace', letterSpacing: -1),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: context.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            remainingStr,
                            style: const TextStyle(color: Colors.orangeAccent, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ).animate().fadeIn()
                  else
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_fire_department_rounded, size: 72, color: Colors.grey.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'Select your fast',
                          style: TextStyle(color: context.textMuted, fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ).animate().fadeIn(),
                ],
              ),
              
              const SizedBox(height: 50),
              
              // Controls
              if (!isFasting)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFastButton('14:10', 'Beginner', 14, () => ref.read(fastingProvider.notifier).startFast(14)),
                    const SizedBox(width: 12),
                    _buildFastButton('16:8', 'Popular', 16, () => ref.read(fastingProvider.notifier).startFast(16), isPrimary: true),
                    const SizedBox(width: 12),
                    _buildFastButton('18:6', 'Advanced', 18, () => ref.read(fastingProvider.notifier).startFast(18)),
                  ],
                ).animate().slideY(begin: 0.5)
              else
                GestureDetector(
                  onTap: () => _confirmEndFast(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Colors.redAccent, Colors.deepOrange]),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.redAccent.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restaurant, color: Colors.white),
                        SizedBox(width: 10),
                        Text('Break Fast Now', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ).animate().slideY(begin: 0.5),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmEndFast(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: context.surface,
        title: const Text('Break Fast?'),
        content: const Text('Are you sure you want to end your fast early?'),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              ref.read(fastingProvider.notifier).endFast();
              context.pop();
            },
            child: const Text('End Fast', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildFastButton(String label, String subtitle, int hours, VoidCallback onTap, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isPrimary ? const LinearGradient(
            colors: [Color(0xFFFF9F43), Color(0xFFFF5252)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) : null,
          color: isPrimary ? null : context.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isPrimary ? Colors.transparent : context.border, width: 2),
          boxShadow: isPrimary ? [
            BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6)),
          ] : [],
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: isPrimary ? Colors.white : context.text, fontWeight: FontWeight.w900, fontSize: 22)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: isPrimary ? Colors.white.withOpacity(0.9) : Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class FastingTimerPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color glowColor;
  final bool isFasting;

  FastingTimerPainter({required this.progress, required this.backgroundColor, required this.glowColor, required this.isFasting});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 15;
    
    // Draw background track
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;
    
    // Draw discrete ticks on background track
    for (int i = 0; i < 60; i++) {
      final angle = (i * 6) * math.pi / 180;
      final p1 = Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle));
      final p2 = Offset(center.dx + (radius - 8) * math.cos(angle), center.dy + (radius - 8) * math.sin(angle));
      canvas.drawLine(p1, p2, Paint()..color = Colors.black.withOpacity(0.2)..strokeWidth = 2);
    }

    canvas.drawCircle(center, radius, bgPaint);

    if (!isFasting) return;

    final sweepAngle = 2 * math.pi * progress;
    
    // Stunning glowing gradient arc
    final gradient = SweepGradient(
      colors: const [Color(0xFFFF9F43), Color(0xFFFF5252), Color(0xFFFF9F43)],
      stops: const [0.0, 0.5, 1.0],
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + 2 * math.pi,
    );

    final rect = Rect.fromCircle(center: center, radius: radius);
    
    // Render glow shadow
    final glowPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    
    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, glowPaint);

    // Render solid foreground line
    final fgPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, fgPaint);
    
    // Render a bright "head" dot at the end of the progress
    final headAngle = -math.pi / 2 + sweepAngle;
    final headCenter = Offset(
      center.dx + radius * math.cos(headAngle),
      center.dy + radius * math.sin(headAngle),
    );
    canvas.drawCircle(headCenter, 12, Paint()..color = Colors.white);
    canvas.drawCircle(headCenter, 12, Paint()..color = Colors.white..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
  }

  @override
  bool shouldRepaint(covariant FastingTimerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isFasting != isFasting;
  }
}

