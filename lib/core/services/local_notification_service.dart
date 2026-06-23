import 'dart:io';

import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Shows OS-level (heads-up) push notifications on Android and iOS.
///
/// Call [LocalNotificationService.instance.init()] once at app startup,
/// then call [showOrderNotification] after order placement.
class LocalNotificationService {
  LocalNotificationService._();

  static final instance = LocalNotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  int _nextId = 0;

  // ── Android notification channel ─────────────────────────────────────────

  static const _kOrderChannelId = 'moto_crafter_orders';
  static const _kOrderChannelName = 'Order Updates';
  static const _kOrderChannelDesc =
      'Notifications for order placements and status updates';

  // ── Init ─────────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;

    // Android 13+ (API 33) requires a runtime permission request.
    if (Platform.isAndroid) {
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.requestNotificationsPermission();
    }
  }

  // ── Public API ───────────────────────────────────────────────────────────

  /// Shows a heads-up notification for order-related events.
  ///
  /// [title] — bold heading, e.g. "Order Placed 🎉"
  /// [body]  — detail line, e.g. "Your order of ₹1,499 is confirmed."
  Future<void> showOrderNotification({
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();

    final androidDetails = AndroidNotificationDetails(
      _kOrderChannelId,
      _kOrderChannelName,
      channelDescription: _kOrderChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        htmlFormatBigText: false,
        htmlFormatContentTitle: false,
      ),
      color: const Color.fromARGB(255, 0, 87, 184),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(_nextId++, title, body, details);
  }
}
