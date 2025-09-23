import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/connection_manager.dart';
import '../../core/permissions.dart';

class EntryScreen extends ConsumerStatefulWidget {
  const EntryScreen({super.key});

  @override
  ConsumerState<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends ConsumerState<EntryScreen> {
  bool _showConnectionDialog = true;
  bool _showVehicleSelection = false;
  bool _showScanning = false;
  String? _selectedBrand;
  String? _selectedModel;
  String? _selectedYear;
  int _scanningProgress = 0;
  String? _connectionStatus;
  List<DiscoveredDeviceInfo> _discoveredDevices = [];

  // Vehicle data
  List<String> _brands = [];
  List<String> _models = [];
  List<String> _years = [];

  @override
  void initState() {
    super.initState();
    _loadVehicleData();
    _checkPermissions();
  }

  Future<void> _loadVehicleData() async {
    try {
      final brandsData = await DefaultAssetBundle.of(context)
          .loadString('assets/brands_models.json');
      final List<dynamic> brandsList = json.decode(brandsData);

      setState(() {
        _brands = brandsList.map((item) => item['brand'] as String).toList();
        _years = List.generate(25, (index) => (2024 - index).toString());
      });
    } catch (e) {
      print('Error loading vehicle data: $e');
    }
  }

  Future<void> _checkPermissions() async {
    final hasPermissions = await AppPermissions.ensureBleScan();
    if (hasPermissions) {
      setState(() {
        _showConnectionDialog = false;
        _showVehicleSelection = true;
      });
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.wifi, color: Colors.blue),
              SizedBox(width: 10),
              Text('Bağlantı Gerekli'),
            ],
          ),
          content: const Text(
            'Bluetooth ve Wi-Fi bağlantısı gerekli. Açmak ister misiniz?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Permission.bluetooth.request();
                await Permission.bluetoothScan.request();
                await Permission.bluetoothConnect.request();
                await Permission.locationWhenInUse.request();
                setState(() {
                  _showConnectionDialog = false;
                  _showVehicleSelection = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text("Bluetooth'u Aç"),
            ),
            OutlinedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Permission.locationWhenInUse.request();
                setState(() {
                  _showConnectionDialog = false;
                  _showVehicleSelection = true;
                });
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue),
                foregroundColor: Colors.blue,
              ),
              child: const Text("Wi-Fi'yi Aç"),
            ),
          ],
        );
      },
    );
  }

  void _onBrandSelected(String? brand) {
    setState(() {
      _selectedBrand = brand;
      _selectedModel = null;
      _models = [];

      if (brand != null) {
        // Load models for selected brand
        // For now, using a simple mapping, in real app you'd load from the JSON
        final brandModelMap = {
          'renault': ['Clio', 'Megane', 'Captur', 'Kadjar', 'Talisman'],
          'fiat': ['Egea', '500', 'Panda', 'Tipo', 'Doblò'],
          'volkswagen': ['Golf', 'Passat', 'Tiguan', 'Polo', 'Jetta'],
        };

        _models = brandModelMap[brand] ?? [];
      }
    });
  }

  Future<void> _startScanning() async {
    if (_selectedBrand == null || _selectedModel == null || _selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen araç bilgilerini seçin')),
      );
      return;
    }

    setState(() {
      _showVehicleSelection = false;
      _showScanning = true;
      _scanningProgress = 0;
      _connectionStatus = null;
      _discoveredDevices = [];
    });

    final connectionManager = ref.read(connectionManagerProvider);

    // Start BLE scanning
    try {
      await connectionManager.scanBle();

      // Listen for discovered devices
      ref.listen(discoveredDevicesProvider, (previous, next) {
        setState(() {
          _discoveredDevices = next;
          _scanningProgress = next.isEmpty ? 30 : 60;
        });
      });

      // Listen for connection state
      ref.listen(connectionStateProvider, (previous, next) {
        setState(() {
          if (next.connectedDevice != null) {
            _scanningProgress = 100;
            _connectionStatus = 'Bağlantı Başarılı - $_selectedBrand $_selectedModel $_selectedYear';
          } else if (next.error != null) {
            _connectionStatus = 'Bağlantı Hatası: ${next.error}';
          }
        });
      });

      // Simulate progress
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) {
          setState(() {
            _scanningProgress = i;
          });
        }
      }

    } catch (e) {
      setState(() {
        _connectionStatus = 'Tarama hatası: $e';
      });
    }
  }

  void _continueToMainMenu() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D47A1), // Dark blue
              Color(0xFF1976D2), // Light blue
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Header Section
                const Text(
                  '🚗 Hoş Geldiniz 🚗',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Strcar',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 40),

                // Connection Dialog
                if (_showConnectionDialog) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.wifi, size: 30, color: Colors.blue),
                            SizedBox(width: 10),
                            Text(
                              'Bağlantı Gerekli',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Bluetooth ve Wi-Fi bağlantısı gerekli. Açmak ister misiniz?',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await Permission.bluetooth.request();
                                  await Permission.bluetoothScan.request();
                                  await Permission.bluetoothConnect.request();
                                  await Permission.locationWhenInUse.request();
                                  setState(() {
                                    _showConnectionDialog = false;
                                    _showVehicleSelection = true;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text("Bluetooth'u Aç"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  await Permission.locationWhenInUse.request();
                                  setState(() {
                                    _showConnectionDialog = false;
                                    _showVehicleSelection = true;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.blue),
                                  foregroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text("Wi-Fi'yi Aç"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else if (_showVehicleSelection) ...[
                  // Vehicle Selection Section
                  Expanded(
                    child: Column(
                      children: [
                        // Brand Selection
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Marka',
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.branding_watermark),
                            ),
                            value: _selectedBrand,
                            items: _brands.map((brand) {
                              return DropdownMenuItem(
                                value: brand,
                                child: Text(_formatBrandName(brand)),
                              );
                            }).toList(),
                            onChanged: _onBrandSelected,
                            dropdownColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Model Selection
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Model',
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.directions_car),
                            ),
                            value: _selectedModel,
                            items: _models.map((model) {
                              return DropdownMenuItem(
                                value: model,
                                child: Text(model),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedModel = value),
                            dropdownColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Year Selection
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Yıl',
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            value: _selectedYear,
                            items: _years.map((year) {
                              return DropdownMenuItem(
                                value: year,
                                child: Text(year),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedYear = value),
                            dropdownColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Start Scanning Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _startScanning,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              'Taramayı Başlat',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (_showScanning) ...[
                  // Scanning Section
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search,
                          size: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Tarama... $_scanningProgress%',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        LinearProgressIndicator(
                          value: _scanningProgress / 100,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        const SizedBox(height: 20),
                        if (_discoveredDevices.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Bulunan Cihazlar:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ..._discoveredDevices.take(3).map((device) => ListTile(
                                  title: Text(device.name),
                                  subtitle: Text('${device.type} - ${device.id}'),
                                  leading: const Icon(Icons.bluetooth),
                                )),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),
                        if (_connectionStatus != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _connectionStatus!.contains('Başarılı')
                                  ? Colors.green.withOpacity(0.9)
                                  : Colors.red.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _connectionStatus!.contains('Başarılı')
                                      ? Icons.check_circle
                                      : Icons.error,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _connectionStatus!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],

                // Continue Button (shown when scanning is complete)
                if (_connectionStatus?.contains('Başarılı') == true)
                  Container(
                    width: double.infinity,
                    height: 50,
                    margin: const EdgeInsets.only(top: 20),
                    child: ElevatedButton(
                      onPressed: _continueToMainMenu,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Devam Et',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatBrandName(String brand) {
    // Convert brand names to proper case
    switch (brand) {
      case 'alfa-romeo':
        return 'Alfa Romeo';
      case 'aston-martin':
        return 'Aston Martin';
      case 'land-rover':
        return 'Land Rover';
      case 'mercedes-benz':
        return 'Mercedes-Benz';
      case 'rolls-royce':
        return 'Rolls-Royce';
      case 'ds-automobiles':
        return 'DS Automobiles';
      default:
        return brand[0].toUpperCase() + brand.substring(1);
    }
  }
}