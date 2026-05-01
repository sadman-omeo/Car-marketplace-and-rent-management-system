import 'package:flutter/material.dart';

import '../../services/inquiry_service.dart';

class ContactSellerScreen extends StatefulWidget {
  final String carId;
  final Map<String, dynamic> car;

  const ContactSellerScreen({
    super.key,
    required this.carId,
    required this.car,
  });

  @override
  State<ContactSellerScreen> createState() => _ContactSellerScreenState();
}

class _ContactSellerScreenState extends State<ContactSellerScreen> {
  final TextEditingController _messageController = TextEditingController();
  final InquiryService _inquiryService = InquiryService();

  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _sendInquiry() async {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      _showMessage('Please write a message');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _inquiryService.submitInquiry(
        carId: widget.carId,
        car: widget.car,
        message: message,
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inquiry sent successfully')),
      );
    } catch (e) {
      _showMessage('Failed to send inquiry');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final carName = '${widget.car['brand']} ${widget.car['model']}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Seller'),
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
                'Send inquiry for: $carName',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _messageController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Write your message',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                onPressed: _sendInquiry,
                icon: const Icon(Icons.send),
                label: const Text('Send Inquiry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}