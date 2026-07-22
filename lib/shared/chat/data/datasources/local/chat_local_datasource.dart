import 'package:shared_preferences/shared_preferences.dart';

abstract class ChatLocalDatasource {
  /// Devuelve true si ya se mostró la card de esta propiedad en esta conversación.
  bool hasPropertyBeenIntroduced(String conversationId, String propertyId);

  /// Marca que la card de esta propiedad ya fue mostrada en esta conversación.
  void markPropertyIntroduced(String conversationId, String propertyId);
}

class ChatLocalDatasourceImpl implements ChatLocalDatasource {
  final SharedPreferences _prefs;

  ChatLocalDatasourceImpl(this._prefs);

  static String _key(String conversationId, String propertyId) =>
      'chat_prop_shown_${conversationId}_$propertyId';

  @override
  bool hasPropertyBeenIntroduced(String conversationId, String propertyId) =>
      _prefs.getBool(_key(conversationId, propertyId)) == true;

  @override
  void markPropertyIntroduced(String conversationId, String propertyId) =>
      _prefs.setBool(_key(conversationId, propertyId), true);
}
