import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  if (args.length < 2) {
    stderr.writeln('Usage: dart tools/convert_csv_to_json.dart <csv_path> <assets_dir> [--no-require-manufacturer]');
    exit(1);
  }
  final csvPath = args[0];
  final outDir = args[1];
  // Require manufacturer by default; can be disabled with --no-require-manufacturer
  final requireManufacturer = !args.contains('--no-require-manufacturer');
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

  int skipped = 0;
  int errors = 0;
  for (var i = 1; i < csv.length; i++) {
    final line = csv[i];
    if (line.trim().isEmpty) continue;
    // naive CSV split respecting quotes
    final parts = _smartSplit(line);
    String getOr(String key, String def) {
      final i = idx[key];
      if (i == null || i >= parts.length) return def;
      final v = parts[i].trim();
      return v.isEmpty ? def : v;
    }
    String? getOpt(String key) {
      final i = idx[key];
      if (i == null || i >= parts.length) return null;
      final v = parts[i].trim();
      return v.isEmpty ? null : v;
    }
    final code = getOr('code', '').toUpperCase();
    if (code.isEmpty) { skipped++; continue; }
    final system = getOr('system', 'Powertrain');
    final isGeneric = getOr('is_generic', 'true').toLowerCase() == 'true';
    final manufacturer = getOpt('manufacturer');
    if (requireManufacturer && (manufacturer == null || manufacturer.isEmpty)) {
      stderr.writeln('Row $i missing manufacturer for code $code.');
      errors++;
      continue;
    }

    en.add({
      'code': code,
      'system': system,
      'manufacturer': manufacturer,
      'is_generic': isGeneric,
      'title': getOr('title_en', code),
      'description': getOr('description_en', ''),
      'causes': _splitList(getOr('causes_en', '')),
      'fixes': _splitList(getOr('fixes_en', '')),
      'license': getOr('license', 'Original content © Strcar (TR/EN)'),
    });
    tr.add({
      'code': code,
      'system': system,
      'manufacturer': manufacturer,
      'is_generic': isGeneric,
      'title': getOr('title_tr', code),
      'description': getOr('description_tr', ''),
      'causes': _splitList(getOr('causes_tr', '')),
      'fixes': _splitList(getOr('fixes_tr', '')),
      'license': getOr('license', 'Orijinal içerik © Strcar (TR/EN)'),
    });
  }

  await File('$outDir/dtc_seed_en.json').writeAsString(const JsonEncoder.withIndent('  ').convert(en));
  await File('$outDir/dtc_seed_tr.json').writeAsString(const JsonEncoder.withIndent('  ').convert(tr));
  stdout.writeln('Wrote ${en.length} EN and ${tr.length} TR codes to $outDir (skipped: $skipped, errors: $errors)');
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