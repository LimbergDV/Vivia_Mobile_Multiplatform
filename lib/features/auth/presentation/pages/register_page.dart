import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:vivia_mobile/features/auth/presentation/widgets/widgets.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    final isLoading = viewModel.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
                  'Regístrate',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 28),

                AuthTextField(
                  controller: viewModel.registerNameController,
                  label: 'Nombre(s) del vendedor',
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

                AuthTextField(
                  controller: viewModel.registerLastNameController,
                  label: 'Apellido(s) del vendedor',
                  hint: 'Escribe tu apellido(s)',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa tu apellido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

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
                    if (value.length < 6) {
                      return 'Mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

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
                const SizedBox(height: 16),

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
                const SizedBox(height: 28),

                AuthPrimaryButton(
                  label: 'Crear Cuenta',
                  isLoading: isLoading,
                  onPressed: () => viewModel.register(),
                ),
                const SizedBox(height: 20),

                const AuthDivider(),
                const SizedBox(height: 20),

                AuthGoogleButton(
                  onPressed:
                  isLoading ? null : () => viewModel.loginWithGoogle(),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}