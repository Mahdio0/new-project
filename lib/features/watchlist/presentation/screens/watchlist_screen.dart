import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/cached_movie_image.dart';
import '../../domain/entities/watchlist_movie.dart';
import '../providers/watchlist_provider.dart';

/// Watchlist Screen — shows offline-first saved movies.
///
/// Performance: SliverList delegate — virtual, no eager rendering.
/// Tab state: preserved by IndexedStack (user returns to same scroll).
class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movies = ref.watch(watchlistProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: CustomScrollView(
          // ClampingScrollPhysics — Android convention, matches HomeScreen.
          physics: const ClampingScrollPhysics(),
          slivers: [
            // App bar
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spacing16,
                AppConstants.spacing16,
                AppConstants.spacing16,
                AppConstants.spacing8,
              ),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'My Watchlist',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),

            if (movies.isEmpty)
              // Empty state — guides user to add movies
              const SliverFillRemaining(
                child: _EmptyWatchlist(),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.spacing16,
                  AppConstants.spacing8,
                  AppConstants.spacing16,
                  AppConstants.spacing8,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    '${movies.length} movie${movies.length == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _WatchlistItem(movie: movies[index]),
                  childCount: movies.length,
                ),
              ),
            ],

            const SliverPadding(
              padding: EdgeInsets.only(bottom: AppConstants.bottomNavHeight),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Watchlist list item ─────────────────────────────────────────────────────

class _WatchlistItem extends ConsumerWidget {
  const _WatchlistItem({required this.movie});
  final WatchlistMovie movie;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      // Swipe-to-remove (Android convention).
      // No confirmDismiss dialog — the undo SnackBar is the recovery path
      // Avoid double confirmation for reversible actions.
      key: ValueKey(movie.id),
      direction: DismissDirection.endToStart,
      background: const _DismissBackground(),
      onDismissed: (_) {
        ref.read(watchlistProvider.notifier).remove(movie.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed "${movie.title}"'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                // Re-add removed movie
                ref.read(watchlistProvider.notifier).add(movie);
              },
            ),
          ),
        );
      },
      child: InkWell(
        onTap: () => context.go('/movie/${movie.id}'),
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        child: Container(
          height: AppConstants.movieListItemHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacing16,
            vertical: AppConstants.spacing8,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: MoviePosterImage(
                  posterPath: movie.posterPath,
                  width: 70,
                  height: 104,
                  heroTag: 'watchlist_poster_${movie.id}',
                ),
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: const Color(0xFFE0E0E0),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFD700), size: 14),
                        const SizedBox(width: 2),
                        Text(
                          movie.voteAverage.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFFFFD700),
                              ),
                        ),
                        const SizedBox(width: AppConstants.spacing8),
                        Text(
                          movie.releaseYear,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Delete button — 48dp touch target, immediate remove + undo
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  onPressed: () {
                    ref.read(watchlistProvider.notifier).remove(movie.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Removed "${movie.title}"'),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'UNDO',
                          onPressed: () {
                            ref.read(watchlistProvider.notifier).add(movie);
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.bookmark_remove_rounded,
                      color: Color(0xFFCF6679), size: 22),
                  tooltip: 'Remove from watchlist',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  const _DismissBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppConstants.spacing16),
      color: const Color(0xFF8C0A0F),
      child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
    );
  }
}

class _EmptyWatchlist extends StatelessWidget {
  const _EmptyWatchlist();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.bookmarks_outlined,
              color: Color(0xFF3C3C3C),
              size: 80,
            ),
            const SizedBox(height: AppConstants.spacing16),
            Text(
              'Your watchlist is empty',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFFA0A0A0),
                  ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              'Tap the bookmark icon on any movie to save it for later. Go explore!',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
