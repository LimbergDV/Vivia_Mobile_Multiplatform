class ChatApiConstants {
  ChatApiConstants._();

  static const String _baseRest = 'https://vivia.aleosh.online/api/chat';
  static const String wsUrl = 'wss://vivia.aleosh.online/ws';

  static String get conversations => '$_baseRest/conversations';

  static String conversationMessages(
    String id, {
    String? before,
    int limit = 50,
  }) {
    final params = <String, String>{'limit': '$limit'};
    if (before != null) params['before'] = before;
    return Uri.parse('$_baseRest/conversations/$id/messages')
        .replace(queryParameters: params)
        .toString();
  }

  static String conversationById(String id) => '$_baseRest/conversations/$id';

  static String conversationDocuments(String id) =>
      '$_baseRest/conversations/$id/documents';
}
