import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/shared/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:vivia_mobile/shared/notifications/domain/usecases/mark_notifications_read_usecase.dart';
import 'package:vivia_mobile/shared/notifications/presentation/viewmodels/notifications_viewmodel.dart';
import 'package:vivia_mobile/shared/notifications/presentation/widgets/notification_filter_bar.dart';
import 'package:vivia_mobile/shared/notifications/presentation/widgets/notifications_content.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => NotificationsViewModel(
        getNotificationsUseCase: ctx.read<GetNotificationsUseCase>(),
        markReadUseCase: ctx.read<MarkNotificationsReadUseCase>(),
      )..load(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const _NotificationsAppBar(),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(height: isLandscape ? 4 : 8),
            const _FilterSection(),
            SizedBox(height: isLandscape ? 8 : 16),
            const Expanded(child: NotificationsContent()),
          ],
        ),
      ),
    );
  }
}

class _NotificationsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _NotificationsAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Notificaciones',
        style: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationsViewModel>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: NotificationFilterBar(
        selected: vm.filter,
        onSelected: context.read<NotificationsViewModel>().selectFilter,
      ),
    );
  }
}
