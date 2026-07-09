import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/features/lessor/verification/presentation/pages/verify_intro_page.dart';
import 'package:vivia_mobile/features/lessor/verification/presentation/pages/verify_results_page.dart';
import 'package:vivia_mobile/features/lessor/verification/presentation/widgets/verify_loader.dart';
import 'package:vivia_mobile/features/lessor/verification/presentation/viewmodels/verification_viewmodel.dart';
import 'package:vivia_mobile/features/user/domain/enums/verification_status.dart';

/// Gate del flujo de verificación: consulta el estado en la API mostrando el
/// loader y redirige a la página correspondiente.
class VerifyEntryPage extends StatefulWidget {
  const VerifyEntryPage({super.key});

  @override
  State<VerifyEntryPage> createState() => _VerifyEntryPageState();
}

class _VerifyEntryPageState extends State<VerifyEntryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveStatus());
  }

  Future<void> _resolveStatus() async {
    final vm = context.read<VerificationViewModel>();
    await vm.fetchStatus();
    if (!mounted) return;

    final verification = vm.verification;
    if (verification == null) return; // error: la vista muestra el estado

    switch (verification.status) {
      case VerificationStatus.unverified:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: VerifyIntroPage.routeName),
            builder: (_) => const VerifyIntroPage(),
          ),
        );
      case VerificationStatus.verified:
        _goToResults(VerifyResultStatus.verified);
      case VerificationStatus.rejected:
        _goToResults(VerifyResultStatus.invalid);
      case VerificationStatus.pendingReview:
        _goToResults(VerifyResultStatus.pending);
    }
  }

  void _goToResults(VerifyResultStatus status) {
    final vm = context.read<VerificationViewModel>();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VerifyResultsPage(
          status: status,
          rejectionReasons: vm.rejectionReasons,
          rejectionComment: vm.rejectionComment,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          if (vm.errorMessage != null && !vm.isLoading) {
            return _ErrorState(
              message: vm.errorMessage!,
              onRetry: _resolveStatus,
            );
          }
          return const VerifyLoader();
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.black38),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0095FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
