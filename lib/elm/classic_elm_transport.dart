// Android-only Classic Bluetooth (SPP) transport using flutter_bluetooth_serial
// Guard imports for Android build contexts.
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'elm_transport.dart';

class ClassicElmTransport implements ElmTransport {
  ClassicElmTransport(this.address);

  final String address;
  BluetoothConnection? _connection;
  final StringBuffer _buffer = StringBuffer();

  @override
  bool get isOpen => _connection?.isConnected == true;

  @override
  Future<void> open() async {
    if (_connection != null && _connection!.isConnected) return;
    _connection = await BluetoothConnection.toAddress(address);
    _connection!.input?.listen((data) {
      _buffer.write(utf8.decode(data, allowMalformed: true));
    });
  }

  @override
  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }

  @override
  Future<void> write(String data) async {
    final conn = _connection;
    if (conn == null || !conn.isConnected) throw StateError('SPP not open');
    conn.output.add(utf8.encode(data));
    await conn.output.allSent;
  }

  @override
  Future<String> readUntil(String terminator, {Duration timeout = const Duration(seconds: 4)}) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      final text = _buffer.toString();
      final idx = text.indexOf(terminator);
      if (idx >= 0) {
        final out = text.substring(0, idx);
        _buffer.clear();
        if (idx + terminator.length < text.length) {
          _buffer.write(text.substring(idx + terminator.length));
        }
        return out;
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    return _buffer.toString();
  }
}

