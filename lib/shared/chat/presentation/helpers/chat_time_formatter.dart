class ChatTimeFormatter {
  ChatTimeFormatter._();

  static String format(DateTime date, {bool upperMeridiem = false}) {
    final meridiem = date.hour >= 12 ? 'pm' : 'am';
    final hour12 = _to12Hour(date.hour);
    final minutes = date.minute.toString().padLeft(2, '0');
    final suffix = upperMeridiem ? meridiem.toUpperCase() : meridiem;
    return '$hour12:$minutes $suffix';
  }

  static int _to12Hour(int hour24) {
    final hour = hour24 % 12;
    return hour == 0 ? 12 : hour;
  }
}
