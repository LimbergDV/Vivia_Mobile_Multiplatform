enum PremiumDeepLinkResult { success, cancel }

class PremiumDeepLink {
  const PremiumDeepLink._();

  static const String scheme = 'viviaapp';
  static const String host = 'premium';

  static PremiumDeepLinkResult? parse(Uri uri) {
    if (uri.scheme != scheme || uri.host != host) return null;
    final path = uri.pathSegments.join('/').toLowerCase();
    if (path.contains('success')) return PremiumDeepLinkResult.success;
    if (path.contains('cancel')) return PremiumDeepLinkResult.cancel;
    return null;
  }
}
