import 'package:flutter/material.dart';

/// Generic loading widget with shimmer-style skeleton.
/// Used while async data is in the loading state.
class AppLoadingWidget extends StatelessWidget {
  const AppLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFFE50914),
        strokeWidth: 2.5,
      ),
    );
  }
}

/// Skeleton placeholder for a movie card during loading.
class MovieCardSkeleton extends StatelessWidget {
  const MovieCardSkeleton({super.key, this.width = 140, this.height = 220});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

/// Skeleton list for the trending feed during first load.
class TrendingSkeletonList extends StatelessWidget {
  const TrendingSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 6,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(right: 12),
        child: MovieCardSkeleton(),
      ),
    );
  }
}
