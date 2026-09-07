import 'dart:convert';

import '../api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeRepository {
  final ApiClient apiClient;

  HomeRepository(this.apiClient);

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
