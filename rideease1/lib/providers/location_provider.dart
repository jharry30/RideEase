// providers/location_provider.dart
import 'package:flutter/foundation.dart';
import '../services/location_service.dart';

class LocationProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();

  Map<String, double> _currentLocation = {};
  List<String> _suggestions = [];
  bool _isLoading = false;
  String? _error;

  Map<String, double> get currentLocation => _currentLocation;
  List<String> get suggestions => _suggestions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getCurrentLocation() async {
    _setLoading(true);
    _error = null;

    try {
      _currentLocation = await _locationService.getCurrentLocation();
    } catch (e) {
      _error = 'Failed to get location';
      debugPrint('Location error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchLocation(String query) async {
    if (query.trim().isEmpty) {
      _suggestions = [];
      notifyListeners();
      return;
    }

    _setLoading(true);
    _error = null;

    try {
      _suggestions = await _locationService.searchLocation(query.trim());
    } catch (e) {
      _suggestions = [];
      _error = 'Search failed';
      debugPrint('Search error: $e');
    } finally {
      _setLoading(false);
    }
  }

  void clearSuggestions() {
    _suggestions = [];
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
