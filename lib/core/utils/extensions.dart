import 'package:flutter/material.dart';

/// Useful extensions used across the app.
extension ContextExtensions on BuildContext {
  /// Show a floating snack bar (Android Material pattern).
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFCF6679) : null,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

extension StringExtensions on String {
  /// Capitalise first letter.
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

extension DoubleExtensions on double {
  /// Format rating to one decimal place (e.g. 7.4).
  String get ratingString => toStringAsFixed(1);
}
