import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../features/home/data/models/movie_model.dart';
import '../../features/movie_detail/data/models/movie_detail_model.dart';
import '../../features/reviews/data/models/review_model.dart';
import '../api/api_client.dart';

final movieApiServiceProvider = Provider<MovieApiService>((ref) {
  return MovieApiService(ref.watch(apiClientProvider));
});

class MovieApiService {
  MovieApiService(this._dio);

  final Dio _dio;

  /// Fetch trending movies for the week.
  /// Pagination: page-based (TMDB uses page offset, max 500 pages).
  Future<List<MovieModel>> getTrendingMovies({int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.trending,
      queryParameters: {'page': page},
    );
    final results = response.data['results'] as List<dynamic>;
    return results.map((e) => MovieModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Fetch now-playing movies (paginated).
  Future<List<MovieModel>> getNowPlayingMovies({int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.nowPlaying,
      queryParameters: {'page': page},
    );
    final results = response.data['results'] as List<dynamic>;
    return results.map((e) => MovieModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Fetch top-rated movies (paginated).
  Future<List<MovieModel>> getTopRatedMovies({int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.topRated,
      queryParameters: {'page': page},
    );
    final results = response.data['results'] as List<dynamic>;
    return results.map((e) => MovieModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Full movie details including runtime, genres, etc.
  Future<MovieDetailModel> getMovieDetail(int movieId) async {
    final response = await _dio.get('${ApiConstants.movieDetails}/$movieId');
    return MovieDetailModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Movie reviews with pagination.
  Future<ReviewsResponse> getMovieReviews(int movieId, {int page = 1}) async {
    final response = await _dio.get(
      '${ApiConstants.movieDetails}/$movieId/reviews',
      queryParameters: {'page': page},
    );
    return ReviewsResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Search movies by query.
  Future<List<MovieModel>> searchMovies(String query, {int page = 1}) async {
    if (query.isEmpty) return [];
    final response = await _dio.get(
      ApiConstants.search,
      queryParameters: {
        'query': query,
        'page': page,
        'include_adult': false,
      },
    );
    final results = response.data['results'] as List<dynamic>;
    return results.map((e) => MovieModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Total pages for trending (used for infinite scroll pagination).
  Future<int> getTrendingTotalPages() async {
    final response = await _dio.get(
      ApiConstants.trending,
      queryParameters: {'page': 1},
    );
    return (response.data['total_pages'] as int).clamp(1, AppConstants.pageSize * 25);
  }
}
