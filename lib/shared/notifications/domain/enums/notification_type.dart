enum NotificationType {
  message,
  publication,
  system,
  general;

  static NotificationType fromApi(String? value) {
    switch (value?.toUpperCase()) {
      case 'MESSAGE':
      case 'MESSAGES':
        return NotificationType.message;
      case 'PUBLICATION':
      case 'PUBLICATIONS':
        return NotificationType.publication;
      case 'SYSTEM':
        return NotificationType.system;
      default:
        return NotificationType.general;
    }
  }
}
