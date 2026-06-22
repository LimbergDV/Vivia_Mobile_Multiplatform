import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/features/auth/domain/enums/user_role.dart';
import 'package:vivia_mobile/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:vivia_mobile/features/auth/presentation/widgets/widgets.dart';

class RegisterPage extends StatelessWidget {
  final UserRole role;

  const RegisterPage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    // Usa el ViewModel inyectado desde main.dart
    return _RegisterView(role: role);
  }
}

class _RegisterView extends StatelessWidget {
  final UserRole role;

  const _RegisterView({required this.role});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    final isLoading = viewModel.status == AuthStatus.loading;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final title = 'Regístrate';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: viewModel.registerFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                const ViviaLogo(size: 80),
                const SizedBox(height: 20),

                Text(
                  title,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Nombre(s) — ambos roles ──────────────────────────
                AuthTextField(
                  controller: viewModel.registerNameController,
                  label: 'Nombre(s)',
                  hint: 'Escribe tu nombre(s)',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa tu nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Apellido Paterno — ambos roles ───────────────────
                AuthTextField(
                  controller: viewModel.registerLastNameController,
                  label: 'Apellido Paterno',
                  hint: 'Escribe tu apellido paterno',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa tu apellido paterno';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Apellido Materno — ambos roles (requerido por backend)
                AuthTextField(
                  controller: viewModel.registerMaternalSurnameController,
                  label: 'Apellido Materno',
                  hint: 'Escribe tu apellido materno',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa tu apellido materno';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Correo Electrónico — ambos roles ─────────────────
                AuthTextField(
                  controller: viewModel.registerEmailController,
                  label: 'Correo Electrónico',
                  hint: 'example@domain.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu correo';
                    }
                    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Correo no válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Teléfono — solo lessor ────────────────────────────
                if (role == UserRole.lessor) ...[
                  AuthTextField(
                    controller: viewModel.registerPhoneController,
                    label: 'Número de teléfono',
                    hint: '9274577845',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa tu número de teléfono';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Contraseña ───────────────────────────────────────
                AuthTextField(
                  controller: viewModel.registerPasswordController,
                  label: 'Contraseña',
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  passwordVisible: viewModel.registerPasswordVisible,
                  onToggleVisibility:
                      viewModel.toggleRegisterPasswordVisibility,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa una contraseña';
                    }
                    if (value.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Confirmar Contraseña ──────────────────────────────
                AuthTextField(
                  controller: viewModel.registerConfirmPasswordController,
                  label: 'Confirmar Contraseña',
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  passwordVisible: viewModel.registerConfirmPasswordVisible,
                  onToggleVisibility:
                      viewModel.toggleRegisterConfirmPasswordVisibility,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirma tu contraseña';
                    }
                    if (value != viewModel.registerPasswordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // ── Botón Crear Cuenta ────────────────────────────────
                AuthPrimaryButton(
                  label: 'Crear Cuenta',
                  isLoading: isLoading,
                  onPressed: () => viewModel.register(role),
                ),
                const SizedBox(height: 20),

                const AuthDivider(),
                const SizedBox(height: 20),

                AuthGoogleButton(
                  onPressed:
                      isLoading ? null : () => viewModel.loginWithGoogle(role),
                ),
                const SizedBox(height: 24),

                // ── Volver ───────────────────────────────────────────
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      'Volver',
                      style: textTheme.bodyMedium?.copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: colorScheme.onSurface,
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
