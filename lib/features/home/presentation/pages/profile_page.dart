import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/features/auth/presentation/pages/role_selector_page.dart';
import 'package:vivia_mobile/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class ProfilePage extends StatelessWidget {
  final String userName;
  final String? avatarUrl;

  const ProfilePage({
    super.key,
    required this.userName,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),

              Text(
                userName,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),

              CircleAvatar(
                radius: 64,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null
                    ? Icon(Icons.person,
                    size: 64, color: colorScheme.primary)
                    : null,
              ),
              const SizedBox(height: 40),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ajustes',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _SettingsItem(
                icon: Icons.logout_rounded,
                label: 'Cerrar Sesión',
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.onSurfaceVariant, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right,
                color: colorScheme.onSurfaceVariant, size: 22),
          ],
        ),
      ),
    );
  }
}