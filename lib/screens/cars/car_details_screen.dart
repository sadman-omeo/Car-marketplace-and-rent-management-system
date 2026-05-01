import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'report_listing_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'book_car_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/booking_service.dart';

import '../inquiries/contact_seller_screen.dart';

class CarDetailsScreen extends StatelessWidget {
  final String carId;
  final Map<String, dynamic> car;

  const CarDetailsScreen({
    super.key,
    required this.carId,
    required this.car,
  });

  Widget _buildCarImage() {
    try {
      final String base64String = car['imageBase64'] ?? '';

      if (base64String.isNotEmpty) {
        Uint8List imageBytes = base64Decode(base64String);
        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.memory(
            imageBytes,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
          ),
        );
      }
    } catch (_) {}

    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Icon(
        Icons.directions_car,
        size: 70,
        color: Colors.black,
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }


  String _formatDate(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate();
      return '${date.day}/${date.month}/${date.year}';
    }
    return '-';
  }

  Widget _buildBookedDatesSection() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: BookingService().getBookingsForCar(carId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD4AF37)),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        final today = DateTime.now();
        final todayOnly = DateTime(today.year, today.month, today.day);

        final bookings = docs
            .map((doc) => doc.data())
            .where((booking) {
          final status = (booking['status'] ?? '').toString().toLowerCase();
          if (status == 'cancelled') return false;

          final endValue = booking['endDate'];
          if (endValue is! Timestamp) return false;

          final endDate = endValue.toDate();
          final endOnly = DateTime(endDate.year, endDate.month, endDate.day);

          return !endOnly.isBefore(todayOnly);
        })
            .toList();

        bookings.sort((a, b) {
          final aStart = a['startDate'];
          final bStart = b['startDate'];

          if (aStart is Timestamp && bStart is Timestamp) {
            return aStart.compareTo(bStart);
          }
          return 0;
        });

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD4AF37)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Booked Dates',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (bookings.isEmpty)
                const Text('No booked dates yet')
              else
                Column(
                  children: bookings.map((booking) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF171717),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD4AF37)),
                      ),
                      child: Text(
                        '${_formatDate(booking['startDate'])}  →  ${_formatDate(booking['endDate'])}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
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



  @override
  Widget build(BuildContext context) {
    final bool isForSale = car['isForSale'] ?? false;
    final bool isForRent = car['isForRent'] ?? false;

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = currentUserId == (car['ownerId'] ?? '');

    final String salePrice = (car['salePrice'] ?? '').toString();
    final String rentPricePerDay = (car['rentPricePerDay'] ?? '').toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF171717),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD4AF37)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCarImage(),
              const SizedBox(height: 16),
              Text(
                '${car['brand']} ${car['model']}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              _infoRow('Year', '${car['year']}'),
              _infoRow('Type', '${car['type']}'),
              _infoRow('Registration No', '${car['registrationNumber']}'),
              _infoRow('Color', '${car['color']}'),
              _infoRow('Mileage', '${car['mileage']}'),
              _infoRow('Fuel Type', '${car['fuelType']}'),
              _infoRow('Transmission', '${car['transmission']}'),
              if (isForSale) _infoRow('Sale Price', salePrice),
              if (isForRent) _infoRow('Rent Per Day', rentPricePerDay),
              const SizedBox(height: 18),
              if (isForSale || isForRent)
                Row(
                  children: [
                    if (isForSale)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'Available for Sale',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (isForSale && isForRent)
                      const SizedBox(width: 12),
                    if (isForRent)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFD4AF37)),
                          ),
                          child: const Text(
                            'Available for Rent',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              if (isForRent) ...[
                const SizedBox(height: 20),
                _buildBookedDatesSection(),
              ],
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportListingScreen(
                        carId: carId,
                        car: car,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.report, color: Colors.redAccent),
                label: const Text(
                  'Report Listing',
                  style: TextStyle(color: Colors.redAccent),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (!isOwner)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ContactSellerScreen(
                          carId: carId,
                          car: car,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.message),
                  label: const Text('Contact Seller'),
                ),
              const SizedBox(height: 12),
              if (isForRent && !isOwner)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookCarScreen(
                          carId: carId,
                          car: car,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.book_online),
                  label: const Text('Book Now'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}