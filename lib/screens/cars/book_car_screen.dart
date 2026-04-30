import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/booking_service.dart';

class BookCarScreen extends StatefulWidget {
  final String carId;
  final Map<String, dynamic> car;

  const BookCarScreen({
    super.key,
    required this.carId,
    required this.car,
  });

  @override
  State<BookCarScreen> createState() => _BookCarScreenState();
}

class _BookCarScreenState extends State<BookCarScreen> {
  final BookingService _bookingService = BookingService();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  double get _rentPerDay {
    return double.tryParse((widget.car['rentPricePerDay'] ?? '0').toString()) ??
        0;
  }

  int get _totalDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  double get _totalPrice {
    return _totalDays * _rentPerDay;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? today,
      firstDate: today,
      lastDate: DateTime(today.year + 2),
    );

    if (picked != null) {
      setState(() {
        _startDate = DateTime(picked.year, picked.month, picked.day);

        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? today,
      firstDate: _startDate ?? today,
      lastDate: DateTime(today.year + 2),
    );

    if (picked != null) {
      setState(() {
        _endDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _confirmBooking() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final ownerId = widget.car['ownerId'] ?? '';

    if (currentUserId == ownerId) {
      _showMessage('You cannot book your own car');
      return;
    }

    if (_startDate == null || _endDate == null) {
      _showMessage('Please select start and end date');
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      _showMessage('End date cannot be before start date');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final hasOverlap = await _bookingService.hasOverlappingBooking(
        carId: widget.carId,
        startDate: _startDate!,
        endDate: _endDate!,
      );

      if (hasOverlap) {
        _showMessage('This car is already booked for the selected dates');
      } else {
        await _bookingService.createBooking(
          carId: widget.carId,
          car: widget.car,
          startDate: _startDate!,
          endDate: _endDate!,
        );

        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking confirmed successfully')),
        );
      }
    } catch (e) {
      _showMessage('Failed to create booking');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _infoBox({
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD4AF37)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFD4AF37),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final carName = '${widget.car['brand']} ${widget.car['model']}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Car'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF171717),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD4AF37)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                carName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              InkWell(
                onTap: _pickStartDate,
                child: _infoBox(
                  title: 'Start Date',
                  value: _formatDate(_startDate),
                ),
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: _pickEndDate,
                child: _infoBox(
                  title: 'End Date',
                  value: _formatDate(_endDate),
                ),
              ),
              const SizedBox(height: 20),
              _infoBox(
                title: 'Rent Per Day',
                value: _rentPerDay.toStringAsFixed(0),
              ),
              const SizedBox(height: 14),
              _infoBox(
                title: 'Total Days',
                value: _totalDays.toString(),
              ),
              const SizedBox(height: 14),
              _infoBox(
                title: 'Total Price',
                value: _totalPrice.toStringAsFixed(0),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                onPressed: _confirmBooking,
                icon: const Icon(Icons.book_online),
                label: const Text('Confirm Booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}