import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/car_service.dart';
import '../../services/user_service.dart';
import '../../widgets/app_drawer.dart';
import '../cars/register_car_screen.dart';

import '../cars/my_registered_cars_screen.dart';

class UserDashboardScreen extends StatelessWidget {
  const UserDashboardScreen({super.key});

  void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title page ekhono baanai nai')),
    );
  }

  Widget _buildProfileCard() {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: UserService().getCurrentUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data?.data() ?? {};
        final name = data['name'] ?? 'User';
        final email = data['email'] ?? '';
        final phone = data['phone'] ?? '';
        final profileImage = data['profileImage'] ?? '';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF171717),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD4AF37)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: const Color(0xFFD4AF37),
                backgroundImage: profileImage.toString().isNotEmpty
                    ? NetworkImage(profileImage)
                    : null,
                child: profileImage.toString().isEmpty
                    ? const Icon(Icons.person, color: Colors.black, size: 34)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(email),
                    const SizedBox(height: 3),
                    Text(phone),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRegisteredCarsPreview() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: CarService().getMyCars(limit: 3),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF171717),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD4AF37)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Registered Cars Preview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyRegisteredCarsScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'View All',
                      style: TextStyle(color: Color(0xFFD4AF37)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (docs.isEmpty)
                const Text('No registered cars yet')
              else
                Column(
                  children: docs.map((doc) {
                    final car = doc.data();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFD4AF37)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: car['imageUrl'] != null &&
                                car['imageUrl'].toString().isNotEmpty
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                car['imageUrl'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.directions_car,
                                    color: Colors.black,
                                  );
                                },
                              ),
                            )
                                : const Icon(
                              Icons.directions_car,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${car['brand']} ${car['model']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('${car['year']} • ${car['type']}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _actionButton(
      BuildContext context, {
        required String title,
        required IconData icon,
      }) {
    return Expanded(
      child: InkWell(
        onTap: () => _showComingSoon(context, title),
        child: Container(
          height: 95,
          decoration: BoxDecoration(
            color: const Color(0xFF171717),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD4AF37)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFFD4AF37), size: 30),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileCard(),
            const SizedBox(height: 16),
            _buildRegisteredCarsPreview(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegisterCarScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Register Car'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _actionButton(
                  context,
                  title: 'Buy Cars',
                  icon: Icons.shopping_bag,
                ),
                const SizedBox(width: 12),
                _actionButton(
                  context,
                  title: 'Sell Your Car',
                  icon: Icons.sell,
                ),
                const SizedBox(width: 12),
                _actionButton(
                  context,
                  title: 'Rent Cars',
                  icon: Icons.car_rental,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}