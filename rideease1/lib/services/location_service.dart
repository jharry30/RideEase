// services/location_service.dart
import 'package:geolocator/geolocator.dart';

class LocationService {
  // Get current device location
  Future<Map<String, double>> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return {
      'lat': position.latitude,
      'lng': position.longitude,
    };
  }

  // Mock search - replace with real API (Google Places, Mapbox, etc.)
  Future<List<String>> searchLocation(String query) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network

    final mockResults = [
      'Quezon City',
      'Makati City',
      'Taguig City',
      'Pasig City',
      'Mandaluyong City',
      'Manila City',
      'Pasay City',
      'Parañaque City',
    ];

    return mockResults
        .where((place) => place.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
