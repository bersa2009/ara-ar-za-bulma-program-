import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/connection_manager.dart';
import '../../core/app_settings.dart';
import '../widgets/drive_warning.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connState = ref.watch(connectionStateProvider);
    final discovered = ref.watch(discoveredDevicesProvider);
    final mgr = ref.read(connectionManagerProvider);
    final settings = ref.watch(appSettingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Strcar - Arıza Teşhisi')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const DriveWarningBanner(),
            const Text(
              'Strcar OBD Bağlantısı',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(spacing: 8, children: [
              ElevatedButton(
                onPressed: connState.scanning ? null : () => mgr.scanBle(),
                child: Text(connState.scanning ? 'BLE Tarama...' : 'BLE Tara'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final list = await mgr.listClassic();
                  ref.read(discoveredDevicesProvider.notifier).state = list;
                },
                child: const Text('Classic (Android)'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Simple WiFi prompt
                  final host = await showDialog<String>(context: context, builder: (ctx) {
                    final ctrl = TextEditingController(text: '192.168.0.10');
                    return AlertDialog(
                      title: const Text('WiFi Host'),
                      content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Host:Port (optional)')),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
                        TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('Bağlan')),
                      ],
                    );
                  });
                  if (host != null && host.isNotEmpty) {
                    final parts = host.split(':');
                    final h = parts[0];
                    final p = parts.length > 1 ? int.tryParse(parts[1]) ?? 35000 : 35000;
                    await mgr.connectWifi(host: h, port: p);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WiFi bağlandı')));
                  }
                },
                child: const Text('WiFi Bağlan'),
              ),
            ]),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 180,
                child: ListView.builder(
                  itemCount: discovered.length,
                  itemBuilder: (ctx, i) {
                    final d = discovered[i];
                    return ListTile(
                      title: Text('${d.name} (${d.type})'),
                      subtitle: Text(d.id),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          try {
                            if (d.type == 'BLE') {
                              await mgr.connectBle(d.id);
                            } else if (d.type == 'Classic') {
                              await mgr.connectClassic(d.id);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bağlandı')));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
                          }
                        },
                        child: const Text('Bağlan'),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (connState.connecting) const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()),
            if (connState.error != null) Padding(padding: const EdgeInsets.all(8), child: Text('Hata: ${connState.error}')),
          ],
        ),
      ),
    );
  }
}

