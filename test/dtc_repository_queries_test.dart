import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:strcar/data/dtc_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('count and ensureSeeded', () async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final repo = DtcRepository();
    final before = await repo.count();
    // Seed minimal assets
    await repo.ensureSeeded(['en', 'tr']);
    final after = await repo.count();
    expect(after >= before, true);
    await repo.close();
  });
}