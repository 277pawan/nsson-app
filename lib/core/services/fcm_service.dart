import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'local_notification_service.dart';

/// Handles FCM token retrieval and refresh notifications.
/// Call [FCMService.instance.getToken()] to get the current token.
class FCMService {
  FCMService._();
  static final FCMService instance = FCMService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initializes listeners for foreground notifications and background notification clicks.
  Future<void> init() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM] Foreground message received: ${message.notification?.title}');
      final notification = message.notification;
      if (notification != null) {
        LocalNotificationService.instance.showOrderNotification(
          title: notification.title ?? '',
          body: notification.body ?? '',
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] App opened from notification: ${message.data}');
    });
  }

  /// Requests notification permission (Android 13+ / iOS) and returns
  /// the current FCM token, or null if permission was denied / unavailable.
  Future<String?> getToken() async {
    try {
      // Request permission — on Android <13 this is a no-op and returns granted.
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('[FCM] Permission denied — skipping token fetch');
        return null;
      }

      final token = await _messaging.getToken();
      debugPrint('[FCM] Token: $token');
      return token;
    } catch (e) {
      debugPrint('[FCM] getToken error: $e');
      return null;
    }
  }

  /// Listen for token refreshes. Call this once after login and pass a
  /// callback that POSTs the new token to your backend.
  void onTokenRefresh(void Function(String token) callback) {
    _messaging.onTokenRefresh.listen(callback);
  }

  /// Subscribe the current device to a Firebase topic.
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('[FCM] Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('[FCM] Topic subscribe failed ($topic): $e');
    }
  }

  Future<void> subscribeToAllUsersTopic() async {
    return subscribeToTopic('all_users');
  }
}
