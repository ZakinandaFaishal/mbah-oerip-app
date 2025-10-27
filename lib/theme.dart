import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 Warna utama dan dasar
  static const Color primaryRed = Color(0xFFD32F2F); // warna utama resto
  static const Color accentRed = Color(0xFFE53935); // warna aksen
  static const Color backgroundWhite = Colors.white;
  static const Color textColor = Colors.black87;

  // 🧩 ThemeData utama (Light Mode)
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryRed,
      primary: primaryRed,
      secondary: accentRed,
      background: backgroundWhite,
      onPrimary: Colors.white,
      onBackground: textColor,
    ),

    // AppBar
    appBarTheme: const AppBarTheme(
      elevation: 0.5,
      centerTitle: true,
      backgroundColor: backgroundWhite,
      foregroundColor: textColor,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      iconTheme: IconThemeData(color: primaryRed),
    ),

    // Tombol utama (ElevatedButton)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),

    // TextField
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: const TextStyle(color: primaryRed),
      floatingLabelStyle: const TextStyle(color: primaryRed),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: primaryRed, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      filled: true,
      fillColor: Colors.white,
    ),

    fontFamily: 'Poppins',
    scaffoldBackgroundColor: backgroundWhite,
  );

  // 🔖 Shortcut agar mudah dipakai di file lain
  static Color get primaryColor => primaryRed;
  static Color get accentColor => accentRed;
  static Color get baseTextColor => textColor;
  static Color get backgroundColor => backgroundWhite;

  // 🖋️ Tambahan text style global
  static const TextStyle headingStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textColor,
  );

  static const TextStyle smallTextStyle = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );
}
