import 'package:flutter/material.dart';

//final appTheme = ThemeData(
  //colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
  //useMaterial3: true,
//);

import 'package:flutter/material.dart';

class AppColors {
  static const primaryText = Color(0xFF003979);
  static const highlight = Color(0xFF8596BD);
  
  static const crimson = Color(0xFFC60A45);
  static const yellow = Color(0xFFFFC423);
  static const brightYellow = Color(0xFFFFF000);
  static const lime = Color(0xFFD5E14D);
  static const red = Color(0xFFED1848);
}

final appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: Colors.white,
  
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primaryText,
    brightness: Brightness.light,
    primary: AppColors.primaryText,
    onPrimary: Colors.white,
    secondary: AppColors.crimson,
    onSecondary: Colors.white,
    tertiary: AppColors.red,
    onTertiary: Colors.white,
    surface: Colors.white,
    onSurface: AppColors.primaryText,
  ),

  textTheme: const TextTheme(
    displayLarge: TextStyle(color: AppColors.primaryText),
    displayMedium: TextStyle(color: AppColors.primaryText),
    displaySmall: TextStyle(color: AppColors.primaryText),
    headlineLarge: TextStyle(color: AppColors.primaryText),
    headlineMedium: TextStyle(color: AppColors.primaryText),
    headlineSmall: TextStyle(color: AppColors.primaryText),
    titleLarge: TextStyle(color: AppColors.primaryText),
    titleMedium: TextStyle(color: AppColors.primaryText),
    titleSmall: TextStyle(color: AppColors.primaryText),
    bodyLarge: TextStyle(color: AppColors.primaryText),
    bodyMedium: TextStyle(color: AppColors.primaryText),
    bodySmall: TextStyle(color: AppColors.primaryText),
    labelLarge: TextStyle(color: AppColors.primaryText),
    labelMedium: TextStyle(color: AppColors.primaryText),
    labelSmall: TextStyle(color: AppColors.primaryText),
  ),

  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: AppColors.primaryText,
    selectionColor: AppColors.highlight,
    selectionHandleColor: AppColors.primaryText,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: AppColors.primaryText,
    ),
  ),
);