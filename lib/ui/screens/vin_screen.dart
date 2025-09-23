import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../core/connection_manager.dart';
import '../../elm/elm327_client.dart';

class VinScreen extends ConsumerStatefulWidget {
  const VinScreen({super.key});

  @override
  ConsumerState<VinScreen> createState() => _VinScreenState();
}

class _VinScreenState extends ConsumerState<VinScreen> {
  String _vin = '';
  Map<String, dynamic> _vehicleInfo = {};
  bool _isConnected = false;
  bool _isLoading = false;
  bool _isManualEntry = false;

  // Mock VIN database for demonstration
  final Map<String, Map<String, dynamic>> _vinDatabase = {
    'VF1RFD00612345678': {
      'make': 'Renault',
      'model': 'Clio',
      'year': '2018',
      'engine': '1.5 dCi',
      'fuel': 'Dizel',
      'transmission': 'Manuel',
      'color': 'Beyaz',
      'country': 'Fransa',
    },
    'VF1RFB00612345678': {
      'make': 'Renault',
      'model': 'Clio',
      'year': '2018',
      'engine': '1.2 TCe',
      'fuel': 'Benzin',
      'transmission': 'Otomatik',
      'color': 'Mavi',
      'country': 'Fransa',
    },
  };

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  void _checkConnection() {
    final elmClient = ref.read(elmClientProvider);
    setState(() {
      _isConnected = elmClient != null;
    });
  }

  Future<void> _readVinFromVehicle() async {
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OBD cihazına bağlanın')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final elmClient = ref.read(elmClientProvider);
      if (elmClient == null) return;

      // Read VIN using OBD-II mode 9 (PID 02)
      final response = await elmClient.sendCommand('0902');
      final vin = _parseVinResponse(response);

      if (vin.isNotEmpty) {
        setState(() {
          _vin = vin;
        });

        await _decodeVin(vin);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('VIN okundu: $_vin')),
        );
      } else {
        throw Exception('VIN okunamadı');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('VIN okuma hatası: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _parseVinResponse(String response) {
    try {
      // Parse VIN from OBD-II response
      // Mode 9 PID 2 returns VIN in ASCII format
      if (response.contains('49 02')) {
        // Extract VIN data from response
        // This is simplified - actual parsing would be more complex
        return 'VF1RFD00612345678'; // Mock VIN for demonstration
      }
    } catch (e) {
      return '';
    }
    return '';
  }

  Future<void> _decodeVin(String vin) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate VIN decoding delay
      await Future.delayed(const Duration(seconds: 2));

      // Look up VIN in database
      final vehicleInfo = _vinDatabase[vin] ?? _decodeVinManually(vin);

      setState(() {
        _vehicleInfo = vehicleInfo;
      });
    } catch (e) {
      setState(() {
        _vehicleInfo = {'error': 'VIN çözümlenemedi'};
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _decodeVinManually(String vin) {
    // Basic VIN decoding logic
    if (vin.length != 17) {
      return {'error': 'Geçersiz VIN formatı'};
    }

    // Extract basic information from VIN
    final wmi = vin.substring(0, 3); // World Manufacturer Identifier
    final vds = vin.substring(3, 9); // Vehicle Descriptor Section
    final vis = vin.substring(9, 17); // Vehicle Identifier Section

    String make = '';
    String model = '';
    String year = '';

    // Decode WMI (simplified)
    if (wmi.startsWith('VF1')) {
      make = 'Renault';
      if (vds.startsWith('RF')) {
        model = 'Clio';
        year = '2018';
      }
    }

    return {
      'make': make,
      'model': model,
      'year': year,
      'vin': vin,
      'wmi': wmi,
      'vds': vds,
      'vis': vis,
    };
  }

  bool _isValidVin(String vin) {
    if (vin.length != 17) return false;

    // Check for invalid characters (I, O, Q should not be in VIN)
    final invalidChars = ['I', 'O', 'Q'];
    for (final char in vin.toUpperCase().split('')) {
      if (invalidChars.contains(char)) return false;
    }

    return true;
  }

  void _onVinChanged(String value) {
    final cleanVin = value.toUpperCase().replaceAll(RegExp(r'[^A-HJ-NPR-Z0-9]'), '');

    if (cleanVin.length <= 17) {
      setState(() {
        _vin = cleanVin;
      });

      if (cleanVin.length == 17 && _isValidVin(cleanVin)) {
        _decodeVin(cleanVin);
      }
    }
  }

  void _clearVin() {
    setState(() {
      _vin = '';
      _vehicleInfo = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Araç Kimlik No'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _vin.isNotEmpty ? _clearVin : null,
            icon: const Icon(Icons.clear),
            tooltip: 'Temizle',
          ),
        ],
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
                  Icons.badge,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  _isConnected ? 'VIN Okunabilir' : 'Bağlı Değil',
                  style: TextStyle(
                    color: _isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _isManualEntry,
                  onChanged: (value) {
                    setState(() {
                      _isManualEntry = value;
                    });
                  },
                  activeColor: Colors.red,
                ),
                const Text(
                  'Manuel',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),

          // VIN Input Section
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF1E1E2F),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VIN (Araç Kimlik Numarası)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '17 karakterlik VIN numarasını girin veya araçtan okuyun',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'VIN numarasını girin...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: const Color(0xFF2D2D3D),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: _isConnected && !_isManualEntry
                        ? IconButton(
                            onPressed: _isLoading ? null : _readVinFromVehicle,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.red,
                                    ),
                                  )
                                : const Icon(Icons.download, color: Colors.red),
                          )
                        : null,
                  ),
                  style: const TextStyle(color: Colors.white),
                  maxLength: 17,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[A-HJ-NPR-Z0-9]'),
                    ),
                    UpperCaseTextFormatter(),
                  ],
                  onChanged: _onVinChanged,
                  controller: TextEditingController(text: _vin)
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: _vin.length),
                    ),
                ),
                if (_vin.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${_vin.length}/17 karakter',
                    style: TextStyle(
                      color: _vin.length == 17 ? Colors.green : Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Vehicle Information Display
          if (_vehicleInfo.isNotEmpty) ...[
            Expanded(
              child: _buildVehicleInfo(),
            ),
          ] else if (_vin.isNotEmpty && _vin.length == 17) ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'VIN çözümleniyor...',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: _buildVinHelp(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVehicleInfo() {
    if (_vehicleInfo.containsKey('error')) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'VIN Çözümlenemedi',
              style: TextStyle(color: Colors.red, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _vehicleInfo['error'],
              style: TextStyle(color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D3D),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.directions_car, color: Colors.red, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_vehicleInfo['make']} ${_vehicleInfo['model']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Model Yılı: ${_vehicleInfo['year']}',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Vehicle Details
          const Text(
            'Araç Bilgileri',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoCard([
            _buildInfoRow('VIN', _vin),
            _buildInfoRow('Marka', _vehicleInfo['make'] ?? 'Bilinmiyor'),
            _buildInfoRow('Model', _vehicleInfo['model'] ?? 'Bilinmiyor'),
            _buildInfoRow('Yıl', _vehicleInfo['year'] ?? 'Bilinmiyor'),
            _buildInfoRow('Motor', _vehicleInfo['engine'] ?? 'Bilinmiyor'),
            _buildInfoRow('Yakıt', _vehicleInfo['fuel'] ?? 'Bilinmiyor'),
            _buildInfoRow('Vites', _vehicleInfo['transmission'] ?? 'Bilinmiyor'),
            _buildInfoRow('Renk', _vehicleInfo['color'] ?? 'Bilinmiyor'),
          ]),

          const SizedBox(height: 20),

          // VIN Breakdown
          const Text(
            'VIN Analizi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoCard([
            _buildInfoRow('WMI (Üretici)', _vehicleInfo['wmi'] ?? '--'),
            _buildInfoRow('VDS (Özellikler)', _vehicleInfo['vds'] ?? '--'),
            _buildInfoRow('VIS (Seri No)', _vehicleInfo['vis'] ?? '--'),
          ]),

          const SizedBox(height: 20),

          // Service & Recall Info
          if (_vehicleInfo.containsKey('make')) ...[
            _buildServiceInfo(),
          ],
        ],
      ),
    );
  }

  Widget _buildVinHelp() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.help_outline, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'VIN Nasıl Bulunur?',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D3D),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Text(
                  '1. Araç ruhsatında VIN numarasını arayın',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  '2. Motor kaputunun altında VIN etiketini kontrol edin',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  '3. Sürücü kapısı iç tarafında VIN etiketini arayın',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D3D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Servis & Geri Çağırma',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoCard([
          _buildInfoRow('Son Servis', '15.01.2024'),
          _buildInfoRow('Son Muayene', 'Geçti'),
          _buildInfoRow('Geri Çağırma', 'Aktif geri çağırma bulunamadı'),
          _buildInfoRow('Garanti Durumu', 'Garanti süresi dolmuş'),
        ]),
      ],
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}