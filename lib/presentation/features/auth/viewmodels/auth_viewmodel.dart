import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../data/repositories/home_repository.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/models/auth/user_model.dart';
import '../../../../core/services/location_sync_service.dart';
import '../../../../core/services/notification_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository authRepository;
  late final HomeRepository _homeRepository;

  AuthViewModel(this.authRepository) {
    _homeRepository = HomeRepository(authRepository.apiClient);
    _checkSavedUser();
  }

  AuthStatus _status = AuthStatus.initial;
  AuthStatus get status => _status;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  String? _phoneNumber; // Store phone for OTP verification

  String? _selectedLanguage;
  String? get selectedLanguage => _selectedLanguage;

  final List<Map<String, String>> languages = [
    {'name': 'O\'zbekcha', 'code': 'uz', 'flag': '🇺🇿'},
    {'name': 'English', 'code': 'en', 'flag': '🇺🇸'},
    {'name': 'Русский', 'code': 'ru', 'flag': '🇷🇺'},
  ];

  void _checkSavedUser() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final token = await authRepository.getSavedToken();
      if (token == null || token.isEmpty) {
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
      } else {
        _currentUser = await authRepository.getCurrentUser();
        if (_currentUser != null) {
          _status = AuthStatus.authenticated;
          await _ensureLocationShareEnabled();
        } else {
          _status = AuthStatus.unauthenticated;
        }
      }
    } catch (e) {
      debugPrint('Auth bootstrap failed: $e');
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<void> syncDeviceToken() async {
    try {
      final token = await NotificationService.getToken();
      if (token != null) {
        String platform = Platform.isAndroid
            ? 'android'
            : (Platform.isIOS ? 'ios' : 'web');
        await authRepository.updateDeviceToken(token, platform);
      }
    } catch (e) {
      debugPrint('Error updating FCM token: $e');
    }
  }

  void selectLanguage(String code) {
    _selectedLanguage = code;
    notifyListeners();
  }

  Future<String?> sendOtp(String phoneNumber) async {
    _status = AuthStatus.loading;
    _phoneNumber = phoneNumber;
    notifyListeners();

    try {
      final otp = await authRepository.sendOtp(phoneNumber);
      _status = AuthStatus.unauthenticated;
      return otp;
    } catch (e) {
      _status = AuthStatus.error;
      return null;
    } finally {
      notifyListeners();
    }
  }

  Future<void> verifyOtp(String otp) async {
    if (_phoneNumber == null) return;

    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final metadata = await _buildDeviceMetadata();
      final token = await authRepository.verifyOtp(
        _phoneNumber!,
        otp,
        deviceModel: metadata.deviceModel,
        platform: metadata.platform,
        appVersion: metadata.appVersion,
      );
      if (token != null) {
        _currentUser = await authRepository.getSavedUser();
        _status = AuthStatus.authenticated;
        await _ensureLocationShareEnabled();
      } else {
        _status = AuthStatus.error;
      }
    } catch (e) {
      _status = AuthStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? middleName,
    String? fio,
    String? username,
    int? countryId,
    int? regionId,
    File? avatar,
  }) async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final updatedUser = await authRepository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        middleName: middleName,
        fio: fio,
        username: username,
        countryId: countryId,
        regionId: regionId,
        avatar: avatar,
      );
      if (updatedUser != null) {
        _currentUser = updatedUser;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      _status = AuthStatus.authenticated;
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    await LocationSyncService.instance.updateTrackingState(
      isAuthenticated: false,
    );
    notifyListeners();
  }

  Future<void> _ensureLocationShareEnabled() async {
    final user = _currentUser;
    if (user == null) {
      return;
    }

    if (user.shareLocation) {
      debugPrint('Location share already enabled for user ${user.id}');
      return;
    }

    debugPrint(
      'Enabling location share for user ${user.id} immediately after auth',
    );
    final enabled = await _homeRepository.setShareLocation(share: true);
    if (!enabled) {
      debugPrint('Failed to enable location share for user ${user.id}');
      return;
    }

    final refreshedUser = await authRepository.getSavedUser();
    if (refreshedUser != null) {
      _currentUser = refreshedUser;
      notifyListeners();
    }
  }

  Future<_VerifyOtpMetadata> _buildDeviceMetadata() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    String deviceModel = 'Unknown device';
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      deviceModel = '${info.manufacturer} ${info.model}'.trim();
    } else if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      deviceModel = info.utsname.machine.isNotEmpty
          ? info.utsname.machine
          : info.model;
    } else {
      deviceModel = Platform.operatingSystem;
    }

    final platform = Platform.isAndroid
        ? 'android'
        : Platform.isIOS
        ? 'ios'
        : 'web';
    final appVersion = packageInfo.version.isNotEmpty
        ? '${packageInfo.version}+${packageInfo.buildNumber}'
        : packageInfo.buildNumber;

    return _VerifyOtpMetadata(
      deviceModel: deviceModel,
      platform: platform,
      appVersion: appVersion,
    );
  }
}

class _VerifyOtpMetadata {
  final String deviceModel;
  final String platform;
  final String appVersion;

  const _VerifyOtpMetadata({
    required this.deviceModel,
    required this.platform,
    required this.appVersion,
  });
}
