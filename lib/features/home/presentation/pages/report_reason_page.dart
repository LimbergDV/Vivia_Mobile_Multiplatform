import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/features/auth/presentation/widgets/auth_background_blobs.dart';
import 'package:vivia_mobile/features/home/presentation/pages/report_details_page.dart';
import 'package:vivia_mobile/features/home/presentation/viewmodels/report_viewmodel.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/report/report_step_header.dart';

class ReportReasonPage extends StatelessWidget {
  const ReportReasonPage({super.key});

  static final _reasons = [
    (ReportReason.impreciso, 'Es impreciso o incorrecto'),
    (ReportReason.noEsPropiedad, 'No es una propiedad real'),
    (ReportReason.estafa, 'Es una estafa'),
    (ReportReason.ofensivo, 'Es ofensivo'),
    (ReportReason.otraMotivo, 'Es por otra motivo'),
  ];

  void _next(BuildContext context) {
    final vm = context.read<ReportViewModel>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: const ReportDetailsPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return isLandscape ? _buildLandscape(context) : _buildPortrait(context);
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
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          'Reportar Publicación',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: const ReportStepHeader(currentStep: 1),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Por qué razón quieres reportar la publicación?',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Consumer<ReportViewModel>(
                    builder: (_, vm, __) => Column(
                      children: _reasons.map((r) {
                        final (reason, label) = r;
                        return _ReasonItem(
                          label: label,
                          isSelected: vm.selectedReason == reason,
                          onTap: () => vm.selectReason(reason),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 150,
            child: Stack(
              children: [
                ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.bottomCenter,
                    maxHeight: 260,
                    child: const AuthBackgroundBlobs(),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Consumer<ReportViewModel>(
                    builder: (_, vm, __) => FilledButton(
                      onPressed: vm.canProceed ? () => _next(context) : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0095FF),
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                      ),
                      child: Text(
                        'Siguiente',
                        style: textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          'Reportar Publicación',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 16, 0),
                  child: const ReportStepHeader(currentStep: 1),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¿Por qué razón quieres reportar la publicación?',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Consumer<ReportViewModel>(
                          builder: (_, vm, __) => Column(
                            children: _reasons.map((r) {
                              final (reason, label) = r;
                              return _ReasonItem(
                                label: label,
                                isSelected: vm.selectedReason == reason,
                                onTap: () => vm.selectReason(reason),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Consumer<ReportViewModel>(
                    builder: (_, vm, __) => FilledButton(
                      onPressed: vm.canProceed ? () => _next(context) : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0095FF),
                        disabledBackgroundColor: Colors.grey.shade300,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Siguiente',
                        style: textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}

class _ReasonItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReasonItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF0095FF),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF0095FF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF0095FF),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0095FF),
                    shape: BoxShape.circle,
                  ),
                ),
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}