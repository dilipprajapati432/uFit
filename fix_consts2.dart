import 'dart:io';

void main() {
  final files = [
    'lib/screens/auth/signup_screen.dart',
    'lib/screens/auth/welcome_screen.dart',
    'lib/screens/dashboard/dashboard_screen.dart',
    'lib/screens/habits/habits_screen.dart',
    'lib/screens/premium/premium_screen.dart',
    'lib/screens/sleep/sleep_screen.dart',
    'lib/screens/water/water_screen.dart',
    'lib/screens/weight/weight_screen.dart',
    'lib/widgets/common_widgets.dart',
    'lib/screens/profile/profile_screen.dart',
  ];

  for (final path in files) {
    final file = File(path);
    if (!file.existsSync()) continue;
    
    String content = file.readAsStringSync();
    
    // Replace specific known bad consts
    content = content.replaceAll('const Text', 'Text');
    content = content.replaceAll('const Icon', 'Icon');
    content = content.replaceAll('const TextStyle', 'TextStyle');
    content = content.replaceAll('const Center', 'Center');
    content = content.replaceAll('const Padding', 'Padding');
    content = content.replaceAll('const SizedBox', 'SizedBox');
    content = content.replaceAll('const Container', 'Container');
    
    file.writeAsStringSync(content);
    print('Cleaned $path');
  }
}
