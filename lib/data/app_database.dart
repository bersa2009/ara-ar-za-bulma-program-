import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

typedef Migration = Future<void> Function(Database db);

class AppDatabaseProvider {
  AppDatabaseProvider({this.dbName = 'strcar.db', this.version = 1, List<Migration>? migrations})
      : _migrations = migrations ?? const [];

  final String dbName;
  final int version;
  final List<Migration> _migrations;

  Database? _db;

  Future<Database> open({Future<void> Function(Database db)? onCreate}) async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final file = p.join(dbPath, dbName);
    _db = await openDatabase(
      file,
      version: version,
      onCreate: (db, v) async {
        if (onCreate != null) {
          await onCreate(db);
        }
      },
      onUpgrade: (db, oldV, newV) async {
        for (final m in _migrations) {
          await m(db);
        }
      },
    );
    return _db!;
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}

