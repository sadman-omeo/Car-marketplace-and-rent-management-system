import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/app_constants.dart';



class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    required String phone,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': 'user',
      'profileImage': defaultProfileImage,
      'createdAt': Timestamp.now(),
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getCurrentUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    return await _firestore.collection('users').doc(user!.uid).get();
  }
}