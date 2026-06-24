import 'package:flutter/material.dart';
import '../../data/models.dart';
import '../../screens/main_shell.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/reset_password_screen.dart';
import '../../screens/auth/waiting_screen.dart';
import '../../screens/products/product_listing_screen.dart';
import '../../screens/products/product_detail_screen.dart';
import '../../screens/cart/checkout_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/orders/order_detail_screen.dart';
import '../../screens/profile/address_screen.dart';
import '../../screens/profile/settings_screen.dart';
import '../../screens/profile/policy_screen.dart';
import '../../screens/profile/help_support_screen.dart';
import '../../screens/profile/about_screen.dart';
import '../../screens/profile/coupons_screen.dart';
class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name;
    final arguments = settings.arguments;
    
    if (routeName != null) {
      final uri = Uri.tryParse(routeName);
      if (uri != null) {
        if ((uri.scheme == 'nssonmotocrafter' && uri.host == 'reset-password') ||
            uri.path == '/reset-password') {
          // Get token from URI query params or from arguments passed by deep link handler
          final token = uri.queryParameters['token'] ?? (arguments as String?) ?? '';
          return _buildRoute(
            ResetPasswordScreen(token: token),
            settings,
          );
        }
      }
    }

    switch (settings.name) {
      case '/':
        return _buildRoute(const MainShell(), settings);

      case '/login':
        return _buildRoute(const LoginScreen(), settings);

      case '/register':
        return _buildRoute(const RegisterScreen(), settings);

      case '/waiting':
        return _buildRoute(const WaitingScreen(), settings);

      case '/products':
        final args = settings.arguments as Map<String, String>?;
        return _buildRoute(
          ProductListingScreen(
            filterCategory: args?['category'],
            filterBrand: args?['brand'],
          ),
          settings,
        );

      case '/product-detail':
        final product = settings.arguments as Product;
        return _buildRoute(
          ProductDetailScreen(product: product),
          settings,
        );

      case '/checkout':
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          CheckoutScreen(initialCouponCode: args?['couponCode'] as String?),
          settings,
        );

      case '/order-detail':
        final orderId = settings.arguments as String;
        return _buildRoute(
          OrderDetailScreen(orderId: orderId),
          settings,
        );

      case '/cart':
        return _buildRoute(const MainShell(initialTab: 2), settings);

      case '/notifications':
        return _buildRoute(const NotificationsScreen(), settings);

      case '/addresses':
        final selectionMode = settings.arguments as bool? ?? false;
        return _buildRoute(
          AddressScreen(selectionMode: selectionMode),
          settings,
        );

      case '/coupons':
        return _buildRoute(const CouponsScreen(), settings);
      case '/settings':
        return _buildRoute(const SettingsScreen(), settings);

      case '/policies':
        return _buildRoute(const PolicyScreen(), settings);

      case '/help':
        return _buildRoute(const HelpSupportScreen(), settings);

      case '/about':
        return _buildRoute(const AboutScreen(), settings);

      default:
        return _buildRoute(const MainShell(), settings);
    }
  }

  static MaterialPageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}

