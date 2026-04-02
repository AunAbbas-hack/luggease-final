import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get user => _auth.authStateChanges();

  Future<UserModel?> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    String? cnic,
    String? vehicleType,
    String? vehicleNumber,
  }) async {
    try {
      debugPrint("AuthService: Starting signup for $email");
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint("AuthService: Firebase Auth account created: ${credential.user?.uid}");

      final userModel = UserModel(
        uid: credential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
        cnic: cnic,
        vehicleType: vehicleType,
        vehicleNumber: vehicleNumber,
      );

      debugPrint("AuthService: Saving user data to Firestore");
      await _db
          .collection('users')
          .doc(userModel.uid)
          .set(userModel.toMap())
          .timeout(const Duration(seconds: 10), onTimeout: () {
        debugPrint("AuthService: Firestore write timed out");
        throw TimeoutException("Failed to save user data. Please check your connection.");
      });
      debugPrint("AuthService: User data saved successfully");
      
      return userModel;
    } catch (e) {
      debugPrint("AuthService Signup Error: $e");
      rethrow;
    }
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc = await _db.collection('users').doc(credential.user!.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _db.collection('users').doc(user.uid).update(user.toMap());
    } catch (e) {
      debugPrint("AuthService Update Error: $e");
      rethrow;
    }
  }
}
