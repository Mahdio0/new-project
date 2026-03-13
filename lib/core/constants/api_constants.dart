/// TMDB API base URL and key constants.
///
/// API Key Security:
/// The key is injected at build time via `--dart-define=TMDB_API_KEY=<your_key>`.
/// Never hard-code the real key in source control.
/// Build command: `flutter run --dart-define=TMDB_API_KEY=abc123`
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';

  // Poster sizes: w92, w154, w185, w342, w500, w780, original
  static const String posterW342 = '$imageBaseUrl/w342';
  static const String posterW500 = '$imageBaseUrl/w500';
  static const String backdropW780 = '$imageBaseUrl/w780';

  /// Injected at build time — never committed to source control.
  /// Provide via: `flutter run --dart-define=TMDB_API_KEY=<your_key>`
  static const String tmdbApiKey = String.fromEnvironment(
    'TMDB_API_KEY',
    defaultValue: '',
  );

  // Endpoints
  static const String trending = '/trending/movie/week';
  static const String movieDetails = '/movie';
  static const String movieReviews = '/movie/{id}/reviews';
  static const String search = '/search/movie';
  static const String nowPlaying = '/movie/now_playing';
  static const String upcoming = '/movie/upcoming';
  static const String topRated = '/movie/top_rated';
}
