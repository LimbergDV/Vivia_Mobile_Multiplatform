import 'package:url_launcher/url_launcher.dart';

class CheckoutLauncher {
  const CheckoutLauncher._();

  static Future<bool> open(String checkoutUrl) async {
    final uri = Uri.tryParse(checkoutUrl);
    if (uri == null) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
