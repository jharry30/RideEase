// screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rideease1/core/constants/colors.dart';
import 'package:rideease1/providers/admin_provider.dart';
import 'package:rideease1/providers/auth_provider.dart'; // Make sure this exists
import 'user_management_screen.dart';
import 'driver_verification_screen.dart';
import 'ride_management_screen.dart';
import 'support_tickets_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load stats after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/welcome', (route) => false);
            },
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          // Loading state
          if (adminProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          // Error state
          if (adminProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    adminProvider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => adminProvider.loadDashboardStats(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // No data
          final stats = adminProvider.dashboardStats;
          if (stats == null) {
            return const Center(child: Text('No dashboard data available'));
          }

          // Success: Show dashboard
          return RefreshIndicator(
            onRefresh: () => adminProvider.loadDashboardStats(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Welcome back, Admin!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Here\'s what\'s happening today',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 30),

                  // Stats Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4,
                    children: [
                      _buildStatCard(
                        title: 'Total Users',
                        value: stats.totalUsers.toString(),
                        icon: Icons.people,
                        color: AppColors.primary,
                      ),
                      _buildStatCard(
                        title: 'Active Rides',
                        value: stats.activeRides.toString(),
                        icon: Icons.directions_car,
                        color: Colors.green,
                      ),
                      _buildStatCard(
                        title: 'Today\'s Revenue',
                        value: '₱${stats.todayRevenue.toStringAsFixed(0)}',
                        icon: Icons.payments,
                        color: Colors.amber[700]!,
                      ),
                      _buildStatCard(
                        title: 'Pending Drivers',
                        value: stats.pendingVerifications.toString(),
                        icon: Icons.person_add,
                        color: Colors.orange,
                      ),
                      _buildStatCard(
                        title: 'Open Tickets',
                        value: stats.openTickets.toString(),
                        icon: Icons.support_agent,
                        color: Colors.blue,
                      ),
                      _buildStatCard(
                        title: 'Disputes',
                        value: stats.unresolvedDisputes.toString(),
                        icon: Icons.warning_amber,
                        color: Colors.red,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  _buildActionCard(
                    title: 'User Management',
                    icon: Icons.people_outline,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const UserManagementScreen())),
                  ),
                  _buildActionCard(
                    title: 'Driver Verification',
                    icon: Icons.verified_user,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DriverVerificationScreen())),
                  ),
                  _buildActionCard(
                    title: 'Ride Management',
                    icon: Icons.local_taxi,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RideManagementScreen())),
                  ),
                  _buildActionCard(
                    title: 'Support Tickets',
                    icon: Icons.headset_mic,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SupportTicketsScreen())),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Fixed: Proper stat card
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: color),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Fixed: Proper action card
  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
