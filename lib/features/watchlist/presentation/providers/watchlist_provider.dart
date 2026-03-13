import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/watchlist_movie.dart';
import '../../../../services/storage/watchlist_storage.dart';

/// Synchronous notifier — Hive operations are O(1) and non-async.
class WatchlistNotifier extends AutoDisposeNotifier<List<WatchlistMovie>> {
  @override
  List<WatchlistMovie> build() {
    return ref.watch(watchlistStorageProvider).getAll();
  }

  bool contains(int movieId) {
    return ref.read(watchlistStorageProvider).contains(movieId);
  }

  Future<void> add(WatchlistMovie movie) async {
    await ref.read(watchlistStorageProvider).add(movie);
    ref.invalidateSelf();
  }

  Future<void> remove(int movieId) async {
    await ref.read(watchlistStorageProvider).remove(movieId);
    ref.invalidateSelf();
  }

  Future<void> toggle(WatchlistMovie movie) async {
    if (contains(movie.id)) {
      await remove(movie.id);
    } else {
      await add(movie);
    }
  }
}

final watchlistProvider =
    AutoDisposeNotifierProvider<WatchlistNotifier, List<WatchlistMovie>>(
  WatchlistNotifier.new,
);

/// Convenience provider — true/false for a specific movieId.
/// Surgical rebuild: only widgets watching this specific id rebuild.
final isInWatchlistProvider = Provider.autoDispose.family<bool, int>((ref, movieId) {
  final movies = ref.watch(watchlistProvider);
  return movies.any((m) => m.id == movieId);
});
