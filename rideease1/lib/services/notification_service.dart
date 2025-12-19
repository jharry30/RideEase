// services/notification_service.dart
import '../models/notification.dart';

class NotificationService {
  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 600));

  Future<List<AppNotification>> getNotifications(String userId) async {
    await _delay();
    return [
      AppNotification(
        id: 'notif_001',
        title: 'Ride Completed',
        body: 'You arrived at NAIA Terminal 3. Thank you for riding!',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        isRead: true,
      ),
      AppNotification(
        id: 'notif_002',
        title: 'Driver On The Way',
        body: 'Kuya Rey is arriving in 3 minutes',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        isRead: false,
      ),
      AppNotification(
        id: 'notif_003',
        title: 'New Promo!',
        body: 'Get 20% off your next 3 rides with code: RIDENOW20',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
    ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> markAsRead(String id) async {
    await _delay();
    // In real app: Firestore update
  }

  Future<void> markAllAsRead(List<String> ids) async {
    await _delay();
  }
}
