// screens/admin/ride_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rideease1/models/ride.dart';
import 'package:rideease1/providers/admin_provider.dart';

class RideManagementScreen extends StatefulWidget {
  const RideManagementScreen({super.key});

  @override
  State<RideManagementScreen> createState() => _RideManagementScreenState();
}

class _RideManagementScreenState extends State<RideManagementScreen> {
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadRides();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ride Management'), centerTitle: true),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final map = {
      'all': 'All',
      'requested': 'Requested',
      'accepted': 'Accepted',
      'inProgress': 'In Progress',
      'completed': 'Completed',
      'cancelled': 'Cancelled',
    };

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: map.keys.map((key) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(map[key]!),
                selected: _filter == key,
                onSelected: (_) => setState(() => _filter = key),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildList() {
    return Consumer<AdminProvider>(
      builder: (context, admin, _) {
        if (admin.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        var rides = admin.rides;
        if (_filter != 'all') {
          rides = rides.where((r) => r.status.name == _filter).toList();
        }

        if (rides.isEmpty) {
          return const Center(child: Text('No rides found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rides.length,
          itemBuilder: (_, i) {
            final ride = rides[i];
            return Card(
              child: ListTile(
                title: Text('Ride ${ride.id.substring(0, 10)}...'),
                subtitle:
                    Text('${ride.pickupAddress} → ${ride.destinationAddress}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(ride.status.displayName),
                    Text('₱${ride.fare.toStringAsFixed(0)}'),
                  ],
                ),
                onTap: () => _showRideDetails(ride),
              ),
            );
          },
        );
      },
    );
  }

  void _showRideDetails(Ride ride) {
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ride Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row('Status', ride.status.displayName),
              _row('Rider', ride.riderName),
              _row('From', ride.pickupAddress),
              _row('To', ride.destinationAddress),
              _row('Fare', '₱${ride.fare.toStringAsFixed(2)}'),
              if (ride.status != RideStatus.completed &&
                  ride.status != RideStatus.cancelled) ...[
                const Divider(),
                TextField(
                  controller: reasonCtrl,
                  decoration: const InputDecoration(labelText: 'Cancel reason'),
                  maxLines: 3,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          if (ride.status != RideStatus.completed &&
              ride.status != RideStatus.cancelled)
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(ctx);
                final reason = reasonCtrl.text.trim().isEmpty
                    ? 'Admin cancel'
                    : reasonCtrl.text;
                final ok = await context
                    .read<AdminProvider>()
                    .cancelRide(ride.id, reason);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Cancelled' : 'Failed')),
                );
              },
              child: const Text('Cancel Ride'),
            ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 100,
              child: Text('$label:',
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
