import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/features/auth/presentation/widgets/auth_background_blobs.dart';
import 'package:vivia_mobile/features/home/presentation/pages/report_success_page.dart';
import 'package:vivia_mobile/features/home/presentation/viewmodels/report_viewmodel.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/report/report_step_header.dart';

class ReportReviewPage extends StatelessWidget {
  const ReportReviewPage({super.key});

  void _submit(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ReportSuccessPage()),
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
            child: const ReportStepHeader(currentStep: 3),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Consumer<ReportViewModel>(
                builder: (_, vm, __) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revisa el reporte',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _ReviewItem(
                      number: 1,
                      title: 'Razón',
                      value: vm.reasonLabel,
                    ),
                    const SizedBox(height: 16),
                    _ReviewItem(
                      number: 2,
                      title: 'Detalles',
                      value: vm.details.isEmpty
                          ? 'Sin detalles adicionales'
                          : vm.details,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => _submit(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0095FF),
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Reportar',
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gracias por tu confinza, el equipo de Vivia revisará rigurosamente el reporte y dará paso a su veredicto. Queremos recordar que Vivia hace un gran esfuerzo para mantener la seguridad dentro de la plataforma.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 150,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.bottomCenter,
                maxHeight: 260,
                child: const AuthBackgroundBlobs(),
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
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          'Reportar Publicación',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<ReportViewModel>(
        builder: (_, vm, __) => Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 16, 0),
                    child: const ReportStepHeader(currentStep: 3),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Revisa el reporte',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _ReviewItem(
                            number: 1,
                            title: 'Razón',
                            value: vm.reasonLabel,
                          ),
                          const SizedBox(height: 16),
                          _ReviewItem(
                            number: 2,
                            title: 'Detalles',
                            value: vm.details.isEmpty
                                ? 'Sin detalles adicionales'
                                : vm.details,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Gracias por tu confinza, el equipo de Vivia revisará rigurosamente el reporte y dará paso a su veredicto. Queremos recordar que Vivia hace un gran esfuerzo para mantener la seguridad dentro de la plataforma.',
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
                    FilledButton(
                      onPressed: () => _submit(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0095FF),
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Reportar',
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final int number;
  final String title;
  final String value;

  const _ReviewItem({
    required this.number,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFF0095FF),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  color: const Color(0xFF0095FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}