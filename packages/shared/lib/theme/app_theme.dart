import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_dimensions.dart';

/// Main app theme configuration
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      
      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryYellow,
        primary: AppColors.primaryYellow,
        secondary: AppColors.primaryDark,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.white,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: AppColors.white,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: AppDimensions.appBarElevation,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: AppTypography.h5,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: true,
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        color: AppColors.cardBackground,
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryYellow,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeightM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          textStyle: AppTypography.buttonMedium,
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryYellow,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeightM),
          side: const BorderSide(color: AppColors.primaryYellow),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          textStyle: AppTypography.buttonMedium.copyWith(
            color: AppColors.primaryYellow,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryYellow,
          textStyle: AppTypography.buttonMedium.copyWith(
            color: AppColors.primaryYellow,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: AppColors.primaryYellow, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingM,
        ),
        labelStyle: AppTypography.inputLabel,
        hintStyle: AppTypography.inputHint,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryYellow,
        unselectedItemColor: AppColors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryYellow,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: AppDimensions.dividerThickness,
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: AppTypography.h1,
        displayMedium: AppTypography.h2,
        displaySmall: AppTypography.h3,
        headlineLarge: AppTypography.h4,
        headlineMedium: AppTypography.h5,
        headlineSmall: AppTypography.h6,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.buttonLarge,
        labelMedium: AppTypography.buttonMedium,
        labelSmall: AppTypography.buttonSmall,
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryYellow,
        brightness: Brightness.dark,
        primary: AppColors.primaryYellow,
        secondary: AppColors.primaryDark,
        surface: const Color(0xFF121212),
        background: const Color(0xFF000000),
        error: AppColors.error,
        onPrimary: AppColors.black,
        onSecondary: AppColors.white,
        onSurface: AppColors.white,
        onBackground: AppColors.white,
        onError: AppColors.white,
      ),
    );
  }
}