import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../data/models.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService _api = ApiService.instance;

  List<AppOrder> _orders = [];
  bool _loading = false;
  String? _error;

  List<AppOrder> get orders => List.unmodifiable(_orders);
  bool get loading => _loading;
  String? get error => _error;
  int get orderCount => _orders.length;

  void reset() {
    _orders = [];
    _loading = false;
    _error = null;
    notifyListeners();
  }

  /// Fetch all orders for the logged-in user from the backend.
  Future<void> fetchOrders() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api.get('/orders', auth: true);
      final rawOrders = res['data'] as List<dynamic>? ?? [];
      _orders = rawOrders
          .map((e) => AppOrder.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      _orders = [];
      _error = e.message;
    } catch (e) {
      _orders = [];
      _error = 'Failed to load orders. Please try again.';
    }
    _loading = false;
    notifyListeners();
  }

  /// Place a new order and return the created AppOrder (or null on failure).
  Future<AppOrder?> placeOrderAndReturn({
    required Map<String, dynamic> orderPayload,
  }) async {
    _error = null;
    try {
      final res = await _api.post(
        '/orders',
        body: orderPayload,
        auth: true,
      );
      final orderData = (res['data'] ?? res['order']) as Map<String, dynamic>;
      final order = AppOrder.fromJson(orderData);
      _orders.insert(0, order);
      notifyListeners();
      return order;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      _error = 'Failed to place order. Please try again.';
      notifyListeners();
      return null;
    }
  }

  /// Place a new order through the backend (creates from current cart).
  Future<bool> placeOrder({
    required Map<String, dynamic> orderPayload,
  }) async {
    _loading = true;
    notifyListeners();
    final order = await placeOrderAndReturn(
      orderPayload: orderPayload,
    );
    _loading = false;
    notifyListeners();
    return order != null;
  }

  /// Fetch a single order by ID.
  Future<AppOrder?> getOrderById(String orderId) async {
    try {
      final res = await _api.get('/orders/$orderId', auth: true);
      final data = (res['data'] ?? res['order']) as Map<String, dynamic>;
      return AppOrder.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// Cancel a pending order.
  Future<bool> cancelOrder(String orderId, {String reason = ''}) async {
    _error = null;
    try {
      await _api.put(
        '/orders/$orderId/cancel',
        body: reason.trim().isEmpty ? {} : {'reason': reason.trim()},
        auth: true,
      );
      await fetchOrders();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to cancel order. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Generate next order ID based on existing orders.
  String get nextOrderId {
    int maxId = 1020;
    for (final o in _orders) {
      final parsed = int.tryParse(o.id);
      if (parsed != null && parsed > maxId) {
        maxId = parsed;
      }
    }
    return '${maxId + 1}';
  }

  /// Fallback: poll GET /payments/status/:appOrderId when the app re-opens
  /// and there might be a pending Razorpay payment.
  ///
  /// Returns the full status map from the backend, including:
  ///   `paymentStatus`: "SUCCESS" | "PENDING" | "EXPIRED" | "FAILED"
  ///   `orderStatus`: "processing" | "awaiting_payment" | "cancelled"
  ///   `orderPaymentStatus`: "PAID" | "UNPAID" | "FAILED"
  ///   `recoveredByPoll`: true  ← if payment was auto-recovered
  Future<Map<String, dynamic>?> pollPaymentStatus(String appOrderId) async {
    try {
      final res = await _api.get('/payments/status/$appOrderId', auth: true);
      return res;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      _error = 'Failed to check payment status. Please try again.';
      notifyListeners();
      return null;
    }
  }
}
