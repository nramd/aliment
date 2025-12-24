import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_item_model.dart';
import 'package:flutter/foundation.dart';

class FoodService {
  final CollectionReference _foodCollection =
      FirebaseFirestore.instance.collection('food_items');

  // --- CREATE:  Menambah Makanan Baru ---
  Future<void> addFoodItem(FoodItemModel item) async {
    try {
      await _foodCollection.add(item.toMap());
    } catch (e) {
      debugPrint("Error adding food:  $e");
      rethrow;
    }
  }

  // --- READ: Mengambil Data Etalase (Realtime) ---
  Stream<List<FoodItemModel>> getFoodItems(String userId) {
    return _foodCollection
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'available')
        .orderBy('expiryDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FoodItemModel.fromFirestore(doc);
      }).toList();
    });
  }

  // --- READ: Mengambil Data Food by ID (Realtime) ---
  Stream<FoodItemModel?> getFoodById(String foodId) {
    return _foodCollection. doc(foodId).snapshots().map((doc) {
      if (doc.exists) {
        return FoodItemModel.fromFirestore(doc);
      }
      return null;
    });
  }

  // --- READ: Mengambil Data Food by ID (Single) ---
  Future<FoodItemModel?> getFoodByIdOnce(String foodId) async {
    try {
      DocumentSnapshot doc = await _foodCollection. doc(foodId).get();
      if (doc.exists) {
        return FoodItemModel. fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint("Error getting food:  $e");
      return null;
    }
  }

  // --- UPDATE: Mengupdate Status ---
  Future<void> updateFoodStatus(String foodId, String newStatus) async {
    try {
      await _foodCollection. doc(foodId).update({
        'status': newStatus,
      });
    } catch (e) {
      debugPrint("Error updating status: $e");
      rethrow;
    }
  }

  // --- UPDATE: Mengupdate Food Item ---
  Future<void> updateFoodItem(String foodId, FoodItemModel item) async {
    try {
      await _foodCollection.doc(foodId).update(item.toMap());
    } catch (e) {
      debugPrint("Error updating food: $e");
      rethrow;
    }
  }

  // --- DELETE: Menghapus Food Item ---
  Future<void> deleteFoodItem(String foodId) async {
    try {
      await _foodCollection.doc(foodId).delete();
    } catch (e) {
      debugPrint("Error deleting food: $e");
      rethrow;
    }
  }
}