import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:vivia_mobile/features/auth/presentation/widgets/widgets.dart';
import 'register_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    final isLoading = viewModel.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // ── Contenido principal ──────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: viewModel.loginFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 56),

                    // Logo
                    const ViviaLogo(size: 80),
                    const SizedBox(height: 24),

                    // Título
                    Text(
                      'Iniciar Sesión',
                      style:
                      Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Campo Email
                    AuthTextField(
                      controller: viewModel.loginEmailController,
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

                    // Campo Contraseña
                    AuthTextField(
                      controller: viewModel.loginPasswordController,
                      label: 'Contraseña',
                      hint: '••••••••',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      passwordVisible: viewModel.loginPasswordVisible,
                      onToggleVisibility:
                      viewModel.toggleLoginPasswordVisibility,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu contraseña';
                        }
                        if (value.length < 6) {
                          return 'Mínimo 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    // Botón Iniciar Sesión
                    AuthPrimaryButton(
                      label: 'Iniciar Sesión',
                      isLoading: isLoading,
                      onPressed: () => viewModel.login(),
                    ),
                    const SizedBox(height: 20),

                    // Separador
                    const AuthDivider(),
                    const SizedBox(height: 20),

                    // Botón Google
                    AuthGoogleButton(
                      onPressed:
                      isLoading ? null : () => viewModel.loginWithGoogle(),
                    ),
                    const SizedBox(height: 40),

                    // Volver
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        'Volver',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          decoration: TextDecoration.underline,
                          color: const Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 220), // espacio para los blobs
                  ],
                ),
              ),
            ),
          ),

          // ── Burbujas decorativas (fondo) ─────────────────
          const AuthBackgroundBlobs(),
        ],
      ),
    );
  }
}