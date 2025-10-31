import 'package:flutter/material.dart';

class AppTheme {
  // Palet utama: coklat dan emas
  static const Color primaryOrange = Color(0xFF5D4037); // Rich Brown (dipakai sbg "primary")
  static const Color accentOrange  = Color(0xFFD4AF37); // Gold (aksen)
  static const Color primaryRed    = Color(0xFFD32F2F);

  // Dasar
  static const Color backgroundWhite = Color(0xFFF6F4EF); // Warm ivory
  static const Color textColor = Color(0xFF2E2A27);       // Dark coffee

  // Variasi pendukung
  static const Color darkBrown  = Color(0xFF3E2723);
  static const Color goldLight  = Color(0xFFEAD18A);
  static const Color goldPale   = Color(0xFFFFF4D6);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryOrange,
      brightness: Brightness.light,
      onBackground: textColor,
    ),
    scaffoldBackgroundColor: backgroundWhite,

    // AppBar dengan nuansa coklat + aksen emas
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundWhite,
      foregroundColor: textColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: accentOrange),
      titleTextStyle: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
    ),

    // Tombol utama: coklat
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    ),

    // Tombol outline: teks coklat, border emas
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryOrange,
        side: const BorderSide(color: accentOrange, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: primaryOrange),
    ),

    // Field input: fokus beraksen emas, ikon berwarna emas
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accentOrange, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: Colors.grey),
      floatingLabelStyle: const TextStyle(
        color: accentOrange,
        fontWeight: FontWeight.w600,
      ),
      prefixIconColor: accentOrange,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
  );

  // Gradient opsional bernuansa coklat → emas
  static LinearGradient get splashGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [darkBrown, accentOrange, goldPale],
      );

  // Teks utilitas
  static const TextStyle headingStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: primaryOrange,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    color: textColor,
  );

  static const TextStyle smallTextStyle = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );
}
