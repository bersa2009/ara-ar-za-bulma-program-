import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/connection_manager.dart';
import '../../data/dtc_repository.dart';
import '../../elm/elm327_client.dart';

class FaultDetectionScreen extends ConsumerStatefulWidget {
  const FaultDetectionScreen({super.key});

  @override
  ConsumerState<FaultDetectionScreen> createState() => _FaultDetectionScreenState();
}

class _FaultDetectionScreenState extends ConsumerState<FaultDetectionScreen> {
  final DtcRepository _dtcRepository = DtcRepository();
  List<Map<String, dynamic>> _detectedFaults = [];
  bool _isScanning = false;
  bool _isClearing = false;

  @override
  void initState() {
    super.initState();
    _initializeDtcRepository();
  }

  Future<void> _initializeDtcRepository() async {
    await _dtcRepository.ensureSeeded(['tr', 'en']);
  }

  Future<void> _scanForFaults() async {
    setState(() {
      _isScanning = true;
      _detectedFaults = [];
    });

    try {
      final connectionManager = ref.read(connectionManagerProvider);
      final elmClient = ref.read(elmClientProvider);

      if (elmClient == null) {
        throw Exception('OBD cihazına bağlanılmamış');
      }

      // Read DTC codes from the vehicle
      final response = await elmClient.sendCommand('03'); // Read DTC command

      if (response.contains('43')) {
        // Parse the response and extract DTC codes
        // This is a simplified example - actual parsing would be more complex
        final dtcCodes = _parseDtcResponse(response);

        // Get detailed information for each DTC code
        final faults = <Map<String, dynamic>>[];
        for (final code in dtcCodes) {
          final dtcInfo = await _dtcRepository.getDtc(code, lang: 'tr');
          if (dtcInfo != null) {
            faults.add(dtcInfo);
          }
        }

        setState(() {
          _detectedFaults = faults;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _clearFaults() async {
    setState(() {
      _isClearing = true;
    });

    try {
      final connectionManager = ref.read(connectionManagerProvider);
      final elmClient = ref.read(elmClientProvider);

      if (elmClient == null) {
        throw Exception('OBD cihazına bağlanılmamış');
      }

      // Clear DTC codes
      await elmClient.sendCommand('04'); // Clear DTC command

      setState(() {
        _detectedFaults = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hata kodları temizlendi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isClearing = false;
      });
    }
  }

  List<String> _parseDtcResponse(String response) {
    // Simplified DTC parsing - actual implementation would be more robust
    final codes = <String>[];
    // Parse the response according to ELM327 protocol
    // This is a placeholder for actual parsing logic
    return codes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arıza Tespit'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Connection Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF2D2D3D),
            child: Row(
              children: [
                Icon(
                  Icons.bluetooth_connected,
                  color: ref.watch(elmClientProvider) != null
                      ? Colors.green
                      : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  ref.watch(elmClientProvider) != null
                      ? 'Bağlı'
                      : 'Bağlı Değil',
                  style: TextStyle(
                    color: ref.watch(elmClientProvider) != null
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isScanning ? null : _scanForFaults,
                    icon: _isScanning
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: const Text('Tara'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isClearing || _detectedFaults.isEmpty
                        ? null
                        : _clearFaults,
                    icon: _isClearing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.clear),
                    label: const Text('Temizle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Faults List
          Expanded(
            child: _detectedFaults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 80,
                          color: Colors.green.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Arıza Kodu Bulunamadı',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Araçta tespit edilen bir sorun yok',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _detectedFaults.length,
                    itemBuilder: (context, index) {
                      final fault = _detectedFaults[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Text(
                              fault['code'].toString().substring(0, 1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            fault['code'] ?? 'Bilinmeyen Kod',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            fault['title'] ?? 'Açıklama mevcut değil',
                            maxLines: 2,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.info),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(fault['code'] ?? 'Bilinmeyen Kod'),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          fault['title'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(fault['description'] ?? ''),
                                        if (fault['causes'] != null) ...[
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Olası Nedenler:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(fault['causes'].toString()),
                                        ],
                                        if (fault['fixes'] != null) ...[
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Önerilen Çözümler:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(fault['fixes'].toString()),
                                        ],
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Kapat'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}