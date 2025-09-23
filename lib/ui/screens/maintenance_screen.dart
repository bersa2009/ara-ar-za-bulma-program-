import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/connection_manager.dart';
import '../../elm/elm327_client.dart';

class MaintenanceScreen extends ConsumerStatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  ConsumerState<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends ConsumerState<MaintenanceScreen> {
  int _currentMileage = 0;
  int _lastMaintenanceMileage = 0;
  List<Map<String, dynamic>> _maintenanceHistory = [];
  bool _isConnected = false;
  bool _isLoading = false;

  // Maintenance schedules based on kilometers
  final List<Map<String, dynamic>> _maintenanceSchedules = [
    {
      'name': 'Yağ Değişimi',
      'interval': 10000,
      'description': 'Motor yağı ve filtre değişimi',
      'category': 'Motor',
      'icon': Icons.oil_barrel,
      'isRequired': true,
    },
    {
      'name': 'Hava Filtresi',
      'interval': 20000,
      'description': 'Hava filtresi değişimi',
      'category': 'Filtreler',
      'icon': Icons.air,
      'isRequired': true,
    },
    {
      'name': 'Yakıt Filtresi',
      'interval': 30000,
      'description': 'Yakıt filtresi değişimi',
      'category': 'Filtreler',
      'icon': Icons.local_gas_station,
      'isRequired': true,
    },
    {
      'name': 'Fren Hidroliği',
      'interval': 40000,
      'description': 'Fren hidroliği değişimi',
      'category': 'Fren Sistemi',
      'icon': Icons.linear_scale,
      'isRequired': true,
    },
    {
      'name': 'Soğutma Sıvısı',
      'interval': 50000,
      'description': 'Antifriz değişimi',
      'category': 'Soğutma',
      'icon': Icons.thermostat,
      'isRequired': true,
    },
    {
      'name': 'V Kayışı',
      'interval': 60000,
      'description': 'V kayışı kontrolü/değişimi',
      'category': 'Motor',
      'icon': Icons.settings,
      'isRequired': true,
    },
    {
      'name': 'Buji Değişimi',
      'interval': 80000,
      'description': 'Buji değişimi',
      'category': 'Ateşleme',
      'icon': Icons.electrical_services,
      'isRequired': true,
    },
    {
      'name': 'Triger Kayışı',
      'interval': 100000,
      'description': 'Triger kayışı değişimi',
      'category': 'Motor',
      'icon': Icons.sync,
      'isRequired': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadMaintenanceData();
    _checkConnection();
  }

  void _checkConnection() {
    final elmClient = ref.read(elmClientProvider);
    setState(() {
      _isConnected = elmClient != null;
    });
  }

  Future<void> _loadMaintenanceData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _currentMileage = prefs.getInt('current_mileage') ?? 85000;
        _lastMaintenanceMileage = prefs.getInt('last_maintenance_mileage') ?? 80000;

        // Load maintenance history
        final historyJson = prefs.getStringList('maintenance_history') ?? [];
        _maintenanceHistory = historyJson.map((item) {
          final parts = item.split('|');
          return {
            'date': parts[0],
            'type': parts[1],
            'mileage': int.parse(parts[2]),
            'cost': double.parse(parts[3]),
            'notes': parts[4],
          };
        }).toList();
      });
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveMaintenanceData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt('current_mileage', _currentMileage);
      await prefs.setInt('last_maintenance_mileage', _lastMaintenanceMileage);

      final historyJson = _maintenanceHistory.map((item) =>
        '${item['date']}|${item['type']}|${item['mileage']}|${item['cost']}|${item['notes']}'
      ).toList();

      await prefs.setStringList('maintenance_history', historyJson);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _updateMileageFromVehicle() async {
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OBD cihazına bağlanın')),
      );
      return;
    }

    try {
      final elmClient = ref.read(elmClientProvider);
      if (elmClient == null) return;

      // Read odometer (PID 31)
      final response = await elmClient.sendCommand('31');
      final mileage = _parseOdometer(response);

      setState(() {
        _currentMileage = mileage;
      });

      await _saveMaintenanceData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Km güncellendi: $_currentMileage')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Km okuma hatası: ${e.toString()}')),
      );
    }
  }

  int _parseOdometer(String response) {
    try {
      if (response.contains('41 31')) {
        final dataPart = response.split('41 31')[1];
        if (dataPart.isNotEmpty) {
          final hexValue = dataPart.substring(0, 4);
          return int.parse(hexValue, radix: 16);
        }
      }
    } catch (e) {
      return _currentMileage; // Fallback to current value
    }
    return _currentMileage;
  }

  Future<void> _addMaintenanceRecord(String type, String notes, double cost) async {
    final record = {
      'date': DateTime.now().toIso8601String().split('T')[0],
      'type': type,
      'mileage': _currentMileage,
      'cost': cost,
      'notes': notes,
    };

    setState(() {
      _maintenanceHistory.insert(0, record);
      _lastMaintenanceMileage = _currentMileage;
    });

    await _saveMaintenanceData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bakım kaydı eklendi')),
    );
  }

  void _showAddMaintenanceDialog() {
    String selectedType = '';
    String notes = '';
    double cost = 0.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Bakım Kaydı Ekle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Bakım Türü',
                    border: OutlineInputBorder(),
                  ),
                  items: _maintenanceSchedules.map((schedule) {
                    return DropdownMenuItem(
                      value: schedule['name'],
                      child: Text(schedule['name']),
                    );
                  }).toList(),
                  onChanged: (value) => selectedType = value ?? '',
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Notlar',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (value) => notes = value,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Maliyet (₺)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => cost = double.tryParse(value) ?? 0.0,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedType.isNotEmpty) {
                  _addMaintenanceRecord(selectedType, notes, cost);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getUpcomingMaintenance() {
    final upcoming = <Map<String, dynamic>>[];

    for (final schedule in _maintenanceSchedules) {
      final interval = schedule['interval'];
      final nextDue = _lastMaintenanceMileage + interval;
      final remaining = nextDue - _currentMileage;

      if (remaining <= 2000) { // Show if due within 2000km
        upcoming.add({
          ...schedule,
          'nextDue': nextDue,
          'remaining': remaining,
          'daysUntil': (remaining / 30).round(), // Rough estimate: 30km/day
        });
      }
    }

    return upcoming;
  }

  List<Map<String, dynamic>> _getOverdueMaintenance() {
    final overdue = <Map<String, dynamic>>[];

    for (final schedule in _maintenanceSchedules) {
      final interval = schedule['interval'];
      final nextDue = _lastMaintenanceMileage + interval;
      final remaining = nextDue - _currentMileage;

      if (remaining < 0) { // Overdue
        overdue.add({
          ...schedule,
          'nextDue': nextDue,
          'overdueBy': -remaining,
        });
      }
    }

    return overdue;
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = _getUpcomingMaintenance();
    final overdue = _getOverdueMaintenance();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Km Bakım'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isConnected ? _updateMileageFromVehicle : null,
            icon: const Icon(Icons.sync),
            tooltip: 'Km Güncelle',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Current Mileage Display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: const Color(0xFF2D2D3D),
                  child: Column(
                    children: [
                      const Text(
                        'Mevcut Kilometre',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_currentMileage.toString()} km',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Son bakım: ${_lastMaintenanceMileage.toString()} km',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Maintenance Status Tabs
                Expanded(
                  child: DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        TabBar(
                          labelColor: Colors.red,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.red,
                          tabs: const [
                            Tab(text: 'Yaklaşan'),
                            Tab(text: 'Vadesi Geçmiş'),
                            Tab(text: 'Geçmiş'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildUpcomingMaintenanceTab(upcoming),
                              _buildOverdueMaintenanceTab(overdue),
                              _buildMaintenanceHistoryTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMaintenanceDialog,
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUpcomingMaintenanceTab(List<Map<String, dynamic>> upcoming) {
    if (upcoming.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Yaklaşan Bakım Yok',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Tüm bakımlar güncel',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upcoming.length,
      itemBuilder: (context, index) {
        final item = upcoming[index];
        return _buildMaintenanceCard(item, isUpcoming: true);
      },
    );
  }

  Widget _buildOverdueMaintenanceTab(List<Map<String, dynamic>> overdue) {
    if (overdue.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.thumb_up, size: 80, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Vadesi Geçmiş Bakım Yok',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: overdue.length,
      itemBuilder: (context, index) {
        final item = overdue[index];
        return _buildMaintenanceCard(item, isOverdue: true);
      },
    );
  }

  Widget _buildMaintenanceHistoryTab() {
    if (_maintenanceHistory.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Bakım Geçmişi Yok',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _maintenanceHistory.length,
      itemBuilder: (context, index) {
        final record = _maintenanceHistory[index];
        return Card(
          color: const Color(0xFF2D2D3D),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.build, color: Colors.red),
            title: Text(
              record['type'],
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              '${record['date']} - ${record['mileage']} km',
              style: TextStyle(color: Colors.grey[400]),
            ),
            trailing: Text(
              '${record['cost'].toStringAsFixed(0)} ₺',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMaintenanceCard(Map<String, dynamic> item, {bool isUpcoming = false, bool isOverdue = false}) {
    Color cardColor = const Color(0xFF2D2D3D);
    Color iconColor = Colors.red;
    String statusText = '';
    IconData statusIcon = Icons.schedule;

    if (isOverdue) {
      cardColor = const Color(0xFF3D2D2D);
      iconColor = Colors.red;
      statusText = '${item['overdueBy']} km fazla';
      statusIcon = Icons.warning;
    } else if (isUpcoming) {
      final remaining = item['remaining'];
      if (remaining <= 1000) {
        iconColor = Colors.orange;
        statusText = '$remaining km kaldı';
        statusIcon = Icons.warning_amber;
      } else {
        iconColor = Colors.green;
        statusText = '$remaining km kaldı';
        statusIcon = Icons.schedule;
      }
    }

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(item['icon'], color: iconColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item['description'],
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
                    Row(
                      children: [
                        Icon(statusIcon, color: iconColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: iconColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item['interval']} km',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (isUpcoming) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: (_currentMileage - _lastMaintenanceMileage) / item['interval'],
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(iconColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}