// lib/screens/main_scaffold.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import 'package:ufit/theme/theme_ext.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const MainScaffold({super.key, required this.child, required this.currentPath});

  static const _tabs = [
    ('/dashboard', Icons.home_outlined, Icons.home_rounded, 'Home'),
    ('/habits', Icons.task_alt_outlined, Icons.task_alt_rounded, 'Habits'),
    ('/workout', Icons.fitness_center_outlined, Icons.fitness_center_rounded, 'Workout'),
    ('/sleep', Icons.bedtime_outlined, Icons.bedtime_rounded, 'Sleep'),
    ('/more', Icons.grid_view_outlined, Icons.grid_view_rounded, 'More'),
  ];

  int get _currentIndex {
    for (int i = 0; i < _tabs.length; i++) {
      if (currentPath.startsWith(_tabs[i].$1)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => context.go(_tabs[i].$1),
        backgroundColor: context.surface,
        height: 64,
        destinations: _tabs.map((t) => NavigationDestination(
          icon: Icon(t.$2),
          selectedIcon: Icon(t.$3),
          label: t.$4,
        )).toList(),
      ),
    );
  }
}
