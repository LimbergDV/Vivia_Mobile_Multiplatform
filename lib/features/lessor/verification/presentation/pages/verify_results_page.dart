import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/features/auth/presentation/widgets/auth_background_blobs.dart';
import 'package:vivia_mobile/features/lessor/verification/presentation/pages/verify_intro_page.dart';
import 'package:vivia_mobile/features/lessor/verification/presentation/widgets/verify_loader.dart';
import 'package:vivia_mobile/features/lessor/verification/presentation/viewmodels/verification_viewmodel.dart';

enum VerifyResultStatus { verified, invalid, pending }

class VerifyResultsPage extends StatelessWidget {
  final VerifyResultStatus status;
  final List<String> rejectionReasons;
  final String rejectionComment;

  const VerifyResultsPage({
    super.key,
    this.status = VerifyResultStatus.verified,
    this.rejectionReasons = const [],
    this.rejectionComment = '',
  });

  void _returnToIntro(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Cierra el flujo de verificación y regresa al Home (ruta raíz).
  void _returnHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Reinicia la verificación (PATCH) y lleva al usuario a la intro para
  /// recomenzar el proceso.
  Future<void> _retryProcess(BuildContext context) async {
    final vm = context.read<VerificationViewModel>();
    final ok = await vm.retryVerification();
    if (!context.mounted) return;

    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: VerifyIntroPage.routeName),
          builder: (_) => const VerifyIntroPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Error al reiniciar el proceso'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Consumer<VerificationViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: VerifyLoader(),
          );
        }
        return isLandscape ? _buildLandscape(context) : _buildPortrait(context);
      },
    );
  }

  Widget _buildPortrait(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => _returnToIntro(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          'Verificar Identidad',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: RepaintBoundary(child: AuthBackgroundBlobs()),
            ),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resultados',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  switch (status) {
                    VerifyResultStatus.verified => const _VerifiedContent(),
                    VerifyResultStatus.invalid => _InvalidContent(
                      reasons: rejectionReasons,
                      comment: rejectionComment,
                      onRetry: () => _retryProcess(context),
                    ),
                    VerifyResultStatus.pending => _PendingContent(
                      onReturnHome: () => _returnHome(context),
                    ),
                  },
                  const SizedBox(height: 32),
                  Text(
                    'Vivia solicita esta información para salvaguardar a nuestros usuarios de extorciones y estafas. Gracias por colaborar con nosotros.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscape(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => _returnToIntro(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          'Verificar Identidad',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resultados',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  switch (status) {
                    VerifyResultStatus.verified =>
                      const _VerifiedLandscapeLeft(),
                    VerifyResultStatus.invalid => _InvalidLandscapeLeft(
                      reasons: rejectionReasons,
                      comment: rejectionComment,
                    ),
                    VerifyResultStatus.pending =>
                      const _PendingLandscapeLeft(),
                  },
                  const SizedBox(height: 24),
                  Text(
                    'Vivia solicita esta información para salvaguardar a nuestros usuarios de extorciones y estafas. Gracias por colaborar con nosotros.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          VerticalDivider(
            width: 1,
            thickness: 0.5,
            color: colorScheme.outlineVariant,
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 24, 24),
              child: switch (status) {
                VerifyResultStatus.verified => const _VerifiedLandscapeRight(),
                VerifyResultStatus.invalid => _InvalidLandscapeRight(
                  onRetry: () => _retryProcess(context),
                ),
                VerifyResultStatus.pending => _PendingLandscapeRight(
                  onReturnHome: () => _returnHome(context),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VerifiedContent extends StatelessWidget {
  const _VerifiedContent();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '¡Haz sido verificado!',
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF0095FF),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Image.asset('assets/images/verify.png', width: 180, height: 180),
        ],
      ),
    );
  }
}

class _PendingContent extends StatelessWidget {
  final VoidCallback onReturnHome;

  const _PendingContent({required this.onReturnHome});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'En espera',
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF0095FF),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tus documentos están siendo revisados por el equipo de Vivia. '
            'Te notificaremos cuando el proceso termine.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 160,
            height: 160,
            child: Lottie.asset(
              'assets/images/clock.json',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 28),
          _ReturnHomeButton(onPressed: onReturnHome),
        ],
      ),
    );
  }
}

class _PendingLandscapeLeft extends StatelessWidget {
  const _PendingLandscapeLeft();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'En espera',
          style: textTheme.headlineSmall?.copyWith(
            color: const Color(0xFF0095FF),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tus documentos están siendo revisados por el equipo de Vivia. '
          'Te notificaremos cuando el proceso termine.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.black54),
        ),
      ],
    );
  }
}

class _PendingLandscapeRight extends StatelessWidget {
  final VoidCallback onReturnHome;

  const _PendingLandscapeRight({required this.onReturnHome});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: SizedBox(
            width: 150,
            height: 150,
            child: Lottie.asset('assets/images/clock.json', fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 28),
        _ReturnHomeButton(onPressed: onReturnHome),
      ],
    );
  }
}

class _ReturnHomeButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ReturnHomeButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF0095FF),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Text(
        'Volver al inicio',
        style: textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InvalidContent extends StatelessWidget {
  final List<String> reasons;
  final String comment;
  final VoidCallback onRetry;

  const _InvalidContent({
    required this.reasons,
    required this.comment,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFFF3B30),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Documentación inválida',
              style: textTheme.titleMedium?.copyWith(
                color: const Color(0xFFFF3B30),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _RejectionCard(reasons: reasons, comment: comment),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onRetry,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0095FF),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            'Reintentar Proceso',
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _RejectionCard extends StatelessWidget {
  final List<String> reasons;
  final String comment;

  const _RejectionCard({required this.reasons, this.comment = ''});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'El equipo de Vívia a determinado que NO validará tu identidad por estos motivos:',
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          if (reasons.isEmpty && comment.isEmpty)
            Text(
              'Sin motivos registrados.',
              style: textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
          ...reasons.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Colors.black54)),
                  Expanded(
                    child: Text(
                      r,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Comentario del equipo: $comment',
              style: textTheme.bodySmall?.copyWith(
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VerifiedLandscapeLeft extends StatelessWidget {
  const _VerifiedLandscapeLeft();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Text(
      '¡Haz sido verificado!',
      style: textTheme.headlineSmall?.copyWith(
        color: const Color(0xFF0095FF),
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _VerifiedLandscapeRight extends StatelessWidget {
  const _VerifiedLandscapeRight();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset('assets/images/verify.png', width: 180, height: 180),
    );
  }
}

class _InvalidLandscapeLeft extends StatelessWidget {
  final List<String> reasons;
  final String comment;

  const _InvalidLandscapeLeft({required this.reasons, this.comment = ''});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFFF3B30),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Documentación inválida',
              style: textTheme.titleMedium?.copyWith(
                color: const Color(0xFFFF3B30),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _RejectionCard(reasons: reasons, comment: comment),
      ],
    );
  }
}

class _InvalidLandscapeRight extends StatelessWidget {
  final VoidCallback onRetry;

  const _InvalidLandscapeRight({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: onRetry,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0095FF),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            'Reintentar Proceso',
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
