class NotificationTable {
  NotificationTable._();

  static const name = 'notifications';

  static const id = 'id';
  static const userId = 'user_id';
  static const type = 'type';
  static const title = 'title';
  static const body = 'body';
  static const createdAt = 'created_at';
  static const isRead = 'is_read';

  static const createTableSql = '''
    CREATE TABLE $name (
      $id TEXT PRIMARY KEY,
      $userId TEXT NOT NULL,
      $type TEXT NOT NULL,
      $title TEXT NOT NULL,
      $body TEXT NOT NULL,
      $createdAt TEXT NOT NULL,
      $isRead INTEGER NOT NULL DEFAULT 0
    )
  ''';

  static const createIndexSql =
      'CREATE INDEX idx_${name}_user ON $name ($userId, $createdAt)';
}
