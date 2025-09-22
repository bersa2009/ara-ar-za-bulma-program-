import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DtcRepository {
  static const _dbName = 'strcar.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> _openDb() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final file = p.join(dbPath, _dbName);
    _db = await openDatabase(
      file,
      version: _dbVersion,
      onCreate: (db, version) async {
        await _createSchema(db);
      },
    );
    return _db!;
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE dtc (
        code TEXT PRIMARY KEY,
        system TEXT NOT NULL,
        manufacturer TEXT,
        is_generic INTEGER NOT NULL DEFAULT 1
      );
    ''');
    await db.execute('''
      CREATE TABLE dtc_i18n (
        code TEXT NOT NULL,
        lang TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        causes TEXT,
        fixes TEXT,
        PRIMARY KEY (code, lang),
        FOREIGN KEY (code) REFERENCES dtc(code) ON DELETE CASCADE
      );
    ''');
    await db.execute('CREATE INDEX idx_dtc_i18n_code_lang ON dtc_i18n(code, lang);');
  }

  Future<void> seedFromAssets({required String lang}) async {
    final db = await _openDb();
    final assetPath = 'assets/dtc_seed_${lang}.json';
    final jsonStr = await rootBundle.loadString(assetPath);
    final List<dynamic> list = json.decode(jsonStr) as List<dynamic>;
    final batch = db.batch();
    for (final item in list) {
      final map = item as Map<String, dynamic>;
      final code = (map['code'] as String).toUpperCase();
      final system = map['system'] as String? ?? 'Powertrain';
      final isGeneric = (map['is_generic'] as bool? ?? true) ? 1 : 0;
      final manufacturer = map['manufacturer'] as String?;
      final title = map['title'] as String? ?? '';
      final description = map['description'] as String?;
      final causes = map['causes'];
      final fixes = map['fixes'];
      batch.insert('dtc', {
        'code': code,
        'system': system,
        'manufacturer': manufacturer,
        'is_generic': isGeneric,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      batch.insert('dtc_i18n', {
        'code': code,
        'lang': lang,
        'title': title,
        'description': description,
        'causes': causes == null ? null : json.encode(causes),
        'fixes': fixes == null ? null : json.encode(fixes),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<Map<String, dynamic>?> getDtc(String code, {required String lang}) async {
    final db = await _openDb();
    final upper = code.toUpperCase();
    final rows = await db.rawQuery('''
      SELECT d.code, d.system, d.is_generic, i.title, i.description, i.causes, i.fixes
      FROM dtc d
      LEFT JOIN dtc_i18n i ON i.code = d.code AND i.lang = ?
      WHERE d.code = ?
      LIMIT 1
    ''', [lang, upper]);
    if (rows.isEmpty) return null;
    final row = rows.first;
    return {
      'code': row['code'],
      'system': row['system'],
      'is_generic': row['is_generic'] == 1,
      'title': row['title'],
      'description': row['description'],
      'causes': _maybeDecodeJson(row['causes']),
      'fixes': _maybeDecodeJson(row['fixes']),
    };
  }

  Future<List<Map<String, dynamic>>> getMany(List<String> codes, {required String lang}) async {
    if (codes.isEmpty) return [];
    final db = await _openDb();
    final placeholders = List.filled(codes.length, '?').join(',');
    final uppers = codes.map((e) => e.toUpperCase()).toList();
    final rows = await db.rawQuery('''
      SELECT d.code, d.system, d.is_generic, i.title, i.description, i.causes, i.fixes
      FROM dtc d
      LEFT JOIN dtc_i18n i ON i.code = d.code AND i.lang = ?
      WHERE d.code IN ($placeholders)
    ''', [lang, ...uppers]);
    return rows.map((row) => {
          'code': row['code'],
          'system': row['system'],
          'is_generic': row['is_generic'] == 1,
          'title': row['title'],
          'description': row['description'],
          'causes': _maybeDecodeJson(row['causes']),
          'fixes': _maybeDecodeJson(row['fixes']),
        }).toList();
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  dynamic _maybeDecodeJson(Object? value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return json.decode(value);
      } catch (_) {
        return value;
      }
    }
    return value;
  }
}

