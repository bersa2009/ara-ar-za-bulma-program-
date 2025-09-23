import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/permissions.dart';
import 'settings.dart';

// State providers for the welcome screen
final selectedBrandProvider = StateProvider<String?>((ref) => null);
final selectedModelProvider = StateProvider<String?>((ref) => null);
final selectedYearProvider = StateProvider<int?>((ref) => null);
final scanProgressProvider = StateProvider<double>((ref) => 0.0);
final foundDevicesProvider = StateProvider<List<String>>((ref) => []);
final connectionStatusProvider = StateProvider<ConnectionStatus>((ref) => ConnectionStatus.none);

enum ConnectionStatus { none, scanning, connected, failed }

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  List<Map<String, dynamic>> brandsModels = [];
  bool showConnectionModal = true;
  bool bluetoothEnabled = false;
  bool wifiEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBrandsModels();
    _loadSavedVehicleInfo();
  }

  void _loadSavedVehicleInfo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(appSettingsProvider);
      if (settings.selectedBrand != null) {
        ref.read(selectedBrandProvider.notifier).state = settings.selectedBrand;
      }
      if (settings.selectedModel != null) {
        ref.read(selectedModelProvider.notifier).state = settings.selectedModel;
      }
      if (settings.selectedYear != null) {
        ref.read(selectedYearProvider.notifier).state = settings.selectedYear;
      }
    });
  }

  Future<void> _loadBrandsModels() async {
    try {
      final String response = await rootBundle.loadString('assets/brands_models.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        brandsModels = data.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      debugPrint('Error loading brands and models: $e');
    }
  }

  Future<void> _requestBluetoothPermission() async {
    final granted = await AppPermissions.ensureBleScan();
    setState(() {
      bluetoothEnabled = granted;
      if (bluetoothEnabled && wifiEnabled) {
        showConnectionModal = false;
      }
    });
    
    if (granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bluetooth izinleri verildi'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _requestWifiPermission() {
    // Simulate WiFi permission request
    setState(() {
      wifiEnabled = true;
      if (bluetoothEnabled && wifiEnabled) {
        showConnectionModal = false;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Wi-Fi bağlantısı etkinleştirildi'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _startOBDScan() async {
    if (!bluetoothEnabled || !wifiEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen önce Bluetooth ve Wi-Fi bağlantılarını etkinleştirin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ref.read(connectionStatusProvider.notifier).state = ConnectionStatus.scanning;
    ref.read(scanProgressProvider.notifier).state = 0.0;
    ref.read(foundDevicesProvider.notifier).state = [];

    // Simulate OBD scanning process
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 300));
      ref.read(scanProgressProvider.notifier).state = i / 100.0;
      
      if (i == 30) {
        ref.read(foundDevicesProvider.notifier).state = ['Vgate iCar'];
      } else if (i == 60) {
        ref.read(foundDevicesProvider.notifier).state = ['Vgate iCar', 'ELM327_BT123'];
      }
    }

    // Simulate successful connection
    await Future.delayed(const Duration(milliseconds: 500));
    ref.read(connectionStatusProvider.notifier).state = ConnectionStatus.connected;
  }

  @override
  Widget build(BuildContext context) {
    final selectedBrand = ref.watch(selectedBrandProvider);
    final selectedModel = ref.watch(selectedModelProvider);
    final selectedYear = ref.watch(selectedYearProvider);
    final scanProgress = ref.watch(scanProgressProvider);
    final foundDevices = ref.watch(foundDevicesProvider);
    final connectionStatus = ref.watch(connectionStatusProvider);

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
          child: Column(
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_car,
                          color: Colors.white,
                          size: 30,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Hoş Geldiniz',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.directions_car,
                          color: Colors.white,
                          size: 30,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Strcar',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        color: Colors.white70,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),

              // Content Section
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Connection Modal
                      if (showConnectionModal) _buildConnectionModal(),
                      
                      // Vehicle Selection
                      if (!showConnectionModal) ...[
                        _buildVehicleSelection(selectedBrand, selectedModel, selectedYear),
                        const SizedBox(height: 20),
                        
                        // OBD Scanning Section
                        _buildOBDScanningSection(connectionStatus, scanProgress, foundDevices, selectedBrand, selectedModel, selectedYear),
                        
                        const Spacer(),
                        
                        // Continue Button
                        if (connectionStatus == ConnectionStatus.connected)
                          _buildContinueButton(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionModal() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.wifi,
                color: Colors.blue.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Bluetooth ve Wi-Fi bağlantısı gerekli. Açmak ister misiniz?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: bluetoothEnabled ? null : _requestBluetoothPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bluetoothEnabled ? Colors.green : Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    bluetoothEnabled ? 'Bluetooth ✓' : 'Bluetooth\'u Aç',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: wifiEnabled ? null : _requestWifiPermission,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: wifiEnabled ? Colors.green : Colors.blue,
                    side: BorderSide(
                      color: wifiEnabled ? Colors.green : Colors.blue,
                      width: 2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    wifiEnabled ? 'Wi-Fi ✓' : 'Wi-Fi\'yi Aç',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSelection(String? selectedBrand, String? selectedModel, int? selectedYear) {
    List<String> availableModels = [];
    if (selectedBrand != null) {
      final brandData = brandsModels.firstWhere(
        (brand) => brand['brand'] == selectedBrand,
        orElse: () => {'models': []},
      );
      availableModels = List<String>.from(brandData['models'] ?? []);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Araç Bilgileriniz',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Brand Dropdown
          _buildDropdown<String>(
            label: 'Marka',
            value: selectedBrand,
            items: brandsModels.map((brand) => brand['brand'] as String).toList(),
            onChanged: (value) {
              ref.read(selectedBrandProvider.notifier).state = value;
              ref.read(selectedModelProvider.notifier).state = null; // Reset model selection
              ref.read(selectedYearProvider.notifier).state = null; // Reset year selection
              ref.read(appSettingsProvider).setVehicleInfo(brand: value);
            },
            displayName: (brand) => brand.split('-').map((word) => 
              word[0].toUpperCase() + word.substring(1)
            ).join(' '),
          ),
          
          const SizedBox(height: 12),
          
          // Model Dropdown
          _buildDropdown<String>(
            label: 'Model',
            value: selectedModel,
            items: availableModels,
            onChanged: (value) {
              ref.read(selectedModelProvider.notifier).state = value;
              ref.read(selectedYearProvider.notifier).state = null; // Reset year selection
              ref.read(appSettingsProvider).setVehicleInfo(
                brand: selectedBrand,
                model: value,
              );
            },
            enabled: selectedBrand != null,
          ),
          
          const SizedBox(height: 12),
          
          // Year Dropdown
          _buildDropdown<int>(
            label: 'Yıl',
            value: selectedYear,
            items: List.generate(30, (index) => 2024 - index), // Years from 2024 to 1995
            onChanged: (value) {
              ref.read(selectedYearProvider.notifier).state = value;
              ref.read(appSettingsProvider).setVehicleInfo(
                brand: selectedBrand,
                model: selectedModel,
                year: value,
              );
            },
            enabled: selectedModel != null,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
    String Function(T)? displayName,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: enabled ? Colors.white : Colors.grey.shade100,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              hint: Text(
                'Seçiniz',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              isExpanded: true,
              onChanged: enabled ? onChanged : null,
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    displayName?.call(item) ?? item.toString(),
                    style: TextStyle(
                      color: enabled ? Colors.black87 : Colors.grey.shade500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOBDScanningSection(ConnectionStatus connectionStatus, double scanProgress, 
      List<String> foundDevices, String? selectedBrand, String? selectedModel, int? selectedYear) {
    
    bool canStartScan = selectedBrand != null && selectedModel != null && selectedYear != null;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'OBD Cihazı Tarama',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (canStartScan && connectionStatus == ConnectionStatus.none)
                ElevatedButton(
                  onPressed: _startOBDScan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Taramayı Başlat'),
                ),
            ],
          ),
          
          if (connectionStatus == ConnectionStatus.scanning) ...[
            const SizedBox(height: 16),
            Text(
              'Tarama... ${(scanProgress * 100).round()}%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: scanProgress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
          
          if (foundDevices.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Bulunan Cihazlar:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            ...foundDevices.map((device) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.bluetooth,
                    size: 16,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    device,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
          
          if (connectionStatus == ConnectionStatus.connected) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bağlantı Başarılı - $selectedBrand ${selectedModel ?? ''} $selectedYear',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/home');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: const Text(
          'Devam Et',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}