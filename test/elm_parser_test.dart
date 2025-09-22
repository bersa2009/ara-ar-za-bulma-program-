import 'package:flutter_test/flutter_test.dart';
import 'package:strcar/elm/elm_parser.dart';

void main() {
  group('ElmParser VIN', () {
    test('parses VIN across multi-frames', () {
      final raw = '> 49 02 01 57 5A 5A 5A 5A 49 02 02 31 32 33 34 35 36 49 02 03 37 38 39 41 42 43 >';
      final vin = ElmParser.parseVin(raw);
      expect(vin, 'WZZZZ123456789ABC');
    });
  });

  group('ElmParser DTC', () {
    test('decodes basic P0xxx code from bytes', () {
      // Response example: 43 01 30 30 30 31 -> P0001 (simplified)
      final raw = '43 01 00 01';
      final codes = ElmParser.parseDtcs(raw, expectedMode: 0x43);
      expect(codes.isNotEmpty, true);
      expect(codes.first.startsWith('P'), true);
    });
  });
}

