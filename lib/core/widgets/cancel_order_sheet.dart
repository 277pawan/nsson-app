import 'package:flutter/material.dart';

import 'app_button.dart';

class CancelOrderSheet extends StatefulWidget {
  final Future<bool> Function(String reason) onConfirm;

  const CancelOrderSheet({
    super.key,
    required this.onConfirm,
  });

  static Future<bool?> show(
    BuildContext context, {
    required Future<bool> Function(String reason) onConfirm,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => CancelOrderSheet(onConfirm: onConfirm),
    );
  }

  @override
  State<CancelOrderSheet> createState() => _CancelOrderSheetState();
}

class _CancelOrderSheetState extends State<CancelOrderSheet> {
  final _controller = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reason = _controller.text.trim();

    if (reason.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a clear cancellation reason.')),
      );
      return;
    }

    setState(() => _loading = true);
    final ok = await widget.onConfirm(reason);
    if (!mounted) return;

    setState(() => _loading = false);

    if (ok) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Cancel order',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please tell us why you want to cancel this order.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 3,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Cancellation reason',
              hintText: 'Example: Ordered by mistake',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Confirm cancellation',
            icon: Icons.cancel_outlined,
            loading: _loading,
            onPressed: _submit,
            backgroundColor: Colors.red.shade600,
          ),
        ],
      ),
    );
  }
}
