import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/connection_manager.dart';
import '../../elm/elm327_client.dart';

class BatteryTestScreen extends ConsumerStatefulWidget {
  const BatteryTestScreen({super.key});

  @override
  ConsumerState<BatteryTestScreen> createState() => _BatteryTestScreenState();
}

class _BatteryTestScreenState extends ConsumerState<BatteryTestScreen> {
  Timer? _testTimer;
  Map<String, dynamic> _batteryData = {};
  bool _isConnected = false;
  bool _isTesting = false;
  bool _isChargingTest = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _startBatteryMonitoring();
  }

  @override
  void dispose() {
    _testTimer?.cancel();
    super.dispose();
  }

  void _checkConnection() {
    final elmClient = ref.read(elmClientProvider);
    setState(() {
      _isConnected = elmClient != null;
    });
  }

  void _startBatteryMonitoring() {
    _testTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isConnected) {
        _readBatteryData();
      }
    });
  }

  Future<void> _readBatteryData() async {
    try {
      final elmClient = ref.read(elmClientProvider);
      if (elmClient == null) return;

      // Read battery voltage (PID 42)
      final voltageResponse = await elmClient.sendCommand('42');
      final voltage = _parseBatteryVoltage(voltageResponse);

      // Read alternator status (PID 43)
      final alternatorResponse = await elmClient.sendCommand('43');
      final alternator = _parseAlternatorStatus(alternatorResponse);

      setState(() {
        _batteryData = {
          'voltage': voltage,
          'alternator': alternator,
          'timestamp': DateTime.now(),
          'isCharging': alternator > 13.5, // Typically alternator charges at 13.5-14.5V
        };
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
      });
    }
  }

  double _parseBatteryVoltage(String response) {
    try {
      if (response.contains('41 42')) {
        final dataPart = response.split('41 42')[1];
        if (dataPart.isNotEmpty) {
          final hexValue = dataPart.substring(0, 2);
          final intValue = int.parse(hexValue, radix: 16);
          return intValue / 10.0; // Convert to volts (OBD-II typically sends value * 10)
        }
      }
    } catch (e) {
      return 0.0;
    }
    return 0.0;
  }

  double _parseAlternatorStatus(String response) {
    try {
      if (response.contains('41 43')) {
        final dataPart = response.split('41 43')[1];
        if (dataPart.isNotEmpty) {
          final hexValue = dataPart.substring(0, 2);
          final intValue = int.parse(hexValue, radix: 16);
          return intValue / 10.0; // Convert to volts
        }
      }
    } catch (e) {
      return 0.0;
    }
    return 0.0;
  }

  Future<void> _performBatteryTest() async {
    setState(() {
      _isTesting = true;
    });

    try {
      // Simulate comprehensive battery test
      await Future.delayed(const Duration(seconds: 3));

      final voltage = _batteryData['voltage'] ?? 0.0;
      final alternator = _batteryData['alternator'] ?? 0.0;
      final isCharging = _batteryData['isCharging'] ?? false;

      // Analyze results
      final analysis = _analyzeBatteryHealth(voltage, alternator, isCharging);

      setState(() {
        _batteryData.addAll(analysis);
        _isTesting = false;
      });

      // Show results dialog
      _showTestResults(analysis);
    } catch (e) {
      setState(() {
        _isTesting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Test hatası: ${e.toString()}')),
      );
    }
  }

  Future<void> _performChargingTest() async {
    setState(() {
      _isChargingTest = true;
    });

    try {
      // Monitor voltage while engine is running
      await Future.delayed(const Duration(seconds: 5));

      final voltage = _batteryData['voltage'] ?? 0.0;
      final alternator = _batteryData['alternator'] ?? 0.0;

      final chargingAnalysis = _analyzeChargingSystem(voltage, alternator);

      setState(() {
        _batteryData.addAll(chargingAnalysis);
        _isChargingTest = false;
      });

      _showChargingResults(chargingAnalysis);
    } catch (e) {
      setState(() {
        _isChargingTest = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Şarj testi hatası: ${e.toString()}')),
      );
    }
  }

  Map<String, dynamic> _analyzeBatteryHealth(double voltage, double alternator, bool isCharging) {
    String status;
    String recommendation;
    Color statusColor;
    IconData statusIcon;

    // Battery voltage analysis
    if (voltage < 12.4) {
      status = 'Kötü';
      recommendation = 'Akü değiştirilmeli';
      statusColor = Colors.red;
      statusIcon = Icons.battery_alert;
    } else if (voltage < 12.6) {
      status = 'Zayıf';
      recommendation = 'Akü şarj edilmeli';
      statusColor = Colors.orange;
      statusIcon = Icons.battery_std;
    } else if (voltage <= 12.8) {
      status = 'İyi';
      recommendation = 'Akü durumu normal';
      statusColor = Colors.green;
      statusIcon = Icons.battery_full;
    } else {
      status = 'Mükemmel';
      recommendation = 'Akü durumu çok iyi';
      statusColor = Colors.blue;
      statusIcon = Icons.battery_charging_full;
    }

    // Estimate battery life
    String estimatedLife;
    if (voltage < 12.2) {
      estimatedLife = '0-6 ay';
    } else if (voltage < 12.4) {
      estimatedLife = '6-12 ay';
    } else if (voltage < 12.6) {
      estimatedLife = '1-2 yıl';
    } else {
      estimatedLife = '2+ yıl';
    }

    return {
      'status': status,
      'recommendation': recommendation,
      'statusColor': statusColor,
      'statusIcon': statusIcon,
      'estimatedLife': estimatedLife,
      'healthScore': _calculateHealthScore(voltage),
    };
  }

  Map<String, dynamic> _analyzeChargingSystem(double voltage, double alternator) {
    String chargingStatus;
    String chargingRecommendation;
    Color chargingColor;
    IconData chargingIcon;

    if (alternator > 14.5) {
      chargingStatus = 'Yüksek Voltaj';
      chargingRecommendation = 'Alternatör kontrolü gerekli';
      chargingColor = Colors.red;
      chargingIcon = Icons.warning;
    } else if (alternator < 13.0) {
      chargingStatus = 'Düşük Şarj';
      chargingRecommendation = 'Şarj sistemi arızalı olabilir';
      chargingColor = Colors.orange;
      chargingIcon = Icons.battery_charging_full;
    } else if (alternator >= 13.5 && alternator <= 14.5) {
      chargingStatus = 'Normal';
      chargingRecommendation = 'Şarj sistemi çalışıyor';
      chargingColor = Colors.green;
      chargingIcon = Icons.check_circle;
    } else {
      chargingStatus = 'Bilinmiyor';
      chargingRecommendation = 'Veri alınamıyor';
      chargingColor = Colors.grey;
      chargingIcon = Icons.help;
    }

    return {
      'chargingStatus': chargingStatus,
      'chargingRecommendation': chargingRecommendation,
      'chargingColor': chargingColor,
      'chargingIcon': chargingIcon,
    };
  }

  int _calculateHealthScore(double voltage) {
    if (voltage >= 12.6) return 100;
    if (voltage >= 12.4) return 75;
    if (voltage >= 12.2) return 50;
    if (voltage >= 12.0) return 25;
    return 0;
  }

  void _showTestResults(Map<String, dynamic> analysis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batarya Test Sonuçları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultRow('Durum', analysis['status'], analysis['statusColor']),
            _buildResultRow('Öneri', analysis['recommendation'], analysis['statusColor']),
            _buildResultRow('Tahmini Ömür', analysis['estimatedLife'], analysis['statusColor']),
            _buildResultRow('Sağlık Skoru', '${analysis['healthScore']}/100', analysis['statusColor']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showChargingResults(Map<String, dynamic> analysis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şarj Sistemi Testi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultRow('Şarj Durumu', analysis['chargingStatus'], analysis['chargingColor']),
            _buildResultRow('Öneri', analysis['chargingRecommendation'], analysis['chargingColor']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final voltage = _batteryData['voltage'] ?? 0.0;
    final alternator = _batteryData['alternator'] ?? 0.0;
    final isCharging = _batteryData['isCharging'] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batarya Testi'),
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
                  Icons.battery_charging_full,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  _isConnected ? 'Batarya İzleniyor...' : 'Bağlı Değil',
                  style: TextStyle(
                    color: _isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Real-time Battery Info
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF1E1E2F),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBatteryInfoCard(
                      'Batarya Voltajı',
                      '${voltage.toStringAsFixed(1)} V',
                      Icons.battery_std,
                      _getVoltageColor(voltage),
                    ),
                    _buildBatteryInfoCard(
                      'Şarj Voltajı',
                      '${alternator.toStringAsFixed(1)} V',
                      Icons.battery_charging_full,
                      _getChargingColor(alternator),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (isCharging)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '🔋 Şarj Ediliyor',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Test Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTesting ? null : _performBatteryTest,
                    icon: _isTesting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.battery_alert),
                    label: const Text('Batarya Testi'),
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
                    onPressed: _isChargingTest ? null : _performChargingTest,
                    icon: _isChargingTest
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.electric_bolt),
                    label: const Text('Şarj Testi'),
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

          // Battery Health Indicator
          if (_batteryData.containsKey('healthScore')) ...[
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Batarya Sağlık Skoru',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: (_batteryData['healthScore'] ?? 0) / 100,
                        strokeWidth: 20,
                        backgroundColor: Colors.grey[800],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getHealthColor(_batteryData['healthScore'] ?? 0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${_batteryData['healthScore'] ?? 0}/100',
                      style: TextStyle(
                        color: _getHealthColor(_batteryData['healthScore'] ?? 0),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _batteryData['estimatedLife'] ?? 'Bilinmiyor',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getVoltageColor(double voltage) {
    if (voltage < 12.4) return Colors.red;
    if (voltage < 12.6) return Colors.orange;
    return Colors.green;
  }

  Color _getChargingColor(double voltage) {
    if (voltage > 14.5) return Colors.red;
    if (voltage < 13.0) return Colors.orange;
    return Colors.green;
  }

  Color _getHealthColor(int score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  Widget _buildBatteryInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D3D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}