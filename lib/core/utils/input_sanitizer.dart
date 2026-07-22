class InputSanitizer {
  static final RegExp _control = RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]');
  static final RegExp _invisible =
      RegExp(r'[\u200B-\u200F\u202A-\u202E\u2060-\u2064\uFEFF]');
  static final RegExp _anyWhitespaceRun = RegExp(r'\s+');
  static final RegExp _horizontalRun = RegExp(r'[^\S\n]+');
  static final RegExp _extraLineBreaks = RegExp(r'\n{3,}');

  static String singleLine(String input) {
    final stripped = _stripUnsafe(input);
    return stripped.replaceAll(_anyWhitespaceRun, ' ').trim();
  }

  static String multiLine(String input) {
    final stripped = _stripUnsafe(input);
    return stripped
        .replaceAll(_horizontalRun, ' ')
        .replaceAll(_extraLineBreaks, '\n\n')
        .trim();
  }

  static String _stripUnsafe(String input) {
    return input.replaceAll(_control, '').replaceAll(_invisible, '');
  }
}
