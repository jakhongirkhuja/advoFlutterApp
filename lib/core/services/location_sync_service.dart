import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../data/api/api_client.dart';
import '../../data/repositories/home_repository.dart';

@pragma('vm:entry-point')
void locationSyncCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    LocationSyncService.instance._log(
      'background dispatcher fired for task=$task input=$inputData',
    );

    try {
      await LocationSyncService.instance.runBackgroundTask(task);
      LocationSyncService.instance._log(
        'background dispatcher completed for task=$task',
      );
      return true;
    } catch (e) {
      LocationSyncService.instance._log(
        'background dispatcher failed for task=$task error=$e',
      );
      return false;
    }
  });
}

class LocationSyncService {
  LocationSyncService._();

  static final LocationSyncService instance = LocationSyncService._();

  static const String _taskUniqueName = 'user-location-sync-periodic';
  static const String _taskName = 'user-location-sync';
  static const String _authEnabledKey = 'location_sync_auth_enabled';
  static const String _lastSentAtKey = 'location_sync_last_sent_at';
  static const String _lastObservedAtKey = 'location_sync_last_observed_at';
  static const String _lastObservedLatKey = 'location_sync_last_observed_lat';
  static const String _lastObservedLngKey = 'location_sync_last_observed_lng';
  static const String _lastMovementAtKey = 'location_sync_last_movement_at';

  static const Duration movingInterval = Duration(minutes: 15);
  static const Duration stationaryInterval = Duration(hours: 3);
  static const double movementThresholdMeters = 50;
  static const double walkingSpeedThresholdMps = 0.8;

  Timer? _foregroundTimer;
  AppLifecycleState _lastLifecycleState = AppLifecycleState.resumed;
  bool _initialized = false;
  bool _syncInProgress = false;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) {
      return;
    }

    _initialized = true;
    _log('initialize requested');

    if (Platform.isAndroid || Platform.isIOS) {
      await Workmanager().initialize(locationSyncCallbackDispatcher);
      _log('workmanager initialized for ${Platform.operatingSystem}');
    }
  }

  Future<void> updateTrackingState({required bool isAuthenticated}) async {
    if (kIsWeb) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authEnabledKey, isAuthenticated);
    _log('updateTrackingState auth=$isAuthenticated');

    if (!isAuthenticated) {
      await _disableTracking();
      return;
    }

    await _ensureLocationPermissionForTracking();
    await _ensureBackgroundTaskRegistered();

    if (_isForegroundLifecycle(_lastLifecycleState)) {
      _startForegroundTimer();
      unawaited(syncNow(source: 'auth_state'));
    }
  }

  Future<void> handleAppLifecycleChange(AppLifecycleState state) async {
    _lastLifecycleState = state;
    _log('lifecycle changed to $state');

    if (kIsWeb) {
      return;
    }

    if (_isForegroundLifecycle(state)) {
      _startForegroundTimer();
      unawaited(syncNow(source: 'app_resumed'));
      return;
    }

    _stopForegroundTimer();
    await _ensureBackgroundTaskRegistered();
  }

  Future<void> runBackgroundTask(String task) async {
    if (task != _taskName) {
      _log('ignoring unknown task=$task');
      return;
    }

    _log('running background task=$task');
    await syncNow(source: 'background_task');
  }

  Future<void> syncNow({String source = 'manual'}) async {
    if (kIsWeb) {
      return;
    }

    if (_syncInProgress) {
      _log('syncNow skipped source=$source reason=already_running');
      return;
    }

    final stopwatch = Stopwatch()..start();
    _syncInProgress = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.getBool(_authEnabledKey).orFalse) {
        _log('syncNow skipped source=$source reason=not_authenticated');
        return;
      }

      if (!await Geolocator.isLocationServiceEnabled()) {
        _log('syncNow skipped source=$source reason=service_disabled');
        return;
      }

      final requireAlwaysPermission =
          Platform.isIOS && source == 'background_task';
      final permission = await _ensureLocationPermission(
        requireAlways: requireAlwaysPermission,
      );
      if (!_allowsLocation(
        permission,
        requireAlways: requireAlwaysPermission,
      )) {
        _log(
          'syncNow skipped source=$source '
          'reason=permission_$permission requireAlways=$requireAlwaysPermission',
        );
        return;
      }

      final position = await _getBestPosition();
      if (position == null) {
        _log('syncNow skipped source=$source reason=no_position');
        return;
      }

      await _evaluateAndSend(position, prefs, source: source);
      _log(
        'syncNow finished source=$source in ${stopwatch.elapsedMilliseconds}ms',
      );
    } catch (e) {
      _log('syncNow failed source=$source error=$e');
    } finally {
      _syncInProgress = false;
    }
  }

  Future<void> _evaluateAndSend(
    Position position,
    SharedPreferences prefs, {
    required String source,
  }) async {
    final now = DateTime.now();
    final lastObservedLat = prefs.getDouble(_lastObservedLatKey);
    final lastObservedLng = prefs.getDouble(_lastObservedLngKey);
    final lastSentAt = _readDateTime(prefs, _lastSentAtKey);

    final movedSinceLastObservation =
        lastObservedLat != null && lastObservedLng != null
        ? Geolocator.distanceBetween(
                lastObservedLat,
                lastObservedLng,
                position.latitude,
                position.longitude,
              ) >=
              movementThresholdMeters
        : true;

    final isWalking =
        movedSinceLastObservation ||
        (position.speed.isFinite && position.speed >= walkingSpeedThresholdMps);

    await prefs.setDouble(_lastObservedLatKey, position.latitude);
    await prefs.setDouble(_lastObservedLngKey, position.longitude);
    await prefs.setInt(_lastObservedAtKey, now.millisecondsSinceEpoch);

    if (isWalking) {
      await prefs.setInt(_lastMovementAtKey, now.millisecondsSinceEpoch);
    }

    final dueForMovingUpdate =
        lastSentAt == null || now.difference(lastSentAt) >= movingInterval;
    final dueForStationaryUpdate =
        lastSentAt == null || now.difference(lastSentAt) >= stationaryInterval;

    final shouldSend = isWalking ? dueForMovingUpdate : dueForStationaryUpdate;
    _log(
      'evaluate source=$source '
      'walking=$isWalking moved=$movedSinceLastObservation '
      'speed=${position.speed} lastSentAt=$lastSentAt '
      'dueMoving=$dueForMovingUpdate dueStationary=$dueForStationaryUpdate '
      'shouldSend=$shouldSend',
    );
    if (!shouldSend) {
      return;
    }

    final repository = HomeRepository(ApiClient());
    await repository.sendCurrentLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    await prefs.setInt(_lastSentAtKey, now.millisecondsSinceEpoch);
    _log(
      'location synced from $source '
      'walking=$isWalking lat=${position.latitude} lng=${position.longitude}',
    );
  }

  Future<Position?> _getBestPosition() async {
    try {
      _log('requesting current position for background sync');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      );
      _log(
        'current position resolved lat=${position.latitude} lng=${position.longitude} '
        'accuracy=${position.accuracy} speed=${position.speed}',
      );
      return position;
    } catch (_) {
      _log('current position failed, falling back to last known position');
      final fallback = await Geolocator.getLastKnownPosition();
      if (fallback != null) {
        _log(
          'last known position resolved lat=${fallback.latitude} lng=${fallback.longitude} '
          'accuracy=${fallback.accuracy} speed=${fallback.speed}',
        );
      }
      return fallback;
    }
  }

  Future<void> _ensureBackgroundTaskRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.getBool(_authEnabledKey).orFalse) {
      return;
    }

    if (!(Platform.isAndroid || Platform.isIOS)) {
      return;
    }

    if (Platform.isIOS) {
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always) {
        _log(
          'skipping background task registration on ios until always permission is granted',
        );
        return;
      }
    }

    _log('registering periodic background task');
    await Workmanager().cancelByUniqueName(_taskUniqueName);
    await Workmanager().registerPeriodicTask(
      _taskUniqueName,
      _taskName,
      frequency: movingInterval,
      initialDelay: movingInterval,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  Future<void> _disableTracking() async {
    _log('disabling location tracking');
    _stopForegroundTimer();

    if (Platform.isAndroid || Platform.isIOS) {
      await Workmanager().cancelByUniqueName(_taskUniqueName);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSentAtKey);
    await prefs.remove(_lastObservedAtKey);
    await prefs.remove(_lastObservedLatKey);
    await prefs.remove(_lastObservedLngKey);
    await prefs.remove(_lastMovementAtKey);
  }

  void _startForegroundTimer() {
    _foregroundTimer?.cancel();
    _log('starting foreground timer');
    _foregroundTimer = Timer.periodic(movingInterval, (_) {
      unawaited(syncNow(source: 'foreground_timer'));
    });
  }

  void _stopForegroundTimer() {
    if (_foregroundTimer != null) {
      _log('stopping foreground timer');
    }
    _foregroundTimer?.cancel();
    _foregroundTimer = null;
  }

  bool _isForegroundLifecycle(AppLifecycleState state) {
    return state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive;
  }

  Future<void> _ensureLocationPermissionForTracking() async {
    if (Platform.isIOS) {
      final permission = await _ensureLocationPermission(requireAlways: true);
      _log('ios tracking permission status after ensure: $permission');
      return;
    }

    final permission = await _ensureLocationPermission(requireAlways: false);
    _log('tracking permission status after ensure: $permission');
  }

  Future<LocationPermission> _ensureLocationPermission({
    required bool requireAlways,
  }) async {
    var permission = await Geolocator.checkPermission();
    _log('current permission status=$permission requireAlways=$requireAlways');

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      _log('permission after request=$permission');
    }

    if (Platform.isIOS &&
        requireAlways &&
        permission == LocationPermission.whileInUse) {
      _log('ios permission is whileInUse, requesting upgrade to always');
      permission = await Geolocator.requestPermission();
      _log('ios permission after always-upgrade request=$permission');
    }

    return permission;
  }

  bool _allowsLocation(
    LocationPermission permission, {
    required bool requireAlways,
  }) {
    if (requireAlways) {
      return permission == LocationPermission.always;
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  DateTime? _readDateTime(SharedPreferences prefs, String key) {
    final rawValue = prefs.getInt(key);
    if (rawValue == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(rawValue);
  }

  void _log(String message) {
    debugPrint(
      '[LocationSyncService][${DateTime.now().toIso8601String()}] $message',
    );
  }
}

extension on bool? {
  bool get orFalse => this ?? false;
}
