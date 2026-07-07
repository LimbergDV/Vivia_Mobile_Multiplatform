import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vivia_mobile/features/auth/domain/enums/user_role.dart';
import 'package:vivia_mobile/features/auth/presentation/pages/role_selector_page.dart';
import 'package:vivia_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:vivia_mobile/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:vivia_mobile/features/user/domain/usecases/get_profile_usecase.dart';
import 'package:vivia_mobile/features/home/presentation/viewmodels/profile_viewmodel.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/profile/profile_avatar_ring.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/profile/profile_completion_bar.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/profile/profile_settings_item.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/profile/profile_subscription_banner.dart';
import 'package:vivia_mobile/features/home/presentation/pages/personal_info_page.dart';
import 'package:vivia_mobile/features/home/presentation/pages/verify_intro_page.dart';

class ProfilePage extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final UserRole role;

  const ProfilePage({
    super.key,
    required this.userName,
    required this.role,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ProfileViewModel(
        getProfileUseCase: ctx.read<GetProfileUseCase>(),
        authRepository: ctx.read<AuthRepository>(),
      )..init(userName, avatarUrl),
      child: _ProfileView(
        userName: userName,
        avatarUrl: avatarUrl,
        role: role,
      ),
    );
  }
}

// ── Vista principal ────────────────────────────────────────────────────────
class _ProfileView extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final UserRole role;

  const _ProfileView({
    required this.userName,
    required this.avatarUrl,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Perfil',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: isLandscape
          ? _LandscapeLayout(
          userName: userName, avatarUrl: avatarUrl, role: role)
          : _PortraitLayout(
          userName: userName, avatarUrl: avatarUrl, role: role),
    );
  }
}

// ── Portrait ───────────────────────────────────────────────────────────────
class _PortraitLayout extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final UserRole role;

  const _PortraitLayout({
    required this.userName,
    required this.avatarUrl,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const _ProfileHeader(avatarSize: 130),
          const SizedBox(height: 36),
          _SettingsList(role: role, userName: userName, avatarUrl: avatarUrl,),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ── Landscape ──────────────────────────────────────────────────────────────
class _LandscapeLayout extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final UserRole role;

  const _LandscapeLayout({
    required this.userName,
    required this.avatarUrl,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: const _ProfileHeader(avatarSize: 110),
          ),
        ),
        VerticalDivider(width: 1, color: colorScheme.outlineVariant),
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: _SettingsList(role: role,  userName: userName, avatarUrl: avatarUrl,),
          ),
        ),
      ],
    );
  }
}

// ── Header: nombre + badge + avatar + completado + premium ─────────────────
class _ProfileHeader extends StatelessWidget {
  final double avatarSize;

  const _ProfileHeader({required this.avatarSize});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Nombre + badge verificado
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                vm.displayName,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            if (vm.showVerifiedBadge) ...[
              const SizedBox(width: 6),
              const _VerifiedBadge(),
            ],
          ],
        ),
        const SizedBox(height: 20),

        // Avatar con anillo de progreso
        ProfileAvatarRing(
          avatarUrl: vm.avatarUrl,
          progress: vm.completionPercent,
          size: avatarSize,
        ),
        const SizedBox(height: 16),

        // Barra de completado
        ProfileCompletionBar(
          completionPercent: vm.completionPercentInt,
          showDot: true,
        ),

        // Banner premium — solo para lessor
        if (vm.showSubscriptionBanner) ...[
          const SizedBox(height: 16),
          ProfileSubscriptionBanner(
            onTap: () {
              // TODO: navegar a suscripción
            },
          ),
        ],
      ],
    );
  }
}

// ── Lista de ajustes ───────────────────────────────────────────────────────
class _SettingsList extends StatelessWidget {
  final UserRole role;
  final String userName;
  final String? avatarUrl;

  const _SettingsList({required this.role, required this.userName, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ajustes',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        if (vm.showVerifyAccount)
          ProfileSettingsItem(
            icon: Icons.verified_user_outlined,
            label: 'Verificar Cuenta',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                settings: const RouteSettings(name: VerifyIntroPage.routeName),
                builder: (_) => const VerifyIntroPage(),
              ),
            ),
          ),
        ProfileSettingsItem(
          icon: Icons.person_outline_rounded,
          label: 'Información Personal',
          showNotificationDot: vm.hasPersonalInfoPending,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PersonalInfoPage(
                userName: userName,
                avatarUrl: avatarUrl,
                role: role,
              ),
            ),
          ),
        ),
        if (vm.showPaymentMethods)
          ProfileSettingsItem(
            icon: Icons.credit_card_outlined,
            label: 'Formas De Pago',
            showNotificationDot: vm.hasPaymentInfoPending,
            onTap: () {
              // TODO: navegar a formas de pago
            },
          ),
        ProfileSettingsItem(
          icon: Icons.logout_rounded,
          label: 'Cerrar Sesión',
          onTap: () => _showLogoutDialog(context),
        ),
        ProfileSettingsItem(
          icon: Icons.block_outlined,
          label: 'Eliminar Cuenta',
          isDestructive: true,
          onTap: () => _showDeleteAccountDialog(context),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '¿Cerrar sesión?',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Se cerrará tu sesión actual.',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancelar',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final authVm =
              Provider.of<AuthViewModel>(context, listen: false);
              await authVm.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (_) => const RoleSelectorPage()),
                      (route) => false,
                );
              }
            },
            child: Text(
              'Cerrar Sesión',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '¿Eliminar cuenta?',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.error,
          ),
        ),
        content: Text(
          'Esta acción es permanente y no se puede deshacer. Todos tus datos serán eliminados.',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancelar',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función próximamente disponible'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Eliminar',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Badge de verificado ────────────────────────────────────────────────────
class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: Color(0xFF0095FF),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_rounded,
        color: Colors.white,
        size: 13,
      ),
    );
  }
}