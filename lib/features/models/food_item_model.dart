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
  final String status; 
  final String?  imageUrl;

  FoodItemModel({
    required this.id,
    required this.userId,
    required this.name,
    required this. category,
    required this.expiryDate,
    required this.addedDate,
    required this.storageLocation,
    required this.quantity,
    required this.unit,
    required this.status,
    this.imageUrl,
  });

  factory FoodItemModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FoodItemModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      category: data['category'] ??  'Lainnya',
      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
      addedDate: (data['addedDate'] as Timestamp).toDate(),
      storageLocation: data['storageLocation'] ?? '',
      quantity: data['quantity'] ?? 1,
      unit: data['unit'] ?? 'pcs',
      status: data['status'] ??  'available',
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name':  name,
      'category': category,
      'expiryDate':  Timestamp.fromDate(expiryDate),
      'addedDate': Timestamp.fromDate(addedDate),
      'storageLocation': storageLocation,
      'quantity': quantity,
      'unit': unit,
      'status': status,
      'imageUrl': imageUrl,
    };
  }

  FoodItemModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    DateTime? expiryDate,
    DateTime?  addedDate,
    String?  storageLocation,
    int?  quantity,
    String? unit,
    String? status,
    String? imageUrl,
  }) {
    return FoodItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      expiryDate:  expiryDate ?? this.expiryDate,
      addedDate: addedDate ?? this. addedDate,
      storageLocation: storageLocation ?? this. storageLocation,
      quantity:  quantity ?? this.quantity,
      unit: unit ?? this.unit,
      status: status ?? this. status,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  int get daysUntilExpiry => expiryDate.difference(DateTime. now()).inDays;

  // Getter untuk status kadaluarsa
  String get expiryStatus {
    if (daysUntilExpiry < 0) return 'Kadaluarsa';
    if (daysUntilExpiry == 0) return 'Hari Ini';
    if (daysUntilExpiry <= 3) return 'Segera Olah';
    return 'Aman';
  }
}