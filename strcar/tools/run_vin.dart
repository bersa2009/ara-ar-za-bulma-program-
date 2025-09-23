import 'package:strcar/elm/elm_parser.dart';

void main() {
  const raw = '49 02 01 57 56 57 5A 5A 49 02 02 5A 31 32 33 34 49 02 03 35 36 37 38 39 41';
  final vin = ElmParser.parseVin(raw);
  print('VIN: $vin');
}

