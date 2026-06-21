import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:vivia_mobile/features/auth/presentation/widgets/widgets.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: isLandscape
          ? _LandscapeLayout(viewModel: viewModel, isLoading: isLoading)
          : _PortraitLayout(viewModel: viewModel, isLoading: isLoading),
    );
  }
}

class _PortraitLayout extends StatelessWidget {
  final AuthViewModel viewModel;
  final bool isLoading;

  const _PortraitLayout({
    required this.viewModel,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: viewModel.loginFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),
                  const ViviaLogo(size: 80),
                  const SizedBox(height: 20),
                  Text(
                    'Iniciar Sesión',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 28),
                  AuthTextField(
                    controller: viewModel.loginEmailController,
                    label: 'Correo Electrónico',
                    hint: 'example@domain.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Ingresa tu correo';
                      if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Correo no válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: viewModel.loginPasswordController,
                    label: 'Contraseña',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    passwordVisible: viewModel.loginPasswordVisible,
                    onToggleVisibility: viewModel.toggleLoginPasswordVisibility,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
                      if (value.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  AuthPrimaryButton(
                    label: 'Iniciar Sesión',
                    isLoading: isLoading,
                    onPressed: () => viewModel.login(),
                  ),
                  const SizedBox(height: 16),
                  const AuthDivider(),
                  const SizedBox(height: 16),
                  AuthGoogleButton(
                    onPressed: isLoading ? null : () => viewModel.loginWithGoogle(),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
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

        const AuthBackgroundBlobs(),
      ],
    );
  }
}

class _LandscapeLayout extends StatelessWidget {
  final AuthViewModel viewModel;
  final bool isLoading;

  const _LandscapeLayout({
    required this.viewModel,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Row(
        children: [
          SizedBox(
            width: screenWidth * 0.35,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ViviaLogo(size: 70),
                  const SizedBox(height: 16),
                  Text(
                    'Iniciar Sesión',
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),

          VerticalDivider(
            width: 1,
            color: colorScheme.outlineVariant,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 20,
              ),
              child: Form(
                key: viewModel.loginFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AuthTextField(
                      controller: viewModel.loginEmailController,
                      label: 'Correo Electrónico',
                      hint: 'example@domain.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresa tu correo';
                        if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Correo no válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    AuthTextField(
                      controller: viewModel.loginPasswordController,
                      label: 'Contraseña',
                      hint: '••••••••',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      passwordVisible: viewModel.loginPasswordVisible,
                      onToggleVisibility: viewModel.toggleLoginPasswordVisibility,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
                        if (value.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    AuthPrimaryButton(
                      label: 'Iniciar Sesión',
                      isLoading: isLoading,
                      onPressed: () => viewModel.login(),
                    ),
                    const SizedBox(height: 14),
                    const AuthDivider(),
                    const SizedBox(height: 14),
                    AuthGoogleButton(
                      onPressed: isLoading ? null : () => viewModel.loginWithGoogle(),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}