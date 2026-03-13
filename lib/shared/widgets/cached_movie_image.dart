import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';

/// OLED-safe cached poster image with memory limits.
/// Mobile performance rule: Always constrain memCacheWidth/Height (mobile-performance.md §3).
class MoviePosterImage extends StatelessWidget {
  const MoviePosterImage({
    super.key,
    required this.posterPath,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.heroTag,
  });

  final String? posterPath;
  final double width;
  final double height;
  final BoxFit fit;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final Widget image = posterPath != null
        ? CachedNetworkImage(
            imageUrl: '${ApiConstants.posterW342}$posterPath',
            width: width,
            height: height,
            fit: fit,
            // Limit decoded image in memory to 2× display size (mobile-performance.md §3)
            memCacheWidth: (width * MediaQuery.of(context).devicePixelRatio * 1.5).toInt(),
            memCacheHeight: (height * MediaQuery.of(context).devicePixelRatio * 1.5).toInt(),
            placeholder: (_, __) => const _PosterPlaceholder(),
            errorWidget: (_, __, ___) => const _PosterError(),
          )
        : const _PosterPlaceholder();

    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: image,
      );
    }
    return image;
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: const Center(
        child: Icon(Icons.movie_outlined, color: Color(0xFF606060), size: 32),
      ),
    );
  }
}

class _PosterError extends StatelessWidget {
  const _PosterError();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: const Center(
        child: Icon(Icons.broken_image_outlined, color: Color(0xFF606060), size: 32),
      ),
    );
  }
}

/// Backdrop image used in movie detail hero area.
class MovieBackdropImage extends StatelessWidget {
  const MovieBackdropImage({
    super.key,
    required this.backdropPath,
    required this.width,
    required this.height,
  });

  final String? backdropPath;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (backdropPath == null) {
      return Container(
        width: width,
        height: height,
        color: const Color(0xFF0D0D0D),
      );
    }
    return CachedNetworkImage(
      imageUrl: '${ApiConstants.backdropW780}$backdropPath',
      width: width,
      height: height,
      fit: BoxFit.cover,
      memCacheWidth: (width * MediaQuery.of(context).devicePixelRatio).toInt(),
      placeholder: (_, __) => Container(
        width: width,
        height: height,
        color: const Color(0xFF0D0D0D),
      ),
      errorWidget: (_, __, ___) => Container(
        width: width,
        height: height,
        color: const Color(0xFF0D0D0D),
      ),
    );
  }
}
