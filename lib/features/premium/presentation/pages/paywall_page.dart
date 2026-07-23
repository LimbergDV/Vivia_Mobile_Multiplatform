import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vivia_mobile/features/premium/domain/enums/payment_method.dart';
import 'package:vivia_mobile/features/premium/presentation/helpers/checkout_launcher.dart';
import 'package:vivia_mobile/features/premium/presentation/pages/payment_pending_page.dart';
import 'package:vivia_mobile/features/premium/presentation/viewmodels/premium_viewmodel.dart';
import 'package:vivia_mobile/features/premium/presentation/widgets/paywall_content.dart';
import 'package:vivia_mobile/shared/widgets/app_alert.dart';

class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PremiumViewModel>().refresh();
    });
  }

  Future<void> _onSelectMethod(PaymentMethod method) async {
    final vm = context.read<PremiumViewModel>();
    final session = await vm.createCheckout(method);
    if (!mounted) return;
    if (session == null) {
      AppAlert.error(context, vm.checkoutError ?? 'No se pudo iniciar el pago');
      return;
    }
    final opened = await CheckoutLauncher.open(session.checkoutUrl);
    if (!mounted) return;
    if (!opened) {
      AppAlert.error(context, 'No se pudo abrir la página de pago');
      return;
    }
    if (!method.isInstant) _goToPending(method);
  }

  void _goToPending(PaymentMethod method) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PaymentPendingPage(method: method)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: Consumer<PremiumViewModel>(
        builder: (context, vm, _) => PaywallContent(
          isPremium: vm.isPremium,
          premiumUntil: vm.premiumUntil,
          pendingMethod: vm.pendingMethod,
          creating: vm.checkoutStatus == CheckoutStatus.creating,
          onSelectMethod: _onSelectMethod,
        ),
      ),
    );
  }
}
