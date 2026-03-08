import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App-wide design constants and theme.
class AppTheme {
  // Colors
  static const Color primaryDark = Color(0xFF0D1B2A);
  static const Color primaryMedium = Color(0xFF1B263B);
  static const Color primaryLight = Color(0xFF415A77);
  static const Color accent = Color(0xFF778DA9);
  static const Color highlight = Color(0xFFE0E1DD);

  static const Color northPole = Color(0xFFE63946); // Red for North (+)
  static const Color southPole = Color(0xFF457B9D); // Blue for South (-)
  static const Color goalColor = Color(0xFF2A9D8F);
  static const Color obstacleColor = Color(0xFF264653);
  static const Color magneticObjectColor = Color(0xFFE9C46A);

  static const Color success = Color(0xFF52B788);
  static const Color warning = Color(0xFFF4A261);
  static const Color error = Color(0xFFE76F51);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryDark, primaryMedium],
  );

  static const LinearGradient gameAreaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
  );

  // Text Styles
  static TextStyle get headingLarge => GoogleFonts.orbitron(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: highlight,
    letterSpacing: 2,
  );

  static TextStyle get headingMedium => GoogleFonts.orbitron(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: highlight,
    letterSpacing: 1.5,
  );

  static TextStyle get headingSmall => GoogleFonts.orbitron(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: highlight,
    letterSpacing: 1,
  );

  static TextStyle get bodyLarge => GoogleFonts.rajdhani(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: accent,
  );

  static TextStyle get bodyMedium => GoogleFonts.rajdhani(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: accent,
  );

  static TextStyle get bodySmall => GoogleFonts.rajdhani(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: accent,
  );

  static TextStyle get buttonText => GoogleFonts.orbitron(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: highlight,
    letterSpacing: 1,
  );

  static TextStyle get polaritySymbol => GoogleFonts.orbitron(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: highlight,
  );

  // Decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: primaryMedium.withValues(alpha: 0.8),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: accent.withValues(alpha: 0.3), width: 1),
  );

  static BoxDecoration get buttonDecoration => BoxDecoration(
    gradient: LinearGradient(colors: [primaryLight, primaryMedium]),
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Shadows
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> magnetGlow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.6),
      blurRadius: 12,
      spreadRadius: 2,
    ),
  ];

  // Theme Data
  static ThemeData get themeData => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: primaryDark,
    colorScheme: const ColorScheme.dark(
      primary: primaryLight,
      secondary: accent,
      surface: primaryMedium,
      error: error,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: headingMedium,
      iconTheme: const IconThemeData(color: highlight),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLight,
        foregroundColor: highlight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: accent),
    ),
    iconTheme: const IconThemeData(color: accent),
  );
}
