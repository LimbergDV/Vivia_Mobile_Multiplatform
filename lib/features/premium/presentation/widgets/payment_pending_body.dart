import 'package:flutter/material.dart';

import 'package:vivia_mobile/features/premium/domain/enums/payment_method.dart';
import 'package:vivia_mobile/features/premium/domain/models/payment_history_item.dart';

class PaymentPendingBody extends StatelessWidget {
  final PaymentMethod method;
  final bool loading;
  final PaymentHistoryItem? item;
  final VoidCallback onRefresh;
  final void Function(String reference) onCopyReference;
  final VoidCallback onClose;

  const PaymentPendingBody({
    super.key,
    required this.method,
    required this.loading,
    required this.item,
    required this.onRefresh,
    required this.onCopyReference,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            const Icon(Icons.schedule_rounded,
                size: 72, color: Color(0xFF26C6DA)),
            const SizedBox(height: 20),
            Text('Pago pendiente',
                textAlign: TextAlign.center, style: textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(
              'Completa tu pago con ${method.label}. Tu Premium se activará '
              'automáticamente cuando el pago se confirme.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            _reference(context, textTheme),
            const Spacer(),
            _actions(context),
          ],
        ),
      ),
    );
  }

  Widget _reference(BuildContext context, TextTheme textTheme) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final reference = item?.reference;
    if (reference == null || reference.isEmpty) {
      return Text(
        'Aún se está generando tu referencia. Usa "Actualizar estado" en unos '
        'momentos o revísala en la página de pago.',
        textAlign: TextAlign.center,
        style: textTheme.bodySmall,
      );
    }
    return _ReferenceCard(
      reference: reference,
      onCopy: () => onCopyReference(reference),
    );
  }

  Widget _actions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: loading ? null : onRefresh,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Actualizar estado'),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: onClose, child: const Text('Entendido')),
      ],
    );
  }
}

class _ReferenceCard extends StatelessWidget {
  final String reference;
  final VoidCallback onCopy;
  const _ReferenceCard({required this.reference, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Referencia', style: textTheme.labelMedium),
                  const SizedBox(height: 4),
                  SelectableText(reference,
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            IconButton(
              onPressed: onCopy,
              icon: const Icon(Icons.copy_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
