import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../features/watchlist/domain/entities/watchlist_movie.dart';
import '../../../../features/watchlist/presentation/providers/watchlist_provider.dart';
import '../../../../shared/widgets/cached_movie_image.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../domain/entities/movie_detail.dart';
import '../providers/movie_detail_provider.dart';

/// Movie Detail Screen — full movie info with watchlist action.
///
/// Architecture notes:
/// - Entered via GoRouter stack push: /movie/:id
/// - Back: GoRouter pops back to previous route (Home or Watchlist)
/// - PopScope handles Android predictive back (Android 14+)
/// - Hero animation: poster image from list → detail
class MovieDetailScreen extends ConsumerWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final int movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(movieDetailProvider(movieId));

    return PopScope(
      // Predictive back support
      canPop: true,
      child: detailAsync.when(
        data: (movie) => Scaffold(
          backgroundColor: Colors.black,
          body: _MovieDetailBody(movie: movie),
        ),
        loading: () => const _DetailLoadingScreen(),
        error: (err, _) => Scaffold(
          backgroundColor: Colors.black,
          // Error state must always offer a way out.
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
              tooltip: 'Back',
            ),
          ),
          body: AppErrorWidget(
            message: err.toString(),
            onRetry: () => ref.invalidate(movieDetailProvider(movieId)),
          ),
        ),
      ),
    );
  }
}

// ─── Main body ──────────────────────────────────────────────────────────────

class _MovieDetailBody extends ConsumerWidget {
  const _MovieDetailBody({required this.movie});
  final MovieDetail movie;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // sizeOf instead of size: only rebuilds when screen SIZE changes, not when
    // any other MediaQueryData field changes.
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isInWatchlist = ref.watch(isInWatchlistProvider(movie.id));

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Collapsing app bar with backdrop image
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          backgroundColor: Colors.black,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
            tooltip: 'Back',
            // 48dp touch target enforced by iconButtonTheme in AppTheme
          ),
          actions: [
            // Watchlist toggle — 48dp button
            IconButton(
              onPressed: () => _toggleWatchlist(context, ref, isInWatchlist),
              icon: Icon(
                isInWatchlist ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                color: isInWatchlist ? const Color(0xFFE50914) : null,
              ),
              tooltip: isInWatchlist ? 'Remove from watchlist' : 'Add to watchlist',
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                MovieBackdropImage(
                  backdropPath: movie.backdropPath,
                  width: screenWidth,
                  height: 260,
                ),
                // Gradient overlay — OLED-safe fade to black
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0xCC000000),
                        Colors.black,
                      ],
                      stops: [0.4, 0.75, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Content
        SliverPadding(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Title row with poster
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Hero poster — matches hero tag from list card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                    child: Hero(
                      tag: 'poster_${movie.id}',
                      child: MoviePosterImage(
                        posterPath: movie.posterPath,
                        width: 100,
                        height: 150,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        if (movie.tagline.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            '"${movie.tagline}"',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: const Color(0xFFA0A0A0),
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: AppConstants.spacing8),
                        // Rating
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Color(0xFFFFD700), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              movie.voteAverage.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFFFFD700),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              ' / 10',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        // Runtime + Year
                        const SizedBox(height: 4),
                        Text(
                          '${movie.releaseYear}  •  ${movie.runtimeFormatted}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.spacing16),

              // Genre chips
              if (movie.genres.isNotEmpty)
                Wrap(
                  spacing: AppConstants.spacing8,
                  runSpacing: AppConstants.spacing8,
                  children: movie.genres
                      .map((g) => Chip(label: Text(g.name)))
                      .toList(),
                ),

              const SizedBox(height: AppConstants.spacing16),

              // Overview
              Text(
                'Overview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                movie.overview.isNotEmpty ? movie.overview : 'No overview available.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color: const Color(0xFFC0C0C0),
                    ),
              ),

              const SizedBox(height: AppConstants.spacing24),

              // Reviews button — 48dp minimum height
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/movie/${movie.id}/reviews'),
                  icon: const Icon(Icons.rate_review_outlined, size: 18),
                  label: const Text('Read Reviews'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE0E0E0),
                    side: const BorderSide(color: Color(0xFF3C3C3C)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.bottomNavHeight),
            ]),
          ),
        ),
      ],
    );
  }

  void _toggleWatchlist(BuildContext context, WidgetRef ref, bool isInWatchlist) {
    final movie = this.movie;
    final watchlistNotifier = ref.read(watchlistProvider.notifier);

    if (isInWatchlist) {
      watchlistNotifier.remove(movie.id);
      // Extension from core/utils/extensions.dart — avoids boilerplate
      context.showSnackBar('Removed "${movie.title}" from watchlist');
    } else {
      watchlistNotifier.add(
        WatchlistMovie(
          id: movie.id,
          title: movie.title,
          posterPath: movie.posterPath,
          voteAverage: movie.voteAverage,
          releaseDate: movie.releaseDate,
          addedAt: DateTime.now(),
        ),
      );
      context.showSnackBar('Added "${movie.title}" to watchlist');
    }
  }
}

class _DetailLoadingScreen extends StatelessWidget {
  const _DetailLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: Colors.black,
            // Back button shown during loading so user isn't stranded.
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
              tooltip: 'Back',
            ),
            flexibleSpace: const FlexibleSpaceBar(
              background: ColoredBox(color: Color(0xFF0D0D0D)),
            ),
          ),
          const SliverFillRemaining(
            child: AppLoadingWidget(),
          ),
        ],
      ),
    );
  }
}
