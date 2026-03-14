/// Review entity from TMDB.
class Review {
  const Review({
    required this.id,
    required this.author,
    required this.content,
    this.createdAt,
    required this.rating,
    this.avatarPath,
  });

  final String id;
  final String author;
  final String content;
  final DateTime? createdAt;
  final double? rating;
  final String? avatarPath;
}
