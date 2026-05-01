import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/inquiry_service.dart';

class ReceivedInquiriesScreen extends StatelessWidget {
  const ReceivedInquiriesScreen({super.key});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'read':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String _formatTimestamp(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate();
      return '${date.day}/${date.month}/${date.year}';
    }
    return '';
  }

  Future<void> _markRead(BuildContext context, String inquiryId) async {
    try {
      await InquiryService().updateInquiryStatus(
        inquiryId: inquiryId,
        status: 'read',
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inquiry marked as read')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update inquiry')),
      );
    }
  }

  Future<void> _markResolved(BuildContext context, String inquiryId) async {
    try {
      await InquiryService().updateInquiryStatus(
        inquiryId: inquiryId,
        status: 'resolved',
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inquiry marked as resolved')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update inquiry')),
      );
    }
  }

  Future<void> _deleteInquiry(BuildContext context, String inquiryId) async {
    try {
      await InquiryService().deleteInquiry(inquiryId);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inquiry deleted successfully')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete inquiry')),
      );
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, String inquiryId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF171717),
          title: const Text('Delete Inquiry'),
          content: const Text('Are you sure you want to delete this inquiry?'),
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
      await _deleteInquiry(context, inquiryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Received Inquiries'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: InquiryService().getMyReceivedInquiries(),
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
                child: Text('No received inquiries found'),
              );
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final inquiry = doc.data();
                final status = (inquiry['status'] ?? 'pending').toString();

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF171717),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD4AF37)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              '${inquiry['brand']} ${inquiry['model']}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
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
                      const SizedBox(height: 10),
                      Text('From: ${inquiry['senderEmail']}'),
                      const SizedBox(height: 6),
                      Text('Message: ${inquiry['message']}'),
                      const SizedBox(height: 6),
                      Text(
                        'Received At: ${_formatTimestamp(inquiry['createdAt'])}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          if (status.toLowerCase() == 'pending')
                            ElevatedButton(
                              onPressed: () {
                                _markRead(context, doc.id);
                              },
                              child: const Text('Mark Read'),
                            ),
                          if (status.toLowerCase() != 'resolved')
                            OutlinedButton(
                              onPressed: () {
                                _markResolved(context, doc.id);
                              },
                              child: const Text('Mark Resolved'),
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