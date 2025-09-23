import 'package:flutter/material.dart';

class AppThemes {
  // Strcar color palette
  static const Color primaryRed = Color(0xFF8B1538);
  static const Color darkBackground = Color(0xFF2C2C54);
  static const Color cardBackground = Color(0xFF1E1E2F);

  static ThemeData light({bool colorblind = false}) {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRed,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
    if (!colorblind) return base;
    // Deuteranopia/Protanopia friendly palette (avoid red/green contrasts)
    final scheme = base.colorScheme.copyWith(
      primary: Colors.blue.shade700,
      secondary: Colors.amber.shade700,
      error: Colors.blueGrey.shade700,
      tertiary: Colors.purple.shade700,
    );
    return base.copyWith(colorScheme: scheme);
  }

  static ThemeData dark({bool colorblind = false}) {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRed,
        brightness: Brightness.dark,
        background: darkBackground,
        surface: cardBackground,
      ),
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: primaryRed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarTheme(
        backgroundColor: darkBackground,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
      ),
    );
    
    if (!colorblind) return base;
    final scheme = base.colorScheme.copyWith(
      primary: Colors.blue.shade200,
      secondary: Colors.amber.shade200,
      error: Colors.blueGrey.shade200,
      tertiary: Colors.purple.shade200,
    );
    return base.copyWith(colorScheme: scheme);
  }
}

