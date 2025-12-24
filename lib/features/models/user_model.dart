import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? username;
  final String? photoUrl;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.username,
    this.photoUrl,
    required this.createdAt,
  });

  // Mengubah data dari Firestore ke object Dart
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      username: data['username'],
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Mengubah object Dart ke format JSON untuk disimpan
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'username': username,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}