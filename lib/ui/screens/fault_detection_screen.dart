import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/connection_manager.dart';
import '../../elm/elm327_client.dart';
import '../../data/dtc_repository.dart';
import '../error_handler.dart';

class FaultDetectionScreen extends ConsumerStatefulWidget {
  const FaultDetectionScreen({super.key});

  @override
  ConsumerState<FaultDetectionScreen> createState() => _FaultDetectionScreenState();
}

class _FaultDetectionScreenState extends ConsumerState<FaultDetectionScreen> {
  List<DtcCode> dtcs = [];
  bool scanning = false;
  bool clearing = false;
  String? error;
  String? vin;

  @override
  Widget build(BuildContext context) {
    final client = ref.watch(elmClientProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C54),
      appBar: AppBar(
        title: const Text('Arıza Tespiti'),
        backgroundColor: const Color(0xFF8B1538),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            onPressed: dtcs.isEmpty || client == null || clearing
                ? null
                : () => _clearDtcs(client),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card with info
            Card(
              color: const Color(0xFF8B1538),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.search, color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'ECU Arıza Kod Taraması',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'ECU üzerinden hata kodlarını (DTC) okur ve bulunan arızaları liste halinde gösterir.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    if (vin != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'VIN: $vin',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Scan button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: scanning || client == null
                    ? null
                    : () => _scanForFaults(client),
                icon: scanning 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.search),
                label: Text(scanning ? 'Taranıyor...' : 'Arıza Kodlarını Tara'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B1538),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Error display
            if (error != null)
              Card(
                color: Colors.red.shade800,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Hata: $error',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Results header
            Row(
              children: [
                const Icon(Icons.list, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Bulunan Arızalar (${dtcs.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // DTC list
            Expanded(
              child: dtcs.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: Colors.green,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Arıza bulunamadı',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tarama yapın veya araç bağlantısını kontrol edin',
                            style: TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: dtcs.length,
                      itemBuilder: (context, index) {
                        final dtc = dtcs[index];
                        return Card(
                          color: const Color(0xFF1E1E2F),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red.shade800,
                              child: const Icon(
                                Icons.warning,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              dtc.code,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              dtc.source,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Colors.white54,
                            ),
                            onTap: () {
                              _showDtcDetails(context, dtc);
                            },
                          ),
                        );
                      },
                    ),
            ),
            
            // Clear button
            if (dtcs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: clearing || client == null
                        ? null
                        : () => _clearDtcs(client),
                    icon: clearing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.delete_sweep),
                    label: Text(clearing ? 'Temizleniyor...' : 'Hataları Sil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanForFaults(Elm327Client client) async {
    setState(() {
      scanning = true;
      error = null;
    });

    try {
      // Read VIN first
      final vinResult = await client.readVin();
      // Read DTCs
      final dtcResult = await client.readDtcs();
      
      setState(() {
        vin = vinResult;
        dtcs = dtcResult;
        scanning = false;
      });

      if (dtcResult.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Arıza bulunamadı. Araç sağlıklı görünüyor.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        scanning = false;
      });
    }
  }

  Future<void> _clearDtcs(Elm327Client client) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2F),
        title: const Text(
          'Hataları Temizle',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tüm arıza kodları silinecek. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      clearing = true;
      error = null;
    });

    try {
      await client.clearDtcs();
      // Re-scan to verify clearing
      final refreshedDtcs = await client.readDtcs();
      
      setState(() {
        dtcs = refreshedDtcs;
        clearing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Arıza kodları başarıyla temizlendi.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        clearing = false;
      });
    }
  }

  void _showDtcDetails(BuildContext context, DtcCode dtc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2F),
        title: Text(
          dtc.code,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Açıklama:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              dtc.source,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            const Text(
              'Örnek: P0300 – Rastgele Silindir Ateşleme Hatası',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}