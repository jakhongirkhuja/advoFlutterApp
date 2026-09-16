import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/models/home/lawyer.dart';
import '../../../../data/models/home/service_category.dart';
import '../../../../data/models/services/organization.dart';
import '../../../../data/models/services/protokol_provider.dart';
import '../../../../data/repositories/home_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeRepository repository;

  HomeViewModel(this.repository) {
    loadHome();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<Lawyer> _popularLawyers = const [];
  List<Lawyer> get popularLawyers => _popularLawyers;

  final Set<int> _savedLawyerIds = <int>{};
  final Set<int> _savedOrganizationIds = <int>{};

  List<Lawyer> get savedLawyers =>
      _popularLawyers.where((lawyer) => _savedLawyerIds.contains(lawyer.id)).toList();

  List<Organization> get savedOrganizations =>
      _organizations.where((organization) => _savedOrganizationIds.contains(organization.id)).toList();

  bool isLawyerSaved(int lawyerId) => _savedLawyerIds.contains(lawyerId);

  Future<void> toggleLawyerBookmark(int lawyerId) async {
    if (!_savedLawyerIds.add(lawyerId)) {
      _savedLawyerIds.remove(lawyerId);
    }
    await _persistBookmarks();
    notifyListeners();
  }

  bool isOrganizationSaved(int organizationId) =>
      _savedOrganizationIds.contains(organizationId);

  Future<void> toggleOrganizationBookmark(int organizationId) async {
    if (!_savedOrganizationIds.add(organizationId)) {
      _savedOrganizationIds.remove(organizationId);
    }
    await _persistBookmarks();
    notifyListeners();
  }

  List<ServiceCategory> _serviceCategories = const [];
  List<ServiceCategory> get serviceCategories => _serviceCategories;

  String _locationName = 'Toshkent shahri';
  String get locationName => _locationName;
  List<Organization> _organizations = const [];
  List<Organization> get organizations => _organizations;
  List<ProtokolProvider> _protokolProviders = const [];
  List<ProtokolProvider> get protokolProviders => _protokolProviders;

  Future<void> loadProtokolProviders() async {
    _protokolProviders = await repository.getProtokolProviders();
    notifyListeners();
  }
  Future<void> loadServices() async {
    _isLoading = true;
    notifyListeners();
    _organizations = await repository.getOrganizations();
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {
      // Local persistence is optional; keep the service list usable if the
      // platform plugin is unavailable during startup.
    }
    _savedOrganizationIds
      ..clear()
      ..addAll(prefs?.getStringList(_savedOrganizationsKey)?.map(int.parse) ?? const <int>[]);
    _isLoading = false;
    notifyListeners();
  }
  Future<void> loadHome() async {
    _isLoading = true;
    notifyListeners();
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {
      // Continue with repository defaults when local storage is unavailable.
    }

    // TODO(Dio): Replace these repository calls with the final home feed API
    // response when the backend endpoints are ready.
    final results = await Future.wait([
      repository.getPopularLawyers(),
      repository.getServiceCategories(),
      repository.getOrganizations(),
    ]);

    _popularLawyers = results[0] as List<Lawyer>;
    final storedLawyerIds = prefs?.getStringList(_savedLawyersKey);
    _savedLawyerIds
      ..clear()
      ..addAll(storedLawyerIds?.map(int.parse) ??
          _popularLawyers.where((lawyer) => lawyer.isBookmarked).map((lawyer) => lawyer.id));
    _serviceCategories = results[1] as List<ServiceCategory>;
    _organizations = results[2] as List<Organization>;
    final storedOrganizationIds = prefs?.getStringList(_savedOrganizationsKey);
    _savedOrganizationIds
      ..clear()
      ..addAll(storedOrganizationIds?.map(int.parse) ?? const <int>[]);
    _locationName = await _loadLocationName();
    _isLoading = false;
    notifyListeners();
  }

  static const _savedLawyersKey = 'saved_lawyer_ids';
  static const _savedOrganizationsKey = 'saved_organization_ids';

  Future<void> loadSavedItems() async {
    final futures = <Future<void>>[];
    if (_popularLawyers.isEmpty) futures.add(loadHome());
    if (_organizations.isEmpty) futures.add(loadServices());
    if (futures.isNotEmpty) await Future.wait(futures);
  }

  Future<void> _persistBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _savedLawyersKey,
        _savedLawyerIds.map((id) => id.toString()).toList(),
      );
      await prefs.setStringList(
        _savedOrganizationsKey,
        _savedOrganizationIds.map((id) => id.toString()).toList(),
      );
    } catch (_) {
      // The in-memory state is still updated even if persistence fails.
    }
  }

  Future<String> _loadLocationName() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return _locationName;

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return _locationName;
      }

      final position = await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 10),
            ),
          );

      // TODO(Dio): This uses the Vatandoshlar address endpoint. Keep the
      // endpoint in HomeRepository when the backend response is finalized.
      final address = await repository.getLocationName(
        position.latitude.toString(),
        position.longitude.toString(),
      );
      return address?.trim().isNotEmpty == true ? address!.trim() : _locationName;
    } catch (_) {
      return _locationName;
    }
  }
}
