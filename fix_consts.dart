import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    if (file.path.contains('app_theme.dart') || file.path.contains('theme_ext.dart') || file.path.contains('fix_colors.dart')) continue;

    String content = file.readAsStringSync();
    
    if (!content.contains('context.')) continue;

    final lines = content.split('\n');
    bool modified = false;

    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('context.bg') || 
          lines[i].contains('context.surface') || 
          lines[i].contains('context.card') || 
          lines[i].contains('context.cardElevated') || 
          lines[i].contains('context.border') || 
          lines[i].contains('context.text') || 
          lines[i].contains('context.textSecondary') || 
          lines[i].contains('context.textMuted')) {
        
        // If the line contains a const keyword before an object that now uses context, remove it.
        // It's safer to just remove all `const ` on lines that have `context.`
        if (lines[i].contains('const ')) {
          lines[i] = lines[i].replaceAll('const ', '');
          modified = true;
        }
      }
    }

    if (modified) {
      file.writeAsStringSync(lines.join('\n'));
      print('Fixed const in ${file.path}');
    }
  }
}
