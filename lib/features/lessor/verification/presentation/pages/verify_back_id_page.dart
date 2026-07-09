import 'package:flutter/material.dart';
import 'package:vivia_mobile/features/lessor/verification/presentation/pages/verify_face_page.dart';
import 'package:vivia_mobile/features/lessor/verification/presentation/widgets/verify_id_capture_view.dart';
import 'package:vivia_mobile/features/lessor/verification/domain/enums/verification_document_type.dart';

class VerifyBackIdPage extends StatelessWidget {
  const VerifyBackIdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return VerifyIdCaptureView(
      stepNumber: 2,
      stepTitle: 'Toma una foto a la segunda cara de la credencial',
      placeholderAsset: 'assets/images/INE-back.png',
      documentType: VerificationDocumentType.ineBack,
      onContinue: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VerifyFacePage()),
      ),
    );
  }
}
