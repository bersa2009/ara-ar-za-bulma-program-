import 'package:flutter_test/flutter_test.dart';
import 'package:strcar/data/dtc_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('seed and fetch DTC EN', () async {
    final repo = DtcRepository();
    await repo.seedFromAssets(lang: 'en');
    final p0420 = await repo.getDtc('P0420', lang: 'en');
    expect(p0420 != null, true);
    expect(p0420!['title'], isNotNull);
    await repo.close();
  });
}

