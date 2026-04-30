import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitReport({
    required String carId,
    required String ownerId,
    required String brand,
    required String model,
    required String reason,
    required String details,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    await _firestore.collection('reports').add({
      'carId': carId,
      'ownerId': ownerId,
      'reporterId': user?.uid ?? '',
      'reporterEmail': user?.email ?? '',
      'brand': brand,
      'model': model,
      'reason': reason,
      'details': details,
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });
  }
}