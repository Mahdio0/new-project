/// Generic pagination wrapper returned by any paginated TMDB API call.
///
/// Eliminates the need for a separate "total pages" request: every list
/// endpoint now returns both the items *and* the pagination metadata in
/// a single network round-trip.
///
/// Example – trending movies on page 2 of 500:
/// ```dart
/// PaginatedResult<Movie>(
///   items: [...],
///   page: 2,
///   totalPages: 500,
///   totalResults: 10000,
/// )
/// ```
class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalResults,
  });

  /// The decoded items on this page.
  final List<T> items;

  /// Current page number (1-based, matches TMDB convention).
  final int page;

  /// Total number of pages available for this query.
  final int totalPages;

  /// Total number of individual results across all pages.
  final int totalResults;

  // ─── Derived helpers ─────────────────────────────────────────────────────

  /// True when the caller has already fetched the last available page.
  bool get hasReachedMax => page >= totalPages;

  /// True when the current page returned no items.
  bool get isEmpty => items.isEmpty;

  /// Total items fetched so far is exactly `items.length` for page 1.
  /// Providers accumulate across pages; use the provider's own list length.
  bool get isFirstPage => page == 1;
}
