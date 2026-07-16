import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class ConfettiOverlay extends StatefulWidget {
  final bool isGoalAchieved;
  final Widget child;

  const ConfettiOverlay({
    super.key,
    required this.isGoalAchieved,
    required this.child,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> {
  late ConfettiController _controller;
  bool _hasPlayed = false;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 2));
    if (widget.isGoalAchieved) {
      _controller.play();
      _hasPlayed = true;
    }
  }

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isGoalAchieved && !oldWidget.isGoalAchieved && !_hasPlayed) {
      _controller.play();
      _hasPlayed = true;
    } else if (!widget.isGoalAchieved && oldWidget.isGoalAchieved) {
      _hasPlayed = false; // Reset if they un-achieve the goal (e.g. deleted a log)
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _controller,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ],
          ),
        ),
      ],
    );
  }
}
