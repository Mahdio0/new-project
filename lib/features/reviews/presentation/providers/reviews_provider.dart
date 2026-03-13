import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/review_model.dart';
import '../../../../services/api/movie_api_service.dart';

class ReviewsState {
  const ReviewsState({
    this.reviews = const [],
    this.currentPage = 1,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.totalResults = 0,
  });

  final List<ReviewModel> reviews;
  final int currentPage;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final int totalResults;

  ReviewsState copyWith({
    List<ReviewModel>? reviews,
    int? currentPage,
    bool? isLoadingMore,
    bool? hasReachedMax,
    int? totalResults,
  }) {
    return ReviewsState(
      reviews: reviews ?? this.reviews,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      totalResults: totalResults ?? this.totalResults,
    );
  }
}

/// Reviews notifier using Riverpod 2 FamilyAsyncNotifier.
/// `arg` (= movieId) is available from the parent class.
class ReviewsNotifier
    extends AutoDisposeFamilyAsyncNotifier<ReviewsState, int> {
  @override
  Future<ReviewsState> build(int arg) async {
    final response = await ref
        .watch(movieApiServiceProvider)
        .getMovieReviews(arg, page: 1);
    return ReviewsState(
      reviews: response.reviews,
      totalResults: response.totalResults,
      hasReachedMax: response.totalPages <= 1,
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || current.hasReachedMax) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;
    try {
      final response = await ref
          .read(movieApiServiceProvider)
          .getMovieReviews(arg, page: nextPage);

      if (response.reviews.isEmpty) {
        state =
            AsyncData(current.copyWith(isLoadingMore: false, hasReachedMax: true));
      } else {
        state = AsyncData(
          current.copyWith(
            reviews: [...current.reviews, ...response.reviews],
            currentPage: nextPage,
            isLoadingMore: false,
            hasReachedMax: nextPage >= response.totalPages,
          ),
        );
      }
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }
}

/// Family provider — one ReviewsNotifier per movieId.
final reviewsProvider = AsyncNotifierProvider.autoDispose
    .family<ReviewsNotifier, ReviewsState, int>(ReviewsNotifier.new);
