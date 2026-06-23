import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/widgets/mc_logo.dart';
import '../providers/cart_provider.dart';
import '../providers/notification_provider.dart';
import 'home/home_screen.dart';
import 'categories/categories_screen.dart';
import 'cart/cart_screen.dart';
import 'orders/orders_screen.dart';
import 'profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  final int initialTab;

  const MainShell({super.key, this.initialTab = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final notif = context.watch<NotificationProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_currentTab != 0) {
          setState(() => _currentTab = 0);
          return;
        }
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Exit')),
            ],
          ),
        );
        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(notif),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.03),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey(_currentTab),
            child: _buildBody(),
          ),
        ),
        bottomNavigationBar: _buildBottomNav(cart),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(NotificationProvider notif) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: AppColors.border,
      titleSpacing: 16,
      title: Row(
        children: [
          const McLogo(size: 54, borderRadius: 14),
          const SizedBox(width: 10),
          Text(
            AppStrings.appName,
            style: GoogleFonts.spaceGrotesk(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 19,
            ),
          ),
        ],
      ),
      actions: [
        // Search
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/products'),
          icon:
              const Icon(Icons.search, color: AppColors.textTertiary, size: 23),
        ),
        // Notifications
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
          icon: Badge(
            isLabelVisible: notif.unreadCount > 0,
            backgroundColor: AppColors.danger,
            label: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (_, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Text(
                notif.unreadCount.toString(),
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
            child: const Icon(Icons.notifications_outlined,
                color: AppColors.textTertiary, size: 23),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildBody() {
    switch (_currentTab) {
      case 0:
        return HomeScreen(
          onNavigateToCategories: () => setState(() => _currentTab = 1),
          onNavigateToProducts: () => Navigator.pushNamed(context, '/products'),
        );
      case 1:
        return const CategoriesScreen();
      case 2:
        return CartScreen(
          onStartShopping: () => setState(() => _currentTab = 0),
        );
      case 3:
        return const OrdersScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }

  Widget _buildBottomNav(CartProvider cart) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: NavigationBar(
          selectedIndex: _currentTab,
          onDestinationSelected: (idx) => setState(() => _currentTab = idx),
          height: 68,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view),
              label: 'Categories',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: cart.itemCount > 0,
                backgroundColor: AppColors.primary,
                label: Text(
                  cart.itemCount.toString(),
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700),
                ),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: cart.itemCount > 0,
                backgroundColor: AppColors.primary,
                label: Text(
                  cart.itemCount.toString(),
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700),
                ),
                child: const Icon(Icons.shopping_cart),
              ),
              label: 'Cart',
            ),
            const NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2),
              label: 'Orders',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
