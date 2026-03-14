import 'package:flutter/material.dart';

/// OLED-optimized dark theme.
/// Background: True Black #000000 — maximum OLED battery savings (mobile-color-system.md).
/// Surfaces: #0D0D0D / #1A1A1A — slight elevation, no harsh edges.
/// Text: #E0E0E0 — not pure white (reduces eye strain).
class AppTheme {
  AppTheme._();

  // OLED colour palette
  static const Color _background = Color(0xFF000000); // True Black
  static const Color _surface = Color(0xFF0D0D0D);
  static const Color _surface2 = Color(0xFF1A1A1A);
  static const Color _surface3 = Color(0xFF2C2C2C);

  static const Color _primary = Color(0xFFE50914); // Netflix-style accent
  static const Color _primaryContainer = Color(0xFF8C0A0F);
  static const Color _onPrimary = Color(0xFFFFFFFF);

  static const Color _textPrimary = Color(0xFFE0E0E0);
  static const Color _textSecondary = Color(0xFFA0A0A0);
  static const Color _textDisabled = Color(0xFF606060);

  static const Color _error = Color(0xFFCF6679);
  static const Color _success = Color(0xFF4CAF50);

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        // Colour scheme
        colorScheme: const ColorScheme.dark(
          surface: _background,
          onSurface: _textPrimary,
          surfaceContainerHighest: _surface2,
          primary: _primary,
          primaryContainer: _primaryContainer,
          onPrimary: _onPrimary,
          secondary: Color(0xFFFFD700),
          onSecondary: Color(0xFF000000),
          error: _error,
          onError: _onPrimary,
        ),

        scaffoldBackgroundColor: _background,
        canvasColor: _background,
        cardColor: _surface,
        dividerColor: _surface3,

        // AppBar — transparent, blends with OLED black
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: _textPrimary,
          titleTextStyle: TextStyle(
            color: _textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),

        // BottomNavigationBar — true black, 80dp height (platform-android.md)
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: _background,
          selectedItemColor: _primary,
          unselectedItemColor: _textDisabled,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          unselectedLabelStyle: TextStyle(fontSize: 12),
        ),

        // NavigationBar (Material 3 version)
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _background,
          indicatorColor: _primaryContainer,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: _primary, size: 24);
            }
            return const IconThemeData(color: _textDisabled, size: 24);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: _primary, fontSize: 12, fontWeight: FontWeight.w500);
            }
            return const TextStyle(color: _textDisabled, fontSize: 12);
          }),
          height: 80,
        ),

        // Cards — dark surface, 12dp corner radius (platform-android.md)
        cardTheme: CardThemeData(
          color: _surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.zero,
        ),

        // Chips
        chipTheme: ChipThemeData(
          backgroundColor: _surface2,
          selectedColor: _primaryContainer,
          labelStyle: const TextStyle(color: _textPrimary, fontSize: 12),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),

        // Text theme — Roboto is Android default (platform-android.md)
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: _textPrimary, fontSize: 57, fontWeight: FontWeight.w300),
          displayMedium: TextStyle(color: _textPrimary, fontSize: 45, fontWeight: FontWeight.w300),
          displaySmall: TextStyle(color: _textPrimary, fontSize: 36, fontWeight: FontWeight.w300),
          headlineLarge: TextStyle(color: _textPrimary, fontSize: 32, fontWeight: FontWeight.w400),
          headlineMedium: TextStyle(color: _textPrimary, fontSize: 28, fontWeight: FontWeight.w400),
          headlineSmall: TextStyle(color: _textPrimary, fontSize: 24, fontWeight: FontWeight.w400),
          titleLarge: TextStyle(color: _textPrimary, fontSize: 22, fontWeight: FontWeight.w400),
          titleMedium: TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
          titleSmall: TextStyle(color: _textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.w400),
          bodyMedium: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w400),
          bodySmall: TextStyle(color: _textSecondary, fontSize: 12, fontWeight: FontWeight.w400),
          labelLarge: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
          labelMedium: TextStyle(color: _textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
          labelSmall: TextStyle(color: _textDisabled, fontSize: 11, fontWeight: FontWeight.w500),
        ),

        // Buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: _onPrimary,
            minimumSize: const Size(double.infinity, 48), // 48dp touch target
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            minimumSize: const Size(48, 48), // 48dp touch target (touch-psychology.md)
            iconSize: 24,
          ),
        ),

        // Input fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surface2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primary),
          ),
          hintStyle: const TextStyle(color: _textDisabled),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),

        // SnackBar
        snackBarTheme: SnackBarThemeData(
          backgroundColor: _surface2,
          contentTextStyle: const TextStyle(color: _textPrimary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          behavior: SnackBarBehavior.floating,
        ),
      );
}
