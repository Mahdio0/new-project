import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';

/// Dio HTTP client configured for TMDB API.
/// Includes: base URL, API key interceptor, timeout.
/// Mobile-specific: compact requests, cursor-style pagination (mobile-backend.md).
final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  // API key interceptor — adds ?api_key= to every request
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.queryParameters['api_key'] = ApiConstants.tmdbApiKey;
        // Mobile backend headers for monitoring (mobile-backend.md §9)
        options.headers['X-Platform'] = 'android';
        handler.next(options);
      },
      onError: (error, handler) {
        // Pass through; repositories handle error mapping
        handler.next(error);
      },
    ),
  );

  return dio;
});
