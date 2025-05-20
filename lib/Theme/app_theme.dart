import 'package:cineverse/Theme/demensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'text_styles.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: AppColors.lightColorScheme,
      textTheme: AppTextStyles.textTheme,
      fontFamily: GoogleFonts.poppins().fontFamily,

      // Button styles
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.horizontalPadding,
            vertical: AppDimensions.verticalPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          ),
          textStyle: AppTextStyles.buttonText,
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        // ignore: deprecated_member_use
        fillColor:
            // ignore: deprecated_member_use
            AppColors.lightColorScheme.surfaceContainerHighest.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          borderSide: BorderSide(
            color: AppColors.lightColorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.all(AppDimensions.contentPadding),
      ),

      // Card theme
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // App bar theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.lightColorScheme.primary,
        foregroundColor: AppColors.lightColorScheme.onPrimary,
        centerTitle: true,
        titleTextStyle: AppTextStyles.appBarTitle,
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightColorScheme.surface,
        selectedItemColor: AppColors.lightColorScheme.primary,
        unselectedItemColor: AppColors.lightColorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Scaffold background color
      scaffoldBackgroundColor: AppColors.lightColorScheme.surface,
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: AppColors.darkColorScheme,
      textTheme: AppTextStyles.textTheme,
      fontFamily: GoogleFonts.poppins().fontFamily,

      // Button styles
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.horizontalPadding,
            vertical: AppDimensions.verticalPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          ),
          textStyle: AppTextStyles.buttonText,
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        // ignore: deprecated_member_use
        fillColor:
            // ignore: deprecated_member_use
            AppColors.darkColorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          borderSide: BorderSide(
            color: AppColors.darkColorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.all(AppDimensions.contentPadding),
      ),

      // Card theme
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // App bar theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.darkColorScheme.surface,
        foregroundColor: AppColors.darkColorScheme.onSurface,
        centerTitle: true,
        titleTextStyle: AppTextStyles.appBarTitle,
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkColorScheme.surface,
        selectedItemColor: AppColors.darkColorScheme.primary,
        unselectedItemColor: AppColors.darkColorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Scaffold background color
      scaffoldBackgroundColor: AppColors.darkColorScheme.surface,
    );
  }
}
