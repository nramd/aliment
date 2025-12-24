import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String? > uploadFoodImage({
    required File imageFile,
    required String userId,
  }) async {
    try {
      // Buat nama file unik dengan timestamp
      final String fileName = 'food_${DateTime.now().millisecondsSinceEpoch}. jpg';
      final String path = 'food_images/$userId/$fileName';

      // Reference ke lokasi penyimpanan
      final Reference ref = _storage.ref().child(path);

      // Upload file
      final UploadTask uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Tunggu upload selesai
      final TaskSnapshot snapshot = await uploadTask;

      // Dapatkan URL download
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image:  $e');
      return null;
    }
  }

  /// Hapus gambar dari Firebase Storage
  Future<void> deleteFoodImage(String imageUrl) async {
    try {
      if (imageUrl. isEmpty) return;
      
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      debugPrint('Image deleted successfully');
    } catch (e) {
      debugPrint('Error deleting image: $e');
    }
  }
}