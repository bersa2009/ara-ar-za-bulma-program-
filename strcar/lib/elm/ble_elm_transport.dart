import 'dart:async';
import 'dart:convert';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'elm_transport.dart';

/// Generic BLE UART transport for ELM-like adapters that expose UART over BLE.
/// Defaults target Nordic UART Service (NUS) UUIDs but can be overridden.
class BleElmTransport implements ElmTransport {
  BleElmTransport({
    required this.deviceId,
    Uuid? serviceUuid,
    Uuid? txCharacteristicUuid,
    Uuid? rxCharacteristicUuid,
    FlutterReactiveBle? ble,
  })  : serviceUuid = serviceUuid ?? Uuid.parse('6E400001-B5A3-F393-E0A9-E50E24DCCA9E'),
        txCharacteristicUuid = txCharacteristicUuid ?? Uuid.parse('6E400003-B5A3-F393-E0A9-E50E24DCCA9E'),
        rxCharacteristicUuid = rxCharacteristicUuid ?? Uuid.parse('6E400002-B5A3-F393-E0A9-E50E24DCCA9E'),
        _ble = ble ?? FlutterReactiveBle();

  final String deviceId;
  final Uuid serviceUuid;
  final Uuid txCharacteristicUuid; // notifications from device
  final Uuid rxCharacteristicUuid; // writes to device
  final FlutterReactiveBle _ble;

  StreamSubscription<List<int>>? _notifySub;
  final StringBuffer _buffer = StringBuffer();
  QualifiedCharacteristic? _tx;
  QualifiedCharacteristic? _rx;
  bool _isOpen = false;

  @override
  bool get isOpen => _isOpen;

  @override
  Future<void> open() async {
    if (_isOpen) return;
    // Establish connection
    final conn = _ble.connectToDevice(id: deviceId, connectionTimeout: const Duration(seconds: 6));
    // Wait for first connected event
    await conn.first;
    _tx = QualifiedCharacteristic(serviceId: serviceUuid, characteristicId: txCharacteristicUuid, deviceId: deviceId);
    _rx = QualifiedCharacteristic(serviceId: serviceUuid, characteristicId: rxCharacteristicUuid, deviceId: deviceId);
    _notifySub = _ble.subscribeToCharacteristic(_tx!).listen((event) {
      _buffer.write(utf8.decode(event, allowMalformed: true));
    });
    _isOpen = true;
  }

  @override
  Future<void> close() async {
    await _notifySub?.cancel();
    _notifySub = null;
    _isOpen = false;
  }

  @override
  Future<void> write(String data) async {
    final rx = _rx;
    if (!_isOpen || rx == null) throw StateError('BLE not open');
    await _ble.writeCharacteristicWithResponse(rx, value: utf8.encode(data));
  }

  @override
  Future<String> readUntil(String terminator, {Duration timeout = const Duration(seconds: 4)}) async {
    if (!_isOpen) throw StateError('BLE not open');
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      final text = _buffer.toString();
      final idx = text.indexOf(terminator);
      if (idx >= 0) {
        final out = text.substring(0, idx);
        // remove consumed from buffer
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

