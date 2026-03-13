import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.author,
    required super.content,
    super.createdAt,
    super.rating,
    super.avatarPath,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final authorDetails = json['author_details'] as Map<String, dynamic>?;
    final ratingRaw = authorDetails?['rating'];
    final avatarRaw = authorDetails?['avatar_path'] as String?;

    // TMDB sometimes prepends the Gravatar URL with a leading slash
    String? avatar;
    if (avatarRaw != null && avatarRaw.isNotEmpty) {
      avatar = avatarRaw.startsWith('/https')
          ? avatarRaw.substring(1)
          : 'https://image.tmdb.org/t/p/w92$avatarRaw';
    }

    return ReviewModel(
      id: json['id'] as String,
      author: json['author'] as String? ?? 'Anonymous',
      content: json['content'] as String? ?? '',
      createdAt: _parseDate(json['created_at'] as String?),
      rating: ratingRaw != null ? (ratingRaw as num).toDouble() : null,
      avatarPath: avatar,
    );
  }

  static DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}

/// Paginated response wrapper for reviews.
class ReviewsResponse {
  const ReviewsResponse({
    required this.reviews,
    required this.page,
    required this.totalPages,
    required this.totalResults,
  });

  final List<ReviewModel> reviews;
  final int page;
  final int totalPages;
  final int totalResults;

  factory ReviewsResponse.fromJson(Map<String, dynamic> json) {
    final results = (json['results'] as List<dynamic>?)
            ?.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return ReviewsResponse(
      reviews: results,
      page: json['page'] as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 1,
      totalResults: json['total_results'] as int? ?? 0,
    );
  }
}
