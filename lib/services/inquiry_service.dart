import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InquiryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> submitInquiry({
    required String carId,
    required Map<String, dynamic> car,
    required String message,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    await _firestore.collection('inquiries').add({
      'carId': carId,
      'ownerId': car['ownerId'] ?? '',
      'senderId': user.uid,
      'senderEmail': user.email ?? '',
      'brand': car['brand'] ?? '',
      'model': car['model'] ?? '',
      'message': message,
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMySentInquiries() {
    final user = _auth.currentUser;

    return _firestore
        .collection('inquiries')
        .where('senderId', isEqualTo: user?.uid ?? '')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMyReceivedInquiries() {
    final user = _auth.currentUser;

    return _firestore
        .collection('inquiries')
        .where('ownerId', isEqualTo: user?.uid ?? '')
        .snapshots();
  }

  Future<void> updateInquiryStatus({
    required String inquiryId,
    required String status,
  }) async {
    await _firestore.collection('inquiries').doc(inquiryId).update({
      'status': status,
    });
  }

  Future<void> deleteInquiry(String inquiryId) async {
    await _firestore.collection('inquiries').doc(inquiryId).delete();
  }
}