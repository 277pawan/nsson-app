import 'package:flutter/material.dart';

class AppStateView extends StatelessWidget {
  final bool loading;
  final String? error;
  final bool empty;
  final Widget child;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onRetry;
  final String emptyTitle;
  final String emptyMessage;

  const AppStateView({
    super.key,
    required this.loading,
    required this.error,
    required this.empty,
    required this.child,
    this.onRefresh,
    this.onRetry,
    this.emptyTitle = 'Nothing here yet',
    this.emptyMessage = 'Pull down to refresh or try again later.',
  });

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (loading) {
      body = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (error != null && error!.trim().isNotEmpty) {
      body = _CenteredState(
        icon: Icons.wifi_off_rounded,
        title: 'Something went wrong',
        message: error!,
        actionLabel: 'Retry',
        onAction: onRetry,
      );
    } else if (empty) {
      body = _CenteredState(
        icon: Icons.inventory_2_outlined,
        title: emptyTitle,
        message: emptyMessage,
        actionLabel: onRetry == null ? null : 'Refresh',
        onAction: onRetry,
      );
    } else {
      body = child;
    }

    if (onRefresh == null) return body;

    return RefreshIndicator(
      onRefresh: onRefresh!,
      child: body is ScrollView
          ? body
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: body,
                ),
              ],
            ),
    );
  }
}

class _CenteredState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _CenteredState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Column(
            key: ValueKey('$title-$message'),
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 58, color: Colors.grey.shade500),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 18),
                OutlinedButton(
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
