enum MessageStatus {
  sent,
  delivered,
  read;

  bool get isRead => this == MessageStatus.read;
}
