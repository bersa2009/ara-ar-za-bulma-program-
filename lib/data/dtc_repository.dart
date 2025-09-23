import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DtcRepository {
  static const _dbName = 'strcar.db';
  static const _dbVersion = 1;

  Database? _db;

  // Gelişmiş DTC bilgisi için yeni metod
  Future<Map<String, dynamic>> getDTCInfo(String dtcCode, String? manufacturer) async {
    try {
      final db = await _openDb();
      final results = await db.query(
        'dtc_codes',
        where: 'code = ? AND (manufacturer = ? OR manufacturer IS NULL)',
        whereArgs: [dtcCode, manufacturer],
        limit: 1,
      );

      if (results.isNotEmpty) {
        return {
          'code': results.first['code'],
          'description': results.first['description'],
          'manufacturer': results.first['manufacturer'],
          'severity': _determineSeverity(dtcCode),
          'category': _getDTCCategory(dtcCode),
          'system': _getSystemName(dtcCode),
        };
      }

      // Eğer spesifik marka bulunamazsa genel arama yap
      final genericResults = await db.query(
        'dtc_codes',
        where: 'code = ? AND manufacturer IS NULL',
        whereArgs: [dtcCode],
        limit: 1,
      );

      if (genericResults.isNotEmpty) {
        return {
          'code': genericResults.first['code'],
          'description': genericResults.first['description'],
          'manufacturer': null,
          'severity': _determineSeverity(dtcCode),
          'category': _getDTCCategory(dtcCode),
          'system': _getSystemName(dtcCode),
        };
      }

      // Hiç bulunamazsa genel bilgi döndür
      return {
        'code': dtcCode,
        'description': _getGenericDTCDescription(dtcCode),
        'manufacturer': manufacturer,
        'severity': _determineSeverity(dtcCode),
        'category': _getDTCCategory(dtcCode),
        'system': _getSystemName(dtcCode),
      };
    } catch (e) {
      return {
        'code': dtcCode,
        'description': 'DTC açıklaması bulunamadı',
        'manufacturer': manufacturer,
        'severity': 'Bilinmiyor',
        'category': 'Genel',
        'system': 'Bilinmiyor',
      };
    }
  }

  // DTC kategorisini belirle
  String _getDTCCategory(String dtcCode) {
    if (dtcCode.length < 2) return 'Bilinmiyor';
    
    final category = dtcCode[0];
    switch (category) {
      case 'P':
        return 'Powertrain (Motor/Şanzıman)';
      case 'B':
        return 'Body (Gövde Elektroniği)';
      case 'C':
        return 'Chassis (Şasi Sistemleri)';
      case 'U':
        return 'Network (İletişim)';
      default:
        return 'Bilinmiyor';
    }
  }

  // Sistem adını belirle
  String _getSystemName(String dtcCode) {
    if (dtcCode.length < 5) return 'Bilinmiyor';
    
    final systemCode = dtcCode.substring(1, 4);
    final systemMap = {
      '030': 'Ateşleme Sistemi',
      '017': 'Yakıt Sistemi',
      '042': 'Emisyon Kontrolü',
      '012': 'Motor Soğutma',
      '044': 'EVAP Sistemi',
      '010': 'Hava/Yakıt Karışımı',
      '020': 'Enjektör Devresi',
      '050': 'Hız/Boşta Çalışma',
      '060': 'ECU/PCM',
      '070': 'Şanzıman',
    };
    
    for (final entry in systemMap.entries) {
      if (systemCode.startsWith(entry.key)) {
        return entry.value;
      }
    }
    
    return 'Motor Yönetimi';
  }

  // Önem derecesi belirle
  String _determineSeverity(String dtcCode) {
    final criticalCodes = [
      'P0016', 'P0017', 'P0020', 'P0021', // Timing zinciri
      'P0087', 'P0088', 'P0089', // Yakıt basıncı
      'P0001', 'P0002', 'P0003', // Yakıt hacim regülatörü
    ];
    
    final highCodes = [
      'P0300', 'P0301', 'P0302', 'P0303', 'P0304', // Misfire
      'P0200', 'P0201', 'P0202', 'P0203', 'P0204', // Enjektör
    ];
    
    final mediumCodes = [
      'P0171', 'P0172', 'P0174', 'P0175', // Karışım
      'P0420', 'P0430', // Katalitik konvertör
    ];
    
    if (criticalCodes.contains(dtcCode)) return 'Kritik';
    if (highCodes.contains(dtcCode)) return 'Yüksek';
    if (mediumCodes.contains(dtcCode)) return 'Orta';
    
    return 'Düşük';
  }

  // Genel DTC açıklaması
  String _getGenericDTCDescription(String dtcCode) {
    if (dtcCode.length < 5) return 'Geçersiz DTC kodu';
    
    final descriptions = {
      'P0300': 'Rastgele Silindir Ateşleme Hatası',
      'P0301': '1. Silindir Ateşleme Hatası',
      'P0302': '2. Silindir Ateşleme Hatası',
      'P0303': '3. Silindir Ateşleme Hatası',
      'P0304': '4. Silindir Ateşleme Hatası',
      'P0305': '5. Silindir Ateşleme Hatası',
      'P0306': '6. Silindir Ateşleme Hatası',
      'P0171': 'Sistem Çok Zayıf (Bank 1)',
      'P0172': 'Sistem Çok Zengin (Bank 1)',
      'P0174': 'Sistem Çok Zayıf (Bank 2)',
      'P0175': 'Sistem Çok Zengin (Bank 2)',
      'P0420': 'Katalitik Konvertör Verimliliği Düşük (Bank 1)',
      'P0430': 'Katalitik Konvertör Verimliliği Düşük (Bank 2)',
      'P0128': 'Motor Soğutma Sistemi Termostat Arızası',
      'P0442': 'EVAP Sistemi Küçük Kaçak',
      'P0016': 'Krank ve Eksantrik Mil Korelasyon Hatası (Bank 1)',
      'P0017': 'Krank ve Eksantrik Mil Korelasyon Hatası (Bank 1 Egzoz)',
      'P0087': 'Yakıt Basıncı Çok Düşük',
      'P0088': 'Yakıt Basıncı Çok Yüksek',
    };
    
    return descriptions[dtcCode] ?? 'DTC $dtcCode: Sistem arızası tespit edildi';
  }

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
      onOpen: (db) async {
        // Performance pragmas for large seed imports
        await db.execute('PRAGMA journal_mode=WAL;');
        await db.execute('PRAGMA synchronous=NORMAL;');
        // Migrate if needed (ensure manufacturer column exists)
        final info = await db.rawQuery("PRAGMA table_info('dtc')");
        final hasManufacturer = info.any((c) => (c['name'] as String).toLowerCase() == 'manufacturer');
        if (!hasManufacturer) {
          await db.execute('ALTER TABLE dtc ADD COLUMN manufacturer TEXT;');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_dtc_manufacturer ON dtc(manufacturer);');
        }
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
    await db.execute('CREATE INDEX idx_dtc_system ON dtc(system);');
    await db.execute('CREATE INDEX idx_dtc_manufacturer ON dtc(manufacturer);');
  }

  Future<void> seedFromAssets({required String lang}) async {
    final db = await _openDb();
    final assetPath = 'assets/dtc_seed_${lang}.json';
    final jsonStr = await rootBundle.loadString(assetPath);
    final List<dynamic> list = json.decode(jsonStr) as List<dynamic>;
    // Chunk inserts to avoid huge batches
    const int chunkSize = 1000;
    for (int i = 0; i < list.length; i += chunkSize) {
      final chunk = list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize);
      await db.transaction((txn) async {
        final batch = txn.batch();
        for (final item in chunk) {
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
      });
    }
  }

  Future<int> count() async {
    final db = await _openDb();
    final res = await db.rawQuery('SELECT COUNT(*) as c FROM dtc');
    return (res.first['c'] as int?) ?? 0;
  }

  Future<void> ensureSeeded(List<String> langs) async {
    final c = await count();
    if (c > 1000) return; // already seeded substantially
    for (final lang in langs) {
      await seedFromAssets(lang: lang);
    }
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

  Future<List<Map<String, dynamic>>> getByManufacturer(String manufacturer, {required String lang}) async {
    final db = await _openDb();
    final rows = await db.rawQuery('''
      SELECT d.code, d.system, d.is_generic, i.title, i.description, i.causes, i.fixes
      FROM dtc d
      LEFT JOIN dtc_i18n i ON i.code = d.code AND i.lang = ?
      WHERE d.manufacturer = ?
    ''', [lang, manufacturer]);
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

  Future<List<Map<String, dynamic>>> search({required String prefix, required String lang, String? manufacturer}) async {
    final db = await _openDb();
    final args = <Object?>[lang, '$prefix%'];
    final manuClause = (manufacturer != null && manufacturer.isNotEmpty) ? 'AND d.manufacturer = ?' : '';
    if (manuClause.isNotEmpty) args.add(manufacturer);
    final rows = await db.rawQuery('''
      SELECT d.code, d.system, d.is_generic, d.manufacturer, i.title, i.description, i.causes, i.fixes
      FROM dtc d
      LEFT JOIN dtc_i18n i ON i.code = d.code AND i.lang = ?
      WHERE d.code LIKE ?
      $manuClause
      ORDER BY d.code ASC
      LIMIT 200
    ''', args);
    return rows.map((row) => {
          'code': row['code'],
          'system': row['system'],
          'is_generic': row['is_generic'] == 1,
          'manufacturer': row['manufacturer'],
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

