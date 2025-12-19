// screens/admin/driver_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rideease1/models/user.dart';
import 'package:rideease1/providers/admin_provider.dart';

class DriverVerificationScreen extends StatefulWidget {
  const DriverVerificationScreen({super.key});

  @override
  State<DriverVerificationScreen> createState() =>
      _DriverVerificationScreenState();
}

class _DriverVerificationScreenState extends State<DriverVerificationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminProvider>().loadPendingDrivers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Driver Verification'), centerTitle: true),
      body: Consumer<AdminProvider>(
        builder: (context, admin, _) {
          if (admin.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (admin.pendingDrivers.isEmpty) {
            return const Center(child: Text('No pending drivers'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: admin.pendingDrivers.length,
            itemBuilder: (_, i) {
              final driver = admin.pendingDrivers[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${driver.firstName} ${driver.lastName}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(driver.email),
                      Text(
                          'Vehicle: ${driver.vehicleModel} • ${driver.licensePlate}'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red),
                              onPressed: () => _reject(driver),
                              child: const Text('Reject'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              onPressed: () => _approve(driver),
                              child: const Text('Approve'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _approve(User driver) async {
    final success = await context
        .read<AdminProvider>()
        .approveDriver(driver.id, 'Verified manually');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(success ? 'Approved!' : 'Failed'),
          backgroundColor: success ? Colors.green : Colors.red),
    );
  }

  void _reject(User driver) async {
    final success = await context
        .read<AdminProvider>()
        .rejectDriver(driver.id, 'Documents incomplete');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(success ? 'Rejected' : 'Failed'),
          backgroundColor: success ? Colors.orange : Colors.red),
    );
  }
}
