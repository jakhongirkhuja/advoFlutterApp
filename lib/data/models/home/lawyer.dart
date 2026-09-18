class Lawyer {
  final int id;
  final String name;
  final String title;
  final int experienceYears;
  final double rating;
  final int reviewsCount;
  final List<String> tags;
  final List<int> serviceTypeIds;
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
    this.serviceTypeIds = const [],
    required this.pricePerMinute,
    required this.imageUrl,
    this.isVerified = false,
    this.isBookmarked = false,
    required this.comment_count,
  });

  factory Lawyer.fromJson(Map<String, dynamic> json) {
    final services = json['services'] is List
        ? List<dynamic>.from(json['services'] as List)
        : const <dynamic>[];
    final serviceNames = services
        .map((item) => item is Map ? item['name']?.toString() : null)
        .whereType<String>()
        .toList();
    final serviceTypeIds = services
        .whereType<Map>()
        .map((item) => _asInt(item['service_type_id'] ?? item['id']))
        .where((id) => id > 0)
        .toList();
    final firstPrice = services
        .whereType<Map>()
        .map((item) => item['price'])
        .whereType<num>()
        .firstOrNull;
    return Lawyer(
      id: _asInt(json['id']),
      name: (json['full_name'] ?? json['name'] ?? '').toString(),
      title: (json['title'] ?? json['status'] ?? 'lawyer').toString(),
      experienceYears: _asInt(json['experience_years']),
      rating: _asDouble(json['rating_avg'] ?? json['rating']),
      reviewsCount: _asInt(json['rating_count'] ?? json['reviews_count']),
      tags: serviceNames.isNotEmpty
          ? serviceNames
          : List<String>.from(json['tags'] as List? ?? const []),
      serviceTypeIds: serviceTypeIds,
      pricePerMinute: _asInt(json['price_per_minute'] ?? firstPrice),
      imageUrl: (json['avatar_url'] ?? json['image_url'] ?? '').toString(),
      isVerified: json['is_verified'] ?? false,
      isBookmarked: json['is_saved'] ?? json['is_bookmarked'] ?? false,
      comment_count: _asInt(
        json['consultations_count'] ?? json['comment_count'],
      ),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }
}
