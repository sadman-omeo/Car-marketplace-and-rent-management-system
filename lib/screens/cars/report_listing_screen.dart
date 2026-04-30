import 'package:flutter/material.dart';

import '../../services/report_service.dart';

class ReportListingScreen extends StatefulWidget {
  final String carId;
  final Map<String, dynamic> car;

  const ReportListingScreen({
    super.key,
    required this.carId,
    required this.car,
  });

  @override
  State<ReportListingScreen> createState() => _ReportListingScreenState();
}

class _ReportListingScreenState extends State<ReportListingScreen> {
  final TextEditingController _detailsController = TextEditingController();
  final ReportService _reportService = ReportService();

  final List<String> _reasons = const [
    'Fake information',
    'Wrong price',
    'Already sold or unavailable',
    'Suspicious activity',
    'Inappropriate content',
    'Other',
  ];

  String? _selectedReason;
  bool _isLoading = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null) {
      _showMessage('Please select a reason');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _reportService.submitReport(
        carId: widget.carId,
        ownerId: widget.car['ownerId'] ?? '',
        brand: widget.car['brand'] ?? '',
        model: widget.car['model'] ?? '',
        reason: _selectedReason!,
        details: _detailsController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted successfully')),
      );
    } catch (e) {
      _showMessage('Failed to submit report');
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
        title: const Text('Report Listing'),
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
                'Reporting: $carName',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                value: _selectedReason,
                dropdownColor: const Color(0xFF171717),
                decoration: const InputDecoration(
                  labelText: 'Select Reason',
                ),
                items: _reasons.map((reason) {
                  return DropdownMenuItem<String>(
                    value: reason,
                    child: Text(reason),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedReason = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _detailsController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Additional Details (optional)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                onPressed: _submitReport,
                icon: const Icon(Icons.report),
                label: const Text('Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}