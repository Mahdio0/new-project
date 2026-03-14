import 'package:flutter_test/flutter_test.dart';

import 'package:movie_db/core/errors/app_exception.dart';
import 'package:movie_db/core/constants/app_constants.dart';
import 'package:movie_db/features/home/domain/entities/movie.dart';
import 'package:movie_db/features/home/presentation/providers/movies_provider.dart';
import 'package:movie_db/features/watchlist/domain/entities/watchlist_movie.dart';
import 'package:movie_db/services/api/paginated_result.dart';

void main() {
  // ─── MovieListState ──────────────────────────────────────────────────────────
  group('MovieListState', () {
    test('default state has empty movies, page 1, and no max reached', () {
      const state = MovieListState();
      expect(state.movies, isEmpty);
      expect(state.currentPage, equals(1));
      expect(state.totalPages, equals(1));
      expect(state.isLoadingMore, isFalse);
      expect(state.hasReachedMax, isFalse);
    });

    test('copyWith preserves unchanged fields', () {
      const initial = MovieListState(currentPage: 3, totalPages: 10);
      final updated = initial.copyWith(isLoadingMore: true);
      expect(updated.currentPage, equals(3));
      expect(updated.totalPages, equals(10));
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

    test('hasReachedMax true when set explicitly', () {
      const state = MovieListState(hasReachedMax: true);
      expect(state.hasReachedMax, isTrue);
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

    test('releaseYear handles empty string', () {
      const movie = Movie(
        id: 2,
        title: 'No Date',
        posterPath: null,
        backdropPath: null,
        overview: '',
        voteAverage: 0.0,
        releaseDate: '',
        popularity: 0.0,
      );
      expect(movie.releaseYear, equals(''));
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

  // ─── PaginatedResult ─────────────────────────────────────────────────────────
  group('PaginatedResult', () {
    test('hasReachedMax is true when page equals totalPages', () {
      const result = PaginatedResult<int>(
        items: [1, 2, 3],
        page: 5,
        totalPages: 5,
        totalResults: 100,
      );
      expect(result.hasReachedMax, isTrue);
    });

    test('hasReachedMax is false when more pages remain', () {
      const result = PaginatedResult<int>(
        items: [1, 2],
        page: 3,
        totalPages: 10,
        totalResults: 200,
      );
      expect(result.hasReachedMax, isFalse);
    });

    test('isEmpty reflects empty items list', () {
      const emptyResult = PaginatedResult<String>(
        items: [],
        page: 1,
        totalPages: 1,
        totalResults: 0,
      );
      expect(emptyResult.isEmpty, isTrue);
    });

    test('isFirstPage is true on page 1', () {
      const result = PaginatedResult<String>(
        items: ['a'],
        page: 1,
        totalPages: 3,
        totalResults: 30,
      );
      expect(result.isFirstPage, isTrue);
    });

    test('isFirstPage is false on subsequent pages', () {
      const result = PaginatedResult<String>(
        items: ['b'],
        page: 2,
        totalPages: 3,
        totalResults: 30,
      );
      expect(result.isFirstPage, isFalse);
    });
  });

  // ─── AppException hierarchy ──────────────────────────────────────────────────
  group('AppException', () {
    test('NetworkException has correct userMessage', () {
      const e = NetworkException();
      expect(e, isA<AppException>());
      expect(e.userMessage, contains('internet'));
    });

    test('TimeoutException is a subtype of AppException', () {
      const e = TimeoutException();
      expect(e, isA<AppException>());
    });

    test('UnauthorizedException userMessage is user-safe', () {
      const e = UnauthorizedException();
      expect(e.userMessage, isNot(contains('dart-define')));
      expect(e.userMessage, contains('Authentication'));
    });

    test('NotFoundException userMessage is concise', () {
      const e = NotFoundException();
      expect(e.userMessage, equals('Content not found.'));
    });

    test('RateLimitException userMessage mentions waiting', () {
      const e = RateLimitException();
      expect(e.userMessage, contains('wait'));
    });

    test('ServerException is a subtype of AppException', () {
      const e = ServerException();
      expect(e, isA<AppException>());
    });

    test('ParseException is a subtype of AppException', () {
      const e = ParseException();
      expect(e, isA<AppException>());
    });

    test('UnknownException wraps a custom message', () {
      const e = UnknownException('something weird');
      expect(e.message, equals('something weird'));
    });

    test('toString includes runtimeType', () {
      const e = NetworkException();
      expect(e.toString(), startsWith('NetworkException'));
    });
  });

  // ─── AppConstants ────────────────────────────────────────────────────────────
  group('AppConstants', () {
    test('minTouchTarget is 48dp (WCAG 2.5.5 / Material Design minimum)', () {
      expect(AppConstants.minTouchTarget, equals(48.0));
    });

    test('spacing values follow 8dp baseline grid', () {
      expect(AppConstants.spacing8, equals(8.0));
      expect(AppConstants.spacing16, equals(16.0));
      expect(AppConstants.spacing24, equals(24.0));
      expect(AppConstants.spacing32, equals(32.0));
    });

    test('bottom nav height is 80dp (Android Material 3 guideline)', () {
      expect(AppConstants.bottomNavHeight, equals(80.0));
    });

    test('pageSize is 20 (TMDB default page size)', () {
      expect(AppConstants.pageSize, equals(20));
    });

    test('Hive box names are non-empty strings', () {
      expect(AppConstants.watchlistBox, isNotEmpty);
      expect(AppConstants.settingsBox, isNotEmpty);
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
