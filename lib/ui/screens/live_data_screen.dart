import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/connection_manager.dart';
import '../../elm/elm327_client.dart';

class LiveDataScreen extends ConsumerStatefulWidget {
  const LiveDataScreen({super.key});

  @override
  ConsumerState<LiveDataScreen> createState() => _LiveDataScreenState();
}

class _LiveDataScreenState extends ConsumerState<LiveDataScreen> {
  Timer? _timer;
  Map<String, String> _sensorData = {};
  bool _isConnected = false;

  // Sensor configurations
  final List<Map<String, dynamic>> _sensors = [
    {'key': 'rpm', 'name': 'Motor Devri', 'unit': 'RPM', 'icon': Icons.tune, 'command': '0C'},
    {'key': 'speed', 'name': 'Hız', 'unit': 'km/h', 'icon': Icons.speed, 'command': '0D'},
    {'key': 'coolant_temp', 'name': 'Motor Sıcaklığı', 'unit': '°C', 'icon': Icons.thermostat, 'command': '05'},
    {'key': 'intake_temp', 'name': 'Emme Sıcaklığı', 'unit': '°C', 'icon': Icons.ac_unit, 'command': '0F'},
    {'key': 'fuel_pressure', 'name': 'Yakıt Basıncı', 'unit': 'kPa', 'icon': Icons.local_gas_station, 'command': '0A'},
    {'key': 'o2_sensor', 'name': 'O2 Sensörü', 'unit': 'V', 'icon': Icons.bubble_chart, 'command': '14'},
    {'key': 'throttle_pos', 'name': 'Gaz Kelebeği', 'unit': '%', 'icon': Icons.power_settings_new, 'command': '11'},
    {'key': 'timing_advance', 'name': 'Avans', 'unit': '°', 'icon': Icons.access_time, 'command': '0E'},
  ];

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _startDataCollection();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkConnection() {
    final elmClient = ref.read(elmClientProvider);
    setState(() {
      _isConnected = elmClient != null;
    });
  }

  void _startDataCollection() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isConnected) {
        _collectSensorData();
      }
    });
  }

  Future<void> _collectSensorData() async {
    try {
      final elmClient = ref.read(elmClientProvider);
      if (elmClient == null) return;

      final newData = Map<String, String>.from(_sensorData);

      for (final sensor in _sensors) {
        try {
          final response = await elmClient.sendCommand(sensor['command']);
          final value = _parseSensorValue(sensor['command'], response);
          if (value.isNotEmpty) {
            newData[sensor['key']] = value;
          }
        } catch (e) {
          // Continue with other sensors if one fails
          continue;
        }
      }

      setState(() {
        _sensorData = newData;
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
      });
    }
  }

  String _parseSensorValue(String command, String response) {
    // Simplified parsing - actual implementation would be more robust
    try {
      if (response.contains('41 $command')) {
        // Extract the data portion after the command response
        final dataPart = response.split('41 $command')[1];
        if (dataPart.isNotEmpty) {
          final hexValue = dataPart.substring(0, 2);
          final intValue = int.parse(hexValue, radix: 16);

          // Convert based on sensor type
          switch (command) {
            case '0C': // RPM
              return ((intValue * 256) / 4).toStringAsFixed(0);
            case '0D': // Speed
              return intValue.toString();
            case '05': // Coolant temperature
              return (intValue - 40).toString();
            case '0F': // Intake air temperature
              return (intValue - 40).toString();
            case '0A': // Fuel pressure
              return (intValue * 3).toString();
            case '14': // O2 sensor voltage
              return (intValue / 200).toStringAsFixed(2);
            case '11': // Throttle position
              return (intValue * 100 / 255).toStringAsFixed(1);
            case '0E': // Timing advance
              return ((intValue - 128) / 2).toStringAsFixed(1);
            default:
              return intValue.toString();
          }
        }
      }
    } catch (e) {
      return '';
    }
    return '';
  }

  Widget _buildSensorCard(Map<String, dynamic> sensor, String? value) {
    return Card(
      color: const Color(0xFF2D2D3D),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              sensor['icon'] as IconData,
              size: 32,
              color: Colors.red,
            ),
            const SizedBox(height: 8),
            Text(
              sensor['name'] as String,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value ?? '--',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              sensor['unit'] as String,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canlı Veri'),
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
                  Icons.wifi,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  _isConnected ? 'Veri Alınıyor...' : 'Bağlı Değil',
                  style: TextStyle(
                    color: _isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_isConnected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'CANLI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Sensor Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: _sensors.length,
              itemBuilder: (context, index) {
                final sensor = _sensors[index];
                final value = _sensorData[sensor['key']];
                return _buildSensorCard(sensor, value);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isConnected ? _collectSensorData : null,
        backgroundColor: Colors.red,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}