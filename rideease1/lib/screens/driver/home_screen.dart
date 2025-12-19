// screens/driver/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rideease1/core/constants/colors.dart';
import 'package:rideease1/core/widgets/bottom_nav_bar.dart';
import 'package:rideease1/core/widgets/map_widget.dart';
import 'package:rideease1/models/ride.dart';
import 'package:rideease1/providers/ride_provider.dart';
import 'package:rideease1/providers/auth_provider.dart';
import 'package:rideease1/screens/common/notification_screen.dart';
import 'package:rideease1/screens/driver/earnings_screen.dart';
import 'package:rideease1/screens/driver/profile_screen.dart';
import 'package:rideease1/screens/driver/active_trip_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Safe: wait for first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RideProvider>().startListeningForRides();
    });
  }

  @override
  void dispose() {
    context.read<RideProvider>().stopListeningForRides();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Now rideProvider is available inside Consumer
    return Consumer<RideProvider>(
      builder: (context, rideProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Driver Dashboard'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen()),
                ),
              ),
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: [
              // Home Tab — Map + Real-time Request
              Stack(
                children: [
                  const MapWidget(),
                  if (rideProvider.availableRides.isNotEmpty &&
                      rideProvider.activeRide == null)
                    _buildRideRequestCard(
                        rideProvider.availableRides.first, rideProvider),
                ],
              ),

              // Active Trip Tab
              rideProvider.activeRide != null
                  ? ActiveTripScreen(ride: rideProvider.activeRide!)
                  : const Center(child: Text('No active trip')),

              // Earnings
              const DriverEarningsScreen(),

              // Notifications
              const NotificationsScreen(),

              // Profile
              const DriverProfileScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
          ),
        );
      },
    );
  }

  // Fixed: rideProvider is now passed as parameter
  Widget _buildRideRequestCard(Ride ride, RideProvider rideProvider) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'New Ride Request!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _infoRow(Icons.location_on, ride.pickupAddress),
            const SizedBox(height: 8),
            _infoRow(Icons.flag, ride.destinationAddress),
            const SizedBox(height: 8),
            _infoRow(Icons.attach_money, '₱${ride.fare.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style:
                        OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () {
                      rideProvider.updateRideStatus(
                          ride.id, RideStatus.cancelled);
                    },
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary),
                    onPressed: () {
                      final driverId = context.read<AuthProvider>().user!.id;
                      rideProvider.acceptRide(ride.id, driverId);
                      setState(
                          () => _currentIndex = 1); // Go to Active Trip tab
                    },
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
