import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/review.dart';

/// Review card — displays author, rating (if available), and review text.
class ReviewCard extends StatefulWidget {
  const ReviewCard({super.key, required this.review});
  final Review review;

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  bool _expanded = false;

  static const int _previewLines = 4;

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final dateFormatted = review.createdAt != null
        ? '${review.createdAt!.day}/${review.createdAt!.month}/${review.createdAt!.year}'
        : '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author row
            Row(
              children: [
                // Avatar
                _ReviewAvatar(avatarPath: review.avatarPath, author: review.author),
                const SizedBox(width: AppConstants.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.author,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: const Color(0xFFE0E0E0),
                            ),
                      ),
                      Text(
                        dateFormatted,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                // Rating badge (if provided)
                if (review.rating != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFD700), size: 14),
                        const SizedBox(width: 2),
                        Text(
                          review.rating!.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: const Color(0xFFFFD700),
                              ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: AppConstants.spacing12),

            // Review content — expandable
            AnimatedCrossFade(
              duration: AppConstants.standardDuration,
              crossFadeState:
                  _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: Text(
                review.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFC0C0C0),
                      height: 1.6,
                    ),
                maxLines: _previewLines,
                overflow: TextOverflow.ellipsis,
              ),
              secondChild: Text(
                review.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFC0C0C0),
                      height: 1.6,
                    ),
              ),
            ),

            // Expand/Collapse — 48dp touch target
            if (review.content.length > 200)
              SizedBox(
                height: 48,
                child: TextButton(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  child: Text(
                    _expanded ? 'Show less' : 'Read more',
                    style: const TextStyle(color: Color(0xFFE50914)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReviewAvatar extends StatelessWidget {
  const _ReviewAvatar({required this.avatarPath, required this.author});
  final String? avatarPath;
  final String author;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: const Color(0xFF2C2C2C),
      foregroundImage:
          avatarPath != null ? NetworkImage(avatarPath!) : null,
      child: Text(
        author.isNotEmpty ? author[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Color(0xFFE0E0E0),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
