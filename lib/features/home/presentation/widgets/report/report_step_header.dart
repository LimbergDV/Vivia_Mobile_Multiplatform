import 'package:flutter/material.dart';

class ReportStepHeader extends StatelessWidget {
  final int currentStep;

  const ReportStepHeader({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(Icons.shield_rounded, color: const Color(0xFF0095FF), size: 32),
        const SizedBox(height: 12),
        Row(
          children: [
            _StepBar(isActive: currentStep >= 1),
            const SizedBox(width: 3),
            _StepBar(isActive: currentStep >= 2),
            const SizedBox(width: 3),
            _StepBar(isActive: currentStep >= 3),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                'Razón',
                textAlign: TextAlign.center,
                style: textTheme.labelSmall?.copyWith(
                  color: currentStep == 1
                      ? const Color(0xFF0095FF)
                      : colorScheme.onSurfaceVariant,
                  fontWeight: currentStep == 1
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            Expanded(
              child: Text(
                'Detalles',
                textAlign: TextAlign.center,
                style: textTheme.labelSmall?.copyWith(
                  color: currentStep == 2
                      ? const Color(0xFF0095FF)
                      : colorScheme.onSurfaceVariant,
                  fontWeight: currentStep == 2
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            Expanded(
              child: Text(
                'Subir reporte',
                textAlign: TextAlign.center,
                style: textTheme.labelSmall?.copyWith(
                  color: currentStep == 3
                      ? const Color(0xFF0095FF)
                      : colorScheme.onSurfaceVariant,
                  fontWeight: currentStep == 3
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StepBar extends StatelessWidget {
  final bool isActive;

  const _StepBar({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 4,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0095FF) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}