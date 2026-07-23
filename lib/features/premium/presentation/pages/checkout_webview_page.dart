import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:vivia_mobile/core/deeplink/premium_deep_link.dart';
import 'package:vivia_mobile/features/premium/presentation/helpers/checkout_launcher.dart';

class CheckoutWebViewPage extends StatefulWidget {
  final String checkoutUrl;
  const CheckoutWebViewPage({super.key, required this.checkoutUrl});

  @override
  State<CheckoutWebViewPage> createState() => _CheckoutWebViewPageState();
}

class _CheckoutWebViewPageState extends State<CheckoutWebViewPage> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = _buildController();
  }

  WebViewController _buildController() {
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _onNavigation,
          onPageStarted: (_) => _setLoading(true),
          onPageFinished: (_) => _setLoading(false),
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  NavigationDecision _onNavigation(NavigationRequest request) {
    final result = PremiumDeepLink.parse(Uri.parse(request.url));
    if (result == null) return NavigationDecision.navigate;
    Navigator.of(context).pop(result);
    return NavigationDecision.prevent;
  }

  void _setLoading(bool value) {
    if (mounted) setState(() => _loading = value);
  }

  Future<void> _openInBrowser() async {
    final opened = await CheckoutLauncher.open(widget.checkoutUrl);
    if (opened && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago seguro'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () =>
              Navigator.of(context).pop(PremiumDeepLinkResult.cancel),
        ),
        actions: [
          IconButton(
            tooltip: 'Abrir en el navegador',
            icon: const Icon(Icons.open_in_new_rounded),
            onPressed: _openInBrowser,
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
