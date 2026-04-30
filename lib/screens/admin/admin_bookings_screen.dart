import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/booking_service.dart';

class AdminBookingsScreen extends StatelessWidget {
  const AdminBookingsScreen({super.key});

  Widget _buildCarImage(Map<String, dynamic> booking) {
    try {
      final String base64String = booking['imageBase64'] ?? '';

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

  String _formatTimestamp(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate();
      return '${date.day}/${date.month}/${date.year}';
    }
    return '';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.orange;
    }
  }

  Future<void> _updateStatus(
      BuildContext context,
      String bookingId,
      String status,
      ) async {
    try {
      await BookingService().updateBookingStatus(
        bookingId: bookingId,
        status: status,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking marked as $status')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update booking')),
      );
    }
  }

  Future<void> _deleteBooking(BuildContext context, String bookingId) async {
    try {
      await BookingService().deleteBooking(bookingId);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking deleted successfully')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete booking')),
      );
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, String bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF171717),
          title: const Text('Delete Booking'),
          content: const Text('Are you sure you want to delete this booking?'),
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
      await _deleteBooking(context, bookingId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Bookings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: BookingService().getAllBookings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs.toList() ?? [];

            docs.sort((a, b) {
              final aTime = a.data()['createdAt'];
              final bTime = b.data()['createdAt'];

              if (aTime is Timestamp && bTime is Timestamp) {
                return bTime.compareTo(aTime);
              }
              return 0;
            });

            if (docs.isEmpty) {
              return const Center(
                child: Text('No bookings found'),
              );
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final booking = doc.data();
                final status = (booking['status'] ?? 'confirmed').toString();

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
                            child: _buildCarImage(booking),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${booking['brand']} ${booking['model']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('Renter: ${booking['renterEmail']}'),
                                Text(
                                  'From: ${_formatTimestamp(booking['startDate'])}',
                                ),
                                Text(
                                  'To: ${_formatTimestamp(booking['endDate'])}',
                                ),
                                Text('Total Days: ${booking['totalDays']}'),
                                Text(
                                  'Rent Per Day: ${booking['rentPricePerDay']}',
                                ),
                                Text(
                                  'Total Price: ${booking['totalPrice']}',
                                  style: const TextStyle(
                                    color: Color(0xFFD4AF37),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(status).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _statusColor(status)),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: _statusColor(status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          if (status.toLowerCase() == 'confirmed')
                            ElevatedButton(
                              onPressed: () {
                                _updateStatus(context, doc.id, 'completed');
                              },
                              child: const Text('Mark Completed'),
                            ),
                          if (status.toLowerCase() == 'confirmed')
                            OutlinedButton(
                              onPressed: () {
                                _updateStatus(context, doc.id, 'cancelled');
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.redAccent),
                              ),
                              child: const Text(
                                'Cancel Booking',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          OutlinedButton(
                            onPressed: () {
                              _showDeleteDialog(context, doc.id);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.redAccent),
                            ),
                            child: const Text(
                              'Delete',
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
    );
  }
}