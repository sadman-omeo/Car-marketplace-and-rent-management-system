import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    required String imageBase64,
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
      'imageBase64': imageBase64,
      'isForSale': false,
      'isForRent': false,
      'salePrice': '',
      'rentPricePerDay': '',
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
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

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllMyCars() {
    final user = FirebaseAuth.instance.currentUser;

    return _firestore
        .collection('registered_cars')
        .where('ownerId', isEqualTo: user!.uid)
        .snapshots();
  }


  Stream<QuerySnapshot<Map<String, dynamic>>> getCarsForSale() {
    return _firestore
        .collection('registered_cars')
        .where('isForSale', isEqualTo: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCarsForRent() {
    return _firestore
        .collection('registered_cars')
        .where('isForRent', isEqualTo: true)
        .snapshots();
  }


  //delete car
  Future<void> deleteRegisteredCar(String carId) async {
    await _firestore.collection('registered_cars').doc(carId).delete();
  }



  // Sell Car

  Future<void> updateSellStatus({
    required String carId,
    required bool isForSale,
    required String salePrice,
  }) async {
    await _firestore.collection('registered_cars').doc(carId).update({
      'isForSale': isForSale,
      'salePrice': isForSale ? salePrice : '',
      'updatedAt': Timestamp.now(),
    });
  }


  // give for Rent Car
  Future<void> updateRentStatus({
    required String carId,
    required bool isForRent,
    required String rentPricePerDay,
  }) async {
    await _firestore.collection('registered_cars').doc(carId).update({
      'isForRent': isForRent,
      'rentPricePerDay': isForRent ? rentPricePerDay : '',
      'updatedAt': Timestamp.now(),
    });
  }
}