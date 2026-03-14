/// Core movie entity used throughout the app.
/// Minimal fields needed for list display (bandwidth efficiency).
class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.backdropPath,
    required this.overview,
    required this.voteAverage,
    required this.releaseDate,
    required this.popularity,
  });

  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final double voteAverage;
  final String releaseDate;
  final double popularity;

  String get releaseYear =>
      releaseDate.length >= 4 ? releaseDate.substring(0, 4) : releaseDate;
}
