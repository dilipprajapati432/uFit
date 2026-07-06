// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  // Brand
  static const primary = Color(0xFF6C63FF);
  static const primaryLight = Color(0xFF9D97FF);
  static const primaryDark = Color(0xFF4A42CC);
  static const secondary = Color(0xFF00D4AA);
  static const secondaryLight = Color(0xFF4DFFDD);
  static const accent = Color(0xFFFF6B6B);
  static const accentOrange = Color(0xFFFF9F43);
  static const accentYellow = Color(0xFFFFD93D);

  // Dark theme
  static const darkBg = Color(0xFF0A0A0F);
  static const darkSurface = Color(0xFF13131A);
  static const darkCard = Color(0xFF1C1C27);
  static const darkCardElevated = Color(0xFF252535);
  static const darkBorder = Color(0xFF2E2E42);
  static const darkText = Color(0xFFF0F0FF);
  static const darkTextSecondary = Color(0xFF8888AA);
  static const darkTextMuted = Color(0xFF55556A);

  // Light theme
  static const lightBg = Color(0xFFF5F5FF);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE8E8F0);
  static const lightText = Color(0xFF1A1A2E);
  static const lightTextSecondary = Color(0xFF6B6B8A);

  // Module Colors
  static const habitColor = Color(0xFF6C63FF);
  static const waterColor = Color(0xFF00B4D8);
  static const workoutColor = Color(0xFFFF6B6B);
  static const sleepColor = Color(0xFF9B5DE5);
  static const weightColor = Color(0xFF00D4AA);
  static const moodColor = Color(0xFFFFD93D);
  static const calorieColor = Color(0xFFFF9F43);

  // Status
  static const success = Color(0xFF00D4AA);
  static const warning = Color(0xFFFFD93D);
  static const error = Color(0xFFFF6B6B);

  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9D97FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const darkGradient = LinearGradient(
    colors: [Color(0xFF13131A), Color(0xFF0A0A0F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const habitGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9B5DE5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const waterGradient = LinearGradient(
    colors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const workoutGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF9F43)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const sleepGradient = LinearGradient(
    colors: [Color(0xFF9B5DE5), Color(0xFF6C63FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const weightGradient = LinearGradient(
    colors: [Color(0xFF00D4AA), Color(0xFF00B4D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const moodGradient = LinearGradient(
    colors: [Color(0xFFFFD93D), Color(0xFFFF9F43)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.darkSurface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.darkText,
    ),
    cardColor: AppColors.darkCard,
    fontFamily: 'SF Pro Display',
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.darkText, letterSpacing: -1),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.darkText, letterSpacing: -0.5),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.darkText),
      headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.darkText),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.darkText),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.darkText),
      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkText),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkText),
      titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.darkTextSecondary),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.darkText, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.darkText, height: 1.5),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.darkTextSecondary),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkText),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.darkTextSecondary),
      labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.darkTextMuted),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      iconTheme: IconThemeData(color: AppColors.darkText),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.darkText,
        fontFamily: 'SF Pro Display',
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      indicatorColor: AppColors.primary.withOpacity(0.2),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary);
        }
        return const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.darkTextSecondary);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary, size: 24);
        }
        return const IconThemeData(color: AppColors.darkTextSecondary, size: 24);
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.darkTextMuted),
      labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkCard,
      selectedColor: AppColors.primary.withOpacity(0.2),
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.darkText),
      side: const BorderSide(color: AppColors.darkBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.darkBorder, thickness: 1),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkCardElevated,
      contentTextStyle: const TextStyle(color: AppColors.darkText),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBg,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.lightSurface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.lightText,
    ),
    cardColor: AppColors.lightCard,
    fontFamily: 'SF Pro Display',
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.lightText, letterSpacing: -1),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.lightText, letterSpacing: -0.5),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.lightText),
      headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.lightText),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.lightText),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.lightText),
      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.lightText),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.lightText),
      titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.lightTextSecondary),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.lightText, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.lightText, height: 1.5),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.lightTextSecondary),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.lightText),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.lightTextSecondary),
      labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.lightTextSecondary),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      iconTheme: IconThemeData(color: AppColors.lightText),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.lightText,
        fontFamily: 'SF Pro Display',
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.lightSurface,
      indicatorColor: AppColors.primary.withOpacity(0.15),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary);
        }
        return const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.lightTextSecondary);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary, size: 24);
        }
        return const IconThemeData(color: AppColors.lightTextSecondary, size: 24);
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.lightTextSecondary),
      labelStyle: const TextStyle(color: AppColors.lightTextSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.lightBorder),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightCard,
      selectedColor: AppColors.primary.withOpacity(0.15),
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.lightText),
      side: const BorderSide(color: AppColors.lightBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.lightBorder, thickness: 1),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.lightText,
      contentTextStyle: const TextStyle(color: AppColors.lightSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

