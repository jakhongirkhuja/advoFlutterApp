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
  });
}
