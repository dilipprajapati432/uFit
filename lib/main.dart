// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app_router.dart';
import 'firebase_options.dart';
import 'providers/app_providers.dart';
import 'services/payment_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  await dotenv.load(fileName: ".env");

  // Initialize notifications asynchronously in the background
  NotificationService.init();

  runApp(
    const ProviderScope(
      child: UFitApp(),
    ),
  );
}

class UFitApp extends ConsumerStatefulWidget {
  const UFitApp({super.key});

  @override
  ConsumerState<UFitApp> createState() => _UFitAppState();
}

class _UFitAppState extends ConsumerState<UFitApp> {
  @override
  void initState() {
    super.initState();
    PaymentService.initIAP(ref);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final isDark = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'uFit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
