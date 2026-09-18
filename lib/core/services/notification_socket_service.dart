import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import 'notification_service.dart';

/// Maintains the authenticated real-time notification WebSocket.
class NotificationSocketService {
  WebSocket? _socket;
  bool _enabled = false;
  bool _connecting = false;

  Future<void> connect() async {
    _enabled = true;
    if (_socket != null || _connecting) return;
    _connecting = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) return;
      final language = prefs.getString('language_code') ?? 'uz';
      final apiUri = Uri.parse(AppConfig.apiBaseUrl);
      final socketUri = apiUri.replace(
        scheme: apiUri.scheme == 'https' ? 'wss' : 'ws',
        path: '/ws/notifications',
      );
      final socket = await WebSocket.connect(
        socketUri.toString(),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.acceptLanguageHeader: language,
        },
      );
      if (!_enabled) {
        await socket.close();
        return;
      }
      _socket = socket;
      socket.listen(
        _handleMessage,
        onError: (Object error) {
          debugPrint('[Notifications WS] $error');
        },
        onDone: _reconnect,
        cancelOnError: true,
      );
    } catch (error) {
      debugPrint('[Notifications WS] connection failed: $error');
      _scheduleReconnect();
    } finally {
      _connecting = false;
    }
  }

  Future<void> disconnect() async {
    _enabled = false;
    final socket = _socket;
    _socket = null;
    await socket?.close();
  }

  void _handleMessage(dynamic raw) {
    try {
      final decoded = jsonDecode(raw.toString());
      if (decoded is! Map) return;
      final message = Map<String, dynamic>.from(decoded);
      if (message['event'] == 'notification') {
        NotificationService.showDataNotification(message);
      }
    } catch (error) {
      debugPrint('[Notifications WS] invalid message: $error');
    }
  }

  void _reconnect() {
    _socket = null;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (!_enabled) return;
    Future<void>.delayed(const Duration(seconds: 5), () {
      if (_enabled) connect();
    });
  }
}
