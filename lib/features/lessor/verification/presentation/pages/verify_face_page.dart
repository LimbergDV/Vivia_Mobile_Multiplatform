import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/features/auth/presentation/widgets/auth_background_blobs.dart';
import 'package:vivia_mobile/shared/widgets/app_alert.dart';
import 'package:vivia_mobile/features/lessor/verification/presentation/pages/verify_intro_page.dart';
import 'package:vivia_mobile/features/lessor/verification/presentation/pages/verify_results_page.dart';
import 'package:vivia_mobile/features/lessor/verification/presentation/widgets/verify_loader.dart';
import 'package:vivia_mobile/features/lessor/verification/presentation/widgets/verify_step_indicator.dart';
import 'package:vivia_mobile/features/lessor/verification/domain/enums/verification_document_type.dart';
import 'package:vivia_mobile/features/lessor/verification/presentation/helpers/verify_capture_helper.dart';
import 'package:vivia_mobile/features/lessor/verification/presentation/viewmodels/verification_viewmodel.dart';

class VerifyFacePage extends StatelessWidget {
  const VerifyFacePage({super.key});

  Future<void> _takeSelfie(BuildContext context) async {
    final vm = context.read<VerificationViewModel>();
    final path = await VerifyCaptureHelper.takeSelfie();
    if (path != null) {
      vm.stageDocument(VerificationDocumentType.selfie, path);
    }
  }

  /// Pide las presigned URLs y sube los tres documentos a S3. Mientras tanto
  /// la vista muestra el loader (vm.isSubmitting).
  Future<void> _submit(BuildContext context) async {
    final vm = context.read<VerificationViewModel>();
    final ok = await vm.submitDocuments();
    if (!context.mounted) return;

    if (ok) {
      // Elimina todo el flujo de captura (selfie, reverso, frente e intro)
      // del stack para que "volver" regrese al perfil y no a las fotos.
      var introRemoved = false;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const VerifyResultsPage(status: VerifyResultStatus.pending),
        ),
        (route) {
          if (introRemoved) return true;
          if (route.settings.name == VerifyIntroPage.routeName) {
            introRemoved = true;
          }
          return false;
        },
      );
    } else {
      AppAlert.error(
        context,
        vm.submitError ?? 'Error al enviar los documentos. Intenta de nuevo.',
      );
    }
  }

  void _onMainAction(BuildContext context, bool hasSelfie) {
    if (hasSelfie) {
      _submit(context);
    } else {
      _takeSelfie(context);
    }
  }

  void _onCancel(BuildContext context) {
    context.read<VerificationViewModel>().abandonCapture();
    Navigator.of(
      context,
    ).popUntil((route) => route.settings.name == VerifyIntroPage.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Verificar Identidad',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Consumer<VerificationViewModel>(
        builder: (context, vm, _) {
          if (vm.isSubmitting) return const VerifyLoader();

          final selfiePath = vm.stagedPath(VerificationDocumentType.selfie);
          return isLandscape
              ? _buildLandscape(context, selfiePath)
              : _buildPortrait(context, selfiePath);
        },
      ),
    );
  }

  Widget _preview(String? selfiePath, {double size = 200}) {
    if (selfiePath == null) {
      return SizedBox(
        width: size,
        height: size,
        child: Lottie.asset(
          'assets/images/scan-face.json',
          fit: BoxFit.contain,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: Image.file(
        File(selfiePath),
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _retakeButton(BuildContext context) {
    return TextButton(
      onPressed: () => _takeSelfie(context),
      child: const Text(
        'Repetir foto',
        style: TextStyle(color: Color(0xFF0095FF), fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _cancelButton(BuildContext context) {
    return TextButton(
      onPressed: () => _onCancel(context),
      child: const Text(
        'Cancelar',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
          decorationColor: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildPortrait(BuildContext context, String? selfiePath) {
    final textTheme = Theme.of(context).textTheme;
    final hasSelfie = selfiePath != null;

    return Stack(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Text(
                  'Toma una foto a tu identificación',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: VerifyStepIndicator(
                  stepNumber: 3,
                  title:
                      'Toma una foto de tu rostro para comprobar que eres el mismo de la identificación',
                ),
              ),
              const SizedBox(height: 48),
              Center(child: _preview(selfiePath)),
              if (hasSelfie) ...[
                const SizedBox(height: 8),
                Center(child: _retakeButton(context)),
                const SizedBox(height: 8),
              ] else
                const SizedBox(height: 52),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => _onMainAction(context, hasSelfie),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0095FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      hasSelfie ? 'Enviar documentos' : 'Tomar foto',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(child: _cancelButton(context)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLandscape(BuildContext context, String? selfiePath) {
    final textTheme = Theme.of(context).textTheme;
    final hasSelfie = selfiePath != null;

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Toma una foto a tu identificación',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                const VerifyStepIndicator(
                  stepNumber: 3,
                  title:
                      'Toma una foto de tu rostro para comprobar que eres el mismo de la identificación',
                ),
              ],
            ),
          ),
        ),
        const VerticalDivider(
          width: 1,
          thickness: 0.5,
          color: Color(0xFFE0E0E0),
        ),
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 24, 16),
            child: Column(
              children: [
                Expanded(child: Center(child: _preview(selfiePath))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: FilledButton(
                          onPressed: () => _onMainAction(context, hasSelfie),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0095FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            hasSelfie ? 'Enviar documentos' : 'Tomar foto',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    if (hasSelfie) _retakeButton(context),
                    _cancelButton(context),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
