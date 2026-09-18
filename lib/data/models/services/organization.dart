class Organization {
  final int id;
  final String name;
  final String type;
  final int lawyerCount;
  final double rating;
  final int reviewsCount;
  final List<String> tags;
  final String imageUrl;
  final String address;
  final bool isVerified;
  final double? latitude;
  final double? longitude;
  final List<String> services;
  final bool isSaved;

  const Organization({
    required this.id,
    required this.name,
    required this.type,
    required this.lawyerCount,
    required this.rating,
    required this.reviewsCount,
    required this.tags,
    required this.imageUrl,
    required this.address,
    this.isVerified = false,
    this.latitude,
    this.longitude,
    this.services = const [],
    this.isSaved = false,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    final serviceValues = json['services'] is List
        ? List<dynamic>.from(json['services'] as List)
        : const <dynamic>[];
    final services = serviceValues
        .map(
          (item) => item is Map ? item['name']?.toString() : item?.toString(),
        )
        .whereType<String>()
        .toList();
    return Organization(
      id: _asInt(json['id']),
      name: (json['name'] ?? '').toString(),
      type: (json['type_name'] ?? json['type'] ?? '').toString(),
      lawyerCount: _asInt(json['lawyers_count'] ?? json['lawyer_count']),
      rating: _asDouble(json['rating_avg'] ?? json['rating']),
      reviewsCount: _asInt(json['rating_count'] ?? json['reviews_count']),
      tags: services,
      imageUrl: (json['poster_url'] ?? json['image_url'] ?? '').toString(),
      address: (json['address'] ?? json['city_name'] ?? '').toString(),
      isVerified: json['is_verified'] == true,
      latitude: _asNullableDouble(json['latitude']),
      longitude: _asNullableDouble(json['longitude']),
      services: services,
      isSaved: json['is_saved'] == true,
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

  static double? _asNullableDouble(dynamic value) {
    if (value == null) return null;
    return _asDouble(value);
  }
}
