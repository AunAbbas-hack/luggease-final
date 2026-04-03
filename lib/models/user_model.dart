import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { customer, driver, admin }

/// Firestore top-level collection for this role (Console: open collection → see all accounts of that type).
extension UserRoleFirestore on UserRole {
  String get collectionName {
    switch (this) {
      case UserRole.customer:
        return 'customers';
      case UserRole.driver:
        return 'drivers';
      case UserRole.admin:
        return 'admins';
    }
  }
}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String? address;
  final UserRole role;
  final String? profileImage;
  final DateTime createdAt;

  // Driver specific fields
  final String? cnic;
  final String? vehicleType;
  final String? vehicleNumber;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    required this.role,
    this.profileImage,
    required this.createdAt,
    this.cnic,
    this.vehicleType,
    this.vehicleNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role.name,
      'profileImage': profileImage,
      'createdAt': Timestamp.fromDate(createdAt),
      'cnic': cnic,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
    };
  }

  static UserRole _roleFromField(Object? value) {
    final s = value?.toString() ?? 'customer';
    return UserRole.values.firstWhere(
      (r) => r.name == s,
      orElse: () => UserRole.customer,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'],
      role: _roleFromField(map['role']),
      profileImage: map['profileImage'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      cnic: map['cnic'],
      vehicleType: map['vehicleType'],
      vehicleNumber: map['vehicleNumber'],
    );
  }
}
