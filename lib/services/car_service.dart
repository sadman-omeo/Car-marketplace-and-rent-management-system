import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/app_constants.dart';



class CarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addRegisteredCar({
    required String brand,
    required String model,
    required String year,
    required String type,
    required String registrationNumber,
    required String color,
    required String mileage,
    required String fuelType,
    required String transmission,
    required String imageUrl,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    await _firestore.collection('registered_cars').add({
      'ownerId': user!.uid,
      'brand': brand,
      'model': model,
      'year': year,
      'type': type,
      'registrationNumber': registrationNumber,
      'color': color,
      'mileage': mileage,
      'fuelType': fuelType,
      'transmission': transmission,
      'imageUrl': imageUrl.trim().isEmpty ? defaultCarImage : imageUrl.trim(),
      'createdAt': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMyCars({int limit = 3}) {
    final user = FirebaseAuth.instance.currentUser;

    return _firestore
        .collection('registered_cars')
        .where('ownerId', isEqualTo: user!.uid)
        .limit(limit)
        .snapshots();
  }
}