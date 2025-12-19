import 'package:flutter/material.dart';
import 'package:rideease1/core/constants/colors.dart';

class DriverSettingsScreen extends StatelessWidget {
  const DriverSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          const Text(
            'Account',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildSettingsItem(context, 'Edit Profile', Icons.person, () {
            // Navigate to profile edit
          }),
          _buildSettingsItem(context, 'Change Password', Icons.lock, () {
            // Change password
          }),
          const SizedBox(height: 20),
          const Text(
            'Preferences',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildSettingsItem(
            context,
            'Vehicle Settings',
            Icons.directions_car,
            () {
              // Vehicle settings
            },
          ),
          _buildSettingsItem(context, 'Payment Methods', Icons.credit_card, () {
            // Payment methods
          }),
          const SizedBox(height: 20),
          _buildSettingsItem(context, 'Help & Support', Icons.help, () {
            // Help center
          }),
          _buildSettingsItem(context, 'Log Out', Icons.logout, () {
            // Log out
          }),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
