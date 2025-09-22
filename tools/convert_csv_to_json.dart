import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  if (args.length < 2) {
    stderr.writeln('Usage: dart tools/convert_csv_to_json.dart <csv_path> <assets_dir>');
    exit(1);
  }
  final csvPath = args[0];
  final outDir = args[1];
  final csv = await File(csvPath).readAsLines();
  if (csv.isEmpty) {
    stderr.writeln('Empty CSV');
    exit(2);
  }
  final header = csv.first.split(',');
  final idx = {
    for (var i = 0; i < header.length; i++) header[i]: i
  };

  final en = <Map<String, dynamic>>[];
  final tr = <Map<String, dynamic>>[];

  for (var i = 1; i < csv.length; i++) {
    final line = csv[i];
    if (line.trim().isEmpty) continue;
    // naive CSV split handling quotes by replacing "," inside quotes with a sentinel
    final parts = _smartSplit(line);
    String get(String key) => parts[idx[key]!] ;
    final code = get('code').toUpperCase();
    final system = get('system');
    final isGeneric = get('is_generic').toLowerCase() == 'true';

    en.add({
      'code': code,
      'system': system,
      'is_generic': isGeneric,
      'title': get('title_en'),
      'description': get('description_en'),
      'causes': _splitList(get('causes_en')),
      'fixes': _splitList(get('fixes_en')),
      'license': get('license'),
    });
    tr.add({
      'code': code,
      'system': system,
      'is_generic': isGeneric,
      'title': get('title_tr'),
      'description': get('description_tr'),
      'causes': _splitList(get('causes_tr')),
      'fixes': _splitList(get('fixes_tr')),
      'license': get('license'),
    });
  }

  await File('$outDir/dtc_seed_en.json').writeAsString(const JsonEncoder.withIndent('  ').convert(en));
  await File('$outDir/dtc_seed_tr.json').writeAsString(const JsonEncoder.withIndent('  ').convert(tr));
  stdout.writeln('Wrote ${en.length} EN and ${tr.length} TR codes to $outDir');
}

List<String> _splitList(String raw) {
  if (raw.trim().isEmpty) return [];
  return raw.split(';').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
}

List<String> _smartSplit(String line) {
  final List<String> parts = [];
  final StringBuffer current = StringBuffer();
  bool inQuotes = false;
  for (int i = 0; i < line.length; i++) {
    final ch = line[i];
    if (ch == '"') {
      inQuotes = !inQuotes;
      continue;
    }
    if (ch == ',' && !inQuotes) {
      parts.add(current.toString());
      current.clear();
    } else {
      current.write(ch);
    }
  }
  parts.add(current.toString());
  return parts;
}