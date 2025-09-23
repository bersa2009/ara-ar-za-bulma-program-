import 'package:flutter_test/flutter_test.dart';
import 'package:strcar/elm/elm_parser.dart';

void main() {
  group('ElmParser VIN', () {
    test('parses VIN across multi-frames', () {
      final raw = '> 49 02 01 57 5A 5A 5A 5A 49 02 02 31 32 33 34 35 36 49 02 03 37 38 39 41 42 43 >';
      final vin = ElmParser.parseVin(raw);
      expect(vin, 'WZZZZ123456789ABC');
    });
    test('returns null when NO DATA', () {
      final vin = ElmParser.parseVin('NO DATA');
      expect(vin, isNull);
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
    test('handles SEARCHING and header noise', () {
      final raw = 'SEARCHING... 43 01 01 0A 00 00';
      final codes = ElmParser.parseDtcs(raw, expectedMode: 0x43);
      expect(codes.isNotEmpty, true);
    });
    test('returns empty on no faults', () {
      final raw = '43 00 00 00 00';
      final codes = ElmParser.parseDtcs(raw, expectedMode: 0x43);
      expect(codes.isEmpty, true);
    });
  });
}

