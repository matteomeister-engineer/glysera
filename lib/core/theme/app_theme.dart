import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_dimens.dart';

class AppTheme {
  AppTheme._();

  static TextStyle montserrat({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.textPrimary,
    double letterSpacing = -0.3,
    double height = 1.2,
  }) =>
      GoogleFonts.montserrat(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    return base.copyWith(
      colorScheme: const ColorScheme.light(
        primary: AppColors.textPrimary,
        onPrimary: AppColors.backgroundPrimary,
        secondary: AppColors.accent,
        onSecondary: AppColors.textOnAccent,
        surface: AppColors.backgroundPrimary,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.backgroundSurface,
        error: AppColors.glucoseUrgentLow,
        onError: AppColors.backgroundPrimary,
      ),
      textTheme: GoogleFonts.montserratTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.montserrat(fontSize: 57, fontWeight: FontWeight.w700, letterSpacing: -2, color: AppColors.textPrimary),
        displayMedium: GoogleFonts.montserrat(fontSize: 45, fontWeight: FontWeight.w700, letterSpacing: -1.5, color: AppColors.textPrimary),
        headlineLarge: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -1, color: AppColors.textPrimary),
        headlineMedium: GoogleFonts.montserrat(fontSize: 26, fontWeight: FontWeight.w600, letterSpacing: -0.5, color: AppColors.textPrimary),
        titleLarge: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.3, color: AppColors.textPrimary),
        titleMedium: GoogleFonts.montserrat(fontSize: 17, fontWeight: FontWeight.w500, letterSpacing: -0.2, color: AppColors.textPrimary),
        bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.5),
        bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.5),
        bodySmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.4),
        labelLarge: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        labelSmall: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
      scaffoldBackgroundColor: AppColors.backgroundPrimary,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundPrimary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.5),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.backgroundSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          side: const BorderSide(color: AppColors.cardBorder, width: AppDimens.borderThin),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          foregroundColor: AppColors.textOnDark,
          minimumSize: const Size(double.infinity, AppDimens.buttonHeight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusFull)),
          elevation: 0,
          textStyle: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(double.infinity, AppDimens.buttonHeight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusFull)),
          side: const BorderSide(color: AppColors.textPrimary),
          textStyle: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppDimens.lg, vertical: AppDimens.md),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMd), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMd), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMd), borderSide: const BorderSide(color: AppColors.textPrimary)),
        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: AppDimens.borderThin, space: 0),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.textPrimary : AppColors.textTertiary),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.accent : AppColors.backgroundSurface),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: const TextStyle(color: AppColors.textOnDark, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMd)),
        behavior: SnackBarBehavior.floating,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {TargetPlatform.iOS: CupertinoPageTransitionsBuilder()},
      ),
    );
  }
}
