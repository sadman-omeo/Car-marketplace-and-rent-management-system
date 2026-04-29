import 'package:flutter/material.dart';

import '../screens/cars/register_car_screen.dart';
import '../services/auth_service.dart';
import '../screens/cars/my_registered_cars_screen.dart';


import '../screens/cars/buy_cars_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _showComingSoon(BuildContext context, String title) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title page ekhono korinai')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF0D0D0D),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.black),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Premium Car Hub',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: Color(0xFFD4AF37)),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car, color: Color(0xFFD4AF37)),
              title: const Text('My Registered Cars'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyRegisteredCarsScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.shopping_bag, color: Color(0xFFD4AF37)),
              title: const Text('Buy Cars'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BuyCarsScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.sell, color: Color(0xFFD4AF37)),
              title: const Text('Sell Your Car'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyRegisteredCarsScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.car_rental, color: Color(0xFFD4AF37)),
              title: const Text('Rent Cars'),
              onTap: () => _showComingSoon(context, 'Rent Cars'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFD4AF37)),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
                await AuthService().signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}