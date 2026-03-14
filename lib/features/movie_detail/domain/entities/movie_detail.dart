import '../../../home/domain/entities/movie.dart';

/// Extended entity for the detail screen — includes runtime, genres, tagline.
class MovieDetail extends Movie {
  const MovieDetail({
    required super.id,
    required super.title,
    required super.posterPath,
    required super.backdropPath,
    required super.overview,
    required super.voteAverage,
    required super.releaseDate,
    required super.popularity,
    required this.runtime,
    required this.genres,
    required this.tagline,
    required this.status,
    required this.voteCount,
    required this.budget,
    required this.revenue,
  });

  final int runtime;
  final List<Genre> genres;
  final String tagline;
  final String status;
  final int voteCount;
  final int budget;
  final int revenue;

  String get runtimeFormatted {
    if (runtime <= 0) return 'N/A';
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }
}

class Genre {
  const Genre({required this.id, required this.name});
  final int id;
  final String name;
}
