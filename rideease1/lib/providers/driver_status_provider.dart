// providers/driver_status_provider.dart
import 'package:flutter/foundation.dart';

class DriverStatusProvider with ChangeNotifier {
  bool _isOnline = false; // Start offline by default

  bool get isOnline => _isOnline;

  void toggleOnlineStatus() {
    _isOnline = !_isOnline;
    notifyListeners();
  }

  void setOnline(bool value) {
    if (_isOnline != value) {
      _isOnline = value;
      notifyListeners();
    }
  }

  void goOnline() => setOnline(true);
  void goOffline() => setOnline(false);
}
