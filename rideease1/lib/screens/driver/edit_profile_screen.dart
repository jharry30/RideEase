// screens/driver/edit_profile_screen.dart
import 'dart:io' show File; // Only import File on mobile

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rideease1/core/constants/colors.dart';
import 'package:rideease1/core/widgets/custom_button.dart';
import 'package:rideease1/core/widgets/custom_text_field.dart';
import 'package:rideease1/providers/auth_provider.dart';

class DriverEditProfileScreen extends StatefulWidget {
  const DriverEditProfileScreen({super.key});

  @override
  State<DriverEditProfileScreen> createState() =>
      _DriverEditProfileScreenState();
}

class _DriverEditProfileScreenState extends State<DriverEditProfileScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _vehicleModelController;
  late final TextEditingController _licensePlateController;

  bool _isLoading = false;
  XFile? _pickedImage; // Use XFile instead of File

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _vehicleModelController =
        TextEditingController(text: user?.vehicleModel ?? '');
    _licensePlateController =
        TextEditingController(text: user?.licensePlate ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _vehicleModelController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() {
        _pickedImage = picked;
      });
    }
  }

  Future<String?> _uploadImage(String userId) async {
    if (_pickedImage == null) return null;

    try {
      final storage = FirebaseStorage.instance;
      final ref = storage.ref().child('profile_images/$userId.jpg');

      UploadTask uploadTask;

      if (kIsWeb) {
        final bytes = await _pickedImage!.readAsBytes();
        uploadTask =
            ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        uploadTask = ref.putFile(File(_pickedImage!.path));
      }

      final snapshot = await uploadTask.whenComplete(() => null);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      _showSnackBar('Image upload failed: $e', isError: true);
      return null;
    }
  }

  Future<void> _handleSaveProfile() async {
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        !_emailController.text.trim().contains('@') ||
        _vehicleModelController.text.trim().isEmpty ||
        _licensePlateController.text.trim().isEmpty) {
      _showSnackBar('Please fill all required fields', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final imageUrl = await _uploadImage(authProvider.user!.id);

      final success = await authProvider.updateUser(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        vehicleModel: _vehicleModelController.text.trim(),
        licensePlate: _licensePlateController.text.trim().toUpperCase(),
        profileImageUrl: imageUrl,
      );

      if (!success) {
        _showSnackBar(authProvider.error ?? 'Update failed', isError: true);
        return;
      }

      _showSnackBar('Profile updated successfully!', isError: false);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Edit Driver Profile'),
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
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _pickedImage != null
                          ? (kIsWeb
                              ? NetworkImage(_pickedImage!.path)
                              : FileImage(File(_pickedImage!.path))
                                  as ImageProvider)
                          : user?.profileImageUrl != null
                              ? NetworkImage(user!.profileImageUrl!)
                              : null,
                      child:
                          _pickedImage == null && user?.profileImageUrl == null
                              ? const Icon(Icons.person,
                                  size: 60, color: AppColors.primary)
                              : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              _buildLabel('First Name'),
              CustomTextField(
                  controller: _firstNameController,
                  hintText: 'First name',
                  prefixIcon: Icons.person_outline),
              const SizedBox(height: 20),
              _buildLabel('Last Name'),
              CustomTextField(
                  controller: _lastNameController,
                  hintText: 'Last name',
                  prefixIcon: Icons.person_outline),
              const SizedBox(height: 20),
              _buildLabel('Email'),
              CustomTextField(
                  controller: _emailController,
                  hintText: 'you@example.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              _buildLabel('Phone'),
              CustomTextField(
                  controller: _phoneController,
                  hintText: '+63 9XX XXX XXXX',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 30),
              const Text('Vehicle Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildLabel('Vehicle Model'),
              CustomTextField(
                  controller: _vehicleModelController,
                  hintText: 'e.g. Toyota Vios 2023',
                  prefixIcon: Icons.directions_car),
              const SizedBox(height: 20),
              _buildLabel('License Plate'),
              CustomTextField(
                  controller: _licensePlateController,
                  hintText: 'ABC-1234',
                  prefixIcon: Icons.confirmation_number_outlined),
              const SizedBox(height: 40),

              _isLoading
                  ? const CircularProgressIndicator()
                  : CustomButton(
                      text: 'Save Changes', onPressed: _handleSaveProfile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      );
}
