import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_item_model.dart';
import 'package:flutter/foundation.dart';

class FoodService {
  // 1. Referensi ke koleksi 'food_items' di database Firestore
  final CollectionReference _foodCollection =
      FirebaseFirestore.instance.collection('food_items');

  // --- CREATE: Menambah Makanan Baru ---
  Future<void> addFoodItem(FoodItemModel item) async {
    try {
      // Kita menggunakan .add() agar Firestore membuatkan ID unik otomatis
      await _foodCollection.add(item.toMap());
    } catch (e) {
      debugPrint("Error adding food: $e");
      rethrow;
    }
  }

  // --- READ: Mengambil Data Etalase (Realtime) ---
  // Fungsi ini mengembalikan 'Stream'. Artinya jika ada perubahan di database,
  // tampilan di aplikasi akan otomatis berubah tanpa perlu refresh/tarik layar.
  Stream<List<FoodItemModel>> getFoodItems(String userId) {
    return _foodCollection
        .where('userId', isEqualTo: userId) // Hanya ambil punya user yang login
        .where('status', isEqualTo: 'available') // Hanya ambil yang masih ada (belum dimakan/dibuang)
        .orderBy('expiryDate', descending: false) // Urutkan dari yang paling cepat kadaluarsa
        .snapshots() // Ini yang bikin realtime
        .map((snapshot) {
      // Mengubah format aneh Firestore menjadi List<FoodItemModel> yang rapi
      return snapshot.docs.map((doc) {
        return FoodItemModel.fromFirestore(doc);
      }).toList();
    });
  }

  // --- UPDATE: Mengupdate Status (Misal: Dimasak atau Dibuang) ---
  Future<void> updateFoodStatus(String foodId, String newStatus) async {
    try {
      await _foodCollection.doc(foodId).update({
        'status': newStatus, 
        // Kita bisa tambah field lain kalau mau, misal 'consumedAt': Timestamp.now()
      });
    } catch (e) {
      debugPrint("Error updating status: $e");
      rethrow;
    }
  }
  
  // --- UPDATE: Edit Data Makanan (Misal salah input nama/jumlah) ---
  Future<void> updateFoodItem(String foodId, Map<String, dynamic> data) async {
    try {
      await _foodCollection.doc(foodId).update(data);
    } catch (e) {
      debugPrint("Error updating food: $e");
      rethrow;
    }
  }

  // --- DELETE: Menghapus Data Selamanya ---
  Future<void> deleteFoodItem(String foodId) async {
    try {
      await _foodCollection.doc(foodId).delete();
    } catch (e) {
      debugPrint("Error deleting food: $e");
      rethrow;
    }
  }
}