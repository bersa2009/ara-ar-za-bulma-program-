import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_settings.dart';
import 'settings.dart';
import '../../core/permissions.dart';
import '../../core/connection_manager.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  List<String> brands = [];
  Map<String, List<String>> brandToModels = {};
  List<int> years = List.generate(30, (i) => DateTime.now().year - i);

  String? selectedBrand;
  String? selectedModel;
  int? selectedYear;

  bool loadingAssets = true;
  Timer? _progressTimer;
  int _progress = 0; // 0..100
  bool _autoConnectTried = false;
  List<DiscoveredDeviceInfo> _classicDevices = const [];

  @override
  void initState() {
    super.initState();
    _loadAssetsAndSettings();
  }

  Future<void> _loadAssetsAndSettings() async {
    final settings = ref.read(appSettingsProvider);
    // Load brands/models
    final raw = await rootBundle.loadString('assets/brands_models.json');
    final data = (json.decode(raw) as List).cast<Map>();
    final map = <String, List<String>>{};
    for (final e in data) {
      final brand = (e['brand'] as String).toLowerCase();
      final models = (e['models'] as List).cast<String>();
      map[brand] = models;
    }
    setState(() {
      brandToModels = map;
      brands = map.keys.toList()..sort();
      selectedBrand = settings.vehicleBrand;
      selectedModel = settings.vehicleModel;
      selectedYear = settings.vehicleYear;
      loadingAssets = false;
    });

    // Preload classic bonded devices (Android)
    unawaited(_loadClassicDevices());
  }

  Future<void> _loadClassicDevices() async {
    try {
      final mgr = ref.read(connectionManagerProvider);
      final list = await mgr.listClassic();
      if (mounted) setState(() => _classicDevices = list);
    } catch (_) {
      // ignore failures silently on non-android
    }
  }

  Future<void> _startBleScan() async {
    final ok = await AppPermissions.ensureBleScan();
    if (!ok) return;
    _progressTimer?.cancel();
    setState(() {
      _progress = 0;
      _autoConnectTried = false;
    });
    _progressTimer = Timer.periodic(const Duration(milliseconds: 200), (t) {
      if (!mounted) return;
      setState(() {
        if (_progress < 95) _progress += 3;
      });
    });
    await ref.read(connectionManagerProvider).scanBle();
  }

  Future<void> _stopBleScan() async {
    await ref.read(connectionManagerProvider).stopBleScan();
    _progressTimer?.cancel();
    setState(() => _progress = 100);
  }

  Future<void> _autoConnectIfFound() async {
    if (_autoConnectTried) return;
    final devices = ref.read(discoveredDevicesProvider);
    if (devices.isEmpty) return;
    final prioritized = devices.firstWhere(
      (d) => d.name.toLowerCase().contains('vgate') || d.name.toLowerCase().contains('elm'),
      orElse: () => devices.first,
    );
    _autoConnectTried = true;
    try {
      await ref.read(connectionManagerProvider).connectBle(prioritized.id);
      await _stopBleScan();
    } catch (_) {
      // keep UI; user can tap a device to retry
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionStateProvider);
    final discovered = ref.watch(discoveredDevicesProvider);
    if (discovered.isNotEmpty && connectionState.connectedDevice == null) {
      // Try auto connect once when we have candidates
      unawaited(_autoConnectIfFound());
    }

    final theme = Theme.of(context);
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.directions_car, color: Colors.white, size: 28),
                        SizedBox(width: 12),
                        Text('Hoş Geldiniz', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                        SizedBox(width: 12),
                        Icon(Icons.directions_car, color: Colors.white, size: 28),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Strcar', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),

                    // Connection prompt card
                    Card(
                      color: Colors.white.withOpacity(0.95),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.wifi, color: Color(0xFF1976D2), size: 28),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text('Bluetooth ve Wi‑Fi bağlantısı gerekli. Açmak ister misiniz?', style: TextStyle(fontSize: 16)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: connectionState.scanning ? null : _startBleScan,
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1976D2)),
                                  icon: const Icon(Icons.bluetooth),
                                  label: const Text("Bluetooth'u Aç"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => AppPermissions.ensureBleScan(),
                                  icon: const Icon(Icons.wifi),
                                  label: const Text('Wi‑Fi\'yi Aç'),
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Vehicle selectors
                    if (!loadingAssets) ...[
                      _LabeledDropdown<String>(
                        label: 'Marka',
                        value: selectedBrand,
                        items: brands,
                        itemBuilder: (s) => Text(_capitalize(s)),
                        onChanged: (v) {
                          setState(() {
                            selectedBrand = v;
                            final ms = brandToModels[v] ?? [];
                            selectedModel = ms.isNotEmpty ? ms.first : null;
                          });
                          if (v != null) settings.setVehicleBrand(v);
                          if (selectedModel != null) settings.setVehicleModel(selectedModel!);
                        },
                      ),
                      const SizedBox(height: 12),
                      _LabeledDropdown<String>(
                        label: 'Model',
                        value: selectedModel,
                        items: (selectedBrand != null ? (brandToModels[selectedBrand] ?? []) : []),
                        itemBuilder: (s) => Text(s),
                        onChanged: (v) {
                          setState(() => selectedModel = v);
                          if (v != null) settings.setVehicleModel(v);
                        },
                      ),
                      const SizedBox(height: 12),
                      _LabeledDropdown<int>(
                        label: 'Yıl',
                        value: selectedYear,
                        items: years,
                        itemBuilder: (y) => Text(y.toString()),
                        onChanged: (v) {
                          setState(() => selectedYear = v);
                          if (v != null) settings.setVehicleYear(v);
                        },
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Scan status + devices
                    Card(
                      color: Colors.white.withOpacity(0.95),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: connectionState.scanning ? (_progress / 100.0) : 0,
                                  minHeight: 6,
                                  backgroundColor: Colors.blue.shade50,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(connectionState.scanning ? 'Tarama… %$_progress' : 'Hazır'),
                            ]),
                            const SizedBox(height: 12),
                            if (discovered.isEmpty && _classicDevices.isEmpty)
                              const Text('Cihaz bulunamadı. Bluetooth\'u açıp tekrar deneyin.'),
                            ...[
                              ...discovered.map((d) => ListTile(
                                    leading: Icon(d.type == 'BLE' ? Icons.bluetooth : Icons.sensors),
                                    title: Text(d.name),
                                    subtitle: Text(d.id),
                                    trailing: ElevatedButton(
                                      onPressed: connectionState.connecting
                                          ? null
                                          : () async {
                                              try {
                                                await ref.read(connectionManagerProvider).connectBle(d.id);
                                                if (mounted) setState(() {});
                                              } catch (_) {}
                                            },
                                      child: const Text('Bağlan'),
                                    ),
                                  )),
                              ..._classicDevices.map((d) => ListTile(
                                    leading: const Icon(Icons.bluetooth_connected),
                                    title: Text(d.name),
                                    subtitle: Text('${d.type} • ${d.id}'),
                                    trailing: ElevatedButton(
                                      onPressed: connectionState.connecting
                                          ? null
                                          : () async {
                                              try {
                                                await ref.read(connectionManagerProvider).connectClassic(d.id);
                                                if (mounted) setState(() {});
                                              } catch (_) {}
                                            },
                                      child: const Text('Bağlan'),
                                    ),
                                  )),
                            ],
                            const SizedBox(height: 8),
                            if (connectionState.connectedDevice != null)
                              Row(children: [
                                const Icon(Icons.check_circle, color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Bağlantı Başarılı – ${_capitalize(settings.vehicleBrand)} ${settings.vehicleModel} ${settings.vehicleYear}',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                              ]),
                            if (connectionState.error != null)
                              Text('Hata: ${connectionState.error}', style: const TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Continue button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: connectionState.connectedDevice == null
                            ? null
                            : () => Navigator.pushReplacementNamed(context, '/home'),
                        child: const Text('Devam Et', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

class _LabeledDropdown<T> extends StatelessWidget {
  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemBuilder,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> items;
  final Widget Function(T) itemBuilder;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              items: items
                  .map((e) => DropdownMenuItem<T>(
                        value: e,
                        child: itemBuilder(e),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

