import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../models/auth/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository(this.apiClient);

  Future<String?> sendOtp(String phone) async {
    try {
      final response = await apiClient.post(
        'auth/sign-in',
        data: {'phone_number': phone.replaceAll(RegExp(r'\D'), '')},
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['otp_code']?.toString();
      }

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to send OTP. Server returned ${response.statusCode}',
        );
      }
      return null;
    } catch (e) {
      print('--- API Error: auth/sign-in ---');
      print(e);
      rethrow;
    }
  }

  Future<String?> verifyOtp(
    String phone,
    String code, {
    String? deviceModel,
    String? platform,
    String? appVersion,
  }) async {
    try {
      final response = await apiClient.post(
        'auth/verify-otp',
        data: {
          'phone_number': phone.replaceAll(RegExp(r'\D'), ''),
          'code': code,
          if (deviceModel != null && deviceModel.trim().isNotEmpty)
            'device_model': deviceModel.trim(),
          if (platform != null && platform.trim().isNotEmpty)
            'platform': platform.trim(),
          if (appVersion != null && appVersion.trim().isNotEmpty)
            'app_version': appVersion.trim(),
        },
      );

      final accessToken = response.data['access_token'];
      final userData = response.data['user'];

      if (accessToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', accessToken);

        if (userData != null) {
          await prefs.setString('user_data', json.encode(userData));
        }

        return accessToken;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      return UserModel.fromJson(json.decode(userJson));
    }
    return null;
  }

  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await apiClient.get('users/me');
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final user = UserModel.fromJson(response.data);
        await saveUser(user);
        return user;
      }
      return null;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        await logout();
        return null;
      }
      rethrow;
    }
  }

  Future<UserModel?> updateProfile({
    String? firstName,
    String? lastName,
    String? middleName,
    String? fio,
    String? username,
    int? countryId,
    int? regionId,
    File? avatar,
  }) async {
    try {
      Map<String, dynamic> data = {
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (middleName != null) 'middle_name': middleName,
        if (fio != null) 'fio': fio,
        if (username != null) 'username': username,
        if (countryId != null) 'country_id': countryId,
        if (regionId != null) 'region_id': regionId,
      };

      if (avatar != null) {
        data['avatar'] = await MultipartFile.fromFile(
          avatar.path,
          filename: avatar.path.split('/').last,
        );
      }

      final response = await apiClient.put(
        'users/me',
        data: FormData.fromMap(data),
      );

      if (response.statusCode == 200) {
        final userData = response.data;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', json.encode(userData));
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(user.toJson()));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  Future<void> updateDeviceToken(String token, String platform) async {
    try {
      await apiClient.post(
        'users/device-token',
        data: {'token': token, 'platform': platform},
      );
    } catch (e) {
      // We don't necessarily want to crash if token update fails,
      // but logging it is good.
      print('Failed to update device token: $e');
    }
  }
}
