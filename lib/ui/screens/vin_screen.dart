import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VinScreen extends ConsumerStatefulWidget {
  const VinScreen({super.key});

  @override
  ConsumerState<VinScreen> createState() => _VinScreenState();
}

class VehicleInfo {
  final String vin;
  final String brand;
  final String model;
  final String year;
  final String engineType;
  final String transmission;
  final String fuelType;
  final String bodyType;
  final String manufacturingLocation;
  final String plantCode;
  final List<String> features;
  final List<RecallInfo> recalls;

  VehicleInfo({
    required this.vin,
    required this.brand,
    required this.model,
    required this.year,
    required this.engineType,
    required this.transmission,
    required this.fuelType,
    required this.bodyType,
    required this.manufacturingLocation,
    required this.plantCode,
    required this.features,
    required this.recalls,
  });
}

class RecallInfo {
  final String campaignNumber;
  final String description;
  final DateTime date;
  final String severity;

  RecallInfo({
    required this.campaignNumber,
    required this.description,
    required this.date,
    required this.severity,
  });
}

class _VinScreenState extends ConsumerState<VinScreen> {
  final TextEditingController _vinController = TextEditingController();
  bool isDecoding = false;
  VehicleInfo? vehicleInfo;
  String? error;

  @override
  void dispose() {
    _vinController.dispose();
    super.dispose();
  }

  Future<void> _readVinFromOBD() async {
    setState(() {
      isDecoding = true;
      error = null;
    });

    try {
      // Simulate reading VIN from OBD
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock VIN for demonstration
      const mockVin = 'VF1RJ000554123456';
      _vinController.text = mockVin;
      
      await _decodeVin(mockVin);
    } catch (e) {
      setState(() {
        error = 'VIN okunamadı: $e';
        isDecoding = false;
      });
    }
  }

  Future<void> _decodeVin(String vin) async {
    if (vin.length != 17) {
      setState(() {
        error = 'VIN 17 karakter olmalıdır';
        isDecoding = false;
      });
      return;
    }

    setState(() {
      isDecoding = true;
      error = null;
    });

    try {
      // Simulate VIN decoding delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock vehicle info based on VIN pattern
      final mockInfo = VehicleInfo(
        vin: vin,
        brand: 'Renault',
        model: 'Clio IV',
        year: '2018',
        engineType: '1.2 TCe 120 HP',
        transmission: '6-Speed Manual',
        fuelType: 'Gasoline',
        bodyType: '5-Door Hatchback',
        manufacturingLocation: 'Flins, France',
        plantCode: 'VF1',
        features: [
          'ABS - Anti-lock Braking System',
          'ESP - Electronic Stability Program',
          'Climate Control',
          'Power Steering',
          'Central Locking',
          'Electric Windows',
          'Airbags (Driver & Passenger)',
          'Radio/CD Player',
        ],
        recalls: [
          RecallInfo(
            campaignNumber: 'R2019-15',
            description: 'Potansiyel fren balata aşınması kontrolü',
            date: DateTime(2019, 8, 15),
            severity: 'Orta',
          ),
          RecallInfo(
            campaignNumber: 'R2020-03',
            description: 'Airbag sensör yazılım güncellemesi',
            date: DateTime(2020, 2, 10),
            severity: 'Düşük',
          ),
        ],
      );

      setState(() {
        vehicleInfo = mockInfo;
        isDecoding = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('VIN başarıyla çözümlendi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        error = 'VIN çözümlenirken hata: $e';
        isDecoding = false;
      });
    }
  }

  void _manualVinEntry() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2F),
          title: const Text(
            'VIN Girişi',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '17 haneli VIN numarasını girin:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLength: 17,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                ],
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'VIN Numarası',
                  labelStyle: TextStyle(color: Colors.white70),
                  hintText: 'Örnek: VF1RJ000554123456',
                  hintStyle: TextStyle(color: Colors.white38),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF8B1538)),
                  ),
                  counterStyle: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.length == 17) {
                  _vinController.text = controller.text;
                  Navigator.of(context).pop();
                  _decodeVin(controller.text);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B1538),
              ),
              child: const Text('Çözümle', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C54),
      appBar: AppBar(
        title: const Text('Araç Kimlik No (VIN)'),
        backgroundColor: const Color(0xFF8B1538),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Card(
              color: const Color(0xFF8B1538),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.credit_card, color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'VIN Çözümleyici',
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
                      'VIN numarasını OBD\'den okur veya manuel girilir. Araç bilgilerini, servis kayıtlarını ve geri çağırma bilgilerini gösterir.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isDecoding ? null : _readVinFromOBD,
                    icon: isDecoding
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.bluetooth),
                    label: Text(isDecoding ? 'Okunuyor...' : 'OBD\'den Oku'),
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
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isDecoding ? null : _manualVinEntry,
                    icon: const Icon(Icons.keyboard),
                    label: const Text('Manuel Giriş'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // VIN display
            if (_vinController.text.isNotEmpty)
              Card(
                color: const Color(0xFF1E1E2F),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.tag, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'VIN Numarası:',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            Text(
                              _vinController.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.white54),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _vinController.text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('VIN kopyalandı')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            
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
                          error!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Vehicle information
            if (vehicleInfo != null) ...[
              const Text(
                'Araç Bilgileri',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Basic info
                      _buildInfoCard(
                        'Temel Bilgiler',
                        Icons.info,
                        [
                          _buildInfoRow('Marka', vehicleInfo!.brand),
                          _buildInfoRow('Model', vehicleInfo!.model),
                          _buildInfoRow('Yıl', vehicleInfo!.year),
                          _buildInfoRow('Motor', vehicleInfo!.engineType),
                          _buildInfoRow('Şanzıman', vehicleInfo!.transmission),
                          _buildInfoRow('Yakıt Tipi', vehicleInfo!.fuelType),
                          _buildInfoRow('Kasa Tipi', vehicleInfo!.bodyType),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Manufacturing info
                      _buildInfoCard(
                        'Üretim Bilgileri',
                        Icons.factory,
                        [
                          _buildInfoRow('Üretim Yeri', vehicleInfo!.manufacturingLocation),
                          _buildInfoRow('Fabrika Kodu', vehicleInfo!.plantCode),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Features
                      _buildInfoCard(
                        'Standart Donanımlar',
                        Icons.star,
                        vehicleInfo!.features.map((feature) => 
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).toList(),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Recalls
                      if (vehicleInfo!.recalls.isNotEmpty)
                        _buildInfoCard(
                          'Geri Çağırma Bilgileri (${vehicleInfo!.recalls.length})',
                          Icons.warning,
                          vehicleInfo!.recalls.map((recall) => 
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getRecallSeverityColor(recall.severity),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        recall.campaignNumber,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${recall.date.day}/${recall.date.month}/${recall.date.year}',
                                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    recall.description,
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ] else if (!isDecoding) ...[
              // No data state
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.credit_card_off,
                        size: 64,
                        color: Colors.white54,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'VIN Bilgisi Yok',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'VIN okumak için OBD bağlantısı yapın\nveya manuel olarak girin',
                        style: TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Card(
      color: const Color(0xFF1E1E2F),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRecallSeverityColor(String severity) {
    switch (severity) {
      case 'Yüksek':
        return Colors.red.shade700;
      case 'Orta':
        return Colors.orange.shade700;
      case 'Düşük':
        return Colors.blue.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}