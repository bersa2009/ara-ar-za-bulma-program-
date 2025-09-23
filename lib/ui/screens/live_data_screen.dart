import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:math';

class LiveDataScreen extends ConsumerStatefulWidget {
  const LiveDataScreen({super.key});

  @override
  ConsumerState<LiveDataScreen> createState() => _LiveDataScreenState();
}

class _LiveDataScreenState extends ConsumerState<LiveDataScreen> {
  bool isConnected = false;
  bool isStreaming = false;
  Timer? _dataTimer;
  
  // Mock live data
  double rpm = 0;
  double speed = 0;
  double engineTemp = 0;
  double fuelPressure = 0;
  double o2Sensor = 0;
  double throttlePosition = 0;
  double intakeAirTemp = 0;
  double batteryVoltage = 12.4;

  @override
  void dispose() {
    _dataTimer?.cancel();
    _dataTimer = null;
    super.dispose();
  }

  void _startDataStream() {
    setState(() {
      isStreaming = true;
      isConnected = true;
    });

    _dataTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          // Simulate realistic engine data
          rpm = 800 + Random().nextDouble() * 3000;
          speed = Random().nextDouble() * 120;
          engineTemp = 85 + Random().nextDouble() * 15;
          fuelPressure = 2.8 + Random().nextDouble() * 1.2;
          o2Sensor = 0.1 + Random().nextDouble() * 0.8;
          throttlePosition = Random().nextDouble() * 100;
          intakeAirTemp = 20 + Random().nextDouble() * 30;
          batteryVoltage = 12.0 + Random().nextDouble() * 2.0;
        });
      }
    });
  }

  void _stopDataStream() {
    _dataTimer?.cancel();
    setState(() {
      isStreaming = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C54),
      appBar: AppBar(
        title: const Text('Canlı Veri'),
        backgroundColor: const Color(0xFF8B1538),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(isStreaming ? Icons.stop : Icons.play_arrow),
            onPressed: isStreaming ? _stopDataStream : _startDataStream,
          ),
        ],
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
                        Icon(
                          isConnected ? Icons.wifi : Icons.wifi_off,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isConnected ? 'Canlı Veri Akışı' : 'Bağlantı Bekleniyor',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isStreaming 
                          ? 'Motor, şanzıman ve sensörlerden gerçek zamanlı parametreler gösteriliyor.'
                          : 'Veri akışını başlatmak için oynat butonuna basın.',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Control button
            if (!isConnected)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startDataStream,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Veri Akışını Başlat'),
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
            
            // Live data grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _buildDataCard(
                    'RPM',
                    rpm.toInt().toString(),
                    'dev/dk',
                    Icons.speed,
                    _getRpmColor(rpm),
                  ),
                  _buildDataCard(
                    'Hız',
                    speed.toInt().toString(),
                    'km/h',
                    Icons.dashboard,
                    _getSpeedColor(speed),
                  ),
                  _buildDataCard(
                    'Motor Sıcaklığı',
                    '${engineTemp.toInt()}°',
                    'Celsius',
                    Icons.thermostat,
                    _getTempColor(engineTemp),
                  ),
                  _buildDataCard(
                    'Yakıt Basıncı',
                    fuelPressure.toStringAsFixed(1),
                    'bar',
                    Icons.local_gas_station,
                    Colors.blue,
                  ),
                  _buildDataCard(
                    'O₂ Sensörü',
                    o2Sensor.toStringAsFixed(2),
                    'V',
                    Icons.sensors,
                    Colors.green,
                  ),
                  _buildDataCard(
                    'Gaz Kelebeği',
                    '${throttlePosition.toInt()}%',
                    'Açıklık',
                    Icons.tune,
                    Colors.orange,
                  ),
                  _buildDataCard(
                    'Hava Sıcaklığı',
                    '${intakeAirTemp.toInt()}°',
                    'Celsius',
                    Icons.air,
                    Colors.cyan,
                  ),
                  _buildDataCard(
                    'Akü Voltajı',
                    batteryVoltage.toStringAsFixed(1),
                    'V',
                    Icons.battery_charging_full,
                    _getBatteryColor(batteryVoltage),
                  ),
                ],
              ),
            ),
            
            // Status indicator
            if (isStreaming)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Veri akışı aktif - Grafik ve tablo görselleri ile sunuluyor',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard(String title, String value, String unit, IconData icon, Color color) {
    return Card(
      color: const Color(0xFF1E1E2F),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              unit,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRpmColor(double rpm) {
    if (rpm < 1000) return Colors.blue;
    if (rpm < 3000) return Colors.green;
    if (rpm < 5000) return Colors.orange;
    return Colors.red;
  }

  Color _getSpeedColor(double speed) {
    if (speed < 50) return Colors.green;
    if (speed < 90) return Colors.orange;
    return Colors.red;
  }

  Color _getTempColor(double temp) {
    if (temp < 85) return Colors.blue;
    if (temp < 95) return Colors.green;
    if (temp < 105) return Colors.orange;
    return Colors.red;
  }

  Color _getBatteryColor(double voltage) {
    if (voltage < 11.5) return Colors.red;
    if (voltage < 12.0) return Colors.orange;
    return Colors.green;
  }
}