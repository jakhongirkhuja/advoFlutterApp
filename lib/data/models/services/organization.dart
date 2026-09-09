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
  });
}
