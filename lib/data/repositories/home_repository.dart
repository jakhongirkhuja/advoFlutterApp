import '../../core/theme/app_theme.dart';
import 'dart:convert';
import 'dart:ui';

import '../../core/config/app_config.dart';
import '../../core/routes/app_router.dart';
import '../api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/home/lawyer.dart';
import '../models/home/service_category.dart';
import '../models/appointments/appointment.dart';
import '../models/services/organization.dart';
import '../models/services/protokol_provider.dart';

class HomeRepository {
  final ApiClient apiClient;

  HomeRepository(this.apiClient);

  Future<List<Lawyer>> getPopularLawyers() async {
    // TODO(Dio): Replace this dummy list with the home lawyers endpoint.
    // Example:
    // final response = await apiClient.get('home/lawyers');
    // return (response.data['items'] as List)
    //     .map((item) => Lawyer.fromJson(item))
    //     .toList();
    return [
      Lawyer(
        id: 1,
        name: 'Aziz Karimov',
        title: 'lawyer',
        experienceYears: 8,
        rating: 4.9,
        reviewsCount: 128,
        tags: ['civil_law', 'business_law'],
        pricePerMinute: 150000,
        imageUrl: '${AppConfig.mediaBaseUrl}/media/lawyers/1.png',
        isVerified: true,
        isBookmarked: true,
        comment_count: 12,
      ),
      Lawyer(
        id: 2,
        name: 'Dilshod Yusupov',
        title: 'lawyer',
        experienceYears: 6,
        rating: 4.7,
        reviewsCount: 102,
        tags: ['labor_law', 'economic_crimes'],
        pricePerMinute: 120000,
        imageUrl: '${AppConfig.mediaBaseUrl}/media/lawyers/2.png',
        isVerified: true,
        comment_count: 7,
      ),
      Lawyer(
        id: 3,
        name: 'Gulnora Tursunova',
        title: 'lawyer',
        experienceYears: 10,
        rating: 4.8,
        reviewsCount: 150,
        tags: ['family_law', 'inheritance_law'],
        pricePerMinute: 200000,
        imageUrl: '${AppConfig.mediaBaseUrl}/media/lawyers/3.png',
        isVerified: true,
        comment_count: 18,
      ),
      Lawyer(
        id: 4,
        name: 'Javohir Mamatov',
        title: 'lawyer',
        experienceYears: 5,
        rating: 4.6,
        reviewsCount: 89,
        tags: ['tax_law', 'enforcement_law'],
        pricePerMinute: 100000,
        imageUrl: '${AppConfig.mediaBaseUrl}/media/lawyers/4.png',
        isVerified: true,
        comment_count: 25,
      ),
    ];
  }

  Future<List<ServiceCategory>> getServiceCategories() async {
    // TODO(Dio): Replace this dummy list with the home services endpoint.
    // Example:
    // final response = await apiClient.get('home/services');
    // return (response.data['items'] as List)
    //     .map((item) => ServiceCategory.fromJson(item))
    //     .toList();
    return [
      ServiceCategory(
        id: 1,
        title: 'organizations',
        iconPath: 'assets/icons/maslahat.svg',
        mainColor: AppTheme.color_FF1C8AFF,
        secondaryColor: AppTheme.color_FF69AFFF,
        route: AppRouter.organizations,
      ),
      ServiceCategory(
        id: 2,
        title: 'lawyers',
        iconPath: 'assets/icons/oila.svg',
        mainColor: AppTheme.color_FF15985B,
        secondaryColor: AppTheme.color_FF40DB93,
        route: AppRouter.lawyers,
      ),
      ServiceCategory(
        id: 3,
        title: 'templates',
        iconPath: 'assets/icons/fuqoro.svg',
        mainColor: AppTheme.color_FF1E9389,
        secondaryColor: AppTheme.color_FF52CFC4,
        route: AppRouter.templates,
      ),
      ServiceCategory(
        id: 4,
        title: 'euro_protocol',
        iconPath: 'assets/icons/jinoyat.svg',
        mainColor: AppTheme.color_FFFFBA00,
        secondaryColor: AppTheme.color_FFE17100,
        route: AppRouter.protokol,
      ),
    ];
  }

  Future<List<Organization>> getOrganizations() async {
    // TODO(Dio): Replace this dummy list with `apiClient.get('organizations')`.
    return const [
      Organization(
        id: 1,
        name: 'ADVO Legal Group',
        type: 'law_firm',
        lawyerCount: 15,
        rating: 4.7,
        reviewsCount: 42,
        tags: ['labor_law', 'economic_crimes'],
        // imageUrl: '${AppConfig.mediaBaseUrl}/media/organizations/1.png',
        imageUrl: '${AppConfig.dummyImageBaseUrl}/organization-1/320/240',

        address: 'Toshkent shahri, Yunusobod tumani',
        isVerified: true,
        latitude: 41.3382,
        longitude: 69.3347,
        services: [
          'Sudda vakillik',
          'Da’vo arizasini tayyorlash',
          'Sudga tayyorgarlik',
          'Apellyatsiya shikoyati',
        ],
      ),
      Organization(
        id: 2,
        name: 'Jasur Legal Services',
        type: 'legal_advice',
        lawyerCount: 10,
        rating: 4.5,
        reviewsCount: 35,
        tags: ['family_law', 'business_law'],
        // imageUrl: '${AppConfig.mediaBaseUrl}/media/organizations/2.png',
        imageUrl: '${AppConfig.dummyImageBaseUrl}/organization-2/320/240',
        address: 'Toshkent shahri, Shayxontohur tumani',
        isVerified: true,
        latitude: 41.3198,
        longitude: 69.2425,
        services: ['Huquqiy maslahat', 'Sudda vakillik', 'Mehnat nizolari'],
      ),
      Organization(
        id: 3,
        name: 'Legal Experts Uzbekistan',
        type: 'legal_advice',
        lawyerCount: 14,
        rating: 4.9,
        reviewsCount: 40,
        tags: ['civil_law', 'court_cases'],
        // imageUrl: '${AppConfig.mediaBaseUrl}/media/organizations/3.png',
        address: 'Toshkent shahri, Mirzo Ulug‘bek tumani',
        imageUrl: '${AppConfig.dummyImageBaseUrl}/organization-3/320/240',
        isVerified: true,
        latitude: 41.3275,
        longitude: 69.2812,
        services: [
          'Fuqarolik huquqi',
          'Shartnoma tayyorlash',
          'Sud maslahatlari',
        ],
      ),
    ];
  }

  Future<List<ProtokolProvider>> getProtokolProviders() async {
    // TODO(Dio): Replace with the dedicated `protokol/providers` request.
    return const [
      ProtokolProvider(
        id: 101,
        name: 'YevroPratakol',
        type: 'law_firm',
        rating: 4.7,
        reviewsCount: 102,
        imageUrl: '${AppConfig.dummyImageBaseUrl}/organization-101/160/120',
        address: 'Toshkent shahri, Yunusobod tumani',
        price: 150000,
        isVerified: true,
        latitude: 41.3382,
        longitude: 69.3347,
      ),
      ProtokolProvider(
        id: 102,
        name: 'EuroAsia Insurance',
        type: 'legal_advice',
        rating: 4.5,
        reviewsCount: 85,
        imageUrl: '${AppConfig.dummyImageBaseUrl}/organization-102/160/120',
        address: 'Toshkent shahri, Shayxontohur tumani',
        price: 150000,
        isVerified: true,
        latitude: 41.3198,
        longitude: 69.2425,
      ),
      ProtokolProvider(
        id: 103,
        name: 'Legal Experts Uzbekistan',
        type: 'legal_advice',
        rating: 4.9,
        reviewsCount: 140,
        imageUrl: '${AppConfig.dummyImageBaseUrl}/organization-103/160/120',
        address: 'Toshkent shahri, Mirzo Ulug‘bek tumani',
        price: 150000,
        isVerified: true,
        latitude: 41.3275,
        longitude: 69.2812,
      ),
    ];
  }

  Future<List<Appointment>> getAppointments() async {
    // TODO(Dio): Replace this dummy list with `apiClient.get('appointments')`.
    return const [
      Appointment(
        id: 1,
        lawyerName: 'Javohir Mamatov',
        lawyerTitle: 'legal_consultant',
        dateLabel: '09.10.2026',
        timeLabel: '16:00',
        status: 'filter_upcoming',
        consultationType: 'video_consultation',
        topic: 'legal_advice',
        rating: 4.6,
        reviewsCount: 89,
        experienceYears: 5,
        countdownTime: '00 : 00 : 10',
        meetingUrl: 'https://meet.google.com/abc-defg-hij',
      ),
      Appointment(
        id: 2,
        lawyerName: 'Javohir Mamatov',
        lawyerTitle: 'legal_consultant',
        dateLabel: '16.03.2026',
        timeLabel: '14:00',
        status: 'filter_past',
        consultationType: 'video_consultation',
        topic: 'legal_advice',
        rating: 4.6,
        reviewsCount: 89,
        experienceYears: 5,
      ),
      Appointment(
        id: 3,
        lawyerName: 'Dilshod Yusupov',
        lawyerTitle: 'lawyer',
        dateLabel: '22.03.2026',
        timeLabel: '11:30',
        status: 'filter_cancelled',
        consultationType: 'phone_call',
        topic: 'labor_law',
        rating: 4.7,
        reviewsCount: 42,
        experienceYears: 6,
      ),
    ];
  }

  Future<List<Map<String, dynamic>>> getNews({
    int limit = 5,
    int offset = 0,
  }) async {
    try {
      final response = await apiClient.get(
        'news',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      if (response.data != null && response.data['items'] != null) {
        return List<Map<String, dynamic>>.from(response.data['items']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getNewsDetail(int id) async {
    try {
      final response = await apiClient.get('news/$id');
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getEvents({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await apiClient.get(
        'events',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      if (response.data != null && response.data['items'] != null) {
        return List<Map<String, dynamic>>.from(response.data['items']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<int?> attendEvent(int eventId) async {
    try {
      final response = await apiClient.post('events/$eventId/attend');
      if (response.data is Map) {
        final value = response.data['participants_count'];
        if (value is int) {
          return value;
        }
        return int.tryParse('$value');
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<int?> cancelAttendEvent(int eventId) async {
    try {
      final response = await apiClient.delete('events/$eventId/attend');
      if (response.data is Map) {
        final value = response.data['participants_count'];
        if (value is int) {
          return value;
        }
        return int.tryParse('$value');
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getQuickServices() async {
    try {
      final response = await apiClient.get('home/services');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getNearbyUsers({
    required String lat,
    required String long,
    int radiusKm = 10,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await apiClient.get(
        'users/nearby',
        queryParameters: {
          'latitude': lat,
          'longitude': long,
          'radius_km': radiusKm,
          'limit': limit,
          'offset': offset,
        },
      );
      if (response.data != null) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getConsularApplications({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await apiClient.get(
        'consular-applications',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      if (response.data != null && response.data['items'] != null) {
        return List<Map<String, dynamic>>.from(response.data['items']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<String?> getLocationName(String lat, String long) async {
    try {
      final response = await apiClient.get(
        'users/location/address',
        queryParameters: {'latitude': lat, 'longitude': long},
      );
      return response.data['address'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<bool> setShareLocation({required bool share}) async {
    try {
      final response = await apiClient.put(
        'users/location/share',
        data: {'share': share},
      );
      final data = response.data;
      if (data is Map) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'user_data',
          json.encode(Map<String, dynamic>.from(data)),
        );
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> sendCurrentLocation({
    required double latitude,
    required double longitude,
  }) async {
    await apiClient.post(
      'users/location',
      data: {'latitude': latitude, 'longitude': longitude},
    );
  }

  Future<List<Map<String, dynamic>>> getCharityCampaigns({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await apiClient.get(
        'charity-campaigns',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      if (response.data != null && response.data['items'] != null) {
        return List<Map<String, dynamic>>.from(response.data['items']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> donateToCharityCampaign({
    required int campaignId,
    required num amount,
  }) async {
    try {
      final response = await apiClient.post(
        'charity-campaigns/$campaignId/donate',
        data: {'amount': amount},
      );
      final data = response.data;
      if (data is Map && data['campaign'] is Map) {
        return Map<String, dynamic>.from(data['campaign'] as Map);
      }
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getLiveStreams({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await apiClient.get(
        'live-streams',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      if (response.data != null && response.data['items'] != null) {
        return List<Map<String, dynamic>>.from(response.data['items']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSuccessStories({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await apiClient.get(
        'success-stories',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      if (response.data != null && response.data['items'] != null) {
        return List<Map<String, dynamic>>.from(response.data['items']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSponsors({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await apiClient.get(
        'sponsors',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      if (response.data != null && response.data['items'] != null) {
        return List<Map<String, dynamic>>.from(response.data['items']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
