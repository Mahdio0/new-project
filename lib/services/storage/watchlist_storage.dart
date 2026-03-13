import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/watchlist/domain/entities/watchlist_movie.dart';
import '../storage/hive_storage.dart';

final watchlistStorageProvider = Provider<WatchlistStorage>((ref) {
  return WatchlistStorage();
});

/// Provides CRUD operations on the Hive watchlist box.
/// All operations are synchronous — Hive is an embedded NoSQL store.
class WatchlistStorage {
  /// All saved movies, sorted by date added (newest first).
  List<WatchlistMovie> getAll() {
    final box = HiveStorage.watchlistBox;
    final movies = box.values.toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return movies;
  }

  /// Returns true if a movie is in the watchlist.
  bool contains(int movieId) {
    return HiveStorage.watchlistBox.containsKey(movieId);
  }

  /// Add a movie to the watchlist. Uses movieId as Hive key for O(1) lookup.
  Future<void> add(WatchlistMovie movie) async {
    await HiveStorage.watchlistBox.put(movie.id, movie);
  }

  /// Remove a movie from the watchlist by its TMDB id.
  Future<void> remove(int movieId) async {
    await HiveStorage.watchlistBox.delete(movieId);
  }

  /// Clear entire watchlist.
  Future<void> clear() async {
    await HiveStorage.watchlistBox.clear();
  }
}
