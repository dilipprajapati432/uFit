import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    if (file.path.contains('app_theme.dart') || file.path.contains('theme_ext.dart') || file.path.contains('fix_colors.dart')) continue;

    String content = file.readAsStringSync();
    if (!content.contains('AppColors.dark')) continue;

    content = content.replaceAll('AppColors.darkBg', 'context.bg');
    content = content.replaceAll('AppColors.darkSurface', 'context.surface');
    content = content.replaceAll('AppColors.darkCardElevated', 'context.cardElevated');
    content = content.replaceAll('AppColors.darkCard', 'context.card');
    content = content.replaceAll('AppColors.darkBorder', 'context.border');
    content = content.replaceAll('AppColors.darkTextSecondary', 'context.textSecondary');
    content = content.replaceAll('AppColors.darkTextMuted', 'context.textMuted');
    content = content.replaceAll('AppColors.darkText', 'context.text');

    // Add import if needed
    if (content.contains('context.bg') || content.contains('context.surface') || content.contains('context.card') || content.contains('context.border') || content.contains('context.text')) {
      if (!content.contains('theme_ext.dart')) {
        // Find last import
        final lines = content.split('\n');
        int lastImportIdx = -1;
        for (int i = 0; i < lines.length; i++) {
          if (lines[i].startsWith('import ')) {
            lastImportIdx = i;
          }
        }
        if (lastImportIdx != -1) {
          // relative path to lib/theme/theme_ext.dart
          lines.insert(lastImportIdx + 1, "import 'package:ufit/theme/theme_ext.dart';");
          content = lines.join('\n');
        }
      }
    }

    file.writeAsStringSync(content);
    print('Updated ${file.path}');
  }
}
