import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );

  static const String _tokenKey = 'auth_token';
  static const Duration _timeout = Duration(seconds: 25);

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl.replaceAll(RegExp(r'/$'), '');
    }

    if (kIsWeb) return 'http://localhost:8080/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080/api';
    return 'http://localhost:8080/api';
  }

  static String get backendHost => baseUrl.replaceFirst(RegExp(r'/api$'), '');

  // ─── Token helpers ────────────────────────────────────────────────────────

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ─── Header builders ─────────────────────────────────────────────────────

  Map<String, String> _jsonHeaders() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Uri _uri(String path) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$cleanPath');
  }

  // ─── Generic request helpers ──────────────────────────────────────────────

  Future<Map<String, dynamic>> get(String path, {bool auth = false}) async {
    final response = await http
        .get(_uri(path), headers: auth ? await _authHeaders() : _jsonHeaders())
        .timeout(_timeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final response = await http
        .post(
          _uri(path),
          headers: auth ? await _authHeaders() : _jsonHeaders(),
          body: jsonEncode(body ?? <String, dynamic>{}),
        )
        .timeout(_timeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final response = await http
        .put(
          _uri(path),
          headers: auth ? await _authHeaders() : _jsonHeaders(),
          body: jsonEncode(body ?? <String, dynamic>{}),
        )
        .timeout(_timeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final response = await http
        .patch(
          _uri(path),
          headers: auth ? await _authHeaders() : _jsonHeaders(),
          body: jsonEncode(body ?? <String, dynamic>{}),
        )
        .timeout(_timeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String path, {bool auth = false}) async {
    final response = await http
        .delete(
          _uri(path),
          headers: auth ? await _authHeaders() : _jsonHeaders(),
        )
        .timeout(_timeout);
    return _handleResponse(response);
  }

  // ─── Image URL resolver ────────────────────────────────────────────────────

  /// Resolves image URLs from the backend.
  /// - Cloudinary / absolute https URLs → returned as-is.
  /// - Protocol-relative //... → prefixed with https:.
  /// - Relative /uploads/... → prefixed with backendHost.
  /// - Relative uploads/... → prefixed with backendHost/.
  static String resolveImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return '';

    // ── Step 1: remap localhost / 127.0.0.1 to the real backend host FIRST
    // so that http://localhost:8080/... URLs returned by the backend work on
    // both Android emulator (10.0.2.2) and physical devices.
    String value = rawUrl
        .trim()
        .replaceFirst(RegExp(r'http://localhost:8080', caseSensitive: false), backendHost)
        .replaceFirst(RegExp(r'http://127\.0\.0\.1:8080', caseSensitive: false), backendHost);

    final lower = value.toLowerCase();

    // ── Step 2: absolute https / http URLs are used as-is after remapping
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return value;
    }

    // ── Step 3: protocol-relative
    if (value.startsWith('//')) {
      return 'https:$value';
    }

    // ── Step 4: root-relative path
    if (value.startsWith('/')) {
      return '$backendHost$value';
    }

    // ── Step 5: relative path like uploads/...
    if (lower.startsWith('uploads/')) {
      return '$backendHost/$value';
    }

    return value;
  }

  // ─── Response handler ─────────────────────────────────────────────────────

  Map<String, dynamic> _handleResponse(http.Response response) {
    dynamic decoded;

    try {
      decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
    } catch (_) {
      decoded = <String, dynamic>{'message': response.body};
    }

    final body = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{'data': decoded};

    if (kDebugMode) {
      debugPrint('[API] ${response.request?.method} ${response.request?.url}');
      debugPrint('[API] status=${response.statusCode}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = body['error'] ??
        body['message'] ??
        body['details'] ??
        'Something went wrong';

    throw ApiException(response.statusCode, message.toString());
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
