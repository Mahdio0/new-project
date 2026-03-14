import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../features/home/data/models/movie_model.dart';
import '../../features/movie_detail/data/models/movie_detail_model.dart';
import '../../features/reviews/data/models/review_model.dart';
import '../api/api_client.dart';
import 'paginated_result.dart';

final movieApiServiceProvider = Provider<MovieApiService>((ref) {
  return MovieApiService(ref.watch(apiClientProvider));
});

/// Thin data-access layer around the TMDB REST API.
///
/// Contract:
///   - All methods are async and can throw an [AppException] on failure.
///   - Paginated endpoints return [PaginatedResult<T>] — a single network
///     round-trip delivers both the items *and* the pagination metadata,
///     eliminating the need for a separate "total pages" call.
///   - Raw [DioException] is caught here and re-thrown as a typed
///     [AppException] (the mapping interceptor in [apiClientProvider] converts
///     most cases; this catch is the last safety net).
class MovieApiService {
  MovieApiService(this._dio);

  final Dio _dio;

  // ─── Trending ────────────────────────────────────────────────────────────

  /// Trending movies for the current week, with full pagination metadata.
  Future<PaginatedResult<MovieModel>> getTrendingMovies({int page = 1}) async {
    return _fetchMoviePage(ApiConstants.trending, page: page);
  }

  // ─── Category lists ──────────────────────────────────────────────────────

  /// Now-playing movies (cinema releases), paginated.
  Future<PaginatedResult<MovieModel>> getNowPlayingMovies({int page = 1}) async {
    return _fetchMoviePage(ApiConstants.nowPlaying, page: page);
  }

  /// Top-rated movies of all time, paginated.
  Future<PaginatedResult<MovieModel>> getTopRatedMovies({int page = 1}) async {
    return _fetchMoviePage(ApiConstants.topRated, page: page);
  }

  // ─── Search ──────────────────────────────────────────────────────────────

  /// Full-text search against the TMDB movie catalogue.
  /// Returns an empty [PaginatedResult] immediately for blank queries to avoid
  /// a wasted network request (no unnecessary traffic).
  Future<PaginatedResult<MovieModel>> searchMovies(
    String query, {
    int page = 1,
  }) async {
    if (query.trim().isEmpty) {
      return const PaginatedResult(
        items: [],
        page: 1,
        totalPages: 1,
        totalResults: 0,
      );
    }
    return _fetchMoviePage(
      ApiConstants.search,
      page: page,
      extra: {'query': query, 'include_adult': false},
    );
  }

  // ─── Movie detail ─────────────────────────────────────────────────────────

  /// Full detail for a single movie — runtime, genres, budget, tagline, etc.
  Future<MovieDetailModel> getMovieDetail(int movieId) async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>('${ApiConstants.movieDetails}/$movieId');
      return MovieDetailModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _extractAppException(e);
    } catch (e) {
      throw ParseException('Failed to decode movie detail: $e');
    }
  }

  // ─── Reviews ─────────────────────────────────────────────────────────────

  /// Paginated user reviews for a movie.
  Future<ReviewsResponse> getMovieReviews(int movieId, {int page = 1}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '${ApiConstants.movieDetails}/$movieId/reviews',
        queryParameters: {'page': page},
      );
      return ReviewsResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw _extractAppException(e);
    } catch (e) {
      throw ParseException('Failed to decode reviews: $e');
    }
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  /// Shared helper for all list/paginated movie endpoints.
  Future<PaginatedResult<MovieModel>> _fetchMoviePage(
    String path, {
    required int page,
    Map<String, dynamic>? extra,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: {'page': page, ...?extra},
      );
      final data = response.data!;
      final results = data['results'] as List<dynamic>? ?? [];
      final movies =
          results.map((e) => MovieModel.fromJson(e as Map<String, dynamic>)).toList();

      // TMDB API hard-caps total_pages at 500 regardless of total_results.
      // See https://developer.themoviedb.org/reference/movie-popular-list
      // Clamping prevents infinite-scroll from requesting beyond page 500.
      final totalPages = (data['total_pages'] as int? ?? 1).clamp(1, 500);
      final totalResults = data['total_results'] as int? ?? 0;

      return PaginatedResult(
        items: movies,
        page: page,
        totalPages: totalPages,
        totalResults: totalResults,
      );
    } on DioException catch (e) {
      throw _extractAppException(e);
    } catch (e) {
      throw ParseException('Failed to decode movie list from $path: $e');
    }
  }

  /// Extracts the [AppException] that the error-mapping interceptor already
  /// attached as [DioException.error], or creates a fallback [UnknownException].
  AppException _extractAppException(DioException e) {
    final inner = e.error;
    if (inner is AppException) return inner;
    // Fallback — should rarely reach here since the interceptor maps everything
    return UnknownException(e.message ?? 'Unexpected error from TMDB.');
  }
}
