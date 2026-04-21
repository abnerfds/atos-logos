import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design System: "Serene Steward"
/// High-End Editorial church management platform.
/// Palette: Ethereal blues + grounded neutrals with atmospheric layering.
class AppTheme {
  AppTheme._();

  // ── Core Palette ──────────────────────────────────────────────────────
  static const primary = Color(0xFF37628A);
  static const primaryDim = Color(0xFF29567D);
  static const onPrimary = Color(0xFFF7F9FF);
  static const primaryContainer = Color(0xFFA6D0FE);
  static const onPrimaryContainer = Color(0xFF16476D);

  static const surface = Color(0xFFF7F9FC);
  static const surfaceContainerLow = Color(0xFFF0F4F8);
  static const surfaceContainer = Color(0xFFE9EEF3);
  static const surfaceContainerHigh = Color(0xFFE3E9EE);
  static const surfaceContainerHighest = Color(0xFFDCE3E9);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);

  static const onSurface = Color(0xFF2C3338);
  static const onSurfaceVariant = Color(0xFF596065);

  static const outline = Color(0xFF747C81);
  static const outlineVariant = Color(0xFFABB3B9);

  static const secondaryContainer = Color(0xFFCDE6F4);
  static const error = Color(0xFFA83836);
  static const onError = Color(0xFFFFF7F6);

  // ── Shadows (tinted, not pure black) ──────────────────────────────────
  static const cardShadow = [
    BoxShadow(
      offset: Offset(0, 12),
      blurRadius: 40,
      color: Color(0x0F2C3338), // rgba(44,51,56, 0.06)
    ),
  ];

  static const buttonShadow = [
    BoxShadow(
      offset: Offset(0, 8),
      blurRadius: 20,
      color: Color(0x3337628A), // rgba(55,98,138, 0.2)
    ),
  ];

  // ── Border Radius ─────────────────────────────────────────────────────
  static const radiusSm = 4.0;
  static const radiusMd = 8.0;
  static const radiusLg = 12.0;
  static const radiusXl = 16.0;

  // ── Theme Data ────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final headlineFont = GoogleFonts.manropeTextTheme();
    final bodyFont = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: surface,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        secondaryContainer: secondaryContainer,
        error: error,
        onError: onError,
      ),
      textTheme: TextTheme(
        displayLarge: headlineFont.displayLarge?.copyWith(
          color: onSurface,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        displayMedium: headlineFont.displayMedium?.copyWith(
          color: onSurface,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineLarge: headlineFont.headlineLarge?.copyWith(
          color: onSurface,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        headlineMedium: headlineFont.headlineMedium?.copyWith(
          color: onSurface,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        headlineSmall: headlineFont.headlineSmall?.copyWith(
          color: onSurface,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: bodyFont.titleLarge?.copyWith(
          color: onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: bodyFont.titleMedium?.copyWith(
          color: onSurface,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: bodyFont.bodyLarge?.copyWith(color: onSurface),
        bodyMedium: bodyFont.bodyMedium?.copyWith(color: onSurface),
        bodySmall: bodyFont.bodySmall?.copyWith(color: onSurfaceVariant),
        labelLarge: bodyFont.labelLarge?.copyWith(
          color: onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
        labelMedium: bodyFont.labelMedium?.copyWith(
          color: onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
        labelSmall: bodyFont.labelSmall?.copyWith(
          color: onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: outline, fontSize: 14),
        labelStyle: const TextStyle(color: onSurfaceVariant),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return surfaceContainerHigh;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        side: BorderSide.none,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: error,
        contentTextStyle: TextStyle(color: onError),
      ),
    );
  }
}
