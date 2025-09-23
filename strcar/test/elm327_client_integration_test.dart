import 'package:flutter_test/flutter_test.dart';
import 'package:strcar/elm/elm327_client.dart';
import 'package:strcar/elm/mock_elm_transport.dart';

void main() {
  test('Elm327Client end-to-end over Mock transport', () async {
    final scripted = {
      'ATZ\r': 'ELM327 v1.5\rOK',
      'ATE0\r': 'OK',
      'ATL0\r': 'OK',
      'ATS0\r': 'OK',
      'ATST64\r': 'OK',
      'ATAT2\r': 'OK',
      'ATSP0\r': 'OK',
      '0902\r': '49 02 01 57 5A 5A 5A 5A 49 02 02 31 32 33 34 35 36 49 02 03 37 38 39 41 42 43',
      '03\r': '43 01 01 0A 00 00',
      '07\r': '47 00 00 00 00',
      '0A\r': '4A 00 00 00 00',
      '04\r': 'OK',
    };
    final transport = MockElmTransport(scripted: scripted);
    final client = Elm327Client(transport);
    await client.initialize();
    final vin = await client.readVin();
    expect(vin, 'WZZZZ123456789ABC');
    final dtcs = await client.readDtcs();
    expect(dtcs.isNotEmpty, true);
    await client.clearDtcs();
  });
}

