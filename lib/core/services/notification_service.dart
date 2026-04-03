import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Request permission with try-catch
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      ).timeout(const Duration(seconds: 5));

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          print('User granted permission');
        }

        // Get Token with try-catch
        try {
          String? token = await _messaging.getToken().timeout(const Duration(seconds: 5));
          if (token != null) {
            await _saveTokenToFirestore(token);
          }
        } catch (e) {
          debugPrint('Error getting FCM token: $e');
        }

        // Listen for token refresh
        FirebaseMessaging.instance.onTokenRefresh.listen((token) {
          _saveTokenToFirestore(token).catchError((e) => debugPrint('Error saving refreshed token: $e'));
        });

        // Handle background messages
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
        
        // Handle foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          if (kDebugMode) {
            print('Got a message whilst in the foreground!');
            print('Message data: ${message.data}');
          }
          
          if (message.notification != null) {
            if (kDebugMode) {
              print('Message also contained a notification: ${message.notification}');
            }
          }
        });
      } else {
        if (kDebugMode) {
          print('User declined or has not accepted permission');
        }
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  static Future<void> _saveTokenToFirestore(String token) async {
    try {
      if (FirebaseAuth.instance.currentUser == null) return;
      await AuthService()
          .saveFcmTokenToProfile(token)
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Error saving token to Firestore: $e');
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Handle background notification logic here
    if (kDebugMode) {
      print("Handling a background message: ${message.messageId}");
    }
  }
}
