import '../../../core/config/app_config.dart';

class UserModel {
  final int id;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String middleName;
  final String fio;
  final String username;
  final int countryId;
  final int regionId;
  final String? avatarPath;
  final bool shareLocation;
  final int points;
  final int trustRating;
  final bool verify;

  UserModel({
    required this.id,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.fio,
    required this.username,
    required this.countryId,
    required this.regionId,
    this.avatarPath,
    required this.shareLocation,
    required this.points,
    required this.trustRating,
    required this.verify,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      phoneNumber: json['phone_number'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      middleName: json['middle_name'] ?? '',
      fio: json['fio'] ?? '',
      username: json['username'] ?? '',
      countryId: json['country_id'] ?? 0,
      regionId: json['region_id'] ?? 0,
      avatarPath: json['avatar_path'],
      shareLocation: json['share_location'] ?? false,
      points: json['points'] ?? 0,
      trustRating: json['trust_rating'] ?? 0,
      verify: json['verify'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'first_name': firstName,
      'last_name': lastName,
      'middle_name': middleName,
      'fio': fio,
      'username': username,
      'country_id': countryId,
      'region_id': regionId,
      'avatar_path': avatarPath,
      'share_location': shareLocation,
      'points': points,
      'trust_rating': trustRating,
      'verify': verify,
    };
  }

  String get fullAvatarUrl {
    if (avatarPath == null || avatarPath!.isEmpty) {
      return '';
    }
    if (avatarPath!.startsWith('http')) {
      return avatarPath!;
    }
    return '${AppConfig.mediaBaseUrl}$avatarPath';
  }
}
