import 'package:flutter/material.dart';
import 'package:vivia_mobile/features/home/presentation/pages/verify_back_id_page.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/verify/verify_id_capture_view.dart';
import 'package:vivia_mobile/features/lessor/domain/enums/verification_document_type.dart';

class VerifyFrontIdPage extends StatelessWidget {
  const VerifyFrontIdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return VerifyIdCaptureView(
      stepNumber: 1,
      stepTitle: 'Toma una foto a la primera cara de la credencial',
      placeholderAsset: 'assets/images/INE-front.png',
      documentType: VerificationDocumentType.ineFront,
      onContinue: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VerifyBackIdPage()),
      ),
    );
  }
}
