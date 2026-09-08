class Lawyer {
  final int id;
  final String name;
  final String title;
  final int experienceYears;
  final double rating;
  final int reviewsCount;
  final List<String> tags;
  final int pricePerMinute;
  final String imageUrl;
  final bool isVerified;
  final bool isBookmarked;
  final int comment_count;

  Lawyer({
    required this.id,
    required this.name,
    required this.title,
    required this.experienceYears,
    required this.rating,
    required this.reviewsCount,
    required this.tags,
    required this.pricePerMinute,
    required this.imageUrl,
    this.isVerified = false,
    this.isBookmarked = false,
    required this.comment_count
  });

  factory Lawyer.fromJson(Map<String, dynamic> json) {
    return Lawyer(
      id: json['id'] as int,
      name: json['name'] as String,
      title: json['title'] as String,
      experienceYears: json['experience_years'] as int,
      rating: (json['rating'] as num).toDouble(),
      reviewsCount: json['reviews_count'] as int,
      tags: List<String>.from(json['tags'] as List),
      pricePerMinute: json['price_per_minute'] as int,
      imageUrl: json['image_url'] as String,
      isVerified: json['is_verified'] ?? false,
      isBookmarked: json['is_bookmarked'] ?? false,
      comment_count: json['comment_count'] ?? 0,
    );
  }
}
