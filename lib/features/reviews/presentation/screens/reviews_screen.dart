import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../providers/reviews_provider.dart';
import '../widgets/review_card.dart';

/// Reviews Screen — paginated TMDB reviews.
///
/// Performance: SliverList with delegate — no eager-loading.
/// Infinite scroll: loadMore() when 80% scrolled.
class ReviewsScreen extends ConsumerStatefulWidget {
  const ReviewsScreen({super.key, required this.movieId});
  final int movieId;

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final max = _scrollController.position.maxScrollExtent;
    if (_scrollController.offset >= max * 0.8) {
      ref.read(reviewsProvider(widget.movieId).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(reviewsProvider(widget.movieId));

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App bar
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.black,
              title: const Text('Reviews'),
              elevation: 0,
              scrolledUnderElevation: 0,
            ),

            reviewsAsync.when(
              data: (state) {
                if (state.reviews.isEmpty) {
                  return const SliverFillRemaining(
                    child: _EmptyReviews(),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == state.reviews.length) {
                        if (state.isLoadingMore) {
                          return const Padding(
                            padding: EdgeInsets.all(AppConstants.spacing16),
                            child: AppLoadingWidget(),
                          );
                        }
                        if (state.hasReachedMax) {
                          return Padding(
                            padding: const EdgeInsets.all(AppConstants.spacing16),
                            child: Text(
                              '${state.totalResults} review${state.totalResults == 1 ? '' : 's'} total',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xFF606060)),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacing16,
                          vertical: AppConstants.spacing8,
                        ),
                        child: ReviewCard(review: state.reviews[index]),
                      );
                    },
                    childCount: state.reviews.length + 1,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: AppLoadingWidget(),
              ),
              error: (err, _) => SliverFillRemaining(
                child: AppErrorWidget(
                  message: err.toString(),
                  onRetry: () => ref.invalidate(reviewsProvider(widget.movieId)),
                ),
              ),
            ),

            const SliverPadding(
              padding: EdgeInsets.only(bottom: AppConstants.spacing32),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyReviews extends StatelessWidget {
  const _EmptyReviews();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.rate_review_outlined,
              color: Color(0xFF3C3C3C), size: 64),
          const SizedBox(height: AppConstants.spacing16),
          Text(
            'No reviews yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFFA0A0A0),
                ),
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            'Be the first to share your thoughts on TMDB.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
