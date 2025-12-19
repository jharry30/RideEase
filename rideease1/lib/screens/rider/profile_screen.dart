// screens/rider/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rideease1/core/constants/colors.dart';
import 'package:rideease1/core/widgets/custom_button.dart';
import 'package:rideease1/providers/auth_provider.dart';
import 'package:rideease1/screens/rider/edit_profile_screen.dart';

class RiderProfileScreen extends StatelessWidget {
  const RiderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Profile'),
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
              CircleAvatar(
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
              const SizedBox(height: 20),

              // Name
              Text(
                user?.name ?? 'Guest User',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // Email
              Text(
                user?.email ?? 'Not logged in',
                style: const TextStyle(
                    fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),

              // Phone
              if (user?.phone.isNotEmpty == true)
                Text(
                  user!.phone,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),

              const SizedBox(height: 40),

              // Edit Profile Button
              CustomButton(
                text: 'Edit Profile',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const RiderEditProfileScreen()),
                  );
                },
                width: double.infinity,
              ),
              const SizedBox(height: 12),

              // Logout Button
              OutlinedButton.icon(
                onPressed: () async {
                  await Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  ).logout();
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/welcome', (route) => false);
                },
                icon: Icon(Icons.logout, color: Colors.red[700]),
                label: Text(
                  'Log Out',
                  style: TextStyle(color: Colors.red[700]),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red[200]!),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
