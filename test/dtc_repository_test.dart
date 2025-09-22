import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:strcar/data/dtc_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('seed and fetch DTC EN', () async {
    // Initialize FFI for desktop test environments.
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final repo = DtcRepository();
    await repo.seedFromAssets(lang: 'en');
    final p0420 = await repo.getDtc('P0420', lang: 'en');
    expect(p0420 != null, true);
    expect(p0420!['title'], isNotNull);
    await repo.close();
  }, skip: 'requires sqlite3 native library in this test environment');
}

