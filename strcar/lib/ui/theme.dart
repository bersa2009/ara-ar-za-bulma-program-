import 'package:flutter/material.dart';

class AppThemes {
  static ThemeData light({bool colorblind = false}) {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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
    final base = ThemeData.dark(useMaterial3: true);
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

