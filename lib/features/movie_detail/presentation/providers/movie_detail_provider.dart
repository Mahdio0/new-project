import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/movie_detail.dart';
import '../../../../services/api/movie_api_service.dart';

final movieDetailProvider =
    FutureProvider.autoDispose.family<MovieDetail, int>((ref, movieId) {
  return ref.watch(movieApiServiceProvider).getMovieDetail(movieId);
});
