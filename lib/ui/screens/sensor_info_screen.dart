import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

class SensorInfoScreen extends ConsumerStatefulWidget {
  const SensorInfoScreen({super.key});

  @override
  ConsumerState<SensorInfoScreen> createState() => _SensorInfoScreenState();
}

class SensorInfoState {
  final String name;
  final String code;
  final bool isWorking;
  final double? value;
  final String unit;
  final String description;
  final IconData icon;

  SensorInfoState({
    required this.name,
    required this.code,
    required this.isWorking,
    this.value,
    required this.unit,
    required this.description,
    required this.icon,
  });
}

class _SensorInfoScreenState extends ConsumerState<SensorInfoScreen> {
  bool isScanning = false;
  List<SensorInfoState> sensors = [];

  @override
  void initState() {
    super.initState();
    _loadSensorData();
  }

  void _loadSensorData() {
    // Mock sensor data
    sensors = [
      SensorInfoState(
        name: 'ABS Sensörü',
        code: 'ABS01',
        isWorking: true,
        value: 0.0,
        unit: 'km/h',
        description: 'Anti-lock Braking System wheel speed sensor',
        icon: Icons.car_crash,
      ),
      SensorInfoState(
        name: 'Lambda Sensörü',
        code: 'O2S11',
        isWorking: true,
        value: 0.45,
        unit: 'V',
        description: 'Oxygen sensor - monitors exhaust gas composition',
        icon: Icons.sensors,
      ),
      SensorInfoState(
        name: 'MAP Sensörü',
        code: 'MAP01',
        isWorking: true,
        value: 1.2,
        unit: 'bar',
        description: 'Manifold Absolute Pressure sensor',
        icon: Icons.compress,
      ),
      SensorInfoState(
        name: 'MAF Sensörü',
        code: 'MAF01',
        isWorking: false,
        value: null,
        unit: 'g/s',
        description: 'Mass Air Flow sensor - measures air intake',
        icon: Icons.air,
      ),
      SensorInfoState(
        name: 'TPS Sensörü',
        code: 'TPS01',
        isWorking: true,
        value: 15.5,
        unit: '%',
        description: 'Throttle Position Sensor',
        icon: Icons.tune,
      ),
      SensorInfoState(
        name: 'ECT Sensörü',
        code: 'ECT01',
        isWorking: true,
        value: 92.0,
        unit: '°C',
        description: 'Engine Coolant Temperature sensor',
        icon: Icons.thermostat,
      ),
      SensorInfoState(
        name: 'IAT Sensörü',
        code: 'IAT01',
        isWorking: true,
        value: 25.0,
        unit: '°C',
        description: 'Intake Air Temperature sensor',
        icon: Icons.device_thermostat,
      ),
      SensorInfoState(
        name: 'VSS Sensörü',
        code: 'VSS01',
        isWorking: true,
        value: 0.0,
        unit: 'km/h',
        description: 'Vehicle Speed Sensor',
        icon: Icons.speed,
      ),
      SensorInfoState(
        name: 'CKP Sensörü',
        code: 'CKP01',
        isWorking: true,
        value: 850.0,
        unit: 'RPM',
        description: 'Crankshaft Position Sensor',
        icon: Icons.rotate_right,
      ),
      SensorInfoState(
        name: 'CMP Sensörü',
        code: 'CMP01',
        isWorking: false,
        value: null,
        unit: 'RPM',
        description: 'Camshaft Position Sensor',
        icon: Icons.settings,
      ),
    ];
  }

  Future<void> _scanSensors() async {
    setState(() {
      isScanning = true;
    });

    // Simulate scanning delay
    await Future.delayed(const Duration(seconds: 2));

    // Randomly update sensor values
    for (int i = 0; i < sensors.length; i++) {
      final sensor = sensors[i];
      if (sensor.isWorking && sensor.value != null) {
        double newValue = sensor.value!;
        switch (sensor.code) {
          case 'O2S11':
            newValue = 0.1 + Random().nextDouble() * 0.8;
            break;
          case 'MAP01':
            newValue = 0.8 + Random().nextDouble() * 1.0;
            break;
          case 'TPS01':
            newValue = Random().nextDouble() * 100;
            break;
          case 'ECT01':
            newValue = 85 + Random().nextDouble() * 15;
            break;
          case 'IAT01':
            newValue = 20 + Random().nextDouble() * 30;
            break;
          case 'CKP01':
            newValue = 800 + Random().nextDouble() * 3000;
            break;
        }
        
        sensors[i] = SensorInfoState(
          name: sensor.name,
          code: sensor.code,
          isWorking: sensor.isWorking,
          value: newValue,
          unit: sensor.unit,
          description: sensor.description,
          icon: sensor.icon,
        );
      }
    }

    setState(() {
      isScanning = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sensör taraması tamamlandı'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final workingSensors = sensors.where((s) => s.isWorking).length;
    final totalSensors = sensors.length;

    return Scaffold(
      backgroundColor: const Color(0xFF2C2C54),
      appBar: AppBar(
        title: const Text('Sensör Bilgisi'),
        backgroundColor: const Color(0xFF8B1538),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: isScanning 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: isScanning ? null : _scanSensors,
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
                        const Icon(Icons.bar_chart, color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Sensör Durumu',
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
                      'Araçtaki tüm sensörlerin anlık durumu gösterilir. Çalışmayan/arızalı sensörler işaretlenir.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStatusChip('Çalışan', workingSensors, Colors.green),
                        const SizedBox(width: 8),
                        _buildStatusChip('Arızalı', totalSensors - workingSensors, Colors.red),
                        const SizedBox(width: 8),
                        _buildStatusChip('Toplam', totalSensors, Colors.blue),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Scan button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isScanning ? null : _scanSensors,
                icon: isScanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.search),
                label: Text(isScanning ? 'Taranıyor...' : 'Sensörleri Tara'),
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
            
            // Sensors list
            Expanded(
              child: ListView.builder(
                itemCount: sensors.length,
                itemBuilder: (context, index) {
                  final sensor = sensors[index];
                  return Card(
                    color: const Color(0xFF1E1E2F),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: sensor.isWorking 
                            ? Colors.green.shade700 
                            : Colors.red.shade700,
                        child: Icon(
                          sensor.icon,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            sensor.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: sensor.isWorking 
                                  ? Colors.green.shade800 
                                  : Colors.red.shade800,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              sensor.isWorking ? 'OK' : 'HATA',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kod: ${sensor.code}',
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          if (sensor.value != null && sensor.isWorking)
                            Text(
                              'Değer: ${sensor.value!.toStringAsFixed(1)} ${sensor.unit}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                        ],
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.white54,
                      ),
                      onTap: () {
                        _showSensorDetails(context, sensor);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showSensorDetails(BuildContext context, SensorInfoState sensor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2F),
        title: Row(
          children: [
            Icon(sensor.icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              sensor.name,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Kod', sensor.code),
            _buildDetailRow('Durum', sensor.isWorking ? 'Çalışıyor' : 'Arızalı'),
            if (sensor.value != null && sensor.isWorking)
              _buildDetailRow('Değer', '${sensor.value!.toStringAsFixed(2)} ${sensor.unit}'),
            const SizedBox(height: 8),
            const Text(
              'Açıklama:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              sensor.description,
              style: const TextStyle(color: Colors.white70),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}