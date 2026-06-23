import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../data/models.dart';
class CouponProvider extends ChangeNotifier {
  final ApiService _api = ApiService.instance;
  List<AppCoupon> _publicCoupons = [];
  List<AppCoupon> _privateCoupons = [];
  bool _loading = false;
  String? _error;
  List<AppCoupon> get publicCoupons => List.unmodifiable(_publicCoupons);
  List<AppCoupon> get privateCoupons => List.unmodifiable(_privateCoupons);
  bool get loading => _loading;
  String? get error => _error;
  void reset() {
    _publicCoupons = [];
    _privateCoupons = [];
    _loading = false;
    _error = null;
    notifyListeners();
  }
  Future<void> fetchCoupons() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      // Fetch public coupons
      final publicRes = await _api.get('/coupon', auth: true);
      final rawPublic = publicRes['coupons'] as List<dynamic>? ??
          publicRes['data'] as List<dynamic>? ??
          [];
      _publicCoupons = rawPublic
          .map((e) => AppCoupon.fromJson(e as Map<String, dynamic>))
          .toList();
      // Fetch private coupons
      final privateRes = await _api.get('/coupon/mine', auth: true);
      final rawPrivate = privateRes['coupons'] as List<dynamic>? ??
          privateRes['data'] as List<dynamic>? ??
          [];
      _privateCoupons = rawPrivate
          .map((e) => AppCoupon.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load coupons.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  Future<Map<String, dynamic>?> applyCoupon(String code, double orderAmount) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api.post(
        '/coupons/apply',
        body: {
          'code': code.trim().toUpperCase(),
          'orderAmount': orderAmount,
        },
        auth: true,
      );
      _loading = false;
      notifyListeners();
      return res;
    } on ApiException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = 'Failed to apply coupon. Please try again.';
      _loading = false;
      notifyListeners();
      return null;
    }
  }
}
