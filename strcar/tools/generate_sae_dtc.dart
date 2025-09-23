import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  final params = _parseArgs(args);
  if (params['--out-csv'] == null) {
    stderr.writeln('Usage: dart tools/generate_sae_dtc.dart --out-csv tools/dtc_seed_template.csv --langs en,tr --include-manufacturers toyota,vw,ford,bmw,mercedes --target-count 10000');
    exit(1);
  }
  final outCsv = params['--out-csv']!;
  final langs = (params['--langs'] ?? 'en,tr').split(',');
  final manufacturers = (params['--include-manufacturers'] ?? 'generic').split(',');
  final targetCount = int.tryParse(params['--target-count'] ?? '10000') ?? 10000;

  final sink = File(outCsv).openWrite();
  sink.writeln('code,system,manufacturer,title_en,description_en,causes_en,fixes_en,title_tr,description_tr,causes_tr,fixes_tr,license');

  int written = 0;
  // SAE generic ranges: P0001-P3499, B0001-B3899, C0001-C1999, U0001-U2199
  written += _emitRange(sink, prefix: 'P', start: 1, end: 3499, manufacturer: 'generic');
  if (written < targetCount) written += _emitRange(sink, prefix: 'B', start: 1, end: 3899, manufacturer: 'generic');
  if (written < targetCount) written += _emitRange(sink, prefix: 'C', start: 1, end: 1999, manufacturer: 'generic');
  if (written < targetCount) written += _emitRange(sink, prefix: 'U', start: 1, end: 2199, manufacturer: 'generic');

  // Manufacturer template ranges: P1xxx/B1xxx/C1xxx/U1xxx for selected brands
  for (final manu in manufacturers.where((m) => m != 'generic')) {
    if (written >= targetCount) break;
    written += _emitRange(sink, prefix: 'P', start: 1000, end: 1999, manufacturer: manu, limit: targetCount - written);
    if (written >= targetCount) break;
    written += _emitRange(sink, prefix: 'B', start: 1000, end: 1999, manufacturer: manu, limit: targetCount - written);
    if (written >= targetCount) break;
    written += _emitRange(sink, prefix: 'C', start: 1000, end: 1999, manufacturer: manu, limit: targetCount - written);
    if (written >= targetCount) break;
    written += _emitRange(sink, prefix: 'U', start: 1000, end: 1999, manufacturer: manu, limit: targetCount - written);
  }

  await sink.flush();
  await sink.close();
  stdout.writeln('Generated $written rows to $outCsv');
}

Map<String, String> _parseArgs(List<String> args) {
  final map = <String, String>{};
  for (int i = 0; i < args.length; i++) {
    final a = args[i];
    if (a.startsWith('--')) {
      final next = (i + 1) < args.length ? args[i + 1] : null;
      if (next != null && !next.startsWith('--')) {
        map[a] = next;
        i++;
      } else {
        map[a] = '';
      }
    }
  }
  return map;
}

int _emitRange(IOSink sink, {required String prefix, required int start, required int end, required String manufacturer, int? limit}) {
  int written = 0;
  for (int n = start; n <= end; n++) {
    if (limit != null && written >= limit) break;
    final code = '$prefix${n.toString().padLeft(4, '0')}';
    final system = _systemForPrefix(prefix);
    final en = _enTemplate(prefix, n, manufacturer);
    final tr = _trTemplate(prefix, n, manufacturer);
    final line = [
      code,
      system,
      manufacturer,
      en['title'],
      en['desc'],
      en['causes'].join(';'),
      en['fixes'].join(';'),
      tr['title'],
      tr['desc'],
      tr['causes'].join(';'),
      tr['fixes'].join(';'),
      manufacturer == 'generic' ? 'Original content © Strcar (TR/EN)' : 'Original content © Strcar (TR/EN)'
    ].map(_escape).join(',');
    sink.writeln(line);
    written++;
  }
  return written;
}

String _systemForPrefix(String p) {
  switch (p) {
    case 'P':
      return 'Powertrain';
    case 'B':
      return 'Body';
    case 'C':
      return 'Chassis';
    case 'U':
      return 'Network';
  }
  return 'Powertrain';
}

Map<String, dynamic> _enTemplate(String p, int n, String manu) {
  final isGeneric = manu == 'generic';
  final title = isGeneric ? _genericTitleEn(p, n) : _manuTitleEn(p, n, manu);
  final desc = isGeneric ? 'Standardized diagnostic trouble code in $p-range.' : 'Manufacturer-specific diagnostic trouble code for $manu.';
  final causes = <String>['Sensor fault', 'Wiring/connector issue', 'Module calibration'];
  final fixes = <String>['Inspect sensor and wiring', 'Check connectors', 'Perform calibration'];
  return {'title': title, 'desc': desc, 'causes': causes, 'fixes': fixes};
}

Map<String, dynamic> _trTemplate(String p, int n, String manu) {
  final isGeneric = manu == 'generic';
  final title = isGeneric ? _genericTitleTr(p, n) : _manuTitleTr(p, n, manu);
  final desc = isGeneric ? '$p aralığında standart arıza kodu.' : '$manu için üreticiye özel arıza kodu.';
  final causes = <String>['Sensör arızası', 'Tesisat/konektör sorunu', 'Modül kalibrasyonu'];
  final fixes = <String>['Sensör ve tesisatı kontrol edin', 'Konektörleri kontrol edin', 'Kalibrasyon yapın'];
  return {'title': title, 'desc': desc, 'causes': causes, 'fixes': fixes};
}

String _genericTitleEn(String p, int n) => switch (p) {
      'P' => 'Powertrain fault $n',
      'B' => 'Body fault $n',
      'C' => 'Chassis fault $n',
      'U' => 'Network fault $n',
      _ => 'DTC $p$n'
    };

String _manuTitleEn(String p, int n, String manu) => '$manu $p$n fault';

String _genericTitleTr(String p, int n) => switch (p) {
      'P' => 'Güç aktarma arızası $n',
      'B' => 'Gövde arızası $n',
      'C' => 'Şasi arızası $n',
      'U' => 'Ağ arızası $n',
      _ => 'DTC $p$n'
    };

String _manuTitleTr(String p, int n, String manu) => '$manu $p$n arızası';

String _escape(String s) {
  if (s.contains(',') || s.contains('"') || s.contains('\n')) {
    return '"' + s.replaceAll('"', '""') + '"';
  }
  return s;
}

