import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/movie.dart';
import '../../../../services/api/movie_api_service.dart';

// ────────────────────────────────────────────────────────────────
// Trending movies — paginated, cached by Riverpod's keepAlive
// ────────────────────────────────────────────────────────────────

/// State for paginated movie list with infinite scroll.
class MovieListState {
  const MovieListState({
    this.movies = const [],
    this.currentPage = 1,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
  });

  final List<Movie> movies;
  final int currentPage;
  final bool isLoadingMore;
  final bool hasReachedMax;

  MovieListState copyWith({
    List<Movie>? movies,
    int? currentPage,
    bool? isLoadingMore,
    bool? hasReachedMax,
  }) {
    return MovieListState(
      movies: movies ?? this.movies,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

/// Trending movies notifier — first page fetched on creation.
/// Uses AsyncNotifier for clean loading/error/data states.
class TrendingMoviesNotifier extends AutoDisposeAsyncNotifier<MovieListState> {
  @override
  Future<MovieListState> build() async {
    final movies = await ref
        .watch(movieApiServiceProvider)
        .getTrendingMovies(page: 1);
    return MovieListState(movies: movies);
  }

  /// Load next page (called when user scrolls near the end of the list).
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || current.hasReachedMax) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;
    try {
      final newMovies = await ref
          .read(movieApiServiceProvider)
          .getTrendingMovies(page: nextPage);

      if (newMovies.isEmpty) {
        state = AsyncData(
          current.copyWith(isLoadingMore: false, hasReachedMax: true),
        );
      } else {
        state = AsyncData(
          current.copyWith(
            movies: [...current.movies, ...newMovies],
            currentPage: nextPage,
            isLoadingMore: false,
          ),
        );
      }
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  /// Pull-to-refresh: reset state and reload page 1.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final movies = await ref
          .read(movieApiServiceProvider)
          .getTrendingMovies(page: 1);
      return MovieListState(movies: movies);
    });
  }
}

final trendingMoviesProvider =
    AutoDisposeAsyncNotifierProvider<TrendingMoviesNotifier, MovieListState>(
  TrendingMoviesNotifier.new,
);

/// Top-rated movies provider.
final topRatedMoviesProvider = FutureProvider.autoDispose<List<Movie>>((ref) {
  return ref.watch(movieApiServiceProvider).getTopRatedMovies();
});

/// Now-playing movies provider.
final nowPlayingMoviesProvider = FutureProvider.autoDispose<List<Movie>>((ref) {
  return ref.watch(movieApiServiceProvider).getNowPlayingMovies();
});
