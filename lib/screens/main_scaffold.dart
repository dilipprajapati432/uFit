// lib/screens/main_scaffold.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import 'package:ufit/theme/theme_ext.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;
  final String currentPath;

  const MainScaffold({super.key, required this.child, required this.currentPath});

  static const _tabs = [
    ('/dashboard', FontAwesomeIcons.house, 'Home'),
    ('/habits', FontAwesomeIcons.squareCheck, 'Habits'),
    ('/workout', FontAwesomeIcons.dumbbell, 'Workout'),
    ('/sleep', FontAwesomeIcons.moon, 'Sleep'),
    ('/more', FontAwesomeIcons.borderAll, 'More'),
  ];

  int get _currentIndex {
    for (int i = 0; i < _tabs.length; i++) {
      if (currentPath.startsWith(_tabs[i].$1)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) {
          if (_currentIndex == i) {
            ref.read(tabScrollEventProvider.notifier).state = _tabs[i].$1;
          } else {
            context.go(_tabs[i].$1);
          }
        },
        backgroundColor: context.surface,
        height: 64,
        destinations: _tabs.map((t) => NavigationDestination(
          icon: FaIcon(t.$2, size: 19, color: context.textSecondary),
          selectedIcon: FaIcon(t.$2, size: 19, color: AppColors.primary),
          label: t.$3,
        )).toList(),
      ),
    );
  }
}
