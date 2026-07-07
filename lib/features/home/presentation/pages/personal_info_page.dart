import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vivia_mobile/features/auth/domain/enums/user_role.dart';
import 'package:vivia_mobile/features/home/presentation/viewmodels/personal_info_viewmodel.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/profile/edit_info_sheet.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/profile/personal_info_field.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/profile/profile_avatar_ring.dart';

class PersonalInfoPage extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final UserRole role;

  const PersonalInfoPage({
    super.key,
    required this.userName,
    required this.role,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final parts = userName.trim().split(RegExp(r'\s+'));
    final first = parts.isNotEmpty ? parts.first : '';
    final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    return ChangeNotifierProvider(
      create: (_) => PersonalInfoViewModel(
        firstName: first,
        lastName: last,
        email: '',
        phone: role == UserRole.lessor ? '' : null,
        location: role == UserRole.lessee ? '' : null,
        avatarUrl: avatarUrl,
      ),
      child: _PersonalInfoView(role: role),
    );
  }
}

class _PersonalInfoView extends StatelessWidget {
  final UserRole role;

  const _PersonalInfoView({required this.role});

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
          'Información Personal',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: isLandscape
          ? _LandscapeLayout(role: role)
          : _PortraitLayout(role: role),
    );
  }
}

class _PortraitLayout extends StatelessWidget {
  final UserRole role;

  const _PortraitLayout({required this.role});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AvatarSection(),
          const SizedBox(height: 32),
          _FieldsSection(role: role),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _LandscapeLayout extends StatelessWidget {
  final UserRole role;

  const _LandscapeLayout({required this.role});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.onDrag,
            padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: const _AvatarSection(),
          ),
        ),
        VerticalDivider(width: 1, color: colorScheme.outlineVariant),
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.onDrag,
            padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: _FieldsSection(role: role),
          ),
        ),
      ],
    );
  }
}

// Sección avatar
class _AvatarSection extends StatelessWidget {
  const _AvatarSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarSize = isLandscape
        ? MediaQuery.of(context).size.height * 0.38
        : screenWidth * 0.40;

    final avatarUrl = context
        .select<PersonalInfoViewModel, String?>((vm) => vm.avatarUrl);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Foto de perfil',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          RepaintBoundary(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ProfileAvatarRing(
                  avatarUrl: avatarUrl,
                  progress: 0.75,
                  size: avatarSize,
                ),
                Positioned(
                  right: 6,
                  bottom: 6,
                  child: GestureDetector(
                    onTap: () {
                      // TODO: conectar con image_picker
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Próximamente: cambio de foto'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0095FF),
                        shape: BoxShape.circle,
                        border:
                        Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Sección de campos
class _FieldsSection extends StatelessWidget {
  final UserRole role;

  const _FieldsSection({required this.role});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PersonalInfoViewModel>();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Datos Personales',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 20),

        PersonalInfoField(
          label: 'Nombre completo',
          value: vm.fullName,
          onEdit: () => _editName(context, vm),
        ),
        const SizedBox(height: 16),

        PersonalInfoField(
          label: 'Correo electrónico',
          value: vm.email,
          onEdit: () => _editEmail(context, vm),
        ),
        const SizedBox(height: 16),

        if (role == UserRole.lessee) ...[
          PersonalInfoField(
            label: 'Ubicación',
            value: vm.location ?? '',
            onEdit: () => _editLocation(context, vm),
          ),
          const SizedBox(height: 16),
        ] else ...[
          PersonalInfoField(
            label: 'Teléfono',
            value: vm.phone ?? '',
            onEdit: () => _editPhone(context, vm),
          ),
          const SizedBox(height: 16),
        ],

        PersonalInfoField(
          label: 'Contraseña',
          value: '••••••••••••',
          isPassword: true,
          onEdit: () => _editPassword(context),
        ),
      ],
    );
  }

  void _editName(BuildContext context, PersonalInfoViewModel vm) {
    EditInfoSheet.show(
      context,
      title: 'Editar Nombre',
      fields: [
        EditFieldConfig(
          label: 'Nombres',
          hint: 'Arturo Elías',
          initialValue: vm.firstName,
        ),
        EditFieldConfig(
          label: 'Apellidos',
          hint: 'Gómez Masa',
          initialValue: vm.lastName,
        ),
      ],
      onSave: (v) => vm.updateName(first: v[0], last: v[1]),
    );
  }

  void _editEmail(BuildContext context, PersonalInfoViewModel vm) {
    EditInfoSheet.show(
      context,
      title: 'Editar Correo Electrónico',
      fields: [
        EditFieldConfig(
          label: 'Correo Electrónico',
          hint: 'ejemplo@correo.com',
          initialValue: vm.email,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
      onSave: (v) => vm.updateEmail(v[0]),
    );
  }

  void _editPhone(BuildContext context, PersonalInfoViewModel vm) {
    EditInfoSheet.show(
      context,
      title: 'Editar Teléfono',
      fields: [
        EditFieldConfig(
          label: 'Teléfono',
          hint: '+52 000 000 0000',
          initialValue: vm.phone ?? '',
          keyboardType: TextInputType.phone,
        ),
      ],
      onSave: (v) => vm.updatePhone(v[0]),
    );
  }

  void _editLocation(BuildContext context, PersonalInfoViewModel vm) {
    EditInfoSheet.show(
      context,
      title: 'Editar Ubicación',
      fields: [
        EditFieldConfig(
          label: 'Ubicación',
          hint: 'Ciudad, Estado, País',
          initialValue: vm.location ?? '',
        ),
      ],
      onSave: (v) => vm.updateLocation(v[0]),
    );
  }

  void _editPassword(BuildContext context) {
    EditInfoSheet.show(
      context,
      title: 'Editar Contraseña',
      fields: const [
        EditFieldConfig(
          label: 'Contraseña',
          isPassword: true,
        ),
        EditFieldConfig(
          label: 'Confirma la nueva contraseña',
          isPassword: true,
        ),
      ],
      onSave: (v) {
        // TODO: conectar con endpoint de cambio de contraseña
      },
    );
  }
}