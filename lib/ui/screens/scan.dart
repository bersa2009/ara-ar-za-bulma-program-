import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/connection_manager.dart';
import '../../elm/elm327_client.dart';
import 'report.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  String? vin;
  List<DtcCode> dtcs = [];
  bool scanning = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    final client = ref.watch(elmClientProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarama'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            onPressed: dtcs.isEmpty || client == null
                ? null
                : () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('DTC Temizleme'),
                        content: const Text('Silmeden önce raporu PDF olarak yedeklemek ister misiniz?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Atla')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('PDF Yedekle')),
                        ],
                      ),
                    );
                    if (ok == true) {
                      // open report screen to export
                      // ignore: use_build_context_synchronously
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportScreen(
                            items: dtcs
                                .map((d) => ReportItem(code: d.code, title: d.source))
                                .toList(),
                          ),
                        ),
                      );
                    }
                    try {
                      setState(() => scanning = true);
                      await client.clearDtcs();
                      final refreshed = await client.readDtcs();
                      setState(() {
                        dtcs = refreshed;
                        scanning = false;
                      });
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('DTC temizlendi')));
                    } catch (e) {
                      setState(() {
                        error = e.toString();
                        scanning = false;
                      });
                    }
                  },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: scanning || client == null
                      ? null
                      : () async {
                          setState(() {
                            scanning = true;
                            error = null;
                          });
                          try {
                            final v = await client.readVin();
                            final codes = await client.readDtcs();
                            setState(() {
                              vin = v;
                              dtcs = codes;
                              scanning = false;
                            });
                          } catch (e) {
                            setState(() {
                              error = e.toString();
                              scanning = false;
                            });
                          }
                        },
                  child: Text(scanning ? 'Taranıyor...' : 'Tara'),
                ),
                const SizedBox(width: 12),
                if (vin != null) Text('VIN: $vin'),
              ],
            ),
            const SizedBox(height: 12),
            if (error != null) Text('Hata: $error', style: const TextStyle(color: Colors.red)),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: dtcs.length,
                itemBuilder: (ctx, i) {
                  final d = dtcs[i];
                  return ListTile(
                    title: Text(d.code),
                    subtitle: Text(d.source),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

