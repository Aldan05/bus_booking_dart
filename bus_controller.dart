import 'package:flutter/material.dart';
import '../models/bus_model.dart';
import '../services/mock_data_service.dart';

class BusController extends ChangeNotifier {
  final List<BusModel> _allBuses = MockDataService.getAvailableBuses();
  List<BusModel> _filteredBuses = [];

  List<BusModel> get filteredBuses => _filteredBuses.isEmpty ? _allBuses : _filteredBuses;

  void searchBuses(String source, String destination) {
    _filteredBuses = _allBuses.where((bus) {
      final route = bus.routeName.toLowerCase();
      return route.contains(source.toLowerCase()) &&
          route.contains(destination.toLowerCase());
    }).toList();

    notifyListeners();
  }
}
