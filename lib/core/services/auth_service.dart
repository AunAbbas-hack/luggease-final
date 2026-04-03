import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get user => _auth.authStateChanges();

  /// Short, user-facing text for signup/login failures (no raw exception dumps).
  static String userMessageForError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'This email is already registered. Please sign in instead.';
        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Invalid email or password.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'network-request-failed':
        case 'too-many-requests':
          return 'Network or rate limit issue. Wait a moment and try again.';
        case 'operation-not-allowed':
          return 'Email/password sign-up is not enabled for this app.';
        default:
          return error.message?.isNotEmpty == true
              ? error.message!
              : 'Something went wrong. Please try again.';
      }
    }
    if (error is TimeoutException) {
      return 'Request timed out. Check your connection and try again.';
    }
    if (error is FirebaseException) {
      return 'Could not save your profile. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  Future<UserModel> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    String? cnic,
    String? vehicleType,
    String? vehicleNumber,
  }) async {
    UserCredential? credential;
    try {
      debugPrint("AuthService: Starting signup for $email");
      credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      debugPrint("AuthService: Firebase Auth account created: ${firebaseUser?.uid}");
      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'null-user',
          message: 'Account creation did not complete. Please try again.',
        );
      }

      final userModel = UserModel(
        uid: firebaseUser.uid,
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
      // Do not wrap in a short Future.timeout — it can throw while the write
      // still completes on the server, causing false errors and orphan Auth users.
      await _db.collection('users').doc(userModel.uid).set(userModel.toMap());
      debugPrint("AuthService: User data saved successfully");

      return userModel;
    } catch (e, st) {
      debugPrint("AuthService Signup Error: $e\n$st");
      if (credential?.user != null) {
        try {
          await credential!.user!.delete();
          debugPrint("AuthService: Rolled back Firebase Auth user after failed signup");
        } catch (del) {
          debugPrint("AuthService: Failed to roll back Auth user: $del");
        }
      }
      rethrow;
    }
  }

  /// Loads the Firestore profile for the current Firebase user, if any.
  Future<UserModel?> loadCurrentUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(doc.data()!);
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid == null) return null;

      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      // Signed in with Auth but no Firestore profile — avoid stuck session in app.
      await _auth.signOut();
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
