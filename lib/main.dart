import 'package:firebase_core/firebase_core.dart';            // ← NEW
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'core/services/local_notification_service.dart';
import 'core/services/fcm_service.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'providers/address_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/coupon_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/waiting_screen.dart';
import 'screens/main_shell.dart';
import 'screens/splash/startup_splash_screen.dart';

// Global navigator key for handling deep links
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
String? _initialDeepLink;
final AppLinks _appLinks = AppLinks();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Capture initial deep link before app fully launches
  try {
    _appLinks.uriLinkStream.first.then((uri) {
      if (uri != null) {
        _initialDeepLink = uri.toString();
      }
    }).catchError((e) {
      print('[DeepLink] Error getting initial link: $e');
    });
  } catch (e) {
    print('[DeepLink] Error getting initial link: $e');
  }

  // ── Firebase init (required before FirebaseMessaging can be used) ─────────
  await Firebase.initializeApp();                              // ← NEW

  // Initialise local notifications (requests permission on Android 13+)
  await LocalNotificationService.instance.init();

  // Initialize FCM listeners (foreground messages, background clicks)
  await FCMService.instance.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MotoCrafterApp());
}

class MotoCrafterApp extends StatelessWidget {
  const MotoCrafterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => CouponProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NSSON Moto Crafter',
        theme: AppTheme.light,
        onGenerateRoute: AppRouter.onGenerateRoute,
        navigatorKey: navigatorKey,
        home: const StartupSplashScreen(child: _AuthGate()),
      ),
    );
  }
}

/// Auth gate: routes user to login, waiting, or main shell based on auth state.
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  @override
  void initState() {
    super.initState();
    final auth      = context.read<AuthProvider>();
    final cart      = context.read<CartProvider>();
    final orders    = context.read<OrderProvider>();
    final addresses = context.read<AddressProvider>();
    final products  = context.read<ProductProvider>();
    final notifications = context.read<NotificationProvider>();
    final coupons   = context.read<CouponProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      products.loadAll();
    });

    auth.onLoginSuccess = () async {
      await Future.wait<void>([
        cart.fetchCart(),
        orders.fetchOrders(),
        addresses.loadAddresses(),
        notifications.fetchNotifications(),
        coupons.fetchCoupons(),
      ]);
      // FCM token sync is handled inside AuthProvider.login() and
      // tryAutoLogin() — no extra call needed here.
    };

    auth.onLogout = () {
      cart.reset();
      orders.reset();
      addresses.reset();
      notifications.reset();
      coupons.reset();
    };

    auth.tryAutoLogin();

    // ── Handle initial deep link and listen for future ones ───────────────
    _handleDeepLink(_initialDeepLink);

    // Listen for deep links while app is running
    _appLinks.uriLinkStream.listen(
      (uri) {
        final link = uri.toString();
        print('[DeepLink] New deep link received: $link');
        _handleDeepLink(link);
      },
      onError: (err) {
        print('[DeepLink] Error receiving link: $err');
      },
    );
  }

  void _handleDeepLink(String? link) {
    if (link == null || link.isEmpty) return;

    print('[DeepLink] Processing: $link');
    final uri = Uri.tryParse(link);
    if (uri == null) return;

    // Route based on deep link scheme/path
    if ((uri.scheme == 'nssonmotocrafter' && uri.host == 'reset-password') ||
        uri.path == '/reset-password') {
      final token = uri.queryParameters['token'] ?? '';
      print('[DeepLink] Routing to reset-password with token: $token');
      navigatorKey.currentState?.pushNamed(
        'nssonmotocrafter://reset-password',
        arguments: token,
      );
    }
  }

  @override
  void dispose() {
    // Clean up deep link listener if needed
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.initializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!auth.isLoggedIn) return const LoginScreen();
    if (!auth.isApproved) return const WaitingScreen();
    return const MainShell();
  }
}
