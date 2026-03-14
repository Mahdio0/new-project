import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../features/home/domain/entities/movie.dart';
import '../../../../shared/widgets/cached_movie_image.dart';

/// Vertical poster card used in horizontal carousels.
///
/// Touch target: card is full 140×220dp — satisfies 48dp minimum.
/// const constructor: prevents unnecessary rebuilds.
class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.movie,
  });

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Full card is the touch area — well above 48dp minimum
      onTap: () => context.go('/movie/${movie.id}'),
      child: SizedBox(
        width: AppConstants.movieCardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster with Hero animation for detail transition
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.cardRadius),
              child: MoviePosterImage(
                posterPath: movie.posterPath,
                width: AppConstants.movieCardWidth,
                height: AppConstants.movieCardHeight,
                heroTag: 'poster_${movie.id}',
              ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            // Title — max 2 lines
            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 2),
            // Rating row
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 12),
                const SizedBox(width: 2),
                Text(
                  movie.voteAverage.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFFFFD700),
                      ),
                ),
                const Spacer(),
                Text(
                  movie.releaseYear,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal list item used in the "now playing" vertical feed.
/// Height: 120dp — satisfies 48dp touch minimum.
class MovieListItem extends StatelessWidget {
  const MovieListItem({
    super.key,
    required this.movie,
    required this.rank,
  });

  final Movie movie;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Ripple effect — Android Material convention
      borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      onTap: () => context.go('/movie/${movie.id}'),
      child: Container(
        height: AppConstants.movieListItemHeight,
        padding: const EdgeInsets.all(AppConstants.spacing8),
        child: Row(
          children: [
            // Rank badge
            SizedBox(
              width: 28,
              child: Text(
                '$rank',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF606060),
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: AppConstants.spacing8),
            // Poster thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: MoviePosterImage(
                posterPath: movie.posterPath,
                width: 70,
                height: 104,
                heroTag: 'poster_list_${movie.id}',
              ),
            ),
            const SizedBox(width: AppConstants.spacing12),
            // Title + meta
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
                      const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 14),
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
            // 48dp chevron touch area
            const SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: Icon(Icons.chevron_right_rounded, color: Color(0xFF606060), size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
