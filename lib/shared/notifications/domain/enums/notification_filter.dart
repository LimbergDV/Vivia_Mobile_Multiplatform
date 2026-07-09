enum NotificationFilter {
  all('Todas'),
  messages('Mensajes'),
  publications('Publicaciones'),
  system('Del sistema');

  const NotificationFilter(this.label);

  final String label;
}
