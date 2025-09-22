import 'package:flutter_test/flutter_test.dart';
import 'package:strcar/elm/elm327_client.dart';
import 'package:strcar/elm/mock_elm_transport.dart';

void main() {
  test('Brand detection from VIN WMI', () async {
    final t = MockElmTransport(scripted: {
      'ATZ\r': 'OK',
      'ATE0\r': 'OK',
      'ATL0\r': 'OK',
      'ATS0\r': 'OK',
      'ATH1\r': 'OK',
      'ATST64\r': 'OK',
      'ATAT2\r': 'OK',
      'ATSP0\r': 'OK',
      'ATDPN\r': 'AUTO,ISO',
      '0902\r': '49 02 01 57 56 57 5A 5A 49 02 02 5A 31 32 33 34 49 02 03 35 36 37 38 39 41',
    });
    final c = Elm327Client(t);
    await c.initialize();
    final vin = await c.readVin();
    final brand = c.detectBrandFromVin(vin);
    expect(brand, 'Volkswagen');
  });
}

