import 'package:hive/hive.dart';

part 'watchlist_movie.g.dart';

/// Minimal movie data stored in the offline Hive watchlist.
/// We store only what we need for the watchlist screen to render without network.
@HiveType(typeId: 0)
class WatchlistMovie extends HiveObject {
  WatchlistMovie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.addedAt,
  });

  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? posterPath;

  @HiveField(3)
  final double voteAverage;

  @HiveField(4)
  final String releaseDate;

  @HiveField(5)
  final DateTime addedAt;

  String get releaseYear =>
      releaseDate.length >= 4 ? releaseDate.substring(0, 4) : releaseDate;
}
