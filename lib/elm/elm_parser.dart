import 'dart:convert';

class ElmParser {
  /// Removes ELM decorations and normalizes the response text for parsing.
  static String sanitize(String raw) {
    var s = raw
        .replaceAll('\r', '\n')
        .replaceAll('\t', ' ')
        .replaceAll('SEARCHING...', '')
        .replaceAll('BUS INIT...', '')
        .replaceAll('NO DATA', '')
        .replaceAll('?', '')
        .replaceAll('OK', '')
        .replaceAll('>','')
        .trim();
    // Collapse multiple spaces/newlines
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }

  /// Extracts a flat list of hex byte strings (e.g., ['49','02','01','57','5A',...])
  /// from a potentially multi-line response containing headers.
  static List<String> extractHexBytes(String raw) {
    final sanitized = sanitize(raw).toUpperCase();
    final matches = RegExp(r'\b[0-9A-F]{2}\b').allMatches(sanitized);
    return matches.map((m) => m.group(0)!).toList();
  }

  /// Parses a VIN from a Mode 09 PID 02 response. Works with multi-frame 49 02 01/02/03 sequences.
  static String? parseVin(String raw) {
    final bytes = extractHexBytes(raw);
    // Gather all ASCII bytes that follow 49 02 xx frames
    final List<int> ascii = [];
    for (int i = 0; i < bytes.length - 2; i++) {
      if (bytes[i] == '49' && bytes[i + 1] == '02') {
        // Skip record number at i+2, then remaining bytes of the frame are ASCII
        final frameStart = i + 3;
        // Take until next '49 02' or end
        int j = frameStart;
        while (j < bytes.length) {
          if (j + 1 < bytes.length && bytes[j] == '49' && bytes[j + 1] == '02') {
            break;
          }
          // Append byte if printable ASCII range (safeguard)
          final value = int.tryParse(bytes[j], radix: 16) ?? 0;
          if (value >= 0x20 && value <= 0x7E) {
            ascii.add(value);
          }
          j++;
        }
        i = j - 1;
      }
    }
    final vin = ascii.isEmpty ? null : utf8.decode(ascii).replaceAll(' ', '');
    if (vin != null && vin.length >= 17) {
      // VIN is 17 chars; take the first 17 if longer
      return vin.substring(0, 17);
    }
    return null;
  }

  /// Parses DTC codes from Mode 03/07/0A responses.
  /// expectedMode should be 0x43, 0x47, or 0x4A (response mode).
  static List<String> parseDtcs(String raw, {required int expectedMode}) {
    final bytes = extractHexBytes(raw);
    // Find first index of expectedMode
    final modeHex = expectedMode.toRadixString(16).toUpperCase().padLeft(2, '0');
    int start = bytes.indexOf(modeHex);
    if (start == -1) {
      // Try to find any response matching expectedMode with header present (skip first 3 header bytes)
      // Already flat bytes, so just proceed with best-effort parsing
      start = 0;
    }
    final dtcBytes = <String>[];
    for (int i = start; i < bytes.length; i++) {
      // Skip the mode byte itself if encountered at position i
      if (i == start && bytes[i] == modeHex) {
        continue;
      }
      dtcBytes.add(bytes[i]);
    }
    // Group into pairs of two bytes per DTC (A,B) -> 5-char code
    final codes = <String>[];
    for (int i = 0; i + 1 < dtcBytes.length; i += 2) {
      final a = int.tryParse(dtcBytes[i], radix: 16) ?? 0;
      final b = int.tryParse(dtcBytes[i + 1], radix: 16) ?? 0;
      if (a == 0 && b == 0) {
        continue;
      }
      final code = _decodeDtcFromBytes(a, b);
      if (code != null) {
        codes.add(code);
      }
    }
    // De-duplicate while preserving order
    final seen = <String>{};
    final unique = <String>[];
    for (final c in codes) {
      if (seen.add(c)) unique.add(c);
    }
    return unique;
  }

  static String? _decodeDtcFromBytes(int a, int b) {
    // Nibbles: a7 a6 -> system; a5 a4 -> first digit; a3..a0 and b7..b0 -> remaining digits
    final systemBits = (a & 0xC0) >> 6; // top 2 bits
    final system = switch (systemBits) {
      0 => 'P',
      1 => 'C',
      2 => 'B',
      3 => 'U',
      _ => 'P',
    };
    final firstDigit = ((a & 0x30) >> 4).toString();
    final secondDigit = (a & 0x0F).toRadixString(16).toUpperCase();
    final thirdDigit = ((b & 0xF0) >> 4).toRadixString(16).toUpperCase();
    final fourthDigit = (b & 0x0F).toRadixString(16).toUpperCase();
    return '$system$firstDigit$secondDigit$thirdDigit$fourthDigit';
  }
}

