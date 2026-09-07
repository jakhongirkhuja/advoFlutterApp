import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/app_config.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: Headers
            .formUrlEncodedContentType, // Always use form data by default
      ),
    );

    // Token Interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          final isTrackedLocationRequest = _isTrackedLocationPath(options.path);
          final startedAt = DateTime.now().millisecondsSinceEpoch;
          options.extra['request_started_at'] = startedAt;

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            print(
              '--- API REQUEST: ${options.method} ${options.path} (Token attached) ---',
            );
          } else {
            print(
              '--- API REQUEST: ${options.method} ${options.path} (NO TOKEN FOUND) ---',
            );
          }

          if (isTrackedLocationRequest) {
            _logTrackedRequest(
              'START ${options.method} ${options.path} '
              'query=${options.queryParameters} data=${options.data}',
            );
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          final options = response.requestOptions;
          if (_isTrackedLocationPath(options.path)) {
            final elapsedMs = _elapsedMs(options);
            final payloadSummary = response.data is List
                ? 'items=${(response.data as List).length}'
                : response.data is Map
                ? 'keys=${(response.data as Map).keys.toList()}'
                : 'type=${response.data.runtimeType}';
            _logTrackedRequest(
              'END ${options.method} ${options.path} '
              'status=${response.statusCode} duration=${elapsedMs}ms $payloadSummary',
            );
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          final options = e.requestOptions;
          if (_isTrackedLocationPath(options.path)) {
            _logTrackedRequest(
              'ERROR ${options.method} ${options.path} '
              'status=${e.response?.statusCode} duration=${_elapsedMs(options)}ms '
              'type=${e.type} message=${e.message}',
            );
          }

          final int? statusCode =
              e.response?.statusCode ??
              (e.response?.data is Map
                  ? e.response?.data['status_code']
                  : null);

          if (statusCode == 401) {
            print('--- UNAUTHORIZED (401) DETECTED ---');
            print('Error message from server: ${e.response?.data?['error']}');

            /* 
          // Future implementation:
          // 1. Delete cache
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('auth_token');
          await prefs.remove('user_data');
          
          // 2. Redirect to login
          // We need a GlobalKey<NavigatorState> to redirect from here
          // navigatorKey.currentState?.pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
          */

            print('Redirect logic is currently commented out as requested.');
          }
          return handler.next(e);
        },
      ),
    );

    // Log requests in debug mode - MUST BE LAST to see modified headers
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: true, // Enabled response headers to see debug info
        error: true,
        compact: true,
      ),
    );
  }

  // Helper for GET requests
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  // Helper for POST requests
  Future<Response> post(String path, {dynamic data}) async {
    return await dio.post(path, data: data);
  }

  // Helper for PUT requests
  Future<Response> put(String path, {dynamic data}) async {
    return await dio.put(path, data: data);
  }

  // Helper for DELETE requests
  Future<Response> delete(String path, {dynamic data}) async {
    return await dio.delete(path, data: data);
  }

  bool _isTrackedLocationPath(String path) {
    return path == 'users/location' ||
        path == 'users/location/address' ||
        path == 'users/nearby';
  }

  int _elapsedMs(RequestOptions options) {
    final startedAt = options.extra['request_started_at'];
    if (startedAt is! int) {
      return -1;
    }
    return DateTime.now().millisecondsSinceEpoch - startedAt;
  }

  void _logTrackedRequest(String message) {
    debugPrint('[ApiClient][${DateTime.now().toIso8601String()}] $message');
  }
}
