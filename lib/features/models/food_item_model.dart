import 'package:cloud_firestore/cloud_firestore.dart';

class FoodItemModel {
  final String id;
  final String userId;
  final String name;
  final String category;
  final DateTime expiryDate;
  final DateTime addedDate;
  final String storageLocation;
  final int quantity;
  final String unit;
  final String status; // 'available', 'consumed', 'trash'

  FoodItemModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.expiryDate,
    required this.addedDate,
    required this.storageLocation,
    required this.quantity,
    required this.unit,
    required this.status,
  });

  factory FoodItemModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FoodItemModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      category: data['category'] ?? 'Umum',
      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
      addedDate: (data['addedDate'] as Timestamp).toDate(),
      storageLocation: data['storageLocation'] ?? 'Dapur',
      quantity: data['quantity'] ?? 0,
      unit: data['unit'] ?? 'pcs',
      status: data['status'] ?? 'available',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'category': category,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'addedDate': Timestamp.fromDate(addedDate),
      'storageLocation': storageLocation,
      'quantity': quantity,
      'unit': unit,
      'status': status,
    };
  }
}