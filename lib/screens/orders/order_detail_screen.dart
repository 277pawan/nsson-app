import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_network_image.dart';
import '../../core/widgets/app_state_view.dart';
import '../../core/widgets/cancel_order_sheet.dart';
import '../../data/models.dart';
import '../../providers/order_provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  AppOrder? _order;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final provider = context.read<OrderProvider>();
      final order = await provider.getOrderById(widget.orderId);
      if (mounted) {
        setState(() {
          _order = order;
          _loading = false;
          _error = order == null ? 'Order not found.' : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Failed to load order.';
        });
      }
    }
  }

  Future<void> _cancelOrder() async {
    final confirmed = await CancelOrderSheet.show(
      context,
      onConfirm: (reason) async {
        final ok = await context
            .read<OrderProvider>()
            .cancelOrder(widget.orderId, reason: reason);
        if (!ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.read<OrderProvider>().error ??
                    'Could not cancel order.',
              ),
            ),
          );
        }
        return ok;
      },
    );

    if (confirmed == true) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order details'),
      ),
      body: AppStateView(
        loading: _loading,
        error: _error,
        empty: !_loading && _error == null && _order == null,
        emptyTitle: 'Order not found',
        emptyMessage: 'This order may have been removed.',
        onRefresh: _load,
        onRetry: _load,
        child: _order == null
            ? const SizedBox.shrink()
            : _OrderDetail(order: _order!, onCancelTap: _cancelOrder),
      ),
    );
  }
}

class _OrderDetail extends StatelessWidget {
  final AppOrder order;
  final VoidCallback onCancelTap;

  const _OrderDetail({
    required this.order,
    required this.onCancelTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final addr = order.shippingAddress;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Status chip ─────────────────────────────────────────────────
          _StatusChip(status: order.status),
          const SizedBox(height: 14),

          // ─── Order meta ───────────────────────────────────────────────────
          _SectionCard(
            children: [
              _MetaRow(
                label: 'Order ID',
                value:
                    '#${order.id.substring(order.id.length > 8 ? order.id.length - 8 : 0).toUpperCase()}',
              ),
              _MetaRow(label: 'Date', value: order.date),
              _MetaRow(
                  label: 'Payment', value: _paymentLabel(order.paymentMethod)),
              _MetaRow(
                label: 'Total',
                value: '₹${order.total.round()}',
                bold: true,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ─── Shipping address ─────────────────────────────────────────────
          if (addr.isNotEmpty) ...[
            Text('Delivery address',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            _SectionCard(
              children: [
                Text(addr, style: theme.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 14),
          ],

          // ─── Items ────────────────────────────────────────────────────────
          Text('Items (${order.items.length})',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 14, endIndent: 14),
              itemBuilder: (_, i) => _ItemTile(item: order.items[i]),
            ),
          ),

          const SizedBox(height: 24),

          // ─── Cancel button ────────────────────────────────────────────────
          if (order.status.toLowerCase() == 'pending') ...[
            AppButton(
              label: 'Cancel order',
              icon: Icons.cancel_outlined,
              onPressed: onCancelTap,
              backgroundColor: Colors.red.shade600,
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  static String _paymentLabel(String method) {
    switch (method.toLowerCase()) {
      case 'cash_on_delivery':
        return 'Cash on delivery';
      case 'razorpay_upi':
        return 'Razorpay / UPI';
      case 'online':
        return 'Online payment';
      default:
        return method.replaceAll('_', ' ');
    }
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final lower = status.toLowerCase();
    final Color bg;
    final Color fg;

    switch (lower) {
      case 'delivered':
        bg = Colors.green.shade100;
        fg = Colors.green.shade800;
        break;
      case 'shipped':
      case 'processing':
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade800;
        break;
      case 'cancelled':
        bg = Colors.red.shade100;
        fg = Colors.red.shade800;
        break;
      default: // pending
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1).toLowerCase(),
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;

  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _MetaRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B))),
          Text(
            value,
            style:
                TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final OrderItem item;

  const _ItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          // Product image
          AppNetworkImage(
            imageUrl: item.image,
            height: 60,
            width: 60,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(width: 12),
          // Name + qty
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity}',
                  style:
                      const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Price
          Text(
            '₹${(item.price * item.quantity).round()}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
