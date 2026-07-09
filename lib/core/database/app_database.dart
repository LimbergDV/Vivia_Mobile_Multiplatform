import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:vivia_mobile/shared/notifications/data/datasources/local/notification_table.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const _fileName = 'vivia.db';
  static const _version = 1;

  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final basePath = await getDatabasesPath();
    final path = p.join(basePath, _fileName);
    return openDatabase(path, version: _version, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(NotificationTable.createTableSql);
    await db.execute(NotificationTable.createIndexSql);
  }
}
