import 'package:cloud_firestore/cloud_firestore.dart';

class FoodRequestModel {
  final String id;
  final String sharedFoodId;
  final String foodName;
  final String?  foodImageUrl;
  final String requesterId;
  final String requesterName;
  final String ownerId;
  final String ownerName;
  final String?  note;
  final String status; // pending, accepted, rejected, cancelled, completed
  final int queuePosition;
  final DateTime createdAt;
  final DateTime?  respondedAt;
  final DateTime? completedAt;

  FoodRequestModel({
    required this.id,
    required this. sharedFoodId,
    required this.foodName,
    this.foodImageUrl,
    required this.requesterId,
    required this.requesterName,
    required this.ownerId,
    required this.ownerName,
    this.note,
    required this.status,
    required this.queuePosition,
    required this.createdAt,
    this.respondedAt,
    this.completedAt,
  });

  factory FoodRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FoodRequestModel(
      id:  doc.id,
      sharedFoodId: data['sharedFoodId'] ?? '',
      foodName: data['foodName'] ?? '',
      foodImageUrl:  data['foodImageUrl'],
      requesterId: data['requesterId'] ?? '',
      requesterName:  data['requesterName'] ?? '',
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      note:  data['note'],
      status:  data['status'] ?? 'pending',
      queuePosition: data['queuePosition'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      respondedAt: data['respondedAt'] != null 
          ? (data['respondedAt'] as Timestamp).toDate() 
          : null,
      completedAt: data['completedAt'] != null 
          ?  (data['completedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sharedFoodId': sharedFoodId,
      'foodName':  foodName,
      'foodImageUrl': foodImageUrl,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'note': note,
      'status': status,
      'queuePosition': queuePosition,
      'createdAt':  Timestamp.fromDate(createdAt),
      'respondedAt': respondedAt != null ?  Timestamp.fromDate(respondedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  // Status helpers
  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
}