import 'dart:async';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'api_service.dart';

/// Handles the new Razorpay payment flow for Moto Crafter.
///
/// Flow:
///   1. Call [initiate] → backend creates Razorpay order + reserves stock.
///   2. Open Razorpay SDK using the returned options.
///   3. On success callback, call [verify] with the SDK response.
///   4. On app reopen with a pending order, call [pollStatus].
class RazorpayService {
  RazorpayService._();
  static final RazorpayService instance = RazorpayService._();

  final _api = ApiService.instance;
  Razorpay? _razorpay;
  Completer<Map<String, dynamic>>? _completer;


  // ─── Step 1: Initiate ───────────────────────────────────────────────────────

  /// Calls POST /payments/razorpay/initiate.
  ///
  /// Provide either [shippingAddressId] (for saved addresses) or a full
  /// [shippingAddress] map. Returns the raw backend response which includes
  /// `key`, `amount`, `currency`, `razorpayOrderId`, `appOrderId`,
  /// `paymentId`, and `expiresAt`.
  Future<Map<String, dynamic>> initiate({
    String? shippingAddressId,
    Map<String, dynamic>? shippingAddress,
   String? couponCode,
    String? couponId,
  }) async {
    final body = <String, dynamic>{};
    if (shippingAddressId != null) {
      body['shippingAddressId'] = shippingAddressId;
    } else if (shippingAddress != null) {
      body['shippingAddress'] = shippingAddress;
    }

if (couponCode != null) {
      body['couponCode'] = couponCode;
    }
    if (couponId != null) {
      body['couponId'] = couponId;
    }

    try {
      final res = await _api.post(
        '/payments/razorpay/initiate',
        body: body,
        auth: true,
      );
      return res;
    } on ApiException {
      rethrow;
    }
  }

  // ─── Step 2: Open SDK ───────────────────────────────────────────────────────

  /// Opens the Razorpay SDK with options from the [initiate] response.
  /// Returns a map with `success` (bool) and SDK response fields.
  Future<Map<String, dynamic>> openCheckout({
    required String key,
    required int amount,
    required String currency,
    required String razorpayOrderId,
    required String name,
    required String email,
    required String phone,
    String storeName = 'NSSON Store',
    String description = 'Order Payment',
    int timeoutSeconds = 180,
  }) async {
    _clear();
    _razorpay = Razorpay();
    _completer = Completer<Map<String, dynamic>>();

    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);

    final options = <String, dynamic>{
      'key': key,
      'amount': amount,
      'currency': currency,
      'order_id': razorpayOrderId,
      'name': storeName,
      'description': description,
      'timeout': timeoutSeconds,
      'prefill': {
        'contact': phone,
        'email': email,
        'name': name,
      },
      'theme': {'color': '#072654'},
    };

    try {
      _razorpay!.open(options);
      return await _completer!.future;
    } catch (e) {
      _clear();
      return {'success': false, 'error': 'Could not open Razorpay: $e'};
    }
  }

  // ─── Step 3: Verify ─────────────────────────────────────────────────────────

  /// Calls POST /payments/razorpay/verify after the SDK success callback.
  /// [appOrderId] comes from the [initiate] response.
  Future<Map<String, dynamic>> verify({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String appOrderId,
  }) async {
    try {
      final res = await _api.post(
        '/payments/razorpay/verify',
        body: {
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
          'appOrderId': appOrderId,
        },
        auth: true,
      );
      return {
        'success': res['success'] == true,
        'message': res['message'] ?? '',
        ...res,
      };
    } on ApiException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ─── Step 3.5: Cancel ───────────────────────────────────────────────────────

  /// Calls POST /payments/razorpay/cancel to release stock and cancel the order immediately.
  Future<Map<String, dynamic>> cancel({required String appOrderId}) async {
    try {
      final res = await _api.post(
        '/payments/razorpay/cancel',
        body: {'appOrderId': appOrderId},
        auth: true,
      );
      return {
        'success': res['success'] == true,
        'message': res['message'] ?? '',
        ...res,
      };
    } on ApiException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ─── Step 4 (Fallback): Poll Status ─────────────────────────────────────────

  /// Calls GET /payments/status/:appOrderId.
  /// Use when the app restarts and there might be a pending payment.
  /// Returns `paymentStatus`, `orderStatus`, `orderPaymentStatus`, and
  /// optionally `recoveredByPoll: true` if payment was auto-recovered.
  Future<Map<String, dynamic>> pollStatus(String appOrderId) async {
    try {
      final res = await _api.get(
        '/payments/status/$appOrderId',
        auth: true,
      );
      return res;
    } on ApiException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ─── SDK callbacks ──────────────────────────────────────────────────────────

  void _onSuccess(PaymentSuccessResponse response) {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete({
        'success': true,
        'paymentId': response.paymentId,
        'orderId': response.orderId,       // razorpay order id
        'signature': response.signature,
      });
    }
    _clear();
  }

  void _onError(PaymentFailureResponse response) {
    if (_completer != null && !_completer!.isCompleted) {
      String errMsg = response.message ?? 'Payment was not completed';
      if (errMsg.trim().toLowerCase() == 'undefined' || errMsg.trim().isEmpty) {
        errMsg = 'Payment cancelled';
      }
      _completer!.complete({
        'success': false,
        'error': errMsg,
      });
    }
    _clear();
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete({
        'success': false,
        'error':
            'External wallet (${response.walletName}) is not supported. Please choose another method.',
      });
    }
    _clear();
  }

  void _clear() {
    _razorpay?.clear();
    _razorpay = null;
  }

  void dispose() => _clear();
}

