import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<bool> hasOverlappingBooking({
    required String carId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final snapshot = await _firestore
        .collection('bookings')
        .where('carId', isEqualTo: carId)
        .get();

    final requestedStart = _dateOnly(startDate);
    final requestedEnd = _dateOnly(endDate);

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final status = (data['status'] ?? '').toString().toLowerCase();
      if (status == 'cancelled') continue;

      final startValue = data['startDate'];
      final endValue = data['endDate'];

      if (startValue is! Timestamp || endValue is! Timestamp) continue;

      final existingStart = _dateOnly(startValue.toDate());
      final existingEnd = _dateOnly(endValue.toDate());

      final overlaps = !requestedEnd.isBefore(existingStart) &&
          !requestedStart.isAfter(existingEnd);

      if (overlaps) {
        return true;
      }
    }

    return false;
  }

  Future<void> createBooking({
    required String carId,
    required Map<String, dynamic> car,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final rentPerDay =
        double.tryParse((car['rentPricePerDay'] ?? '0').toString()) ?? 0;

    final totalDays = endDate.difference(startDate).inDays + 1;
    final totalPrice = rentPerDay * totalDays;

    await _firestore.collection('bookings').add({
      'carId': carId,
      'ownerId': car['ownerId'] ?? '',
      'renterId': user.uid,
      'renterEmail': user.email ?? '',
      'brand': car['brand'] ?? '',
      'model': car['model'] ?? '',
      'imageBase64': car['imageBase64'] ?? '',
      'startDate': Timestamp.fromDate(_dateOnly(startDate)),
      'endDate': Timestamp.fromDate(_dateOnly(endDate)),
      'totalDays': totalDays,
      'rentPricePerDay': car['rentPricePerDay'] ?? '',
      'totalPrice': totalPrice,
      'status': 'confirmed',
      'createdAt': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMyBookings() {
    final user = _auth.currentUser;

    return _firestore
        .collection('bookings')
        .where('renterId', isEqualTo: user?.uid ?? '')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getBookingsForCar(String carId) {
    return _firestore
        .collection('bookings')
        .where('carId', isEqualTo: carId)
        .snapshots();
  }
}