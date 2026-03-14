/// Typed exception hierarchy for the Movie DB app.
///
/// All service-layer errors are caught and re-thrown as one of these subtypes.
/// The UI layer only ever handles [AppException] — it never sees raw [DioException]
/// or Dart I/O errors. This enforces clean layer separation.
///
/// Usage:
/// ```dart
/// try {
///   final result = await movieApiService.getTrendingMovies();
/// } on AppException catch (e) {
///   // safe to display e.userMessage to the user
/// }
/// ```
sealed class AppException implements Exception {
  const AppException(this.message);

  /// Developer-facing message (used in logs / Flutter DevTools).
  final String message;

  /// User-friendly one-liner safe to show in a SnackBar or error widget.
  String get userMessage => message;

  @override
  String toString() => '${runtimeType.toString()}: $message';
}

// ─── Network layer errors ─────────────────────────────────────────────────────

/// Device has no connectivity, or the connection timed out / was reset.
/// Offline watchlist should still be accessible when this is thrown.
class NetworkException extends AppException {
  const NetworkException([
    super.message = 'No internet connection. Check your network and try again.',
  ]);
}

/// The request took too long to complete (connect or receive timeout).
class TimeoutException extends AppException {
  const TimeoutException([
    super.message = 'Request timed out. Please try again.',
  ]);
}

// ─── HTTP / server layer errors ───────────────────────────────────────────────

/// HTTP 401 — Invalid or missing TMDB API key.
class UnauthorizedException extends AppException {
  const UnauthorizedException()
      : super(
          'Authentication failed. Ensure TMDB_API_KEY is set via '
          '--dart-define=TMDB_API_KEY=<your_key>.',
        );

  @override
  String get userMessage =>
      'Authentication error. Please check app configuration.';
}

/// HTTP 404 — Resource (movie, reviews page, etc.) does not exist.
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'The requested resource was not found.']);

  @override
  String get userMessage => 'Content not found.';
}

/// HTTP 429 — TMDB rate-limit exceeded.
class RateLimitException extends AppException {
  const RateLimitException()
      : super('TMDB rate limit exceeded. Slow down requests.');

  @override
  String get userMessage => 'Too many requests. Please wait a moment.';
}

/// HTTP 5xx — TMDB backend error.
class ServerException extends AppException {
  const ServerException([
    super.message = 'A server error occurred. Please try again later.',
  ]);

  @override
  String get userMessage => 'Server error. Please try again later.';
}

// ─── Parse / decode errors ────────────────────────────────────────────────────

/// JSON decoding or type-cast failed on the API response.
class ParseException extends AppException {
  const ParseException([
    super.message = 'Failed to parse the server response.',
  ]);

  @override
  String get userMessage => 'Received unexpected data from the server.';
}

// ─── Catch-all ────────────────────────────────────────────────────────────────

/// Any other unexpected error that doesn't fit a specific category.
class UnknownException extends AppException {
  const UnknownException([
    super.message = 'An unexpected error occurred.',
  ]);
}
