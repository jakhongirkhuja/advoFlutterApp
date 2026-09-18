import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../api/api_client.dart';

/// Typed entry point for the endpoints from the Advokat OpenAPI document.
/// UI-specific model conversion stays in feature repositories/view models.
class AdvokatRepository {
  final ApiClient apiClient;

  const AdvokatRepository(this.apiClient);

  Future<Map<String, dynamic>> health() async =>
      _map((await apiClient.get('/')).data);

  Future<List<Map<String, dynamic>>> getVersions({String? appType}) async =>
      _items(
        (await apiClient.get(
          '/versions',
          queryParameters: {if (appType != null) 'app_type': appType},
        )).data,
      );

  Future<Map<String, dynamic>> createVersion({
    required String version,
    required String appType,
  }) async => _map(
    (await apiClient.post(
      '/versions',
      data: {'version': version, 'app_type': appType},
    )).data,
  );

  Future<Map<String, dynamic>> updateVersion(
    int id, {
    required String version,
    required String appType,
  }) async => _map(
    (await apiClient.put(
      '/versions/$id',
      data: {'version': version, 'app_type': appType},
    )).data,
  );

  Future<void> deleteVersion(int id) async => apiClient.delete('/versions/$id');

  Future<Map<String, dynamic>> askChatbot({
    String? message,
    int? conversationId,
    File? file,
  }) async {
    final response = await apiClient.post(
      '/chatbot/ask',
      data: FormData.fromMap({
        if (message?.trim().isNotEmpty == true) 'message': message!.trim(),
        if (conversationId != null) 'conversation_id': conversationId,
        if (file != null)
          'file': await MultipartFile.fromFile(
            file.path,
            filename: _fileName(file.path),
          ),
      }),
    );
    return _map(response.data);
  }

  Future<List<Map<String, dynamic>>> getChatbotConversations() async =>
      _itemsOrList((await apiClient.get('/chatbot/conversations')).data);

  Future<Map<String, dynamic>> getChatbotHistory(int conversationId) async =>
      _map(
        (await apiClient.get(
          '/chatbot/history',
          queryParameters: {'conversation_id': conversationId},
        )).data,
      );

  Future<void> deleteChatbotConversation(int id) async =>
      apiClient.delete('/chatbot/conversations/$id');

  Future<List<Map<String, dynamic>>> getPurchasedTemplates() async =>
      _itemsOrList((await apiClient.get('/clients/me/templates')).data);

  Future<List<Map<String, dynamic>>> getSavedLawyers() async =>
      _itemsOrList((await apiClient.get('/clients/me/saved-lawyers')).data);

  Future<List<Map<String, dynamic>>> getSavedOrganizations() async =>
      _itemsOrList(
        (await apiClient.get('/clients/me/saved-organizations')).data,
      );

  Future<List<Map<String, dynamic>>> getClientDevices() async =>
      _itemsOrList((await apiClient.get('/clients/me/devices')).data);

  Future<void> revokeClientDevice(int id) async =>
      apiClient.delete('/clients/me/devices/$id');

  Future<List<Map<String, dynamic>>> getSuggestions({
    bool lawyer = false,
  }) async => _itemsOrList(
    (await apiClient.get(
      lawyer ? '/lawyers/me/suggestions' : '/clients/me/suggestions',
    )).data,
  );

  Future<Map<String, dynamic>> sendSuggestion({
    required String comment,
    File? image,
    bool lawyer = false,
  }) async => _map(
    (await apiClient.post(
      lawyer ? '/lawyers/me/suggestions' : '/clients/me/suggestions',
      data: FormData.fromMap({
        'comment': comment,
        if (image != null)
          'image': await MultipartFile.fromFile(
            image.path,
            filename: _fileName(image.path),
          ),
      }),
    )).data,
  );

  Future<Map<String, dynamic>> getVerification() async =>
      _map((await apiClient.get('/verification')).data);

  Future<Map<String, dynamic>> submitVerification({
    required File passportFront,
    required File passportBack,
    required File selfie,
  }) async => _map(
    (await apiClient.post(
      '/verification',
      data: FormData.fromMap({
        'passport_front': await MultipartFile.fromFile(
          passportFront.path,
          filename: _fileName(passportFront.path),
        ),
        'passport_back': await MultipartFile.fromFile(
          passportBack.path,
          filename: _fileName(passportBack.path),
        ),
        'selfie': await MultipartFile.fromFile(
          selfie.path,
          filename: _fileName(selfie.path),
        ),
      }),
    )).data,
  );

  Future<Map<String, dynamic>> reviewVerification(
    int id, {
    required String status,
    String? reason,
  }) async => _map(
    (await apiClient.post(
      '/admin/verifications/$id/review',
      data: {'status': status, if (reason != null) 'reason': reason},
    )).data,
  );

  Future<List<Map<String, dynamic>>> getContacts({String? type}) async =>
      _itemsOrList(
        (await apiClient.get(
          '/contacts',
          queryParameters: {if (type != null) 'type': type},
        )).data,
      );

  Future<List<Map<String, dynamic>>> getContributors({
    int? regionId,
    int? cityId,
  }) async => _itemsOrList(
    (await apiClient.get(
      '/sponsorship/contributors',
      queryParameters: {
        if (regionId != null) 'region_id': regionId,
        if (cityId != null) 'city_id': cityId,
      },
    )).data,
  );

  Future<Map<String, dynamic>> addContribution({
    int projectId = 1,
    required num amount,
    String? paymentMethod,
    bool isAnonymous = false,
  }) async => _map(
    (await apiClient.post(
      '/sponsorship/contributions',
      data: {
        'project_id': projectId,
        'amount': amount,
        if (paymentMethod != null) 'payment_method': paymentMethod,
        'is_anonymous': isAnonymous,
      },
    )).data,
  );

  Future<Map<String, dynamic>> getLawyers({
    int page = 1,
    int limit = 20,
    String? search,
    int? practiceAreaId,
    int? serviceTypeId,
    num? minPrice,
    num? maxPrice,
    num? minRating,
    int? minExperience,
    int? maxExperience,
    bool? verified,
    String? status,
    int? organizationId,
  }) async => _map(
    (await apiClient.get(
      '/lawyers',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search?.isNotEmpty == true) 'search': search,
        if (practiceAreaId != null) 'practice_area_id': practiceAreaId,
        if (serviceTypeId != null) 'service_type_id': serviceTypeId,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
        if (minRating != null) 'min_rating': minRating,
        if (minExperience != null) 'min_experience': minExperience,
        if (maxExperience != null) 'max_experience': maxExperience,
        if (verified != null) 'verified': verified,
        if (status != null) 'status': status,
        if (organizationId != null) 'organization_id': organizationId,
      },
    )).data,
  );

  Future<Map<String, dynamic>> getLawyerDashboard() async =>
      _map((await apiClient.get('/lawyers/dashboard')).data);

  Future<Map<String, dynamic>> getLawyerProfile() async =>
      _map((await apiClient.get('/lawyers/me/profile')).data);

  Future<List<Map<String, dynamic>>> getLawyerDevices() async =>
      _itemsOrList((await apiClient.get('/lawyers/me/devices')).data);

  Future<void> revokeLawyerDevice(int id) async =>
      apiClient.delete('/lawyers/me/devices/$id');

  Future<Map<String, dynamic>> updateLawyerProfile({
    String? firstName,
    String? lastName,
    String? parentName,
    String? birthday,
    String? beginDate,
    String? bio,
    List<int>? practiceAreaIds,
    File? avatar,
    File? license,
  }) async => _map(
    (await apiClient.put(
      '/lawyers/me/profile',
      data: FormData.fromMap({
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (parentName != null) 'parent_name': parentName,
        if (birthday != null) 'birthday': birthday,
        if (beginDate != null) 'begin_date': beginDate,
        if (bio != null) 'bio': bio,
        if (practiceAreaIds != null) 'practice_area_ids': practiceAreaIds,
        if (avatar != null)
          'avatar': await MultipartFile.fromFile(
            avatar.path,
            filename: _fileName(avatar.path),
          ),
        if (license != null)
          'license': await MultipartFile.fromFile(
            license.path,
            filename: _fileName(license.path),
          ),
      }),
    )).data,
  );

  Future<Map<String, dynamic>> getLawyerProfileSection(String tab) async =>
      _map((await apiClient.get('/lawyers/me/$tab')).data);

  Future<Map<String, dynamic>> getLawyerTab(int id, String tab) async => _map(
    (await apiClient.get(
      '/lawyers/$id/tab',
      queryParameters: {'tab': tab},
    )).data,
  );

  Future<Map<String, dynamic>> getLawyerAvailability(
    int id, {
    String? date,
  }) async => _map(
    (await apiClient.get(
      '/lawyers/$id/availability',
      queryParameters: {if (date != null) 'date': date},
    )).data,
  );

  Future<Map<String, dynamic>> setLawyerSaved(int id, bool saved) async => _map(
    (saved
            ? await apiClient.post('/lawyers/$id/save')
            : await apiClient.delete('/lawyers/$id/save'))
        .data,
  );

  Future<Map<String, dynamic>> getLawyerReport({
    String period = 'monthly',
    String? from,
    String? to,
  }) async => _map(
    (await apiClient.get(
      '/lawyers/reports',
      queryParameters: {
        'period': period,
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      },
    )).data,
  );

  Future<Map<String, dynamic>> getLawyerAppointments({
    bool upcoming = false,
  }) async => _map(
    (await apiClient.get(
      upcoming
          ? '/lawyers/appointments/upcoming'
          : '/lawyers/appointments/today',
    )).data,
  );

  Future<Map<String, dynamic>> getLawyerAppointment(int id) async =>
      _map((await apiClient.get('/lawyers/appointments/$id')).data);

  Future<Map<String, dynamic>> setLawyerService({
    required int serviceTypeId,
    required num price,
    String currency = 'UZS',
  }) async => _map(
    (await apiClient.put(
      '/lawyers/me/services/$serviceTypeId',
      data: {'price': price, 'currency': currency},
    )).data,
  );

  Future<void> deleteLawyerService(int serviceTypeId) async =>
      apiClient.delete('/lawyers/me/services/$serviceTypeId');

  Future<Map<String, dynamic>> addLawyerDocument({
    required String collection,
    required String name,
    required File file,
    String? issuedDate,
  }) async => _map(
    (await apiClient.post(
      '/lawyers/me/$collection',
      data: FormData.fromMap({
        'name': name,
        if (issuedDate != null) 'issued_date': issuedDate,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: _fileName(file.path),
        ),
      }),
    )).data,
  );

  Future<Map<String, dynamic>> updateLawyerDocument({
    required String collection,
    required int id,
    required String name,
    File? file,
    String? issuedDate,
  }) async => _map(
    (await apiClient.put(
      '/lawyers/me/$collection/$id',
      data: FormData.fromMap({
        'name': name,
        if (issuedDate != null) 'issued_date': issuedDate,
        if (file != null)
          'file': await MultipartFile.fromFile(
            file.path,
            filename: _fileName(file.path),
          ),
      }),
    )).data,
  );

  Future<void> deleteLawyerDocument(String collection, int id) async =>
      apiClient.delete('/lawyers/me/$collection/$id');

  Future<Map<String, dynamic>> getOrganizations({
    int page = 1,
    int limit = 20,
    String? search,
    int? typeId,
    int? serviceTypeId,
    int? cityId,
    bool? verified,
  }) async => _map(
    (await apiClient.get(
      '/organizations',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search?.isNotEmpty == true) 'search': search,
        if (typeId != null) 'type_id': typeId,
        if (serviceTypeId != null) 'service_type_id': serviceTypeId,
        if (cityId != null) 'city_id': cityId,
        if (verified != null) 'verified': verified,
      },
    )).data,
  );

  Future<Map<String, dynamic>> getOrganizationTab(int id, String tab) async =>
      _map(
        (await apiClient.get(
          '/organizations/$id/tab',
          queryParameters: {'tab': tab},
        )).data,
      );

  Future<Map<String, dynamic>> setOrganizationSaved(int id, bool saved) async =>
      _map(
        (saved
                ? await apiClient.post('/organizations/$id/save')
                : await apiClient.delete('/organizations/$id/save'))
            .data,
      );

  Future<List<Map<String, dynamic>>> getPracticeAreas() async =>
      _itemsOrList((await apiClient.get('/practice-areas')).data);

  Future<List<Map<String, dynamic>>> getServiceTypes() async =>
      _itemsOrList((await apiClient.get('/service-types')).data);

  Future<Map<String, dynamic>> createAppointment({
    required int lawyerId,
    required int serviceTypeId,
    required String date,
    required String startTime,
    required String receptionType,
    required String paymentMethod,
    String? problemDescription,
    List<File> documents = const [],
  }) async => _map(
    (await apiClient.post(
      '/appointments',
      data: FormData.fromMap({
        'lawyer_id': lawyerId,
        'service_type_id': serviceTypeId,
        'date': date,
        'start_time': startTime,
        'reception_type': receptionType,
        'payment_method': paymentMethod,
        if (problemDescription?.isNotEmpty == true)
          'problem_description': problemDescription,
        if (documents.isNotEmpty)
          'documents': [
            for (final file in documents)
              await MultipartFile.fromFile(
                file.path,
                filename: _fileName(file.path),
              ),
          ],
      }),
    )).data,
  );

  Future<List<Map<String, dynamic>>> getAppointments({
    String status = 'all',
  }) async => _items(
    (await apiClient.get(
      '/appointments',
      queryParameters: {'status': status},
    )).data,
  );

  Future<Map<String, dynamic>> getAppointment(int id) async =>
      _map((await apiClient.get('/appointments/$id')).data);

  Future<void> cancelAppointment(int id) async =>
      apiClient.delete('/appointments/$id');

  Future<void> reviewAppointment(
    int id, {
    required int rating,
    String? comment,
  }) async => apiClient.post(
    '/appointments/$id/review',
    data: {'rating': rating, if (comment != null) 'comment': comment},
  );

  Future<Map<String, dynamic>> updateLawyerAppointment(
    int id,
    String action, {
    String? reason,
  }) async => _map(
    (await apiClient.post(
      '/lawyers/appointments/$id/$action',
      data: {if (reason != null) 'reason': reason},
    )).data,
  );

  Future<List<Map<String, dynamic>>> getEuroProtocolTypes() async =>
      _itemsOrList((await apiClient.get('/euro-protocol-types')).data);

  Future<List<Map<String, dynamic>>> getEuroProtocols({
    int? typeId,
    int? cityId,
    String status = 'active',
  }) async => _itemsOrList(
    (await apiClient.get(
      '/euro-protocols',
      queryParameters: {
        if (typeId != null) 'type_id': typeId,
        if (cityId != null) 'city_id': cityId,
        'status': status,
      },
    )).data,
  );

  Future<List<Map<String, dynamic>>> getNearbyEuroProtocols({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  }) async => _items(
    (await apiClient.get(
      '/euro-protocols/nearby',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'radius_km': radiusKm,
      },
    )).data,
  );

  Future<Map<String, dynamic>> getEuroProtocol(int id) async =>
      _map((await apiClient.get('/euro-protocols/$id')).data);

  Future<Map<String, dynamic>> registerEuroProtocol(int id) async =>
      _map((await apiClient.post('/euro-protocols/$id/register')).data);

  Future<Map<String, dynamic>> setEuroProtocolSaved(int id, bool saved) async =>
      _map(
        (saved
                ? await apiClient.post('/euro-protocols/$id/save')
                : await apiClient.delete('/euro-protocols/$id/save'))
            .data,
      );

  Future<Map<String, dynamic>> cancelEuroProtocol(int id) async =>
      _map((await apiClient.post('/euro-protocols/$id/cancel')).data);

  Future<Map<String, dynamic>> startEuroCall({
    required double latitude,
    required double longitude,
  }) async => _map(
    (await apiClient.post(
      '/euro-calls',
      data: {'latitude': latitude, 'longitude': longitude},
    )).data,
  );

  Future<Map<String, dynamic>> getEuroCall(int id) async =>
      _map((await apiClient.get('/euro-calls/$id')).data);

  Future<Map<String, dynamic>> updateEuroCall(int id, String action) async =>
      _map((await apiClient.post('/euro-calls/$id/$action')).data);

  Future<List<Map<String, dynamic>>> getIncomingEuroCalls() async =>
      _items((await apiClient.get('/euro-protocol/calls/incoming')).data);

  Future<List<Map<String, dynamic>>> getEuroCallHistory() async =>
      _itemsOrList((await apiClient.get('/euro-protocol/calls/history')).data);

  Future<Map<String, dynamic>> getIncomingEuroCall(int id) async =>
      _map((await apiClient.get('/euro-protocol/calls/$id')).data);

  Future<Map<String, dynamic>> respondToEuroCall(
    int id, {
    required bool accept,
  }) async => _map(
    (await apiClient.post(
      '/euro-protocol/calls/$id/respond',
      data: {'accept': accept},
    )).data,
  );

  Future<Map<String, dynamic>> updateEuroProfile({
    String? displayName,
    String? phone,
    double? latitude,
    double? longitude,
    bool? isAvailable,
  }) async => _map(
    (await apiClient.put(
      '/euro-protocol/me',
      data: {
        if (displayName != null) 'display_name': displayName,
        if (phone != null) 'phone': phone,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (isAvailable != null) 'is_available': isAvailable,
      },
    )).data,
  );

  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async => _map(
    (await apiClient.get(
      '/notifications',
      queryParameters: {'page': page, 'limit': limit},
    )).data,
  );

  Future<void> markNotificationRead(int id) async =>
      apiClient.post('/notifications/$id/read');

  Future<void> markAllNotificationsRead() async =>
      apiClient.post('/notifications/read-all');

  Future<Map<String, dynamic>> getDocumentTemplates({
    int page = 1,
    int limit = 20,
    String? search,
  }) async => _map(
    (await apiClient.get(
      '/document-templates',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search?.isNotEmpty == true) 'search': search,
      },
    )).data,
  );

  Future<Map<String, dynamic>> getDocumentTemplate(int id) async =>
      _map((await apiClient.get('/document-templates/$id')).data);

  Future<Map<String, dynamic>> purchaseDocumentTemplate(
    int id, {
    required String paymentMethod,
  }) async => _map(
    (await apiClient.post(
      '/document-templates/$id/purchase',
      data: {'payment_method': paymentMethod},
    )).data,
  );

  Future<Map<String, dynamic>> submitDocumentTemplate(
    int clientTemplateId, {
    required Map<String, String> fieldValues,
  }) async => _map(
    (await apiClient.post(
      '/client-templates/$clientTemplateId/submissions',
      data: FormData.fromMap({'field_values': jsonEncode(fieldValues)}),
    )).data,
  );

  static Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  static List<Map<String, dynamic>> _items(dynamic value) {
    if (value is Map && value['data'] != null) value = value['data'];
    if (value is! Map || value['items'] is! List) return const [];
    return _list(value['items']);
  }

  static List<Map<String, dynamic>> _itemsOrList(dynamic value) {
    if (value is Map && value['data'] != null) value = value['data'];
    if (value is Map && value['items'] is List) return _list(value['items']);
    return _list(value);
  }

  static List<Map<String, dynamic>> _list(dynamic value) => value is List
      ? value
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
      : const [];

  static String _fileName(String path) =>
      path.replaceAll('\\', '/').split('/').last;
}
