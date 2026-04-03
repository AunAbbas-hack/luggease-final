import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Order: role-based collections first, then legacy `users` for old installs.
  static const List<String> _profileLookupOrder = [
    'customers',
    'drivers',
    'admins',
    'users',
  ];

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

  Future<DocumentSnapshot<Map<String, dynamic>>?> _firstExistingProfile(
    String uid,
  ) async {
    final snaps = await Future.wait(
      _profileLookupOrder.map((c) => _db.collection(c).doc(uid).get()),
    );
    for (final doc in snaps) {
      if (doc.exists && doc.data() != null) return doc;
    }
    return null;
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

      final collection = role.collectionName;
      debugPrint("AuthService: Saving user data to Firestore/$collection");
      await _db
          .collection(collection)
          .doc(userModel.uid)
          .set(userModel.toMap());
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
    final doc = await _firstExistingProfile(uid);
    if (doc == null || !doc.exists || doc.data() == null) return null;
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

      final doc = await _firstExistingProfile(uid);
      if (doc != null && doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
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
      final existing = await _firstExistingProfile(user.uid);
      if (existing != null && existing.exists) {
        await existing.reference.update(user.toMap());
        return;
      }
      await _db
          .collection(user.role.collectionName)
          .doc(user.uid)
          .set(user.toMap());
    } catch (e) {
      debugPrint("AuthService Update Error: $e");
      rethrow;
    }
  }

  /// Merges FCM token into whichever profile doc exists (or legacy `users`).
  Future<void> saveFcmTokenToProfile(String token) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final snap = await _firstExistingProfile(uid);
    if (snap == null || !snap.exists) return;
    await snap.reference.set(
      {
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
