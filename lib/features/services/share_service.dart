import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aliment/features/models/shared_food_model.dart';
import 'package:aliment/features/models/food_request_model.dart';
import 'package:aliment/features/models/food_item_model.dart';

class ShareService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SHARED FOODS

  // Bagikan makanan dari etalase
  Future<String> shareFoodFromEtalase({
    required FoodItemModel food,
    required String ownerName,
    required GeoPoint? location,
    required String? address,
    String? description,
  }) async {
    final now = DateTime.now();

    final docRef = await _firestore.collection('shared_foods').add({
      'foodId': food.id,
      'ownerId': food.userId,
      'ownerName': ownerName,
      'name': food.name,
      'description': description ?? '',
      'quantity': food.quantity,
      'unit': food.unit,
      'category': food.category,
      'imageUrl': food.imageUrl,
      'expiryDate': Timestamp.fromDate(food.expiryDate),
      'location': location,
      'address': address,
      'status': 'available',
      'selectedRequestId': null,
      'requestCount': 0,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });

    // Update food_items untuk tandai sudah di-share
    await _firestore.collection('food_items').doc(food.id).update({
      'isShared': true,
      'sharedFoodId': docRef.id,
    });

    return docRef.id;
  }

  // Get semua makanan yang dibagikan (untuk Jelajahi)
  Stream<List<SharedFoodModel>> getAvailableSharedFoods(
      {String? excludeUserId}) {
    Query query = _firestore
        .collection('shared_foods')
        .where('status', isEqualTo: 'available')
        .orderBy('createdAt', descending: true);

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => SharedFoodModel.fromFirestore(doc))
          .where(
              (food) => excludeUserId == null || food.ownerId != excludeUserId)
          .toList();
    });
  }

  // Get makanan yang saya bagikan
  Stream<List<SharedFoodModel>> getMySharedFoods(String userId) {
    return _firestore
        .collection('shared_foods')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final foods = snapshot.docs
          .map((doc) => SharedFoodModel.fromFirestore(doc))
          .toList();
      // Sort di client side untuk menghindari composite index
      foods.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return foods;
    });
  }

  // Get detail shared food
  Future<SharedFoodModel?> getSharedFoodById(String id) async {
    final doc = await _firestore.collection('shared_foods').doc(id).get();
    if (doc.exists) {
      return SharedFoodModel.fromFirestore(doc);
    }
    return null;
  }

  // Stream detail shared food
  Stream<SharedFoodModel?> streamSharedFood(String id) {
    return _firestore.collection('shared_foods').doc(id).snapshots().map((doc) {
      if (doc.exists) {
        return SharedFoodModel.fromFirestore(doc);
      }
      return null;
    });
  }

  // Update status shared food
  Future<void> updateSharedFoodStatus(String id, String status) async {
    await _firestore.collection('shared_foods').doc(id).update({
      'status': status,
      'updatedAt': Timestamp.now(),
    });
  }

  // Cancel/Tarik shared food
  Future<void> cancelSharedFood(
      String sharedFoodId, String originalFoodId) async {
    // Update shared food status
    await _firestore.collection('shared_foods').doc(sharedFoodId).update({
      'status': 'cancelled',
      'updatedAt': Timestamp.now(),
    });

    // Update original food item
    await _firestore.collection('food_items').doc(originalFoodId).update({
      'isShared': false,
      'sharedFoodId': null,
    });

    // Reject all pending requests
    final pendingRequests = await _firestore
        .collection('food_requests')
        .where('sharedFoodId', isEqualTo: sharedFoodId)
        .where('status', isEqualTo: 'pending')
        .get();

    final batch = _firestore.batch();
    for (var doc in pendingRequests.docs) {
      batch.update(doc.reference, {
        'status': 'rejected',
        'respondedAt': Timestamp.now(),
      });
    }
    await batch.commit();
  }

  // FOOD REQUESTS

  // Ajukan permintaan
  Future<String> createRequest({
    required SharedFoodModel sharedFood,
    required String requesterId,
    required String requesterName,
    String? note,
  }) async {
    // Get current queue position
    final existingRequests = await _firestore
        .collection('food_requests')
        .where('sharedFoodId', isEqualTo: sharedFood.id)
        .where('status', isEqualTo: 'pending')
        .get();

    final queuePosition = existingRequests.docs.length + 1;

    final docRef = await _firestore.collection('food_requests').add({
      'sharedFoodId': sharedFood.id,
      'foodName': sharedFood.name,
      'foodImageUrl': sharedFood.imageUrl,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'ownerId': sharedFood.ownerId,
      'ownerName': sharedFood.ownerName,
      'note': note,
      'status': 'pending',
      'queuePosition': queuePosition,
      'createdAt': Timestamp.now(),
      'respondedAt': null,
      'completedAt': null,
    });

    // Update request count di shared food
    await _firestore.collection('shared_foods').doc(sharedFood.id).update({
      'requestCount': FieldValue.increment(1),
      'updatedAt': Timestamp.now(),
    });

    return docRef.id;
  }

  // Get antrian permintaan untuk suatu makanan
  Stream<List<FoodRequestModel>> getRequestsForFood(String sharedFoodId) {
    return _firestore
        .collection('food_requests')
        .where('sharedFoodId', isEqualTo: sharedFoodId)
        .where('status', isEqualTo: 'pending')
        .orderBy('queuePosition')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FoodRequestModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get permintaan saya (sebagai requester)
  Stream<List<FoodRequestModel>> getMyRequests(String userId) {
    return _firestore
        .collection('food_requests')
        .where('requesterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FoodRequestModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get permintaan masuk (sebagai owner)
  Stream<List<FoodRequestModel>> getIncomingRequests(String userId) {
    return _firestore
        .collection('food_requests')
        .where('ownerId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FoodRequestModel.fromFirestore(doc))
          .toList();
    });
  }

  // Terima request (dan auto-reject yang lain)
  Future<void> acceptRequest(String requestId, String sharedFoodId) async {
    final batch = _firestore.batch();
    final now = Timestamp.now();

    // Accept the selected request
    batch.update(
      _firestore.collection('food_requests').doc(requestId),
      {
        'status': 'accepted',
        'respondedAt': now,
      },
    );

    // Reject all other pending requests
    final otherRequests = await _firestore
        .collection('food_requests')
        .where('sharedFoodId', isEqualTo: sharedFoodId)
        .where('status', isEqualTo: 'pending')
        .get();

    for (var doc in otherRequests.docs) {
      if (doc.id != requestId) {
        batch.update(doc.reference, {
          'status': 'rejected',
          'respondedAt': now,
        });
      }
    }

    // Update shared food status
    batch.update(
      _firestore.collection('shared_foods').doc(sharedFoodId),
      {
        'status': 'reserved',
        'selectedRequestId': requestId,
        'updatedAt': now,
      },
    );

    await batch.commit();
  }

  // Tolak satu request
  Future<void> rejectRequest(String requestId) async {
    // Get request data first
    final requestDoc =
        await _firestore.collection('food_requests').doc(requestId).get();

    if (requestDoc.exists) {
      final requestData = requestDoc.data() as Map<String, dynamic>;
      final sharedFoodId = requestData['sharedFoodId'] as String;

      // Update request status
      await _firestore.collection('food_requests').doc(requestId).update({
        'status': 'rejected',
        'respondedAt': Timestamp.now(),
      });

      // Decrement request count di shared food
      await _firestore.collection('shared_foods').doc(sharedFoodId).update({
        'requestCount': FieldValue.increment(-1),
        'updatedAt': Timestamp.now(),
      });
    }
  }

  // Batalkan request (oleh requester)
  Future<void> cancelRequest(String requestId, String sharedFoodId) async {
    await _firestore.collection('food_requests').doc(requestId).update({
      'status': 'cancelled',
      'respondedAt': Timestamp.now(),
    });

    // Decrement request count
    await _firestore.collection('shared_foods').doc(sharedFoodId).update({
      'requestCount': FieldValue.increment(-1),
      'updatedAt': Timestamp.now(),
    });
  }

  // Tandai sudah diambil (complete transaction)
  Future<void> markAsCompleted(
      String requestId, String sharedFoodId, String originalFoodId) async {
    final batch = _firestore.batch();
    final now = Timestamp.now();

    // Complete the request
    batch.update(
      _firestore.collection('food_requests').doc(requestId),
      {
        'status': 'completed',
        'completedAt': now,
      },
    );

    // Complete the shared food
    batch.update(
      _firestore.collection('shared_foods').doc(sharedFoodId),
      {
        'status': 'completed',
        'updatedAt': now,
      },
    );

    // Update original food item
    batch.update(
      _firestore.collection('food_items').doc(originalFoodId),
      {
        'isShared': false,
        'sharedFoodId': null,
        'status': 'shared', // atau bisa dihapus
      },
    );

    await batch.commit();
  }

  // Check if user already requested this food
  Future<bool> hasUserRequested(String sharedFoodId, String userId) async {
    final query = await _firestore
        .collection('food_requests')
        .where('sharedFoodId', isEqualTo: sharedFoodId)
        .where('requesterId', isEqualTo: userId)
        .where('status', whereIn: ['pending', 'accepted']).get();

    return query.docs.isNotEmpty;
  }

  // Get request by ID
  Future<FoodRequestModel?> getRequestById(String requestId) async {
    final doc =
        await _firestore.collection('food_requests').doc(requestId).get();
    if (doc.exists) {
      return FoodRequestModel.fromFirestore(doc);
    }
    return null;
  }

  // HISTORY

  // Get riwayat (completed & rejected)
  Stream<List<FoodRequestModel>> getHistory(String userId) {
    return _firestore
        .collection('food_requests')
        .where('requesterId', isEqualTo: userId)
        .where('status', whereIn: ['completed', 'rejected', 'cancelled'])
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => FoodRequestModel.fromFirestore(doc))
              .toList();
        });
  }
}
