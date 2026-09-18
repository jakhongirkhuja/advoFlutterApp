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
        'clients/login',
        data: {'phone': _normalizePhone(phone)},
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['otp']?.toString();
      }

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to send OTP. Server returned ${response.statusCode}',
        );
      }
      return null;
    } catch (e) {
      print('--- API Error: clients/login ---');
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
        'clients/login/confirm',
        data: {'phone': _normalizePhone(phone), 'otp': code},
      );

      final accessToken = response.data['token'];
      final userData = response.data['client'];

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
      final response = await apiClient.get('clients/me');
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
    String? birthday,
    String? phone,
    String? email,
    double? latitude,
    double? longitude,
    File? avatar,
  }) async {
    try {
      Map<String, dynamic> data = {
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (birthday != null) 'birthday': birthday,
        if (phone != null) 'phone': _normalizePhone(phone),
        if (email != null) 'email': email,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };

      if (avatar != null) {
        data['avatar'] = await MultipartFile.fromFile(
          avatar.path,
          filename: avatar.path.split('/').last,
        );
      }

      final response = await apiClient.put(
        'clients/me',
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
    // The supplied Advokat API does not expose a device-token endpoint yet.
  }

  Future<String?> sendRegistrationOtp({
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    final response = await apiClient.post(
      'clients/register',
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'phone': _normalizePhone(phone),
      },
    );
    return response.data is Map ? response.data['otp']?.toString() : null;
  }

  Future<String?> confirmRegistration({
    required String phone,
    required String otp,
  }) async {
    final response = await apiClient.post(
      'clients/register/confirm',
      data: {'phone': _normalizePhone(phone), 'otp': otp},
    );
    return _saveAuthResponse(response.data);
  }

  Future<void> updateLanguage(String languageCode) async {
    await apiClient.put('clients/me/lang', data: {'lang': languageCode});
  }

  Future<String?> _saveAuthResponse(dynamic data) async {
    if (data is! Map) return null;
    final token = data['token']?.toString();
    if (token == null || token.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    final client = data['client'];
    if (client is Map) {
      await prefs.setString(
        'user_data',
        json.encode(Map<String, dynamic>.from(client)),
      );
    }
    return token;
  }

  String _normalizePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits.startsWith('998') ? '+$digits' : '+998$digits';
  }
}
