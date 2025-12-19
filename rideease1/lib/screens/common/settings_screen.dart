// screens/common/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:rideease1/core/constants/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class CommonSettingsScreen extends StatelessWidget {
  const CommonSettingsScreen({super.key});

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeader('Preferences'),
          _buildSettingsItem(
            context,
            title: 'Language',
            icon: Icons.language,
            subtitle: 'English (US)',
            onTap: () =>
                _showSnackBar(context, 'Language settings coming soon'),
          ),
          _buildSettingsItem(
            context,
            title: 'Notifications',
            icon: Icons.notifications_outlined,
            trailing: Switch(value: true, onChanged: (_) {}),
          ),
          _buildSettingsItem(
            context,
            title: 'Dark Mode',
            icon: Icons.dark_mode_outlined,
            trailing: Switch(value: false, onChanged: (_) {}),
          ),
          const SizedBox(height: 24),
          _buildHeader('Legal'),
          _buildSettingsItem(
            context,
            title: 'Privacy Policy',
            icon: Icons.privacy_tip_outlined,
            onTap: () => _launchURL('https://rideease.ph/privacy'),
          ),
          _buildSettingsItem(
            context,
            title: 'Terms of Service',
            icon: Icons.description_outlined,
            onTap: () => _launchURL('https://rideease.ph/terms'),
          ),
          _buildSettingsItem(
            context,
            title: 'About RideEase',
            icon: Icons.info_outline,
            onTap: () => _showSnackBar(
                context, 'RideEase v1.0.0 • Made with love in PH'),
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'RideEase © 2025',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
