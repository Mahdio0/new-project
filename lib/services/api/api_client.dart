import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';

/// Dio HTTP client configured for TMDB API.
///
/// Responsibilities:
///   1. Attach `api_key` and `X-Platform` headers to every request.
///   2. Retry transient failures (network blips, 5xx) up to [_maxRetries] times
///      with exponential back-off — critical for mobile.
///   3. Map [DioException] → typed [AppException] so the rest of the app never
///      catches raw Dio internals (clean layer contract).
///   4. Log requests/responses to Flutter DevTools console.
///      Rule: Never use print() — use debugPrint(), which is silent in release.
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

  // ── 1. API key + platform header interceptor ─────────────────────────────
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.queryParameters['api_key'] = ApiConstants.tmdbApiKey;
        // Helps TMDB analytics & server-side monitoring
        options.headers['X-Platform'] = 'android';
        handler.next(options);
      },
    ),
  );

  // ── 2. Retry interceptor — 3 retries with exponential back-off ───────────
  dio.interceptors.add(_RetryInterceptor(dio));

  // ── 3. DevTools logging (debug builds only — zero cost in release) ───────
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: false, // keep logs readable; bodies are large for TMDB
        responseBody: false,
        requestHeader: false,
        responseHeader: false,
        // Use debugPrint (not print!) — respects Flutter DevTools log limits
        logPrint: (obj) => debugPrint('[API] $obj'),
      ),
    );
  }

  // ── 4. Error-mapping interceptor — DioException → AppException ───────────
  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (DioException error, handler) {
        handler.reject(
          DioException(
            requestOptions: error.requestOptions,
            error: _mapToAppException(error),
            type: error.type,
            response: error.response,
          ),
        );
      },
    ),
  );

  return dio;
});

// ─── Retry Interceptor ────────────────────────────────────────────────────────

/// Retries idempotent GET requests on transient failures.
///
/// Retried conditions:
///   - [DioExceptionType.connectionError] (no network / socket closed)
///   - [DioExceptionType.connectionTimeout] / [DioExceptionType.receiveTimeout]
///   - HTTP 500, 502, 503, 504 (server temporarily unavailable)
///
/// Not retried: 4xx client errors (retrying won't help).
class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this._dio);

  final Dio _dio;

  static const int _maxRetries = 3;
  static const Duration _baseDelay = Duration(milliseconds: 500);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = err.requestOptions.extra['_retryCount'] as int? ?? 0;

    if (_shouldRetry(err) && attempt < _maxRetries) {
      // Exponential back-off: delay = 500ms × 2^attempt → 500ms, 1s, 2s
      // (1 << attempt) computes 2^attempt using a bit-shift (0→1, 1→2, 2→4)
      final delay = _baseDelay * (1 << attempt);
      debugPrint('[API] Retry ${attempt + 1}/$_maxRetries after ${delay.inMilliseconds}ms'
          ' — ${err.requestOptions.path}');

      await Future<void>.delayed(delay);

      // Carry retry count in extra so we can track it across retries
      final options = err.requestOptions..extra['_retryCount'] = attempt + 1;
      try {
        final response = await _dio.fetch<dynamic>(options);
        handler.resolve(response);
      } on DioException catch (retryError) {
        handler.next(retryError);
      }
      return;
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return true;
      case DioExceptionType.badResponse:
        final status = err.response?.statusCode ?? 0;
        return status >= 500; // retry server-side errors only
      default:
        return false;
    }
  }
}

// ─── DioException → AppException mapping ─────────────────────────────────────

/// Converts a [DioException] into a typed [AppException].
///
/// Called inside the error-mapping interceptor before the exception propagates
/// up to the provider / UI layer. The provider catches `AppException` and turns
/// it into a user-readable error state.
AppException _mapToAppException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionError:
      return const NetworkException();
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const TimeoutException();
    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode ?? 0;
      return switch (statusCode) {
        401 => const UnauthorizedException(),
        404 => const NotFoundException(),
        429 => const RateLimitException(),
        >= 500 => const ServerException(),
        _ => ServerException('HTTP $statusCode received from TMDB API.'),
      };
    case DioExceptionType.cancel:
      return const UnknownException('Request was cancelled.');
    default:
      final inner = error.error;
      if (inner is AppException) return inner;
      return UnknownException(error.message ?? 'Unknown network error.');
  }
}
