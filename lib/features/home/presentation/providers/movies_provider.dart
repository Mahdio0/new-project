import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/movie.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../services/api/movie_api_service.dart';

// ────────────────────────────────────────────────────────────────
// Trending movies — paginated, cached by Riverpod's keepAlive
// ────────────────────────────────────────────────────────────────

/// State for paginated movie list with infinite scroll.
class MovieListState {
  const MovieListState({
    this.movies = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
  });

  final List<Movie> movies;
  final int currentPage;
  final int totalPages;
  final bool isLoadingMore;
  final bool hasReachedMax;

  MovieListState copyWith({
    List<Movie>? movies,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
    bool? hasReachedMax,
  }) {
    return MovieListState(
      movies: movies ?? this.movies,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

/// Trending movies notifier — first page fetched on creation.
/// Uses AsyncNotifier for clean loading/error/data states (Riverpod 2.0).
class TrendingMoviesNotifier extends AutoDisposeAsyncNotifier<MovieListState> {
  @override
  Future<MovieListState> build() async {
    final result = await ref
        .watch(movieApiServiceProvider)
        .getTrendingMovies(page: 1);
    return MovieListState(
      movies: result.items,
      currentPage: result.page,
      totalPages: result.totalPages,
      hasReachedMax: result.hasReachedMax,
    );
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
      final result = await ref
          .read(movieApiServiceProvider)
          .getTrendingMovies(page: nextPage);

      state = AsyncData(
        current.copyWith(
          movies: [...current.movies, ...result.items],
          currentPage: result.page,
          totalPages: result.totalPages,
          isLoadingMore: false,
          hasReachedMax: result.hasReachedMax,
        ),
      );
    } on AppException {
      // Restore previous state — user can retry by scrolling again
      state = AsyncData(current.copyWith(isLoadingMore: false));
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  /// Pull-to-refresh: reset state and reload page 1.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(movieApiServiceProvider)
          .getTrendingMovies(page: 1);
      return MovieListState(
        movies: result.items,
        currentPage: result.page,
        totalPages: result.totalPages,
        hasReachedMax: result.hasReachedMax,
      );
    });
  }
}

final trendingMoviesProvider =
    AutoDisposeAsyncNotifierProvider<TrendingMoviesNotifier, MovieListState>(
  TrendingMoviesNotifier.new,
);

/// Top-rated movies provider (first page only — used as a secondary feed).
final topRatedMoviesProvider = FutureProvider.autoDispose<List<Movie>>((ref) async {
  final result = await ref.watch(movieApiServiceProvider).getTopRatedMovies();
  return result.items;
});

/// Now-playing movies provider (first page only — used as a secondary feed).
final nowPlayingMoviesProvider = FutureProvider.autoDispose<List<Movie>>((ref) async {
  final result = await ref.watch(movieApiServiceProvider).getNowPlayingMovies();
  return result.items;
});
