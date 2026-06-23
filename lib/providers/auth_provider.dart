import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/api_routes.dart';
import '../core/services/api_service.dart';
import '../core/services/fcm_service.dart';   // ← NEW
import '../data/models.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider();

  final ApiService _api = ApiService.instance;

  static const String _cachedUserKey   = 'cached_user_profile';
  static const String _rememberMeKey   = 'remember_me';
  static const String _savedIdentifier = 'saved_identifier';
  static const String _savedPassword   = 'saved_password';

  UserInfo? _user;
  bool _loading = false;
  bool _initializing = true;
  String? _error;

  Future<void> Function()? onLoginSuccess;
  VoidCallback? onLogout;

  UserInfo? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isApproved => _user?.isApproved ?? false;
  bool get loading => _loading;
  bool get initializing => _initializing;
  String? get error => _error;

  // ── Local cache helpers ───────────────────────────────────────────────────

  Future<void> _saveUserCache(UserInfo user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cachedUserKey, jsonEncode(user.toJson()));
    } catch (_) {}
  }

  Future<UserInfo?> _loadUserCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cachedUserKey);
      if (raw != null) {
        return UserInfo.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  Future<void> _clearUserCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cachedUserKey);
    } catch (_) {}
  }

  // ── Remember Me helpers ──────────────────────────────────────────────────

  Future<void> saveRememberMe(String identifier, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_rememberMeKey, true);
      await prefs.setString(_savedIdentifier, identifier);
      await prefs.setString(_savedPassword, password);
    } catch (_) {}
  }

  Future<void> clearRememberMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_rememberMeKey);
      await prefs.remove(_savedIdentifier);
      await prefs.remove(_savedPassword);
    } catch (_) {}
  }

  Future<Map<String, String>?> getSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remembered = prefs.getBool(_rememberMeKey) ?? false;
      if (!remembered) return null;
      final id  = prefs.getString(_savedIdentifier);
      final pwd = prefs.getString(_savedPassword);
      if (id != null && pwd != null) {
        return {'identifier': id, 'password': pwd};
      }
    } catch (_) {}
    return null;
  }

  // ── FCM Token ─────────────────────────────────────────────────────────────

  /// Gets the FCM token from Firebase and POSTs it to the backend.
  /// Safe to call multiple times — fails silently so it never blocks the user.
  Future<void> syncFcmToken() async {
    try {
      final token = await FCMService.instance.getToken();
      if (token == null) return;

      await _api.post(
        ApiRoutes.saveFcmToken,
        body: {'fcmToken': token},
        auth: true,
      );
      debugPrint('[FCM] Token synced to backend ✓');
    } catch (e) {
      // Non-fatal — push notifications just won't work until next sync.
      debugPrint('[FCM] Token sync failed (non-fatal): $e');
    }
  }

  /// Registers a listener so that when Firebase rotates the token
  /// (e.g. app reinstall, token expiry) it is automatically re-synced.
  void _listenForTokenRefresh() {
    FCMService.instance.onTokenRefresh((newToken) async {
      debugPrint('[FCM] Token refreshed — re-syncing…');
      try {
        await _api.post(
          ApiRoutes.saveFcmToken,
          body: {'fcmToken': newToken},
          auth: true,
        );
        debugPrint('[FCM] Refreshed token synced ✓');
      } catch (e) {
        debugPrint('[FCM] Refresh sync failed: $e');
      }
    });
  }

  Future<void> _subscribeToAllUsersTopic() async {
    try {
      await FCMService.instance.subscribeToAllUsersTopic();
    } catch (_) {
      // Non-fatal — topic subscription is best-effort.
    }
  }

  // ── Auto-login ────────────────────────────────────────────────────────────

  Future<void> tryAutoLogin() async {
    _initializing = true;
    notifyListeners();

    final token = await _api.getToken();
    if (token == null) {
      _initializing = false;
      notifyListeners();
      return;
    }

    // Step 1: restore from local cache instantly so UI shows immediately
    final cached = await _loadUserCache();
    if (cached != null) {
      _user = cached;
      _initializing = false;
      notifyListeners();
      await onLoginSuccess?.call();
      // Sync FCM token on app resume — catches reinstalls / token rotation
      await syncFcmToken();
      await _subscribeToAllUsersTopic();
      _listenForTokenRefresh();
    }

    // Step 2: refresh from API in background
    try {
      final res = await _api.get(ApiRoutes.authMe, auth: true);
      _user = UserInfo.fromJson(res['user']);
      await _saveUserCache(_user!);

      if (cached == null) {
        _initializing = false;
        notifyListeners();
        await onLoginSuccess?.call();
        await syncFcmToken();
        await _subscribeToAllUsersTopic();
        _listenForTokenRefresh();
      } else {
        notifyListeners();
      }
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        await _api.clearToken();
        await _clearUserCache();
        _user = null;
        _initializing = false;
        notifyListeners();
      } else {
        if (cached == null) {
          _user = null;
          _initializing = false;
          notifyListeners();
        }
      }
    } catch (_) {
      if (cached == null) {
        _user = null;
        _initializing = false;
        notifyListeners();
      }
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<bool> login(
    String identifier,
    String password, {
    bool rememberMe = false,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.post(ApiRoutes.authLogin, body: {
        'identifier': identifier.trim(),
        'password': password,
      });
      await _api.saveToken(res['token']);
      _user = UserInfo.fromJson(res['user']);

      await _saveUserCache(_user!);

      if (rememberMe) {
        await saveRememberMe(identifier.trim(), password);
      } else {
        await clearRememberMe();
      }

      _loading = false;
      notifyListeners();
      await onLoginSuccess?.call();

      // Sync FCM token after a successful login.
      // Run in background — don't await so login screen dismisses instantly.
      unawaited(syncFcmToken());
      unawaited(_subscribeToAllUsersTopic());
      _listenForTokenRefresh();

      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection failed. ${e.toString()}';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    String shopName = '',
    String gstNumber = '',
    String address = '',
    String name = '',
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    if (password != confirmPassword) {
      _error = 'Passwords do not match';
      _loading = false;
      notifyListeners();
      return false;
    }

    try {
      final res = await _api.post(ApiRoutes.authRegister, body: {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
        'password': password,
        'confirmPassword': confirmPassword,
        'address': address.trim(),
        'shopDetails': {
          'shopName': shopName.trim(),
          'gstNumber': gstNumber.trim(),
          'businessAddress': address.trim(),
        },
      });

      _user = UserInfo.fromJson(res['user'] ?? {
        'id': 'new_user',
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'role': 'customer',
        'approvalStatus': 'pending',
      });

      await _api.clearToken();
      _loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection failed. ${e.toString()}';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Password helpers ──────────────────────────────────────────────────────

  Future<bool> requestPasswordResetLink(String email) async {
    _error = null;
    // ✂️ Removed _loading = true / notifyListeners() — ForgotPasswordScreen
    // manages its own loading state, and notifyListeners() mid-await was
    // causing the _dependents.isEmpty crash by rebuilding the widget tree
    // while the async call was still in flight.
    try {
      await _api.post(ApiRoutes.forgotPassword, body: {
        'email': email.trim().toLowerCase(),
      });
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Connection failed. ${e.toString()}';
      return false;
    }
  }

  Future<bool> resetPassword(
    String token,
    String newPassword,
    String confirmPassword,
  ) async {
    _loading = true;
    _error = null;
    notifyListeners();

    if (newPassword != confirmPassword) {
      _error = 'Passwords do not match';
      _loading = false;
      notifyListeners();
      return false;
    }

    try {
      final body = {
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      };

      await _api.post(
        ApiRoutes.resetPassword(token.trim()),
        body: body,
      );
      _loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection failed. ${e.toString()}';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    _loading = true;
    _error = null;
    notifyListeners();

    if (newPassword != confirmPassword) {
      _error = 'Passwords do not match';
      _loading = false;
      notifyListeners();
      return false;
    }

    try {
      await _api.post(
        ApiRoutes.changePassword,
        body: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
        auth: true,
      );
      _loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection failed. ${e.toString()}';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> approveUser() async {
    if (_user == null) return;
    _user = _user!.copyWith(status: 'Approved');
    notifyListeners();
  }

  // ── Update Profile ────────────────────────────────────────────────────────

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? shopName,
    String? email,
    String? phone,
    String? address,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    if (_user == null) {
      _error = 'No active session found.';
      _loading = false;
      notifyListeners();
      return false;
    }

    try {
      final body = <String, dynamic>{};
      if (firstName != null && firstName.trim().isNotEmpty) body['firstName'] = firstName.trim();
      if (lastName != null && lastName.trim().isNotEmpty) body['lastName'] = lastName.trim();
      if (email != null && email.trim().isNotEmpty) body['email'] = email.trim().toLowerCase();
      if (phone != null && phone.trim().isNotEmpty) body['phone'] = phone.trim();
      if (address != null && address.trim().isNotEmpty) body['address'] = address.trim();
      if (shopName != null && shopName.trim().isNotEmpty) body['shopDetails'] = {'shopName': shopName.trim()};

      await _api.put(ApiRoutes.authMe, body: body, auth: true);

      final res = await _api.get(ApiRoutes.authMe, auth: true);
      _user = UserInfo.fromJson(res['user']);
      await _saveUserCache(_user!);

      _loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection failed. ${e.toString()}';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    try {
      await _api.post(ApiRoutes.authLogout, auth: true);
    } catch (_) {}

    await _api.clearToken();

    _user = null;
    _error = null;
    notifyListeners();
    onLogout?.call();
  }
}

// ignore: implementation_imports
void unawaited(Future<void> future) {
  future.catchError((e) => debugPrint('[unawaited] $e'));
}
