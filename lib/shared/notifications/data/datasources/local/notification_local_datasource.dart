import 'package:sqflite/sqflite.dart';
import 'package:vivia_mobile/core/database/app_database.dart';
import 'package:vivia_mobile/shared/notifications/data/datasources/local/notification_table.dart';
import 'package:vivia_mobile/shared/notifications/data/models/notification_entity.dart';

abstract class NotificationLocalDatasource {
  Future<void> insert(NotificationEntity entity);
  Future<List<NotificationEntity>> getByUser(String userId);
  Future<int> unreadCount(String userId);
  Future<void> markAllRead(String userId);
}

class NotificationLocalDatasourceImpl implements NotificationLocalDatasource {
  final AppDatabase _appDatabase;

  NotificationLocalDatasourceImpl(this._appDatabase);

  @override
  Future<void> insert(NotificationEntity entity) async {
    final db = await _appDatabase.database;
    await db.insert(
      NotificationTable.name,
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<NotificationEntity>> getByUser(String userId) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      NotificationTable.name,
      where: '${NotificationTable.userId} = ?',
      whereArgs: [userId],
      orderBy: '${NotificationTable.createdAt} DESC',
    );
    return rows.map(NotificationEntity.fromMap).toList();
  }

  @override
  Future<int> unreadCount(String userId) async {
    final db = await _appDatabase.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM ${NotificationTable.name} '
      'WHERE ${NotificationTable.userId} = ? AND ${NotificationTable.isRead} = 0',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<void> markAllRead(String userId) async {
    final db = await _appDatabase.database;
    await db.update(
      NotificationTable.name,
      {NotificationTable.isRead: 1},
      where: '${NotificationTable.userId} = ?',
      whereArgs: [userId],
    );
  }
}
