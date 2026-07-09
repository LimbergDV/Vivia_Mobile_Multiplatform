class NotificationDateFormatter {
  NotificationDateFormatter._();

  static const _months = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  static String format(DateTime date) {
    final month = _months[date.month - 1];
    return '${date.day} de $month ${date.year}';
  }
}
