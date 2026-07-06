import 'package:flutter/material.dart';

extension ThemeColors on BuildContext {
  Color get bg => Theme.of(this).scaffoldBackgroundColor;
  Color get surface => Theme.of(this).colorScheme.surface;
  Color get card => Theme.of(this).cardColor;
  Color get cardElevated => Theme.of(this).dialogTheme.backgroundColor ?? Theme.of(this).colorScheme.surface;
  Color get border => Theme.of(this).dividerTheme.color ?? Colors.grey;
  Color get text => Theme.of(this).textTheme.bodyLarge?.color ?? Colors.white;
  Color get textSecondary => Theme.of(this).textTheme.bodySmall?.color ?? Colors.grey;
  Color get textMuted => Theme.of(this).textTheme.labelSmall?.color ?? Colors.grey;
}
