import 'dart:async';

import 'elm_transport.dart';

class DtcCode {
  final String code;
  final String source; // stored, pending, permanent

  DtcCode({required this.code, required this.source});
}

class Elm327Client {
  Elm327Client(this.transport);

  final ElmTransport transport;

  Future<void> initialize() async {
    await transport.open();
    await _cmd('ATZ', settleMs: 1200);
    await _cmd('ATE0');
    await _cmd('ATL0');
    await _cmd('ATS0');
    await _cmd('ATST64');
    await _cmd('ATAT2');
    await _cmd('ATSP0');
  }

  Future<String?> readVin() async {
    final res = await _cmd('0902');
    return _parseVin(res);
  }

  Future<List<DtcCode>> readDtcs() async {
    final stored = await _cmd('03');
    final pending = await _cmd('07');
    final permanent = await _cmd('0A');
    return _parseDtcs({
      'stored': stored,
      'pending': pending,
      'permanent': permanent,
    });
  }

  Future<void> clearDtcs() async {
    await _cmd('04');
  }

  Future<String> _cmd(String cmd, {int settleMs = 0}) async {
    await transport.write('$cmd\r');
    if (settleMs > 0) {
      await Future.delayed(Duration(milliseconds: settleMs));
    }
    final res = await transport.readUntil('>');
    return res;
  }

  // Minimal VIN parse placeholder; to be replaced with robust ISO-TP handling
  String? _parseVin(String raw) {
    final cleaned = raw
        .replaceAll('SEARCHING...', '')
        .replaceAll('NO DATA', '')
        .replaceAll(RegExp(r'\s'), '')
        .toUpperCase();
    // Very naive: look for 17-char alnum sequence
    final match = RegExp(r'[A-Z0-9]{17}').firstMatch(cleaned);
    return match?.group(0);
  }

  // Minimal DTC parse placeholder; proper implementation will decode hex frames
  List<DtcCode> _parseDtcs(Map<String, String> responses) {
    final List<DtcCode> all = [];
    responses.forEach((source, text) {
      final codes = _extractPLikeCodes(text);
      for (final c in codes) {
        all.add(DtcCode(code: c, source: source));
      }
    });
    return all;
  }

  List<String> _extractPLikeCodes(String text) {
    final cleaned = text.toUpperCase();
    final matches = RegExp(r'[PCBU][0-9]{4}').allMatches(cleaned);
    return matches.map((m) => m.group(0)!).toSet().toList();
  }
}

