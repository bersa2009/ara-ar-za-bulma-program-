import 'dart:async';

import 'elm_transport.dart';
import 'elm_parser.dart';

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
    return ElmParser.parseVin(res);
  }

  Future<List<DtcCode>> readDtcs() async {
    final stored = await _cmd('03');
    final pending = await _cmd('07');
    final permanent = await _cmd('0A');
    final storedCodes = ElmParser.parseDtcs(stored, expectedMode: 0x43);
    final pendingCodes = ElmParser.parseDtcs(pending, expectedMode: 0x47);
    final permanentCodes = ElmParser.parseDtcs(permanent, expectedMode: 0x4A);
    final List<DtcCode> all = [];
    for (final c in storedCodes) {
      all.add(DtcCode(code: c, source: 'stored'));
    }
    for (final c in pendingCodes) {
      all.add(DtcCode(code: c, source: 'pending'));
    }
    for (final c in permanentCodes) {
      all.add(DtcCode(code: c, source: 'permanent'));
    }
    // de-duplicate by code keeping first occurrence
    final seen = <String>{};
    final unique = <DtcCode>[];
    for (final d in all) {
      if (seen.add(d.code)) unique.add(d);
    }
    return unique;
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

  // Old naive parsers removed in favor of ElmParser
}

