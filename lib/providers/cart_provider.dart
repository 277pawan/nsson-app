import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../data/models.dart';

class CartProvider extends ChangeNotifier {
  final ApiService _api = ApiService.instance;

  List<CartItem> _items = [];
  bool _loading = false;
  String? _error;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  String? get error => _error;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  int get subtotal =>
      _items.fold(0, (sum, item) => sum + item.price * item.quantity);
 double get gstAmount => 0.0;
  double get total => subtotal.toDouble();

  void reset() {
    _items = [];
    _loading = false;
    _error = null;
    notifyListeners();
  }

  bool isInCart(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  int getQuantity(String productId) {
    final idx = _items.indexWhere((item) => item.productId == productId);
    return idx >= 0 ? _items[idx].quantity : 0;
  }

  /// Fetch the user's cart from the backend.
  Future<void> fetchCart() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api.get('/cart', auth: true);
      final data = res['data'] as Map<String, dynamic>;
      final rawItems = data['items'] as List<dynamic>? ?? [];
      _items = rawItems
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      _items = [];
      _error = e.message;
    } catch (e) {
      _items = [];
      _error = 'Failed to load cart. Please try again.';
    }
    _loading = false;
    notifyListeners();
  }

  /// Add a product to the backend cart, then refresh local state.
  Future<bool> addToCart(Product product, {int quantity = 1}) async {
    _error = null;
    try {
      final res = await _api.post('/cart',
          body: {
            'productId': product.id,
            'quantity': quantity,
          },
          auth: true);
      _parseCartResponse(res);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Failed to add item to cart. Please try again.';
    }
    notifyListeners();
    return false;
  }

  Future<bool> removeFromCart(String productId) async {
    _error = null;
    try {
      final res = await _api.delete('/cart/$productId', auth: true);
      _parseCartResponse(res);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Failed to remove item from cart. Please try again.';
    }
    notifyListeners();
    return false;
  }

  Future<bool> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      return removeFromCart(productId);
    }
    _error = null;
    try {
      final res = await _api.put('/cart/$productId',
          body: {'quantity': quantity}, auth: true);
      _parseCartResponse(res);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Failed to update cart quantity. Please try again.';
    }
    notifyListeners();
    return false;
  }

  Future<bool> increment(String productId) async {
    final idx = _items.indexWhere((item) => item.productId == productId);
    if (idx >= 0) {
      return updateQuantity(productId, _items[idx].quantity + 1);
    }
    return false;
  }

  Future<bool> decrement(String productId) async {
    final idx = _items.indexWhere((item) => item.productId == productId);
    if (idx >= 0) {
      return updateQuantity(productId, _items[idx].quantity - 1);
    }
    return false;
  }

  Future<bool> clearCart() async {
    _error = null;
    try {
      await _api.delete('/cart', auth: true);
      _items = [];
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Failed to clear cart. Please try again.';
    }
    notifyListeners();
    return false;
  }

  void _parseCartResponse(Map<String, dynamic> res) {
    final data = res['data'] as Map<String, dynamic>?;
    if (data == null) return;
    final rawItems = data['items'] as List<dynamic>? ?? [];
    _items = rawItems
        .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
