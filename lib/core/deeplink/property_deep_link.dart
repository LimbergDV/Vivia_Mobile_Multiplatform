/// Enlaces para compartir propiedades y abrirlas desde fuera de la app.
///
/// Se comparte una URL **https** (`https://vivia.aleosh.online/property/{id}`)
/// porque es la única que las apps de chat (WhatsApp, Telegram, etc.) vuelven
/// clickeable: un esquema propio como `vivia://` se queda como texto plano.
/// Con Android App Links / iOS Universal Links configurados en el dominio, al
/// tocar esa URL se abre la app en el detalle sin importar el rol; si la app no
/// está instalada, abre el sitio web.
///
/// También se acepta el esquema propio `vivia://property/{id}` como respaldo
/// (útil para pruebas por `adb`).
///
/// Requiere del lado servidor (dominio `vivia.aleosh.online`):
///   - `/.well-known/assetlinks.json` (Android)
///   - `/.well-known/apple-app-site-association` (iOS)
/// Ver `deeplinks/README.md` en la raíz del repo.
class PropertyDeepLink {
  const PropertyDeepLink._();

  /// Esquema propio (respaldo / pruebas).
  static const String scheme = 'vivia';
  static const String schemeHost = 'property';

  /// Dominio web para enlaces clickeables en chats (App/Universal Links).
  static const String webHost = 'vivia.aleosh.online';
  static const String pathSegment = 'property';

  /// URL que se comparte: https clickeable en cualquier chat.
  static String buildUrl(String propertyId) =>
      'https://$webHost/$pathSegment/$propertyId';

  /// Extrae el id de propiedad de un URI entrante (https del dominio o el
  /// esquema propio), o null si no corresponde a un enlace de propiedad.
  static String? parsePropertyId(Uri uri) {
    // Esquema propio: vivia://property/{id}
    if (uri.scheme == scheme && uri.host == schemeHost) {
      return _cleanId(
          uri.pathSegments.isEmpty ? null : uri.pathSegments.first);
    }

    // Web link: https://vivia.aleosh.online/property/{id}
    if ((uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host == webHost &&
        uri.pathSegments.length >= 2 &&
        uri.pathSegments.first == pathSegment) {
      return _cleanId(uri.pathSegments[1]);
    }

    return null;
  }

  static String? _cleanId(String? raw) {
    final id = raw?.trim() ?? '';
    return id.isEmpty ? null : id;
  }
}
