import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/animations.dart';
import '../../data/models.dart';
import '../../providers/notification_provider.dart';

enum _Filter { all, unread, orders, offers, info }

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  _Filter _filter = _Filter.all;
  bool _loading = true;

  late final AnimationController _headerCtrl;
  late final Animation<double> _headerAnim;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _headerAnim =
        CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic);

    // Fetch notifications from backend, then show UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<NotificationProvider>()
          .fetchNotifications()
          .whenComplete(() {
        if (mounted) {
          setState(() => _loading = false);
          _headerCtrl.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  List<AppNotification> _filtered(List<AppNotification> all) {
    switch (_filter) {
      case _Filter.unread:
        return all.where((n) => !n.read).toList();
      case _Filter.orders:
        return all.where((n) => n.type == NoticeType.approved).toList();
      case _Filter.offers:
        return all.where((n) => n.type == NoticeType.discount).toList();
      case _Filter.info:
        return all.where((n) => n.type == NoticeType.info).toList();
      case _Filter.all:
        return all;
    }
  }

  void _confirmClearAll(BuildContext context, NotificationProvider provider) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all notifications'),
        content: const Text('This will delete all notifications permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              provider.clearAll();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications cleared'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text(AppStrings.notifications),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (provider.unreadCount > 0)
                  TextButton.icon(
                    onPressed: () {
                      provider.markAllAsRead();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.done_all,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('All marked as read'),
                            ],
                          ),
                          backgroundColor: AppColors.success,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    icon: const Icon(Icons.done_all, size: 18),
                    label: const Text('Read all'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary),
                  ),
                if (provider.notifications.isNotEmpty)
                  IconButton(
                    onPressed: () => _confirmClearAll(context, provider),
                    icon: const Icon(Icons.delete_sweep_outlined, size: 22),
                    color: AppColors.textTertiary,
                    tooltip: 'Clear all',
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter bar slides in from top
          AnimatedBuilder(
            animation: _headerAnim,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, (1 - _headerAnim.value) * -24),
              child: Opacity(
                  opacity: _headerAnim.value.clamp(0.0, 1.0), child: child),
            ),
            child: _buildFilterBar(),
          ),

          Expanded(
            child: _loading
                ? _buildSkeleton()
                : Consumer<NotificationProvider>(
                    builder: (context, provider, _) {
                      final items = _filtered(provider.notifications);
                      if (items.isEmpty) return _buildEmpty();
                      return _buildList(provider, items);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _Filter.values
              .map((f) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _NotifFilterChip(
                      filter: f,
                      selected: _filter == f,
                      onTap: () => setState(() => _filter = f),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildList(
      NotificationProvider provider, List<AppNotification> items) {
    return RefreshIndicator(
      onRefresh: () => provider.fetchNotifications(),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: items.length,
        itemBuilder: (context, idx) {
          final n = items[idx];
          return StaggerAnimation(
            index: idx,
            incrementMs: 55,
            child: Dismissible(
              key: ValueKey(n.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                provider.removeNotification(n.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification deleted'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline, color: Colors.white, size: 24),
                    SizedBox(height: 4),
                    Text('Delete',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              child: _NotificationCard(
                notification: n,
                onTap: () => provider.markAsRead(n.id),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    const labels = {
      _Filter.all: ('No notifications yet', "You're all caught up!"),
      _Filter.unread: ('No unread notifications', "You're all caught up!"),
      _Filter.orders: (
        'No order updates',
        'Order status changes will appear here.'
      ),
      _Filter.offers: (
        'No offers yet',
        'Deals and discounts will appear here.'
      ),
      _Filter.info: ('No info alerts', 'Platform updates will appear here.'),
    };
    final (title, sub) = labels[_filter]!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BounceIn(
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_none,
                    color: AppColors.primary, size: 38),
              ),
            ),
            const SizedBox(height: 18),
            FadeIn(
              durationMs: 600,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            FadeIn(
              durationMs: 750,
              child: Text(
                sub,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: 5,
      itemBuilder: (_, __) => const NotificationSkeleton(),
    );
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────

class _NotifFilterChip extends StatelessWidget {
  final _Filter filter;
  final bool selected;
  final VoidCallback onTap;

  const _NotifFilterChip({
    required this.filter,
    required this.selected,
    required this.onTap,
  });

  static const Map<_Filter, (String, IconData)> _meta = {
    _Filter.all: ('All', Icons.notifications_outlined),
    _Filter.unread: ('Unread', Icons.mark_email_unread_outlined),
    _Filter.orders: ('Orders', Icons.check_circle_outline),
    _Filter.offers: ('Offers', Icons.local_offer_outlined),
    _Filter.info: ('Info', Icons.info_outline),
  };

  @override
  Widget build(BuildContext context) {
    final (label, icon) = _meta[filter]!;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 15,
                color: selected ? Colors.white : AppColors.textTertiary),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Notification card ─────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;

  const _NotificationCard({required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    final (icon, tone) = switch (notification.type) {
      NoticeType.approved => (Icons.check_circle_outline, AppColors.success),
      NoticeType.discount => (Icons.local_offer_outlined, AppColors.warning),
      NoticeType.info => (Icons.info_outline, AppColors.primary),
    };

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.read ? Colors.white : const Color(0xFFF0F6FF),
          borderRadius: BorderRadius.circular(16),
          border: notification.read
              ? Border.all(color: AppColors.border, width: 0.8)
              : const Border(
                  left: BorderSide(color: AppColors.primary, width: 4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: notification.read ? 0.03 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: tone, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: notification.read
                                ? FontWeight.w600
                                : FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        notification.time,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  if (!notification.read) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Tap to mark as read',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
