import 'package:flutter/material.dart';

class AppColors {
  // Primary movie theme colors
  static const Color primaryRed = Color(0xFFE50914);
  static const Color darkRed = Color(0xFFB81D24);
  static const Color accentGold = Color(0xFFFFD700);

  // Neutral colors
  static const Color darkGrey = Color(0xFF1F1F1F);
  static const Color mediumGrey = Color(0xFF333333);
  static const Color lightGrey = Color(0xFF8C8C8C);
  static const Color offWhite = Color(0xFFF5F5F1);

  // Status colors
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFFFA000);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF1976D2);

  // Light theme color scheme
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryRed,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFFFDAD6),
    onPrimaryContainer: Color(0xFF410002),
    secondary: accentGold,
    onSecondary: Color(0xFF3D2F00),
    secondaryContainer: Color(0xFFFFE08C),
    onSecondaryContainer: Color(0xFF241A00),
    tertiary: Color(0xFF006C51),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFF8FF8D0),
    onTertiaryContainer: Color(0xFF002116),
    error: error,
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    background: offWhite,
    onBackground: Color(0xFF1A1C1E),
    surface: Colors.white,
    onSurface: Color(0xFF1A1C1E),
    surfaceVariant: Color(0xFFF4DDDA),
    onSurfaceVariant: Color(0xFF534341),
    outline: Color(0xFF857371),
    shadow: Color(0xFF000000),
    inverseSurface: Color(0xFF2F3133),
    onInverseSurface: Color(0xFFF1F0F4),
    inversePrimary: Color(0xFFFFB4AB),
    surfaceTint: primaryRed,
  );

  // Dark theme color scheme
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFFFB4AB),
    onPrimary: Color(0xFF690005),
    primaryContainer: darkRed,
    onPrimaryContainer: Color(0xFFFFDAD6),
    secondary: Color(0xFFEAC148),
    onSecondary: Color(0xFF3D2F00),
    secondaryContainer: Color(0xFF574400),
    onSecondaryContainer: Color(0xFFFFE08C),
    tertiary: Color(0xFF71DBB4),
    onTertiary: Color(0xFF003828),
    tertiaryContainer: Color(0xFF00513C),
    onTertiaryContainer: Color(0xFF8FF8D0),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    background: darkGrey,
    onBackground: Color(0xFFE2E2E6),
    surface: mediumGrey,
    onSurface: Color(0xFFE2E2E6),
    surfaceVariant: Color(0xFF534341),
    onSurfaceVariant: Color(0xFFD8C2BF),
    outline: Color(0xFFA08C8A),
    shadow: Color(0xFF000000),
    inverseSurface: Color(0xFFE2E2E6),
    onInverseSurface: Color(0xFF2F3133),
    inversePrimary: primaryRed,
    surfaceTint: Color(0xFFFFB4AB),
  );
}
