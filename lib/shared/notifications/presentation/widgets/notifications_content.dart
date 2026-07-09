import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/shared/notifications/domain/models/notification_model.dart';
import 'package:vivia_mobile/shared/notifications/presentation/viewmodels/notifications_viewmodel.dart';
import 'package:vivia_mobile/shared/notifications/presentation/widgets/notification_card.dart';
import 'package:vivia_mobile/shared/notifications/presentation/widgets/notifications_empty_state.dart';
import 'package:vivia_mobile/shared/notifications/presentation/widgets/notifications_skeleton_list.dart';

class NotificationsContent extends StatelessWidget {
  const NotificationsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationsViewModel>();
    if (vm.isLoading) return const NotificationsSkeletonList();
    if (vm.error != null && vm.notifications.isEmpty) {
      return _ErrorView(message: vm.error!);
    }
    if (vm.isEmpty) return const NotificationsEmptyState();
    return _NotificationsList(items: vm.notifications);
  }
}

class _NotificationsList extends StatelessWidget {
  final List<NotificationModel> items;

  const _NotificationsList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: RefreshIndicator(
          onRefresh: context.read<NotificationsViewModel>().load,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, i) => NotificationCard(notification: items[i]),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: colorScheme.error, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: context.read<NotificationsViewModel>().load,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
