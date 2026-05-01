import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/car_service.dart';

class AdminListingsScreen extends StatefulWidget {
  const AdminListingsScreen({super.key});

  @override
  State<AdminListingsScreen> createState() => _AdminListingsScreenState();
}

class _AdminListingsScreenState extends State<AdminListingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  bool _matchesSearch(Map<String, dynamic> car) {
    final query = searchText.trim().toLowerCase();
    if (query.isEmpty) return true;

    final brand = (car['brand'] ?? '').toString().toLowerCase();
    final model = (car['model'] ?? '').toString().toLowerCase();

    return brand.contains(query) || model.contains(query);
  }

  Future<void> _removeFromSale(BuildContext context, String carId) async {
    try {
      await CarService().adminRemoveFromSale(carId);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from sale')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update sale status')),
      );
    }
  }

  Future<void> _removeFromRent(BuildContext context, String carId) async {
    try {
      await CarService().adminRemoveFromRent(carId);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from rent')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update rent status')),
      );
    }
  }

  Future<void> _deleteCar(BuildContext context, String carId) async {
    try {
      await CarService().deleteRegisteredCar(carId);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing deleted successfully')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete listing')),
      );
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, String carId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF171717),
          title: const Text('Delete Listing'),
          content: const Text('Are you sure you want to delete this listing?'),
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

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Listings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Search by brand or model',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: CarService().getAllRegisteredCarsForAdmin(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs.toList() ?? [];
                  final filteredDocs = docs.where((doc) {
                    return _matchesSearch(doc.data());
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return const Center(
                      child: Text('No listings found'),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final car = doc.data();

                      final bool isForSale = car['isForSale'] ?? false;
                      final bool isForRent = car['isForRent'] ?? false;
                      final String salePrice = (car['salePrice'] ?? '').toString();
                      final String rentPricePerDay =
                      (car['rentPricePerDay'] ?? '').toString();

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
                                      Text('Owner ID: ${car['ownerId']}'),
                                      if (isForSale)
                                        Text(
                                          'Sale Price: $salePrice',
                                          style: const TextStyle(
                                            color: Color(0xFFD4AF37),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      if (isForRent)
                                        Text(
                                          'Rent Per Day: $rentPricePerDay',
                                          style: const TextStyle(
                                            color: Color(0xFFD4AF37),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                if (isForSale)
                                  _statusChip('For Sale', Colors.green),
                                if (isForSale && isForRent)
                                  const SizedBox(width: 8),
                                if (isForRent)
                                  _statusChip('For Rent', Colors.blue),
                                if (!isForSale && !isForRent)
                                  _statusChip('Private', Colors.orange),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                if (isForSale)
                                  OutlinedButton(
                                    onPressed: () {
                                      _removeFromSale(context, doc.id);
                                    },
                                    child: const Text('Remove Sale'),
                                  ),
                                if (isForRent)
                                  OutlinedButton(
                                    onPressed: () {
                                      _removeFromRent(context, doc.id);
                                    },
                                    child: const Text('Remove Rent'),
                                  ),
                                OutlinedButton(
                                  onPressed: () {
                                    _showDeleteDialog(context, doc.id);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.redAccent),
                                  ),
                                  child: const Text(
                                    'Delete Listing',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}