import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:vivia_mobile/features/auth/domain/enums/user_role.dart';
import 'package:vivia_mobile/features/auth/domain/usecases/put_ubication_usecase.dart';
import 'package:vivia_mobile/features/user/domain/models/full_profile.dart';
import 'package:vivia_mobile/features/user/domain/usecases/update_email_usecase.dart';
import 'package:vivia_mobile/features/user/domain/usecases/update_name_usecase.dart';
import 'package:vivia_mobile/features/user/domain/usecases/update_password_usecase.dart';
import 'package:vivia_mobile/features/user/domain/usecases/update_phone_usecase.dart';
import 'package:vivia_mobile/features/user/domain/usecases/update_profile_photo_usecase.dart';
import 'package:vivia_mobile/features/user/presentation/viewmodels/personal_info_viewmodel.dart';
import 'package:vivia_mobile/features/user/presentation/widgets/profile/edit_info_sheet.dart';
import 'package:vivia_mobile/features/user/presentation/widgets/profile/personal_info_field.dart';
import 'package:vivia_mobile/features/user/presentation/widgets/profile/profile_avatar_ring.dart';
import 'package:vivia_mobile/shared/widgets/app_alert.dart';

class PersonalInfoPage extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final UserRole role;
  final FullProfile? profile;

  const PersonalInfoPage({
    super.key,
    required this.userName,
    required this.role,
    this.avatarUrl,
    this.profile,
  });

  @override
  Widget build(BuildContext context) {
    // Fallback al seed del login si el perfil completo aún no cargó.
    final parts = userName.trim().split(RegExp(r'\s+'));
    final seedFirst = parts.isNotEmpty ? parts.first : '';
    final seedPaternal = parts.length > 1 ? parts[1] : '';
    final seedMaternal = parts.length > 2 ? parts.sublist(2).join(' ') : '';

    return ChangeNotifierProvider(
      create: (ctx) => PersonalInfoViewModel(
        updateNameUseCase: ctx.read<UpdateNameUseCase>(),
        updateEmailUseCase: ctx.read<UpdateEmailUseCase>(),
        updatePhoneUseCase: ctx.read<UpdatePhoneUseCase>(),
        updatePasswordUseCase: ctx.read<UpdatePasswordUseCase>(),
        updateProfilePhotoUseCase: ctx.read<UpdateProfilePhotoUseCase>(),
        putUbicationUseCase: ctx.read<PutUbicationUseCase>(),
        firstName: profile?.name ?? seedFirst,
        paternalSurname: profile?.paternalSurname ?? seedPaternal,
        maternalSurname: profile?.maternalSurname ?? seedMaternal,
        email: profile?.email ?? '',
        isLessor: role == UserRole.lessor,
        isVerified: profile?.isVerified ?? false,
        hasLocation: profile?.latitude != null && profile?.longitude != null,
        phone: role == UserRole.lessor ? (profile?.phoneNumber ?? '') : null,
        avatarUrl: profile?.photoUrl ?? avatarUrl,
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
    final isUploading = context
        .select<PersonalInfoViewModel, bool>((vm) => vm.isUploadingPhoto);
    final progress = context
        .select<PersonalInfoViewModel, double>((vm) => vm.completionPercent);

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
                  progress: progress,
                  size: avatarSize,
                ),
                Positioned(
                  right: 6,
                  bottom: 6,
                  child: GestureDetector(
                    onTap: isUploading ? null : () => _pickAndUploadPhoto(context),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0095FF),
                        shape: BoxShape.circle,
                        border:
                        Border.all(color: Colors.white, width: 2),
                      ),
                      child: isUploading
                          ? const Padding(
                              padding: EdgeInsets.all(7),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
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

  Future<void> _pickAndUploadPhoto(BuildContext context) async {
    final vm = context.read<PersonalInfoViewModel>();

    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null || !context.mounted) return;

    final isPng = file.name.toLowerCase().endsWith('.png');
    final contentType =
        file.mimeType ?? (isPng ? 'image/png' : 'image/jpeg');
    if (contentType != 'image/jpeg' && contentType != 'image/png') {
      AppAlert.error(context, 'Solo se permiten imágenes JPG o PNG');
      return;
    }

    try {
      final bytes = await file.readAsBytes();
      await vm.updatePhoto(bytes: bytes, contentType: contentType);
      if (!context.mounted) return;
      AppAlert.success(context, 'Tu foto de perfil se actualizó correctamente.');
    } catch (e) {
      if (!context.mounted) return;
      AppAlert.error(context, e.toString().replaceFirst('Exception: ', ''));
    }
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

        if (role == UserRole.lessor) ...[
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
          onEdit: () => _editPassword(context, vm),
        ),

        if (role == UserRole.lessee) ...[
          const SizedBox(height: 24),
          const _EditLocationButton(),
        ],
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
          label: 'Apellido Paterno',
          hint: 'Gómez',
          initialValue: vm.paternalSurname,
        ),
        EditFieldConfig(
          label: 'Apellido Materno',
          hint: 'Masa',
          initialValue: vm.maternalSurname,
          isRequired: false,
        ),
      ],
      onSave: (v) => vm.updateName(
        name: v[0],
        paternalSurname: v[1],
        maternalSurname: v[2],
      ),
      successMessage: 'Tu nombre se actualizó correctamente.',
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
      successMessage: 'Tu correo electrónico se actualizó correctamente.',
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
      successMessage: 'Tu teléfono se actualizó correctamente.',
    );
  }

  void _editPassword(BuildContext context, PersonalInfoViewModel vm) {
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
      onSave: (v) => vm.updatePassword(v[0]),
      successMessage: 'Tu contraseña se actualizó correctamente.',
    );
  }
}

// Botón para editar ubicación (solo lessee)
class _EditLocationButton extends StatelessWidget {
  const _EditLocationButton();

  Future<void> _onPressed(BuildContext context) async {
    final vm = context.read<PersonalInfoViewModel>();
    try {
      await vm.updateUbication();
      if (!context.mounted) return;
      AppAlert.success(context, 'Ubicación actualizada exitosamente.');
    } catch (e) {
      if (!context.mounted) return;
      AppAlert.error(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpdating = context
        .select<PersonalInfoViewModel, bool>((vm) => vm.isUpdatingLocation);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: isUpdating ? null : () => _onPressed(context),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF0095FF),
          disabledBackgroundColor: const Color(0xFF0095FF).withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        icon: isUpdating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Icon(Icons.location_on_outlined, size: 20),
        label: Text(
          isUpdating ? 'Actualizando…' : 'Editar Ubicación',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}