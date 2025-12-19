// app.dart or wherever your main routing lives
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rideease1/providers/auth_provider.dart';
import 'package:rideease1/screens/auth/welcome_screen.dart';
import 'package:rideease1/screens/rider/home_screen.dart';
import 'package:rideease1/screens/driver/home_screen.dart';
import 'package:rideease1/screens/admin/admin_dashboard_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading while checking auth state
        if (authProvider.isLoading) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF00C853)),
                    SizedBox(height: 24),
                    Text(
                      'Loading RideEase...',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Not logged in
        if (!authProvider.isAuthenticated || authProvider.user == null) {
          return const WelcomeScreen();
        }

        final user = authProvider.user!;

        // Admin
        if (user.isAdmin == true) {
          return const AdminDashboardScreen();
        }

        // Driver
        if (user.isDriver == true) {
          return const DriverHomeScreen();
        }

        // Rider (default)
        return const RiderHomeScreen();
      },
    );
  }
}
