import 'package:flutter/material.dart';
import 'package:rideease1/core/constants/colors.dart';
import 'package:rideease1/core/widgets/custom_button.dart';
import 'package:rideease1/screens/rider/ride_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _pickupController = TextEditingController();

  String _selectedRideType = 'Standard';
  String _selectedPrice = '\$12.50';
  String _selectedDuration = '15 min';

  @override
  void initState() {
    super.initState();
    _pickupController.text = 'Current Location';
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _pickupController.dispose();
    super.dispose();
  }

  void _selectRideType(String type, String price, String duration) {
    setState(() {
      _selectedRideType = type;
      _selectedPrice = price;
      _selectedDuration = duration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Ride'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pickup location
              Text(
                'Pickup Location',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _pickupController,
                  decoration: const InputDecoration(
                    hintText: 'Current Location',
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.my_location,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Destination
              Text(
                'Destination',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _destinationController,
                  decoration: const InputDecoration(
                    hintText: 'Where to?',
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.location_on,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Ride options
              Text(
                'Choose Your Ride',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              Expanded(
                child: ListView(
                  children: [
                    // Standard ride option
                    _buildRideOption(
                      'Standard',
                      'Economy car - up to 4 passengers',
                      '\$12.50',
                      '15 min',
                      '10.5 km',
                      Icons.directions_car,
                    ),
                    const SizedBox(height: 10),

                    // Premium ride option
                    _buildRideOption(
                      'Premium',
                      'Luxury car - up to 4 passengers',
                      '\$22.50',
                      '12 min',
                      '10.5 km',
                      Icons.star,
                    ),
                    const SizedBox(height: 10),

                    // SUV ride option
                    _buildRideOption(
                      'SUV',
                      'Spacious SUV - up to 6 passengers',
                      '\$28.50',
                      '14 min',
                      '10.5 km',
                      Icons.airport_shuttle,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Book ride button
              CustomButton(
                text: 'Book $_selectedRideType - $_selectedPrice',
                onPressed: () {
                  if (_destinationController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a destination'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RideDetailsScreen(
                        pickup: _pickupController.text,
                        destination: _destinationController.text,
                        rideType: _selectedRideType,
                        price: _selectedPrice,
                        duration: _selectedDuration,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRideOption(
    String type,
    String description,
    String price,
    String duration,
    String distance,
    IconData icon,
  ) {
    final isSelected = _selectedRideType == type;

    return GestureDetector(
      onTap: () => _selectRideType(type, price, duration),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.primary : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$duration • $distance',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.check_circle, color: AppColors.primary),
              ),
          ],
        ),
      ),
    );
  }
}
