/// App-wide constants.
/// All spacing follows the Android 8dp baseline grid (platform-android.md).
class AppConstants {
  AppConstants._();

  // Touch targets — minimum 48dp per Material Design / WCAG
  static const double minTouchTarget = 48.0;

  // Spacing — 8dp baseline grid (platform-android.md)
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;

  // Card / corner radius
  static const double cardRadius = 12.0;
  static const double chipRadius = 8.0;

  // Movie card dimensions (for ListView.builder itemExtent optimization)
  static const double movieCardHeight = 220.0;
  static const double movieCardWidth = 140.0;
  static const double movieListItemHeight = 120.0;

  // Bottom nav height (platform-android.md — 80dp)
  static const double bottomNavHeight = 80.0;

  // Animation durations (mobile-performance.md)
  static const Duration microDuration = Duration(milliseconds: 150);
  static const Duration standardDuration = Duration(milliseconds: 250);
  static const Duration pageDuration = Duration(milliseconds: 350);

  // Pagination
  static const int pageSize = 20;

  // Hive box names
  static const String watchlistBox = 'watchlist';
  static const String settingsBox = 'settings';
}
