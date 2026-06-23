import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/api_service.dart';
import '../../core/services/razorpay_service.dart';
import '../../core/services/local_notification_service.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../data/models.dart';
import '../../providers/notification_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/coupon_provider.dart';
import '../profile/address_screen.dart';
import '../../core/widgets/animations.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, this.initialCouponCode});

  final String? initialCouponCode;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _couponCtrl = TextEditingController();

  bool _loading = false;
  bool _success = false;
  String _paymentMethod = 'cash_on_delivery';
  bool _useSavedAddress = false;
  Address? _selectedAddress;

  // ── Coupon state ───────────────────────────────────────────────────────────
  String? _appliedCouponCode;
  String? _appliedCouponId;
  double? _discountAmount;
  double? _finalAmount;
  bool _couponLoading = false;

  // ── Razorpay countdown state ───────────────────────────────────────────────
  Timer? _countdownTimer;
  String? _countdownText;
  DateTime? _paymentExpiry;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl.text = user?.name ?? '';
    _phoneCtrl.text = user?.phone ?? '';
    _addressCtrl.text = user?.address ?? '';
    _couponCtrl.text = widget.initialCouponCode?.toUpperCase() ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addrProvider = context.read<AddressProvider>();
      addrProvider.loadAddresses().then((_) {
        if (addrProvider.defaultAddress != null) {
          setState(() {
            _selectedAddress = addrProvider.defaultAddress;
            _useSavedAddress = true;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    _couponCtrl.dispose();
    super.dispose();
  }

  // ─── Order payload ────────────────────────────────────────────────────────
  Map<String, dynamic> _buildOrderPayload(String paymentMethod) {
    return <String, dynamic>{
      'paymentMethod': paymentMethod,
      if (_useSavedAddress && _selectedAddress != null)
        'shippingAddressId': _selectedAddress!.id,
      if (!_useSavedAddress)
        'shippingAddress': {
          'fullName': _nameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'addressLine1': _addressCtrl.text.trim(),
          'city': _cityCtrl.text.trim(),
          'state': _stateCtrl.text.trim(),
          'postalCode': _pincodeCtrl.text.trim(),
          'country': 'IN',
        },
      if (_appliedCouponCode != null) 'couponCode': _appliedCouponCode,
      if (_appliedCouponId != null) 'couponId': _appliedCouponId,
    };
  }

  // ─── Coupon helpers ───────────────────────────────────────────────────────
  Future<void> _applyCoupon() async {
    final code = _couponCtrl.text.trim().toUpperCase();
    if (code.isEmpty) return;

    final cart = context.read<CartProvider>();
    final couponProvider = context.read<CouponProvider>();
    setState(() => _couponLoading = true);

    final res = await couponProvider.applyCoupon(code, cart.total);
    if (!mounted) return;

    if (res != null && res['success'] == true) {
      final data = res['data'] as Map<String, dynamic>;
      setState(() {
        _appliedCouponCode = data['code']?.toString() ?? code;
        _appliedCouponId = data['couponId']?.toString();
        _discountAmount = _asDouble(data['discountAmount']);
        _finalAmount = _asDouble(data['finalAmount']);
        _couponLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Coupon applied! You save Rs ${_discountAmount?.toStringAsFixed(0) ?? '0'}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() => _couponLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(couponProvider.error ?? 'Invalid or expired coupon'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _removeCoupon() {
    setState(() {
      _appliedCouponCode = null;
      _appliedCouponId = null;
      _discountAmount = null;
      _finalAmount = null;
    });
    _couponCtrl.clear();
  }

  static double _asDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  // ─── Countdown helpers ────────────────────────────────────────────────────
  void _startCountdown(DateTime expiresAt) {
    _paymentExpiry = expiresAt;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final remaining =
          _paymentExpiry?.difference(DateTime.now()) ?? Duration.zero;
      if (remaining.isNegative) {
        _stopCountdown();
        return;
      }
      setState(() {
        final minutes =
            remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
        final seconds =
            remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
        _countdownText = '$minutes:$seconds';
      });
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    if (!mounted) return;
    setState(() => _countdownText = null);
  }

  // ─── Place order ──────────────────────────────────────────────────────────
  Future<void> _placeOrder() async {
    if (!_useSavedAddress && !_formKey.currentState!.validate()) return;
    if (_useSavedAddress && _selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    setState(() => _loading = true);
    final cart = context.read<CartProvider>();
    final auth = context.read<AuthProvider>();

    // ── Razorpay flow ────────────────────────────────────────────────────────
    if (_paymentMethod == 'razorpay_upi') {
      final user = auth.user;

      Map<String, dynamic> initiateRes;
      try {
        initiateRes = await RazorpayService.instance.initiate(
          shippingAddressId: (_useSavedAddress && _selectedAddress != null)
              ? _selectedAddress!.id
              : null,
          shippingAddress: (!_useSavedAddress)
              ? {
                  'fullName': _nameCtrl.text.trim(),
                  'phone': _phoneCtrl.text.trim(),
                  'addressLine1': _addressCtrl.text.trim(),
                  'city': _cityCtrl.text.trim(),
                  'state': _stateCtrl.text.trim(),
                  'postalCode': _pincodeCtrl.text.trim(),
                  'country': 'IN',
                }
              : null,
          couponCode: _appliedCouponCode,
          couponId: _appliedCouponId,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is ApiException
                ? e.message
                : 'Could not start payment. Try again.'),
            backgroundColor: AppColors.danger,
          ),
        );
        setState(() => _loading = false);
        return;
      }

      final rzpKey = initiateRes['key']?.toString() ?? '';
      final rzpAmount = (initiateRes['amount'] as num?)?.toInt() ?? 0;
      final rzpCurrency = initiateRes['currency']?.toString() ?? 'INR';
      final razorpayOrderId = initiateRes['razorpayOrderId']?.toString() ?? '';
      final appOrderId = initiateRes['appOrderId']?.toString() ?? '';
      final expiresAtStr = initiateRes['expiresAt']?.toString();

      if (expiresAtStr != null) {
        _startCountdown(DateTime.parse(expiresAtStr));
      }

      final sdkResult = await RazorpayService.instance.openCheckout(
        key: rzpKey,
        amount: rzpAmount,
        currency: rzpCurrency,
        razorpayOrderId: razorpayOrderId,
        name: user?.name ?? _nameCtrl.text.trim(),
        email: user?.email ?? '',
        phone: user?.phone ?? _phoneCtrl.text.trim(),
      );
      _stopCountdown();
      if (!mounted) return;

      if (sdkResult['success'] != true) {
        if (appOrderId.isNotEmpty) {
          RazorpayService.instance
              .cancel(appOrderId: appOrderId)
              .catchError((err) {
            debugPrint('[Checkout] Failed to auto-cancel order: $err');
            return <String, dynamic>{};
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(sdkResult['error'] ??
                'Payment failed. Your cart is safe — try again.'),
            backgroundColor: AppColors.danger,
          ),
        );
        setState(() => _loading = false);
        return;
      }

      final verifyRes = await RazorpayService.instance.verify(
        razorpayOrderId: sdkResult['orderId']?.toString() ?? '',
        razorpayPaymentId: sdkResult['paymentId']?.toString() ?? '',
        razorpaySignature: sdkResult['signature']?.toString() ?? '',
        appOrderId: appOrderId,
      );
      if (!mounted) return;

      if (verifyRes['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((verifyRes['error']?.toString().isNotEmpty == true)
                ? verifyRes['error'].toString()
                : (verifyRes['message']?.toString().isNotEmpty == true)
                    ? verifyRes['message'].toString()
                    : 'Payment verification failed'),
            backgroundColor: AppColors.danger,
          ),
        );
        setState(() => _loading = false);
        return;
      }

      if (mounted) {
        context.read<NotificationProvider>().addNotification(
              title: 'Order Placed',
              message:
                  'Your Razorpay order of Rs\u00a0${cart.total.toStringAsFixed(0)} has been placed. We\u2019ll confirm it shortly.',
              type: NoticeType.info,
            );
        LocalNotificationService.instance.showOrderNotification(
          title: 'Order Placed ✅',
          body:
              'Your order of ₹${cart.total.toStringAsFixed(0)} has been placed. We\'ll confirm it shortly!',
        );
      }

      cart.reset();
      setState(() {
        _loading = false;
        _success = true;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
      return;
    }

    // ── COD flow ──────────────────────────────────────────────────────────────
    final orderProvider = context.read<OrderProvider>();
    final success = await orderProvider.placeOrder(
      orderPayload: _buildOrderPayload(_paymentMethod),
    );

    if (!success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(orderProvider.error ?? 'Order failed')),
      );
      setState(() => _loading = false);
      return;
    }

    if (mounted) {
      context.read<NotificationProvider>().addNotification(
            title: 'Order Placed',
            message:
                'Your COD order of Rs\u00a0${cart.total.toStringAsFixed(0)} has been placed. We\u2019ll confirm it shortly.',
            type: NoticeType.info,
          );
      LocalNotificationService.instance.showOrderNotification(
        title: 'Order Placed ✅',
        body:
            'Your COD order of ₹${cart.total.toStringAsFixed(0)} has been placed. We\'ll confirm it shortly!',
      );
    }

    cart.reset();
    setState(() {
      _loading = false;
      _success = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_success) return _buildSuccessView();

    final cart = context.watch<CartProvider>();
    final addrProvider = context.watch<AddressProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.checkout),
        backgroundColor: AppColors.surface,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            // ── Delivery Address ─────────────────────────────────────────
            _buildSection(
              title: 'Delivery Address',
              icon: Icons.location_on_outlined,
              children: [
                if (addrProvider.addresses.isNotEmpty) ...[
                  ...addrProvider.addresses
                      .map((addr) => _buildAddressOption(addr)),
                  const SizedBox(height: 8),
                  const Divider(),
                ],
                _buildNewAddressToggle(),
                if (!_useSavedAddress) ...[
                  const SizedBox(height: 14),
                  _buildNewAddressForm(),
                ],
                const SizedBox(height: 8),
                // FIX: wrapped in SizedBox(width: double.infinity) so the
                // button's `minimumSize: Size(double.infinity, 44)` gets a
                // tight width constraint from its parent instead of the
                // loose constraint a bare Column child provides. Without
                // this wrapper, Flutter throws "BoxConstraints forces an
                // infinite width", which breaks layout for the whole
                // ListView and makes the entire page un-tappable.
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push<Address>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AddressScreen(selectionMode: true),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          _selectedAddress = result;
                          _useSavedAddress = true;
                        });
                      }
                    },
                    icon:
                        const Icon(Icons.add_location_alt_outlined, size: 18),
                    label: const Text('Add New Address'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Payment Method ────────────────────────────────────────────
            _buildSection(
              title: AppStrings.paymentMethod,
              icon: Icons.payment_outlined,
              children: [
                _buildPaymentOption(
                  value: 'cash_on_delivery',
                  title: 'Cash on Delivery',
                  subtitle: 'Pay when you receive your order',
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.local_shipping_outlined,
                        color: AppColors.primary, size: 22),
                  ),
                ),
                const SizedBox(height: 10),
                _buildPaymentOption(
                  value: 'razorpay_upi',
                  title: 'Razorpay',
                  subtitle: 'UPI, Cards, Net Banking',
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        'assets/razorpay-logo.png',
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: AppColors.primary,
                            size: 22),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Order Summary ─────────────────────────────────────────────
            _buildSection(
              title: AppStrings.orderSummary,
              icon: Icons.receipt_long_outlined,
              children: [
                ...cart.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.name} x ${item.quantity}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary),
                            ),
                          ),
                          Text(
                            'Rs ${item.price * item.quantity}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ],
                      ),
                    )),
                const Divider(),
                _row('Subtotal', 'Rs ${cart.subtotal}'),
                _row('Shipping', 'FREE', valueColor: AppColors.success),
                if (_discountAmount != null && _discountAmount! > 0)
                  _row(
                    'Discount (${_appliedCouponCode ?? ''})',
                    '- Rs ${_discountAmount!.toStringAsFixed(0)}',
                    valueColor: AppColors.success,
                  ),
                const Divider(),
                _row('Total', 'Rs ${cart.total.toStringAsFixed(0)}',
                    isBold: true, fontSize: 16),
                _row(
                  'Amount to Pay',
                  'Rs ${(_finalAmount ?? cart.total).toStringAsFixed(0)}',
                  isBold: true,
                  fontSize: 18,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Coupon Section ────────────────────────────────────────────
            _buildSection(
              title: 'Apply Coupon',
              icon: Icons.local_offer_outlined,
              children: [
                if (_appliedCouponCode == null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _couponCtrl,
                          enabled: !_couponLoading,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: 'Enter coupon code',
                            hintStyle:
                                const TextStyle(color: AppColors.textTertiary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: AppColors.border),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _applyCoupon(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 46,
                        child: FilledButton(
                          onPressed: _couponLoading ? null : _applyCoupon,
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _couponLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, '/coupons'),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.card_giftcard_outlined,
                              size: 16, color: AppColors.primary),
                          SizedBox(width: 6),
                          Text(
                            'Browse available coupons',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: AppColors.success.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppColors.success, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _appliedCouponCode!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppColors.success,
                                ),
                              ),
                              Text(
                                'You save Rs ${_discountAmount?.toStringAsFixed(0) ?? '0'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _removeCoupon,
                          icon: const Icon(Icons.close,
                              color: AppColors.success, size: 18),
                          tooltip: 'Remove coupon',
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // ── Countdown banner ──────────────────────────────────────────
            if (_countdownText != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Payment expires in $_countdownText',
                      style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ],
                ),
              ),

            // ── Place Order button ─────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _loading ? null : _placeOrder,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : Icon(
                        _paymentMethod == 'razorpay_upi'
                            ? Icons.account_balance_wallet_outlined
                            : Icons.check_circle_outline,
                        size: 20,
                      ),
                label: Text(
                  _loading
                      ? (_paymentMethod == 'razorpay_upi'
                          ? (_countdownText != null
                              ? 'Waiting for payment...'
                              : 'Initiating Razorpay...')
                          : 'Placing Order...')
                      : (_paymentMethod == 'razorpay_upi'
                          ? 'Pay with Razorpay'
                          : AppStrings.placeOrder),
                  style: const TextStyle(fontSize: 16),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: _paymentMethod == 'razorpay_upi'
                      ? const Color(0xFF072654)
                      : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─── Helper widgets ───────────────────────────────────────────────────────

  Widget _buildAddressOption(Address addr) {
    final isSelected = _useSavedAddress && _selectedAddress?.id == addr.id;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedAddress = addr;
        _useSavedAddress = true;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBg : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withOpacity(0.5)
                : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        addr.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.borderLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          addr.addressType.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                      if (addr.isDefault) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'DEFAULT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    addr.displayShort,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    addr.phone,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewAddressToggle() {
    final isSelected = !_useSavedAddress;
    return GestureDetector(
      onTap: () => setState(() => _useSavedAddress = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBg : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withOpacity(0.5)
                : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            const Icon(Icons.add_location_alt_outlined,
                color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Enter new address',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewAddressForm() {
    return Column(
      children: [
        TextFormField(
          controller: _nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person_outline, size: 20),
          ),
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(Icons.phone_outlined, size: 20),
          ),
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _addressCtrl,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Address',
            prefixIcon: Icon(Icons.location_on_outlined, size: 20),
            alignLabelWithHint: true,
          ),
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cityCtrl,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _stateCtrl,
                decoration: const InputDecoration(labelText: 'State'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _pincodeCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Pincode'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String title,
    required String subtitle,
    required Widget leading,
  }) {
    final isSelected = _paymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBg : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withOpacity(0.5)
                : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value,
      {bool isBold = false, double fontSize = 14, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                color:
                    isBold ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
                fontSize: fontSize,
              )),
          Text(value,
              style: TextStyle(
                color: valueColor ??
                    (isBold ? AppColors.primary : AppColors.textPrimary),
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                fontSize: fontSize,
              )),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleIn(
              child: Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 64,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.orderSuccess,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Redirecting to your orders...',
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}
