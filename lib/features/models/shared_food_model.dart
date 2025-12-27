import 'package:cloud_firestore/cloud_firestore.dart';

class SharedFoodModel {
  final String id;
  final String foodId; // Reference ke food_items
  final String ownerId;
  final String ownerName;
  final String name;
  final String?  description;
  final int quantity;
  final String unit;
  final String category;
  final String?  imageUrl;
  final DateTime expiryDate;
  final GeoPoint?  location;
  final String?  address;
  final String status; // available, reserved, completed, cancelled
  final String?  selectedRequestId;
  final int requestCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  SharedFoodModel({
    required this.id,
    required this.foodId,
    required this.ownerId,
    required this.ownerName,
    required this. name,
    this.description,
    required this.quantity,
    required this.unit,
    required this.category,
    this.imageUrl,
    required this.expiryDate,
    this.location,
    this. address,
    required this.status,
    this.selectedRequestId,
    required this.requestCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SharedFoodModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SharedFoodModel(
      id: doc.id,
      foodId: data['foodId'] ?? '',
      ownerId: data['ownerId'] ?? '',
      ownerName:  data['ownerName'] ?? '',
      name: data['name'] ?? '',
      description: data['description'],
      quantity: data['quantity'] ?? 0,
      unit:  data['unit'] ?? '',
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'],
      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
      location: data['location'] as GeoPoint?,
      address:  data['address'],
      status:  data['status'] ?? 'available',
      selectedRequestId: data['selectedRequestId'],
      requestCount: data['requestCount'] ??  0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'foodId':  foodId,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'name': name,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'category': category,
      'imageUrl': imageUrl,
      'expiryDate':  Timestamp.fromDate(expiryDate),
      'location': location,
      'address': address,
      'status': status,
      'selectedRequestId': selectedRequestId,
      'requestCount':  requestCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  int get daysUntilExpiry {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.difference(today).inDays;
  }

  // Status helpers
  bool get isAvailable => status == 'available';
  bool get isReserved => status == 'reserved';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
}