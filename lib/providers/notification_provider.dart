import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../data/models.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _api = ApiService.instance;

  List<AppNotification> _notifications = [];
  bool _loading = false;
  String? _error;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.read).length;
  bool get loading => _loading;
  String? get error => _error;

  // ─── Fetch from backend ────────────────────────────────────────────────────

  Future<void> fetchNotifications() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api.get('/notifications', auth: true);
      final raw = res['notifications'] as List<dynamic>? ??
          res['data'] as List<dynamic>? ??
          [];
      _notifications = raw
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Failed to load notifications.';
    }
    _loading = false;
    notifyListeners();
  }

  // ─── Register device FCM token ─────────────────────────────────────────────

  Future<void> registerToken(String token) async {
    try {
      await _api.post('/notifications/register-token',
          body: {'token': token}, auth: true);
    } catch (_) {
      // non-fatal
    }
  }

  Future<void> unregisterToken(String token) async {
    try {
      await _api.post('/notifications/unregister-token',
          body: {'token': token}, auth: true);
    } catch (_) {
      // non-fatal
    }
  }

  // ─── Mark read ─────────────────────────────────────────────────────────────

  Future<void> markAsRead(String id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx < 0) return;
    _notifications[idx] = _notifications[idx].copyWith(read: true);
    notifyListeners();
    try {
      await _api.patch('/notifications/$id/read', body: {}, auth: true);
    } catch (_) {
      // non-fatal — optimistic update stays
    }
  }

  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(read: true);
    }
    notifyListeners();
    try {
      await _api.patch('/notifications/read-all', body: {}, auth: true);
    } catch (_) {
      // non-fatal
    }
  }

  // ─── Local helpers (still used by UI) ─────────────────────────────────────

  void addNotification({
    required String title,
    required String message,
    NoticeType type = NoticeType.info,
  }) {
    _notifications.insert(
      0,
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        type: type,
        time: 'Just now',
        read: false,
      ),
    );
    notifyListeners();
  }

  /// Delete a single notification — optimistic, synced with backend.
  Future<void> removeNotification(String id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    AppNotification? removed;
    if (idx >= 0) {
      removed = _notifications[idx];
      _notifications.removeAt(idx);
      notifyListeners();
    }
    try {
      await _api.delete('/notifications/$id', auth: true);
    } catch (_) {
      // Restore on failure
      if (removed != null) {
        _notifications.insert(idx >= 0 ? idx : 0, removed);
        notifyListeners();
      }
    }
  }

  /// Delete ALL notifications — optimistic, synced with backend.
  Future<void> clearAll() async {
    final backup = List<AppNotification>.from(_notifications);
    _notifications.clear();
    notifyListeners();
    try {
      await _api.delete('/notifications', auth: true);
    } catch (_) {
      // Restore on failure
      _notifications = backup;
      notifyListeners();
    }
  }

  void reset() {
    _notifications.clear();
    _loading = false;
    _error = null;
    notifyListeners();
  }
}
