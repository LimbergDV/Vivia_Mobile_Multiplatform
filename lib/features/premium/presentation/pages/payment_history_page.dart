import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vivia_mobile/features/premium/domain/models/payment_history_item.dart';
import 'package:vivia_mobile/features/premium/domain/usecases/get_payment_history_usecase.dart';
import 'package:vivia_mobile/features/premium/presentation/viewmodels/premium_viewmodel.dart';
import 'package:vivia_mobile/features/premium/presentation/widgets/payment_history_view.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  bool _loading = true;
  String? _error;
  List<PaymentHistoryItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    context.read<PremiumViewModel>().refresh();
    try {
      _items = await context.read<GetPaymentHistoryUseCase>().execute();
      _error = null;
    } catch (e) {
      _error = 'No se pudo cargar tu historial. Intenta de nuevo.';
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de pago')),
      body: Consumer<PremiumViewModel>(
        builder: (context, vm, _) => PaymentHistoryView(
          loading: _loading,
          error: _error,
          items: _items,
          isPremium: vm.isPremium,
          premiumUntil: vm.premiumUntil,
          onRetry: _load,
        ),
      ),
    );
  }
}
