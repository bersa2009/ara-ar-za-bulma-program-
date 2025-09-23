import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateScreen extends ConsumerStatefulWidget {
  const UpdateScreen({super.key});

  @override
  ConsumerState<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends ConsumerState<UpdateScreen> {
  String _currentVersion = '1.0.0';
  String _latestVersion = '1.2.0';
  bool _isCheckingUpdates = false;
  bool _isUpdatingApp = false;
  bool _isUpdatingDatabase = false;
  bool _isUpdatingFirmware = false;

  final List<Map<String, dynamic>> _updateHistory = [
    {
      'type': 'Uygulama',
      'version': '1.1.0',
      'date': '2024-01-10',
      'description': 'Yeni özellikler eklendi',
    },
    {
      'type': 'Veritabanı',
      'version': '2024.1',
      'date': '2024-01-08',
      'description': 'Yeni DTC kodları eklendi',
    },
    {
      'type': 'Firmware',
      'version': '2.1.0',
      'date': '2024-01-05',
      'description': 'OBD cihazı firmware güncellendi',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentVersion();
  }

  Future<void> _loadCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _currentVersion = packageInfo.version;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _checkForUpdates() async {
    setState(() {
      _isCheckingUpdates = true;
    });

    try {
      // Simulate update check
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, this would check a server for updates
      setState(() {
        _latestVersion = '1.2.0'; // Mock latest version
        _isCheckingUpdates = false;
      });

      if (_currentVersion != _latestVersion) {
        _showUpdateAvailableDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uygulama güncel')),
        );
      }
    } catch (e) {
      setState(() {
        _isCheckingUpdates = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Güncelleme kontrolü hatası: ${e.toString()}')),
      );
    }
  }

  void _showUpdateAvailableDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Güncelleme Mevcut'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mevcut sürüm: $_currentVersion'),
            Text('Yeni sürüm: $_latestVersion'),
            const SizedBox(height: 16),
            const Text('Yeni özellikler:'),
            const SizedBox(height: 8),
            const Text('• Yeni arıza kodları desteği'),
            const Text('• Geliştirilmiş kullanıcı arayüzü'),
            const Text('• Performans iyileştirmeleri'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: _updateApp,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateApp() async {
    setState(() {
      _isUpdatingApp = true;
    });

    try {
      // Simulate app update process
      await Future.delayed(const Duration(seconds: 3));

      setState(() {
        _currentVersion = _latestVersion;
        _isUpdatingApp = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uygulama başarıyla güncellendi')),
      );

      Navigator.pop(context); // Close dialog
    } catch (e) {
      setState(() {
        _isUpdatingApp = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Güncelleme hatası: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateDatabase() async {
    setState(() {
      _isUpdatingDatabase = true;
    });

    try {
      // Simulate database update
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isUpdatingDatabase = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veritabanı güncellendi')),
      );
    } catch (e) {
      setState(() {
        _isUpdatingDatabase = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veritabanı güncelleme hatası: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateFirmware() async {
    setState(() {
      _isUpdatingFirmware = true;
    });

    try {
      // Simulate firmware update
      await Future.delayed(const Duration(seconds: 4));

      setState(() {
        _isUpdatingFirmware = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Firmware güncellendi')),
      );
    } catch (e) {
      setState(() {
        _isUpdatingFirmware = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firmware güncelleme hatası: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUpdate = _currentVersion != _latestVersion;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Güncelleme'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Current Version Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF2D2D3D),
            child: Column(
              children: [
                const Text(
                  'Mevcut Sürüm',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'v$_currentVersion',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (hasUpdate) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'GÜNCELLEME MEVCUT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Update Sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // App Update Section
                _buildUpdateSection(
                  'Uygulama Güncellemesi',
                  'Strcar uygulamasını güncelleyin',
                  Icons.smartphone,
                  hasUpdate,
                  _isUpdatingApp,
                  _isCheckingUpdates,
                  _checkForUpdates,
                  _updateApp,
                ),

                const SizedBox(height: 16),

                // Database Update Section
                _buildUpdateSection(
                  'Veritabanı Güncellemesi',
                  'DTC kodları ve araç veritabanını güncelleyin',
                  Icons.storage,
                  false,
                  _isUpdatingDatabase,
                  false,
                  _updateDatabase,
                  null,
                ),

                const SizedBox(height: 16),

                // Firmware Update Section
                _buildUpdateSection(
                  'Firmware Güncellemesi',
                  'Bağlı OBD cihazının firmware\'ini güncelleyin',
                  Icons.memory,
                  false,
                  _isUpdatingFirmware,
                  false,
                  _updateFirmware,
                  null,
                ),

                const SizedBox(height: 20),

                // Update History
                _buildUpdateHistorySection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateSection(
    String title,
    String subtitle,
    IconData icon,
    bool hasUpdate,
    bool isUpdating,
    bool isChecking,
    VoidCallback onCheck,
    VoidCallback? onUpdate,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D3D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.red, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasUpdate)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'YENİ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isUpdating || isChecking ? null : onCheck,
                  icon: isChecking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.update),
                  label: Text(isChecking ? 'Kontrol Ediliyor...' : 'Kontrol Et'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              if (onUpdate != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isUpdating ? null : onUpdate,
                    icon: isUpdating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download),
                    label: Text(isUpdating ? 'Güncelleniyor...' : 'Güncelle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateHistorySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D3D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Güncelleme Geçmişi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._updateHistory.map((update) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2F),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${update['type']} ${update['version']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        update['description'],
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        update['date'],
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}