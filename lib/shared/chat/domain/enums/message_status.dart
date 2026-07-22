enum MessageStatus {
  pending,
  failed,
  sent,
  delivered,
  read;

  bool get isPending => this == MessageStatus.pending;
  bool get isFailed => this == MessageStatus.failed;
  bool get isRead => this == MessageStatus.read;
}
