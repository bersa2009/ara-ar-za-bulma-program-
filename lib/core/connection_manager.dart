import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as spp;

import '../elm/elm327_client.dart';
import '../elm/elm_transport.dart';
import '../elm/wifi_elm_transport.dart';
import '../elm/ble_elm_transport.dart';
import '../elm/classic_elm_transport.dart';

class DiscoveredDeviceInfo {
  final String id;
  final String name;
  final String type; // BLE/Classic/WiFi
  DiscoveredDeviceInfo({required this.id, required this.name, required this.type});
}

class ConnectionStateModel {
  final bool scanning;
  final bool connecting;
  final String? connectedDevice;
  final String? error;
  const ConnectionStateModel({this.scanning = false, this.connecting = false, this.connectedDevice, this.error});
  ConnectionStateModel copyWith({bool? scanning, bool? connecting, String? connectedDevice, String? error}) =>
      ConnectionStateModel(
        scanning: scanning ?? this.scanning,
        connecting: connecting ?? this.connecting,
        connectedDevice: connectedDevice ?? this.connectedDevice,
        error: error,
      );
}

final bleInstanceProvider = Provider<FlutterReactiveBle>((ref) => FlutterReactiveBle());

final discoveredDevicesProvider = StateProvider<List<DiscoveredDeviceInfo>>((ref) => const []);
final connectionStateProvider = StateProvider<ConnectionStateModel>((ref) => const ConnectionStateModel());
final elmClientProvider = Provider<Elm327Client?>((ref) => null);

class ConnectionManager {
  ConnectionManager(this.ref);
  final Ref ref;
  StreamSubscription<DiscoveredDevice>? _bleScanSub;

  Future<void> scanBle() async {
    final ble = ref.read(bleInstanceProvider);
    ref.read(discoveredDevicesProvider.notifier).state = [];
    ref.read(connectionStateProvider.notifier).state = const ConnectionStateModel(scanning: true);
    _bleScanSub?.cancel();
    _bleScanSub = ble.scanForDevices(withServices: const [], scanMode: ScanMode.lowLatency).listen((d) {
      final list = [...ref.read(discoveredDevicesProvider)];
      if (list.indexWhere((e) => e.id == d.id) == -1) {
        list.add(DiscoveredDeviceInfo(id: d.id, name: d.name.isEmpty ? 'BLE ${d.id}' : d.name, type: 'BLE'));
        ref.read(discoveredDevicesProvider.notifier).state = list;
      }
    }, onError: (e) {
      ref.read(connectionStateProvider.notifier).state = ConnectionStateModel(error: e.toString());
    });
  }

  Future<void> stopBleScan() async {
    await _bleScanSub?.cancel();
    _bleScanSub = null;
    final st = ref.read(connectionStateProvider);
    ref.read(connectionStateProvider.notifier).state = st.copyWith(scanning: false);
  }

  Future<List<DiscoveredDeviceInfo>> listClassic() async {
    if (!Platform.isAndroid) return [];
    final bonded = await spp.FlutterBluetoothSerial.instance.getBondedDevices();
    return bonded
        .map((d) => DiscoveredDeviceInfo(id: d.address, name: d.name ?? 'SPP ${d.address}', type: 'Classic'))
        .toList();
  }

  Future<Elm327Client> connectBle(String deviceId) async {
    ref.read(connectionStateProvider.notifier).state = const ConnectionStateModel(connecting: true);
    final transport = BleElmTransport(deviceId: deviceId);
    final client = Elm327Client(transport);
    try {
      await client.initialize();
      ref.read(connectionStateProvider.notifier).state = const ConnectionStateModel(connecting: false, connectedDevice: 'BLE');
      return client;
    } catch (e) {
      ref.read(connectionStateProvider.notifier).state = ConnectionStateModel(error: e.toString());
      rethrow;
    }
  }

  Future<Elm327Client> connectClassic(String address) async {
    ref.read(connectionStateProvider.notifier).state = const ConnectionStateModel(connecting: true);
    final transport = ClassicElmTransport(address);
    final client = Elm327Client(transport);
    try {
      await client.initialize();
      ref.read(connectionStateProvider.notifier).state = const ConnectionStateModel(connecting: false, connectedDevice: 'Classic');
      return client;
    } catch (e) {
      ref.read(connectionStateProvider.notifier).state = ConnectionStateModel(error: e.toString());
      rethrow;
    }
  }

  Future<Elm327Client> connectWifi({required String host, int port = 35000}) async {
    ref.read(connectionStateProvider.notifier).state = const ConnectionStateModel(connecting: true);
    final transport = WifiElmTransport(host: host, port: port);
    final client = Elm327Client(transport);
    try {
      await client.initialize();
      ref.read(connectionStateProvider.notifier).state = const ConnectionStateModel(connecting: false, connectedDevice: 'WiFi');
      return client;
    } catch (e) {
      ref.read(connectionStateProvider.notifier).state = ConnectionStateModel(error: e.toString());
      rethrow;
    }
  }
}

final connectionManagerProvider = Provider<ConnectionManager>((ref) => ConnectionManager(ref));

