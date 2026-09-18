import 'package:flutter/foundation.dart';

import '../../../../data/models/appointments/appointment.dart';
import '../../../../data/repositories/home_repository.dart';

class AppointmentsViewModel extends ChangeNotifier {
  final HomeRepository repository;

  AppointmentsViewModel(this.repository) {
    loadAppointments();
  }

  static const filters = [
    'filter_all',
    'filter_upcoming',
    'filter_past',
    'filter_cancelled',
  ];

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String _selectedFilter = 'filter_all';
  String get selectedFilter => _selectedFilter;

  List<Appointment> _appointments = const [];

  List<Appointment> get appointments {
    if (_selectedFilter == 'filter_all') return _appointments;
    return _appointments
        .where((appointment) => appointment.status == _selectedFilter)
        .toList();
  }

  Future<void> loadAppointments() async {
    _isLoading = true;
    notifyListeners();

    // TODO(Dio): Replace this repository call with `apiClient.get('appointments')`.
    _appointments = await repository.getAppointments();
    _isLoading = false;
    notifyListeners();
  }

  void selectFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }
}
