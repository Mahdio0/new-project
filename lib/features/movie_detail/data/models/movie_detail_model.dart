import '../../domain/entities/movie_detail.dart';

class MovieDetailModel extends MovieDetail {
  const MovieDetailModel({
    required super.id,
    required super.title,
    required super.posterPath,
    required super.backdropPath,
    required super.overview,
    required super.voteAverage,
    required super.releaseDate,
    required super.popularity,
    required super.runtime,
    required super.genres,
    required super.tagline,
    required super.status,
    required super.voteCount,
    required super.budget,
    required super.revenue,
  });

  factory MovieDetailModel.fromJson(Map<String, dynamic> json) {
    final genreList = (json['genres'] as List<dynamic>?)
            ?.map((g) => Genre(
                  id: g['id'] as int,
                  name: g['name'] as String,
                ))
            .toList() ??
        [];

    return MovieDetailModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      overview: json['overview'] as String? ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: json['release_date'] as String? ?? '',
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      runtime: json['runtime'] as int? ?? 0,
      genres: genreList,
      tagline: json['tagline'] as String? ?? '',
      status: json['status'] as String? ?? '',
      voteCount: json['vote_count'] as int? ?? 0,
      budget: json['budget'] as int? ?? 0,
      revenue: json['revenue'] as int? ?? 0,
    );
  }
}
