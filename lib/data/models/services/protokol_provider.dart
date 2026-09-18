class ProtokolProvider {
  final int id;
  final String name;
  final String type;
  final double rating;
  final int reviewsCount;
  final String address;
  final String imageUrl;
  final int price;
  final bool isVerified;
  final double latitude;
  final double longitude;
  final bool isSaved;

  const ProtokolProvider({
    required this.id,
    required this.name,
    required this.type,
    required this.rating,
    required this.reviewsCount,
    required this.address,
    required this.imageUrl,
    required this.price,
    required this.latitude,
    required this.longitude,
    this.isVerified = false,
    this.isSaved = false,
  });

  factory ProtokolProvider.fromJson(Map<String, dynamic> json) {
    return ProtokolProvider(
      id: _asInt(json['id']),
      name: (json['title'] ?? json['name'] ?? '').toString(),
      type: (json['type_name'] ?? json['type'] ?? '').toString(),
      rating: _asDouble(json['rating_avg'] ?? json['rating']),
      reviewsCount: _asInt(json['rating_count'] ?? json['reviews_count']),
      address: (json['address'] ?? json['city_name'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
      price: _asInt(json['price_from'] ?? json['price']),
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      isVerified: json['is_verified'] == true,
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
}
