// providers/notification_provider.dart
import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Load notifications for a user
  Future<void> loadNotifications(String userId) async {
    if (userId.isEmpty) return;

    _setLoading(true);
    _error = null;

    try {
      final fetched = await _notificationService.getNotifications(userId);
      _notifications = fetched
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      _error = 'Failed to load notifications';
      debugPrint('NotificationProvider Error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Mark single notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;

    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();

    try {
      await _notificationService.markAsRead(notificationId);
    } catch (e) {
      debugPrint('Failed to mark notification as read: $e');
      // Optionally revert UI change
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final unreadIds = _notifications
        .where((n) => !n.isRead)
        .map((n) => n.id)
        .toList();
    if (unreadIds.isEmpty) return;

    _notifications = _notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    notifyListeners();

    try {
      await _notificationService.markAllAsRead(unreadIds);
    } catch (e) {
      debugPrint('Failed to mark all as read: $e');
    }
  }

  /// Add a new notification (e.g., from FCM)
  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  /// Clear all notifications (for logout)
  void clear() {
    _notifications.clear();
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
