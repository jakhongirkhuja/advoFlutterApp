import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../data/models/home/lawyer.dart';
import '../../../../data/models/home/service_category.dart';
import '../../../../data/models/services/organization.dart';
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
  List<Lawyer> get savedLawyers =>
      _popularLawyers.where((lawyer) => _savedLawyerIds.contains(lawyer.id)).toList();

  bool isLawyerSaved(int lawyerId) => _savedLawyerIds.contains(lawyerId);

  void toggleLawyerBookmark(int lawyerId) {
    if (!_savedLawyerIds.add(lawyerId)) {
      _savedLawyerIds.remove(lawyerId);
    }
    notifyListeners();
  }

  List<ServiceCategory> _serviceCategories = const [];
  List<ServiceCategory> get serviceCategories => _serviceCategories;

  String _locationName = 'Toshkent shahri';
  String get locationName => _locationName;
  List<Organization> _organizations = const [];
  List<Organization> get organizations => _organizations;
  Future<void> loadServices() async {
    _isLoading = true;
    notifyListeners();
    _organizations = await repository.getOrganizations();
    _isLoading = false;
    notifyListeners();
  }
  Future<void> loadHome() async {
    _isLoading = true;
    notifyListeners();

    // TODO(Dio): Replace these repository calls with the final home feed API
    // response when the backend endpoints are ready.
    final results = await Future.wait([
      repository.getPopularLawyers(),
      repository.getServiceCategories(),
    ]);

    _popularLawyers = results[0] as List<Lawyer>;
    _savedLawyerIds
      ..clear()
      ..addAll(_popularLawyers.where((lawyer) => lawyer.isBookmarked).map((lawyer) => lawyer.id));
    _serviceCategories = results[1] as List<ServiceCategory>;
    _locationName = await _loadLocationName();
    _isLoading = false;
    notifyListeners();
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
