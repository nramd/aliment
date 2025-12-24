import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mendapatkan User yang sedang login saat ini
  User? get currentUser => _auth.currentUser;

  // Stream untuk memantau status login (Logout/Login) realtime
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign Up
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String username,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;

      if (user != null) {
        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          displayName: name,
          username: username,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
      }
      
      return user;
    } catch (e) {
      debugPrint("Error Register: $e");
      rethrow; 
    }
  }

  // Sign In
  Future<User?> signIn({required String email, required String password}) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      debugPrint("Error Login: $e");
      rethrow;
    }
  }

  // --- LOGOUT ---
  Future<void> signOut() async {
    await _auth.signOut();
  }
}