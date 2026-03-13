import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:movie_db/features/home/presentation/providers/movies_provider.dart';
import 'package:movie_db/features/watchlist/domain/entities/watchlist_movie.dart';
import 'package:movie_db/features/home/domain/entities/movie.dart';
import 'package:movie_db/core/constants/app_constants.dart';

void main() {
  // ─── MovieListState ──────────────────────────────────────────────────────────
  group('MovieListState', () {
    test('default state has empty movies and page 1', () {
      const state = MovieListState();
      expect(state.movies, isEmpty);
      expect(state.currentPage, equals(1));
      expect(state.isLoadingMore, isFalse);
      expect(state.hasReachedMax, isFalse);
    });

    test('copyWith preserves unchanged fields', () {
      const initial = MovieListState(currentPage: 3);
      final updated = initial.copyWith(isLoadingMore: true);
      expect(updated.currentPage, equals(3));
      expect(updated.isLoadingMore, isTrue);
      expect(updated.hasReachedMax, isFalse);
    });

    test('copyWith movies replaces list correctly', () {
      final movie = _testMovie();
      const initial = MovieListState();
      final updated = initial.copyWith(movies: [movie]);
      expect(updated.movies.length, equals(1));
      expect(updated.movies.first.id, equals(1));
    });
  });

  // ─── Movie entity ────────────────────────────────────────────────────────────
  group('Movie entity', () {
    test('releaseYear extracts 4-digit year', () {
      final movie = _testMovie();
      expect(movie.releaseYear, equals('2024'));
    });

    test('releaseYear returns full string if < 4 chars', () {
      const movie = Movie(
        id: 1,
        title: 'T',
        posterPath: null,
        backdropPath: null,
        overview: '',
        voteAverage: 7.0,
        releaseDate: '202',
        popularity: 1.0,
      );
      expect(movie.releaseYear, equals('202'));
    });
  });

  // ─── WatchlistMovie entity ───────────────────────────────────────────────────
  group('WatchlistMovie', () {
    test('releaseYear extracted correctly', () {
      final wm = WatchlistMovie(
        id: 42,
        title: 'Inception',
        posterPath: '/poster.jpg',
        voteAverage: 8.8,
        releaseDate: '2010-07-16',
        addedAt: DateTime(2024, 1, 1),
      );
      expect(wm.releaseYear, equals('2010'));
    });

    test('id is used as Hive key (int)', () {
      final wm = WatchlistMovie(
        id: 999,
        title: 'Test',
        posterPath: null,
        voteAverage: 5.0,
        releaseDate: '2023-01-01',
        addedAt: DateTime(2024),
      );
      expect(wm.id, equals(999));
    });
  });

  // ─── AppConstants ────────────────────────────────────────────────────────────
  group('AppConstants', () {
    test('minTouchTarget is 48dp', () {
      expect(AppConstants.minTouchTarget, equals(48.0));
    });

    test('spacing values follow 8dp grid', () {
      expect(AppConstants.spacing8, equals(8.0));
      expect(AppConstants.spacing16, equals(16.0));
      expect(AppConstants.spacing24, equals(24.0));
      expect(AppConstants.spacing32, equals(32.0));
    });

    test('bottom nav height is 80dp (Android Material 3 guideline)', () {
      expect(AppConstants.bottomNavHeight, equals(80.0));
    });
  });
}

Movie _testMovie() => const Movie(
      id: 1,
      title: 'Test Movie',
      posterPath: '/test.jpg',
      backdropPath: null,
      overview: 'A test movie overview.',
      voteAverage: 7.5,
      releaseDate: '2024-06-15',
      popularity: 100.0,
    );
