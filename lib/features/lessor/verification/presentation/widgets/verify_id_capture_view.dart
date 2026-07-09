import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/features/auth/presentation/widgets/auth_background_blobs.dart';
import 'package:vivia_mobile/features/lessor/verification/presentation/pages/verify_intro_page.dart';
import 'package:vivia_mobile/features/lessor/verification/presentation/widgets/verify_id_frame.dart';
import 'package:vivia_mobile/features/lessor/verification/presentation/widgets/verify_step_indicator.dart';
import 'package:vivia_mobile/features/lessor/verification/domain/enums/verification_document_type.dart';
import 'package:vivia_mobile/features/lessor/verification/presentation/helpers/verify_capture_helper.dart';
import 'package:vivia_mobile/features/lessor/verification/presentation/viewmodels/verification_viewmodel.dart';

/// Vista compartida para capturar una cara de la credencial con el scanner
/// de documentos (recorte automático on-device). La imagen queda staged en
/// [VerificationViewModel] y se muestra como preview con opción de repetir.
class VerifyIdCaptureView extends StatelessWidget {
  final int stepNumber;
  final String stepTitle;
  final String placeholderAsset;
  final VerificationDocumentType documentType;
  final VoidCallback onContinue;

  const VerifyIdCaptureView({
    super.key,
    required this.stepNumber,
    required this.stepTitle,
    required this.placeholderAsset,
    required this.documentType,
    required this.onContinue,
  });

  Future<void> _scan(BuildContext context) async {
    final vm = context.read<VerificationViewModel>();
    final path = await VerifyCaptureHelper.scanIdCard();
    if (path != null) vm.stageDocument(documentType, path);
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
          final stagedPath = vm.stagedPath(documentType);
          return isLandscape
              ? _buildLandscape(context, stagedPath)
              : _buildPortrait(context, stagedPath);
        },
      ),
    );
  }

  Widget _frame(String? stagedPath) {
    return VerifyIdFrame(
      showCameraIcon: stagedPath == null,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: stagedPath != null
            ? Image.file(File(stagedPath), fit: BoxFit.contain)
            : Image.asset(placeholderAsset, fit: BoxFit.cover),
      ),
    );
  }

  Widget _mainButton(
    BuildContext context,
    String? stagedPath, {
    double height = 52,
    double fontSize = 16,
  }) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton(
        onPressed: stagedPath != null ? onContinue : () => _scan(context),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF0095FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          stagedPath != null ? 'Continuar' : 'Tomar foto',
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _retakeButton(BuildContext context) {
    return TextButton(
      onPressed: () => _scan(context),
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

  Widget _buildPortrait(BuildContext context, String? stagedPath) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
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
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: VerifyStepIndicator(stepNumber: stepNumber, title: stepTitle),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(child: _frame(stagedPath)),
          ),
        ),
        if (stagedPath != null) Center(child: _retakeButton(context)),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: _mainButton(context, stagedPath),
        ),
        const SizedBox(height: 8),
        Center(child: _cancelButton(context)),
        const SizedBox(height: 4),
        const RepaintBoundary(child: AuthBackgroundBlobs()),
      ],
    );
  }

  Widget _buildLandscape(BuildContext context, String? stagedPath) {
    final textTheme = Theme.of(context).textTheme;

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
                VerifyStepIndicator(stepNumber: stepNumber, title: stepTitle),
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
                Expanded(child: Center(child: _frame(stagedPath))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _mainButton(
                        context,
                        stagedPath,
                        height: 46,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 14),
                    if (stagedPath != null) _retakeButton(context),
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
