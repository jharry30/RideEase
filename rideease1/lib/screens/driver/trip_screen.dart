// screens/driver/trip_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rideease1/core/constants/colors.dart';
import 'package:rideease1/core/widgets/custom_button.dart';
import 'package:rideease1/models/ride.dart';
import 'package:rideease1/providers/ride_provider.dart';

class TripScreen extends StatelessWidget {
  const TripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RideProvider>(
      builder: (context, rideProvider, child) {
        final ride = rideProvider.activeRide;

        if (ride == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Current Trip')),
            body: const Center(
              child: Text(
                'No active trip',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('Current Trip'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black87,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: ride.status.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    ride.status.displayName,
                    style: TextStyle(
                      color: ride.status.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Pickup Location
                _buildLocationCard(
                  title: 'Pickup Location',
                  address: ride.pickupAddress,
                  icon: Icons.circle,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),

                // Destination
                _buildLocationCard(
                  title: 'Drop-off Location',
                  address: ride.destinationAddress,
                  icon: Icons.location_on,
                  color: AppColors.secondary,
                ),
                const SizedBox(height: 30),

                // Passenger Info Card
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        // Passenger Photo
                        CircleAvatar(
                          radius: 34,
                          backgroundImage: ride.riderPhotoUrl != null &&
                                  ride.riderPhotoUrl!.isNotEmpty
                              ? NetworkImage(ride.riderPhotoUrl!)
                              : null,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: ride.riderPhotoUrl == null ||
                                  ride.riderPhotoUrl!.isEmpty
                              ? const Icon(Icons.person,
                                  size: 40, color: AppColors.primary)
                              : null,
                        ),
                        const SizedBox(width: 16),

                        // Name + Name + Rating
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ride.riderName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${ride.riderRating.toStringAsFixed(1)} stars • ${ride.riderTotalRides} rides',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Call & Message Buttons
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.phone,
                                  color: AppColors.primary, size: 28),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Calling passenger...')),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.message_outlined,
                                  color: AppColors.primary, size: 28),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Opening chat...')),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Action Button
                CustomButton(
                  text: ride.status == RideStatus.accepted
                      ? 'Start Trip'
                      : ride.status == RideStatus.inProgress
                          ? 'Complete Trip'
                          : 'Trip Ended',
                  onPressed: ride.status == RideStatus.completed ||
                          ride.status == RideStatus.cancelled
                      ? null
                      : () async {
                          final newStatus = ride.status == RideStatus.accepted
                              ? RideStatus.inProgress
                              : RideStatus.completed;

                          final success = await rideProvider.updateRideStatus(
                              ride.id, newStatus);

                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Trip is now ${newStatus.displayName.toLowerCase()}'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            if (newStatus == RideStatus.completed) {
                              Navigator.pop(context);
                            }
                          }
                        },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationCard({
    required String title,
    required String address,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(address,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
