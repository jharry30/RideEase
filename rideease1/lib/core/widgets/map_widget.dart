import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rideease1/core/constants/colors.dart';

class MapWidget extends StatefulWidget {
  final bool showDriverMarkers;
  final bool showPickupMarkers;

  const MapWidget({
    super.key,
    this.showDriverMarkers = false,
    this.showPickupMarkers = false,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final MapController _mapController = MapController();
  LatLng _currentPosition = const LatLng(14.5995, 120.9842); // Manila default
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoading = false);
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoading = false);
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      // Move map to current location
      _mapController.move(_currentPosition, 15.0);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    // Current location marker
    markers.add(
      Marker(
        point: _currentPosition,
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 20),
        ),
      ),
    );

    // Add driver markers if needed (for rider view)
    if (widget.showDriverMarkers) {
      // Sample nearby drivers
      markers.addAll([
        _buildDriverMarker(
          LatLng(
            _currentPosition.latitude + 0.005,
            _currentPosition.longitude + 0.005,
          ),
        ),
        _buildDriverMarker(
          LatLng(
            _currentPosition.latitude - 0.003,
            _currentPosition.longitude + 0.007,
          ),
        ),
        _buildDriverMarker(
          LatLng(
            _currentPosition.latitude + 0.008,
            _currentPosition.longitude - 0.004,
          ),
        ),
      ]);
    }

    // Add pickup markers if needed (for driver view)
    if (widget.showPickupMarkers) {
      // Sample pickup locations
      markers.addAll([
        _buildPickupMarker(
          LatLng(
            _currentPosition.latitude + 0.01,
            _currentPosition.longitude + 0.01,
          ),
        ),
        _buildPickupMarker(
          LatLng(
            _currentPosition.latitude - 0.008,
            _currentPosition.longitude + 0.012,
          ),
        ),
      ]);
    }

    return markers;
  }

  Marker _buildDriverMarker(LatLng position) {
    return Marker(
      point: position,
      width: 35,
      height: 35,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(Icons.directions_car, color: Colors.white, size: 18),
      ),
    );
  }

  Marker _buildPickupMarker(LatLng position) {
    return Marker(
      point: position,
      width: 35,
      height: 35,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.warning,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(
          Icons.person_pin_circle,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentPosition,
            initialZoom: 15.0,
            minZoom: 5.0,
            maxZoom: 18.0,
          ),
          children: [
            // OpenStreetMap tile layer
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.rideease1',
              maxZoom: 19,
            ),
            // Markers layer
            MarkerLayer(markers: _buildMarkers()),
          ],
        ),

        // Loading indicator
        if (_isLoading)
          Container(
            color: Colors.white.withOpacity(0.8),
            child: const Center(child: CircularProgressIndicator()),
          ),

        // Recenter button
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            onPressed: () {
              _mapController.move(_currentPosition, 15.0);
            },
            child: const Icon(Icons.my_location, color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
