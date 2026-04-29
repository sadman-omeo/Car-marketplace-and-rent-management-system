import 'package:cloud_firestore/cloud_firestore.dart';

class CarModel {
  final String id;
  final String brand;
  final String name;
  final String model;
  final String year;
  final String type;
  final String registrationNumber;
  final String imageUrl;

  // Rental-related fields
  final bool isForRent;
  final String? rentPrice;
  final bool isAvailable;

  CarModel({
    required this.id,
    required this.brand,
    required this.name,
    required this.model,
    required this.year,
    required this.type,
    required this.registrationNumber,
    required this.imageUrl,
    this.isForRent = false,
    this.rentPrice,
    this.isAvailable = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'name': name,
      'model': model,
      'year': year,
      'type': type,
      'registrationNumber': registrationNumber,
      'imageUrl': imageUrl,
      'isForRent': isForRent,
      'rentPrice': rentPrice,
      'isAvailable': isAvailable,
    };
  }

  factory CarModel.fromMap(Map<String, dynamic> map) {
    return CarModel(
      id: map['id']?.toString() ?? '',
      brand: map['brand']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      model: map['model']?.toString() ?? '',
      year: map['year']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      registrationNumber: map['registrationNumber']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      isForRent: map['isForRent'] ?? false,
      rentPrice: map['rentPrice']?.toString(),
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  factory CarModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CarModel.fromMap({
      ...data,
      'id': doc.id,
    });
  }

  CarModel copyWith({
    String? id,
    String? brand,
    String? name,
    String? model,
    String? year,
    String? type,
    String? registrationNumber,
    String? imageUrl,
    bool? isForRent,
    String? rentPrice,
    bool? isAvailable,
  }) {
    return CarModel(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      name: name ?? this.name,
      model: model ?? this.model,
      year: year ?? this.year,
      type: type ?? this.type,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      isForRent: isForRent ?? this.isForRent,
      rentPrice: rentPrice ?? this.rentPrice,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}