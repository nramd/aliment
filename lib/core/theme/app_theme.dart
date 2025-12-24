import 'package:flutter/material.dart';
import 'app_colors.dart'; // File palet warna Anda

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.normal),
    scaffoldBackgroundColor: AppColors.light,

    // Atur tema untuk AppBar secara global
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.light,
      foregroundColor: AppColors.normal, // Warna untuk title dan ikon
      elevation: 0,
    ),

    // Atur tema untuk ElevatedButton secara global
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.normal,
        foregroundColor: AppColors.lightActive,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
  );
}
