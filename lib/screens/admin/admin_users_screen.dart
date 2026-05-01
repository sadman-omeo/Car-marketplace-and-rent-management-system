import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/user_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(Map<String, dynamic> user) {
    final query = searchText.trim().toLowerCase();
    if (query.isEmpty) return true;

    final name = (user['name'] ?? '').toString().toLowerCase();
    final email = (user['email'] ?? '').toString().toLowerCase();
    final phone = (user['phone'] ?? '').toString().toLowerCase();

    return name.contains(query) ||
        email.contains(query) ||
        phone.contains(query);
  }

  Future<void> _updateUserStatus(
      BuildContext context,
      String userId,
      String status,
      ) async {
    try {
      await UserService().updateUserStatus(
        userId: userId,
        status: status,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User marked as $status')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update user status')),
      );
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'blocked':
        return Colors.redAccent;
      case 'active':
      default:
        return Colors.green;
    }
  }

  Widget _statusChip(String status) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
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
        title: const Text('Manage Users'),
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
                labelText: 'Search by name, email or phone',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: UserService().getAllUsersForAdmin(),
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
                      child: Text('No users found'),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final user = doc.data();

                      final name = (user['name'] ?? '').toString();
                      final email = (user['email'] ?? '').toString();
                      final phone = (user['phone'] ?? '').toString();
                      final status =
                      (user['status'] ?? 'active').toString();

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
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Color(0xFFD4AF37),
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                _statusChip(status),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text('Email: $email'),
                            const SizedBox(height: 4),
                            Text('Phone: $phone'),
                            const SizedBox(height: 6),
                            Text('User ID: ${doc.id}'),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                if (status.toLowerCase() != 'blocked')
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        _updateUserStatus(
                                          context,
                                          doc.id,
                                          'blocked',
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                      child: const Text(
                                        'Block',
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (status.toLowerCase() != 'blocked')
                                  const SizedBox(width: 12),
                                if (status.toLowerCase() == 'blocked')
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _updateUserStatus(
                                          context,
                                          doc.id,
                                          'active',
                                        );
                                      },
                                      child: const Text('Unblock'),
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