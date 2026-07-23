import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:vivia_mobile/features/premium/domain/enums/payment_method.dart';
import 'package:vivia_mobile/features/premium/domain/models/payment_history_item.dart';
import 'package:vivia_mobile/features/premium/domain/usecases/get_payment_history_usecase.dart';
import 'package:vivia_mobile/features/premium/presentation/viewmodels/premium_viewmodel.dart';
import 'package:vivia_mobile/features/premium/presentation/widgets/payment_pending_body.dart';

class PaymentPendingPage extends StatefulWidget {
  final PaymentMethod method;
  const PaymentPendingPage({super.key, required this.method});

  @override
  State<PaymentPendingPage> createState() => _PaymentPendingPageState();
}

class _PaymentPendingPageState extends State<PaymentPendingPage> {
  bool _loading = true;
  PaymentHistoryItem? _item;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    context.read<PremiumViewModel>().refresh();
    try {
      final history = await context.read<GetPaymentHistoryUseCase>().execute();
      _item = _latestForMethod(history);
    } catch (_) {
      _item = null;
    }
    if (mounted) setState(() => _loading = false);
  }

  PaymentHistoryItem? _latestForMethod(List<PaymentHistoryItem> history) {
    final matches = history.where((h) => h.method == widget.method).toList()
      ..sort((a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
    return matches.isEmpty ? null : matches.first;
  }

  void _copyReference(String reference) {
    Clipboard.setData(ClipboardData(text: reference));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Referencia copiada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pago pendiente')),
      body: PaymentPendingBody(
        method: widget.method,
        loading: _loading,
        item: _item,
        onRefresh: _load,
        onCopyReference: _copyReference,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }
}
