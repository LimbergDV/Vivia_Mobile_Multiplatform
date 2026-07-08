import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/features/home/domain/models/report_reason_model.dart';
import 'package:vivia_mobile/features/home/presentation/pages/report_details_page.dart';
import 'package:vivia_mobile/features/home/presentation/viewmodels/report_viewmodel.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/report/report_step_header.dart';

class ReportReasonPage extends StatefulWidget {
  const ReportReasonPage({super.key});

  @override
  State<ReportReasonPage> createState() => _ReportReasonPageState();
}

class _ReportReasonPageState extends State<ReportReasonPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportViewModel>().loadReasons();
    });
  }

  void _goToDetails() {
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final vm = context.watch<ReportViewModel>();
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: isLandscape ? 8 : 24),
              const ReportStepHeader(currentStep: 1),
              SizedBox(height: isLandscape ? 8 : 32),
              Text(
                'Razón del reporte',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '¿Por qué quieres reportar esta publicación?',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: isLandscape ? 8 : 24),
              Expanded(
                child: _buildContent(vm, colorScheme, textTheme),
              ),
              SizedBox(height: isLandscape ? 8 : 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: vm.canProceed ? _goToDetails : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0095FF),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                    const Color(0xFF0095FF).withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continuar',
                    style: textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(height: isLandscape ? 12 : 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
      ReportViewModel vm,
      ColorScheme colorScheme,
      TextTheme textTheme,
      ) {
    if (vm.isLoadingReasons) {
      return ListView.separated(
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => _SkeletonReason(colorScheme: colorScheme),
      );
    }

    if (vm.error != null && vm.reasons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                color: colorScheme.error, size: 40),
            const SizedBox(height: 12),
            Text(
              vm.error!,
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.read<ReportViewModel>().loadReasons(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: vm.reasons.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final reason = vm.reasons[i];
        final isSelected = vm.selectedReason?.id == reason.id;
        return _ReasonItem(
          reason: reason,
          isSelected: isSelected,
          onTap: () => context.read<ReportViewModel>().selectReason(reason),
          textTheme: textTheme,
        );
      },
    );
  }
}

class _ReasonItem extends StatelessWidget {
  final ReportReasonModel reason;
  final bool isSelected;
  final VoidCallback onTap;
  final TextTheme textTheme;

  const _ReasonItem({
    required this.reason,
    required this.isSelected,
    required this.onTap,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0095FF).withOpacity(0.08)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0095FF)
                : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF0095FF)
                    : const Color(0xFF0095FF).withOpacity(0.12),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                  color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                reason.name,
                style: textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? const Color(0xFF0095FF)
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0095FF)
                      : Colors.grey.shade400,
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonReason extends StatelessWidget {
  final ColorScheme colorScheme;

  const _SkeletonReason({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}