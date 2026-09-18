import '../../core/theme/app_theme.dart';
import 'dart:ui';
import 'package:dio/dio.dart';

import '../../core/routes/app_router.dart';
import '../api/api_client.dart';
import '../models/home/lawyer.dart';
import '../models/home/service_category.dart';
import '../models/appointments/appointment.dart';
import '../models/services/organization.dart';
import '../models/services/protokol_provider.dart';

class HomeRepository {
  final ApiClient apiClient;

  HomeRepository(this.apiClient);

  Future<List<Lawyer>> getPopularLawyers() async {
    try {
      final response = await apiClient.get(
        'lawyers',
        queryParameters: {'page': 1, 'limit': 20},
      );
      final items = response.data is Map ? response.data['items'] : null;
      if (items is List) {
        return items
            .whereType<Map>()
            .map((item) => Lawyer.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (_) {}
    return const [];
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
    try {
      final response = await apiClient.get(
        'organizations',
        queryParameters: {'page': 1, 'limit': 20},
      );
      final items = response.data is Map ? response.data['items'] : null;
      if (items is List) {
        return items
            .whereType<Map>()
            .map(
              (item) => Organization.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  Future<List<ProtokolProvider>> getProtokolProviders() async {
    try {
      final response = await apiClient.get('euro-protocols');
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map>()
            .map(
              (item) =>
                  ProtokolProvider.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  Future<List<Appointment>> getAppointments() async {
    try {
      final response = await apiClient.get(
        'appointments',
        queryParameters: {'status': 'all'},
      );
      final items = response.data is Map ? response.data['items'] : null;
      if (items is List) {
        return items
            .whereType<Map>()
            .map(
              (item) => Appointment.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  Future<bool> setLawyerSaved(int lawyerId, {required bool saved}) async {
    final response = saved
        ? await apiClient.post('lawyers/$lawyerId/save')
        : await apiClient.delete('lawyers/$lawyerId/save');
    if (response.data is Map && response.data['saved'] is bool) {
      return response.data['saved'] as bool;
    }
    return saved;
  }

  Future<bool> setOrganizationSaved(
    int organizationId, {
    required bool saved,
  }) async {
    final response = saved
        ? await apiClient.post('organizations/$organizationId/save')
        : await apiClient.delete('organizations/$organizationId/save');
    if (response.data is Map && response.data['saved'] is bool) {
      return response.data['saved'] as bool;
    }
    return saved;
  }

  Future<bool> setEuroProtocolSaved(
    int protocolId, {
    required bool saved,
  }) async {
    if (saved) {
      await apiClient.post('euro-protocols/$protocolId/save');
    } else {
      await apiClient.delete('euro-protocols/$protocolId/save');
    }
    return saved;
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
    return null;
  }

  Future<bool> setShareLocation({required bool share}) async {
    // Location visibility is not part of the supplied API contract.
    return true;
  }

  Future<void> sendCurrentLocation({
    required double latitude,
    required double longitude,
  }) async {
    await apiClient.put(
      'clients/me',
      data: FormData.fromMap({'latitude': latitude, 'longitude': longitude}),
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
