import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF2563EB);
  static const background = Color(0xFFF1F5F9);
  static const panel = Colors.white;
  static const border = Color(0xFFE2E8F0);
  static const success = Color(0xFF16A34A);
  static const muted = Color(0xFF64748B);
  static const danger = Color(0xFFDC2626);
}

ThemeData buildTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    scaffoldBackgroundColor: AppColors.background,
    useMaterial3: true,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      isDense: true,
      filled: true,
      fillColor: Colors.white,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: AppColors.border),
      ),
      elevation: 0,
    ),
  );
}