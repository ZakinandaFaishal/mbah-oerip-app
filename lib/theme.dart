import 'package:flutter/material.dart';

class AppTheme {
  // Warna utama dan dasar
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color primaryRed = Color(0xFFD32F2F);
  static const Color accentOrange = Color(0xFFFF8C42);
  static const Color backgroundWhite = Colors.white;
  static const Color textColor = Colors.black87;

  // ThemeData utama (Light Mode)
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryOrange, // wajib
      brightness: Brightness.light,
      onBackground: textColor,
    ),

    scaffoldBackgroundColor: backgroundWhite,

    // AppBar
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(color: primaryOrange),
      backgroundColor: backgroundWhite,
      foregroundColor: textColor,
      elevation: 0,
    ),
  );

  // Shortcut
  static Color get primaryColor => primaryOrange;
  static Color get accentColor => accentOrange;
  static Color get baseTextColor => textColor;
  static Color get backgroundColor => backgroundWhite;

  static const TextStyle headingStyle = TextStyle();
  static const TextStyle bodyStyle = TextStyle();
  static const TextStyle smallTextStyle = TextStyle();
}
