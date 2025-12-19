// providers/admin_provider.dart
import 'package:flutter/foundation.dart';
import '../models/admin_stats.dart';
import '../models/user.dart';
import '../models/ride.dart';
import '../models/support_ticket.dart';
import '../models/dispute.dart';
import '../models/promo_code.dart';
import '../models/announcement.dart';
import '../services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();

  AdminStats? _dashboardStats;
  List<User> _users = [];
  List<User> _pendingDrivers = [];
  List<Ride> _rides = [];
  List<Dispute> _disputes = [];
  List<SupportTicket> _tickets = [];
  List<PromoCode> _promoCodes = [];
  List<Announcement> _announcements = [];

  bool _isLoading = false;
  String? _error;

  // Getters
  AdminStats? get dashboardStats => _dashboardStats;
  List<User> get users => _users;
  List<User> get pendingDrivers => _pendingDrivers;
  List<Ride> get rides => _rides;
  List<Dispute> get disputes => _disputes;
  List<SupportTicket> get tickets => _tickets;
  List<PromoCode> get promoCodes => _promoCodes;
  List<Announcement> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Dashboard
  Future<void> loadDashboardStats() async {
    _setLoading(true);
    _error = null;
    try {
      _dashboardStats = await _adminService.getDashboardStats();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load dashboard stats';
      debugPrint(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // User Management
  Future<void> loadUsers({String? searchQuery, String? userType}) async {
    _setLoading(true);
    _error = null;
    try {
      _users = await _adminService.getAllUsers(
        searchQuery: searchQuery,
        userType: userType,
      );
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load users';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> suspendUser(String userId) async {
    try {
      await _adminService.suspendUser(userId);
      await loadUsers(); // Refresh list
      return true;
    } catch (e) {
      _error = 'Failed to suspend user';
      return false;
    }
  }

  Future<bool> activateUser(String userId) async {
    try {
      await _adminService.activateUser(userId);
      await loadUsers();
      return true;
    } catch (e) {
      _error = 'Failed to activate user';
      return false;
    }
  }

  // Driver Verification
  Future<void> loadPendingDrivers() async {
    _setLoading(true);
    _error = null;
    try {
      _pendingDrivers = await _adminService.getPendingDriverVerifications();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load pending drivers';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> approveDriver(String driverId, String notes) async {
    try {
      await _adminService.approveDriver(driverId, notes);
      await loadPendingDrivers();
      await loadDashboardStats();
      return true;
    } catch (e) {
      _error = 'Failed to approve driver';
      return false;
    }
  }

  Future<bool> rejectDriver(String driverId, String reason) async {
    try {
      await _adminService.rejectDriver(driverId, reason);
      await loadPendingDrivers();
      await loadDashboardStats();
      return true;
    } catch (e) {
      _error = 'Failed to reject driver';
      return false;
    }
  }

  // Ride Management
  Future<void> loadRides() async {
    _setLoading(true);
    _error = null;
    try {
      _rides = await _adminService.getRecentRides();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load rides';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> cancelRide(String rideId, String reason) async {
    try {
      await _adminService.cancelRide(rideId, reason);
      await loadRides();
      return true;
    } catch (e) {
      _error = 'Failed to cancel ride';
      return false;
    }
  }

  // Disputes
  Future<void> loadDisputes() async {
    _setLoading(true);
    _error = null;
    try {
      _disputes = await _adminService.getDisputes();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load disputes';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resolveDispute(String disputeId, String resolution) async {
    try {
      await _adminService.resolveDispute(disputeId, resolution);
      await loadDisputes();
      await loadDashboardStats();
      return true;
    } catch (e) {
      _error = 'Failed to resolve dispute';
      return false;
    }
  }

  // Support Tickets
  Future<void> loadTickets({TicketStatus? status}) async {
    _setLoading(true);
    _error = null;
    try {
      _tickets = await _adminService.getSupportTickets();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load tickets';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resolveTicket(String ticketId, String resolution) async {
    try {
      await _adminService.resolveTicket(ticketId, resolution);
      await loadTickets();
      await loadDashboardStats();
      return true;
    } catch (e) {
      _error = 'Failed to resolve ticket';
      return false;
    }
  }

  Future<bool> addTicketMessage(String ticketId, String message) async {
    try {
      await _adminService.addTicketMessage(ticketId, message);
      await loadTickets();
      return true;
    } catch (e) {
      _error = 'Failed to send message';
      return false;
    }
  }

  // Promo Codes
  Future<void> loadPromoCodes() async {
    _setLoading(true);
    _error = null;
    try {
      _promoCodes = await _adminService.getPromoCodes();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load promo codes';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createPromoCode(PromoCode promoCode) async {
    try {
      await _adminService.createPromoCode(promoCode);
      await loadPromoCodes();
      return true;
    } catch (e) {
      _error = 'Failed to create promo';
      return false;
    }
  }

  Future<bool> deactivatePromoCode(String promoId) async {
    try {
      await _adminService.deactivatePromoCode(promoId);
      await loadPromoCodes();
      return true;
    } catch (e) {
      _error = 'Failed to deactivate promo';
      return false;
    }
  }

  // Announcements
  Future<void> loadAnnouncements() async {
    _setLoading(true);
    _error = null;
    try {
      _announcements = await _adminService.getAnnouncements();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load announcements';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createAnnouncement(Announcement announcement) async {
    try {
      await _adminService.createAnnouncement(announcement);
      await loadAnnouncements();
      return true;
    } catch (e) {
      _error = 'Failed to create announcement';
      return false;
    }
  }

  Future<bool> deleteAnnouncement(String announcementId) async {
    try {
      await _adminService.deleteAnnouncement(announcementId);
      await loadAnnouncements();
      return true;
    } catch (e) {
      _error = 'Failed to delete announcement';
      return false;
    }
  }

  // Helper
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clear() {
    _dashboardStats = null;
    _users.clear();
    _pendingDrivers.clear();
    _rides.clear();
    _disputes.clear();
    _tickets.clear();
    _promoCodes.clear();
    _announcements.clear();
    _error = null;
    notifyListeners();
  }
}
