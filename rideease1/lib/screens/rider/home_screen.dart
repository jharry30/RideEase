import 'package:flutter/material.dart';
import 'package:rideease1/core/widgets/bottom_nav_bar.dart';
import 'package:rideease1/core/widgets/map_widget.dart';
import 'package:rideease1/screens/rider/search_screen.dart';
import 'package:rideease1/screens/rider/wallet_screen.dart';
import 'package:rideease1/screens/rider/profile_screen.dart';
import 'package:rideease1/screens/rider/trips_screen.dart';
import 'package:rideease1/screens/common/notification_screen.dart';

class RiderHomeScreen extends StatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  State<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen> {
  int _currentIndex = 0;

  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RiderProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RideEase'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _navigateToNotifications,
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _navigateToProfile,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Home tab content with map
          Stack(
            children: [
              // Map showing current location and nearby drivers
              const MapWidget(showDriverMarkers: true),

              // Search bar overlay
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Where to?',
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SearchScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Trips tab content
          const RiderTripsScreen(),

          // Wallet tab content
          const RiderWalletScreen(),

          // Notifications tab content
          const NotificationsScreen(),

          // Profile tab content
          const RiderProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
