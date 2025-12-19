// lib/screens/driver/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rideease1/core/constants/colors.dart';
import 'package:rideease1/core/widgets/custom_button.dart';
import 'package:rideease1/providers/auth_provider.dart';
import 'package:rideease1/screens/driver/edit_profile_screen.dart';
import 'package:rideease1/screens/driver/vehicle_documents_screen.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  void _handleEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DriverEditProfileScreen()),
    );
  }

  void _handleVehicleDocuments() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VehicleDocumentsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Driver Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Profile Photo
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: user?.profileImageUrl != null
                      ? NetworkImage(user!.profileImageUrl!)
                      : null,
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  child: user?.profileImageUrl == null
                      ? const Icon(Icons.person,
                          size: 64, color: AppColors.primary)
                      : null,
                ),
              ),
              const SizedBox(height: 24),

              // Name
              Text(
                '${user?.firstName ?? 'John'} ${user?.lastName ?? 'Doe'}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // Email
              Text(
                user?.email ?? 'driver@example.com',
                style: const TextStyle(
                    fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),

              // Phone
              Text(
                user?.phone ?? '+63 912 345 6789',
                style: const TextStyle(
                    fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Vehicle Info
              Container(
                padding: const EdgeInsets.all(16),
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
                    const Text(
                      'Vehicle Information',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.directions_car, 'Model',
                        user?.vehicleModel ?? 'Toyota Vios 2023'),
                    _buildInfoRow(Icons.confirmation_number, 'License Plate',
                        user?.licensePlate ?? 'ABC-123'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Buttons - Adjusted spacing to prevent overlap
              CustomButton(
                text: 'Edit Profile',
                onPressed: _handleEditProfile,
              ),
              const SizedBox(height: 16), // Increased spacing

              CustomButton(
                text: 'Vehicle Documents',
                onPressed: _handleVehicleDocuments,
                backgroundColor: AppColors.secondary,
              ),
              const SizedBox(height: 16), // Increased spacing

              OutlinedButton.icon(
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/welcome', (route) => false);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(
                  height:
                      32), // Extra bottom padding to avoid overlap with nav bar if any
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
