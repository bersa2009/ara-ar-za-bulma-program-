import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/connection_manager.dart';
import '../../elm/elm327_client.dart';

class SensorInfoScreen extends ConsumerStatefulWidget {
  const SensorInfoScreen({super.key});

  @override
  ConsumerState<SensorInfoScreen> createState() => _SensorInfoScreenState();
}

class _SensorInfoScreenState extends ConsumerState<SensorInfoScreen> {
  Timer? _timer;
  Map<String, Map<String, dynamic>> _sensorStatus = {};
  bool _isConnected = false;

  // Sensor configurations with their test commands and status indicators
  final List<Map<String, dynamic>> _sensors = [
    {
      'key': 'o2_sensor',
      'name': 'O2 Sensörü (Lambda)',
      'description': 'Egzoz gazı oksijen seviyesi',
      'icon': Icons.bubble_chart,
      'command': '14',
      'unit': 'V',
      'good_range': {'min': 0.1, 'max': 0.9}
    },
    {
      'key': 'map_sensor',
      'name': 'MAP Sensörü',
      'description': 'Emme manifold basıncı',
      'icon': Icons.compress,
      'command': '0B',
      'unit': 'kPa',
      'good_range': {'min': 20, 'max': 100}
    },
    {
      'key': 'maf_sensor',
      'name': 'MAF Sensörü',
      'description': 'Emilen hava miktarı',
      'icon': Icons.air,
      'command': '10',
      'unit': 'kg/h',
      'good_range': {'min': 0, 'max': 50}
    },
    {
      'key': 'abs_sensor',
      'name': 'ABS Sensörü',
      'description': 'Fren sistemi sensörü',
      'icon': Icons.linear_scale,
      'command': '1C',
      'unit': 'Hz',
      'good_range': {'min': 0, 'max': 1000}
    },
    {
      'key': 'tps_sensor',
      'name': 'TPS Sensörü',
      'description': 'Gaz kelebeği pozisyonu',
      'icon': Icons.power_settings_new,
      'command': '11',
      'unit': '%',
      'good_range': {'min': 0, 'max': 100}
    },
    {
      'key': 'ect_sensor',
      'name': 'ECT Sensörü',
      'description': 'Motor soğutma suyu sıcaklığı',
      'icon': Icons.thermostat,
      'command': '05',
      'unit': '°C',
      'good_range': {'min': 70, 'max': 110}
    },
    {
      'key': 'iat_sensor',
      'name': 'IAT Sensörü',
      'description': 'Emme havası sıcaklığı',
      'icon': Icons.ac_unit,
      'command': '0F',
      'unit': '°C',
      'good_range': {'min': -10, 'max': 50}
    },
    {
      'key': 'vss_sensor',
      'name': 'VSS Sensörü',
      'description': 'Araç hız sensörü',
      'icon': Icons.speed,
      'command': '0D',
      'unit': 'km/h',
      'good_range': {'min': 0, 'max': 200}
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _startSensorMonitoring();
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

  void _startSensorMonitoring() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_isConnected) {
        _checkSensorStatuses();
      }
    });
  }

  Future<void> _checkSensorStatuses() async {
    try {
      final elmClient = ref.read(elmClientProvider);
      if (elmClient == null) return;

      final newStatus = Map<String, Map<String, dynamic>>.from(_sensorStatus);

      for (final sensor in _sensors) {
        try {
          final response = await elmClient.sendCommand(sensor['command']);
          final value = _parseSensorValue(sensor['command'], response);

          if (value.isNotEmpty) {
            final double numericValue = double.tryParse(value) ?? 0.0;
            final goodRange = sensor['good_range'] as Map<String, dynamic>;
            final min = goodRange['min'] as double;
            final max = goodRange['max'] as double;

            bool isWorking = numericValue >= min && numericValue <= max;

            newStatus[sensor['key']] = {
              'value': value,
              'isWorking': isWorking,
              'lastChecked': DateTime.now(),
            };
          }
        } catch (e) {
          // Mark sensor as unknown if we can't read it
          newStatus[sensor['key']] = {
            'value': '--',
            'isWorking': null,
            'lastChecked': DateTime.now(),
          };
        }
      }

      setState(() {
        _sensorStatus = newStatus;
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
      });
    }
  }

  String _parseSensorValue(String command, String response) {
    try {
      if (response.contains('41 $command')) {
        final dataPart = response.split('41 $command')[1];
        if (dataPart.isNotEmpty) {
          final hexValue = dataPart.substring(0, 2);
          final intValue = int.parse(hexValue, radix: 16);

          switch (command) {
            case '14': // O2 sensor voltage
              return (intValue / 200).toStringAsFixed(2);
            case '0B': // MAP sensor
              return intValue.toString();
            case '10': // MAF sensor
              return (intValue / 10).toStringAsFixed(1);
            case '1C': // ABS sensor (simplified)
              return intValue.toString();
            case '11': // TPS sensor
              return (intValue * 100 / 255).toStringAsFixed(1);
            case '05': // ECT sensor
              return (intValue - 40).toString();
            case '0F': // IAT sensor
              return (intValue - 40).toString();
            case '0D': // VSS sensor
              return intValue.toString();
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

  Widget _buildSensorCard(Map<String, dynamic> sensor) {
    final sensorData = _sensorStatus[sensor['key']];
    final value = sensorData?['value'] ?? '--';
    final isWorking = sensorData?['isWorking'];
    final lastChecked = sensorData?['lastChecked'] as DateTime?;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isWorking == null) {
      statusColor = Colors.grey;
      statusText = 'Bilinmiyor';
      statusIcon = Icons.help_outline;
    } else if (isWorking) {
      statusColor = Colors.green;
      statusText = 'Çalışıyor';
      statusIcon = Icons.check_circle;
    } else {
      statusColor = Colors.red;
      statusText = 'Arızalı';
      statusIcon = Icons.error;
    }

    return Card(
      color: const Color(0xFF2D2D3D),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  sensor['icon'] as IconData,
                  size: 32,
                  color: statusColor,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sensor['name'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        sensor['description'] as String,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(statusIcon, color: statusColor),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Değer: $value ${sensor['unit']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                if (lastChecked != null)
                  Text(
                    'Son kontrol: ${_formatTime(lastChecked)}',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s önce';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}d önce';
    } else {
      return '${difference.inHours}sa önce';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensör Bilgisi'),
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
                  Icons.sensors,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  _isConnected ? 'Sensörler İzleniyor...' : 'Bağlı Değil',
                  style: TextStyle(
                    color: _isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Legend
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1E1E2F),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(Colors.green, 'Çalışıyor'),
                _buildLegendItem(Colors.red, 'Arızalı'),
                _buildLegendItem(Colors.grey, 'Bilinmiyor'),
              ],
            ),
          ),

          // Sensors List
          Expanded(
            child: ListView.builder(
              itemCount: _sensors.length,
              itemBuilder: (context, index) {
                final sensor = _sensors[index];
                return _buildSensorCard(sensor);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isConnected ? _checkSensorStatuses : null,
        backgroundColor: Colors.red,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 12),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}