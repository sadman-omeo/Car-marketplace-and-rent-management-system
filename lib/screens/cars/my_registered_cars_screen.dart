import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/car_service.dart';

class MyRegisteredCarsScreen extends StatelessWidget {
  const MyRegisteredCarsScreen({super.key});

  Widget _buildCarImage(Map<String, dynamic> car) {
    try {
      final String base64String = car['imageBase64'] ?? '';

      if (base64String.isNotEmpty) {
        Uint8List imageBytes = base64Decode(base64String);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            imageBytes,
            fit: BoxFit.cover,
            width: 70,
            height: 70,
          ),
        );
      }
    } catch (_) {}

    return const Icon(
      Icons.directions_car,
      color: Colors.black,
    );
  }

  Future<void> _deleteCar(BuildContext context, String carId) async {
    try {
      await CarService().deleteRegisteredCar(carId);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Car deleted successfully')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete car')),
      );
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, String carId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF171717),
          title: const Text('Delete Car'),
          content: const Text('Are you sure you want to delete this car?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFFD4AF37)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _deleteCar(context, carId);
    }
  }

  Future<String?> _showPriceDialog({
    required BuildContext context,
    required String title,
    required String label,
    String initialValue = '',
  }) async {
    final controller = TextEditingController(text: initialValue);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF171717),
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: label),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFFD4AF37)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text(
                'Save',
                style: TextStyle(color: Color(0xFFD4AF37)),
              ),
            ),
          ],
        );
      },
    );

    return result;
  }

  Future<void> _toggleSell({
    required BuildContext context,
    required String carId,
    required bool newValue,
    required String currentPrice,
  }) async {
    try {
      if (newValue) {
        final price = await _showPriceDialog(
          context: context,
          title: 'Set Sale Price',
          label: 'Sale Price',
          initialValue: currentPrice,
        );

        if (price == null || price.isEmpty) return;

        await CarService().updateSellStatus(
          carId: carId,
          isForSale: true,
          salePrice: price,
        );
      } else {
        await CarService().updateSellStatus(
          carId: carId,
          isForSale: false,
          salePrice: '',
        );
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sell status updated')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update sell status')),
      );
    }
  }

  Future<void> _toggleRent({
    required BuildContext context,
    required String carId,
    required bool newValue,
    required String currentPrice,
  }) async {
    try {
      if (newValue) {
        final price = await _showPriceDialog(
          context: context,
          title: 'Set Rent Price',
          label: 'Rent Price Per Day',
          initialValue: currentPrice,
        );

        if (price == null || price.isEmpty) return;

        await CarService().updateRentStatus(
          carId: carId,
          isForRent: true,
          rentPricePerDay: price,
        );
      } else {
        await CarService().updateRentStatus(
          carId: carId,
          isForRent: false,
          rentPricePerDay: '',
        );
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rent status updated')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update rent status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Registered Cars'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: CarService().getAllMyCars(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return const Center(
                child: Text('No registered cars found'),
              );
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final car = doc.data();

                final bool isForSale = car['isForSale'] ?? false;
                final bool isForRent = car['isForRent'] ?? false;
                final String salePrice = car['salePrice'] ?? '';
                final String rentPricePerDay = car['rentPricePerDay'] ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF171717),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD4AF37)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _buildCarImage(car),
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
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('Year: ${car['year']}'),
                                Text('Type: ${car['type']}'),
                                Text('Reg No: ${car['registrationNumber']}'),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _showDeleteDialog(context, doc.id);
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Put this car for Sale',
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Switch(
                                  value: isForSale,
                                  activeColor: const Color(0xFFD4AF37),
                                  onChanged: (value) {
                                    _toggleSell(
                                      context: context,
                                      carId: doc.id,
                                      newValue: value,
                                      currentPrice: salePrice,
                                    );
                                  },
                                ),
                              ],
                            ),
                            if (isForSale)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Sale Price: $salePrice'),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Put this car for Rent',
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Switch(
                                  value: isForRent,
                                  activeColor: const Color(0xFFD4AF37),
                                  onChanged: (value) {
                                    _toggleRent(
                                      context: context,
                                      carId: doc.id,
                                      newValue: value,
                                      currentPrice: rentPricePerDay,
                                    );
                                  },
                                ),
                              ],
                            ),
                            if (isForRent)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Rent Per Day: $rentPricePerDay'),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}