import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'LuggEase';
  
  // Colors
  static const Color primaryColor = Color(0xFF2563EB); // Vibrant Blue
  static const Color secondaryColor = Color(0xFF1E293B); 
  static const Color backgroundColor = Color(0xFF050A18); // Very Dark Blue/Black
  static const Color surfaceColor = Color(0xFF0F172A); // Card/Surface Color
  static const Color cardColor = Color(0xFF1E293B);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color accentColor = Color(0xFF3B82F6);
  
  // Firestore Collections (profiles by role — see UserRole.collectionName)
  static const String customersCollection = 'customers';
  static const String driversCollection = 'drivers';
  static const String adminsCollection = 'admins';
  /// Legacy; AuthService still reads this for existing accounts until migrated.
  static const String legacyUsersCollection = 'users';
  static const String bookingsCollection = 'bookings';
  static const String chatsCollection = 'chats';
  static const String ratingsCollection = 'ratings';
  static const String paymentsCollection = 'payments';
  
  // Others
  static const Duration splashDelay = Duration(seconds: 3);
}
