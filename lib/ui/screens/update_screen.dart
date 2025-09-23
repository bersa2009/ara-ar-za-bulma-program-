import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateScreen extends ConsumerStatefulWidget {
  const UpdateScreen({super.key});

  @override
  ConsumerState<UpdateScreen> createState() => _UpdateScreenState();
}

class UpdateInfo {
  final String component;
  final String currentVersion;
  final String availableVersion;
  final bool hasUpdate;
  final String description;
  final int sizeKB;
  final DateTime releaseDate;
  final IconData icon;

  UpdateInfo({
    required this.component,
    required this.currentVersion,
    required this.availableVersion,
    required this.hasUpdate,
    required this.description,
    required this.sizeKB,
    required this.releaseDate,
    required this.icon,
  });
}

class _UpdateScreenState extends ConsumerState<UpdateScreen> {
  bool isCheckingUpdates = false;
  bool isUpdating = false;
  double updateProgress = 0.0;
  String? currentlyUpdating;
  List<UpdateInfo> updateComponents = [];

  @override
  void initState() {
    super.initState();
    _loadUpdateInfo();
  }

  void _loadUpdateInfo() {
    updateComponents = [
      UpdateInfo(
        component: 'Strcar Uygulaması',
        currentVersion: '1.2.5',
        availableVersion: '1.3.0',
        hasUpdate: true,
        description: 'Yeni AI analiz özellikleri, performans iyileştirmeleri ve hata düzeltmeleri',
        sizeKB: 15420,
        releaseDate: DateTime.now().subtract(const Duration(days: 2)),
        icon: Icons.phone_android,
      ),
      UpdateInfo(
        component: 'DTC Veritabanı',
        currentVersion: '2024.08',
        availableVersion: '2024.09',
        hasUpdate: true,
        description: 'Yeni DTC kodları, güncellenmiş açıklamalar ve üretici özel kodlar',
        sizeKB: 2840,
        releaseDate: DateTime.now().subtract(const Duration(days: 1)),
        icon: Icons.database,
      ),
      UpdateInfo(
        component: 'Bakım Önerileri',
        currentVersion: '3.1.2',
        availableVersion: '3.1.2',
        hasUpdate: false,
        description: 'Marka ve model bazlı bakım tavsiyeleri ve periyodik kontrol listeleri',
        sizeKB: 1250,
        releaseDate: DateTime.now().subtract(const Duration(days: 10)),
        icon: Icons.build_circle,
      ),
      UpdateInfo(
        component: 'Sensör Listeleri',
        currentVersion: '4.0.1',
        availableVersion: '4.0.3',
        hasUpdate: true,
        description: 'Güncel sensör tanımları ve yeni araç modelleri için destek',
        sizeKB: 890,
        releaseDate: DateTime.now().subtract(const Duration(hours: 12)),
        icon: Icons.sensors,
      ),
      UpdateInfo(
        component: 'Dil Paketleri',
        currentVersion: '1.0.0',
        availableVersion: '1.0.0',
        hasUpdate: false,
        description: 'Türkçe ve İngilizce dil desteği',
        sizeKB: 340,
        releaseDate: DateTime.now().subtract(const Duration(days: 30)),
        icon: Icons.language,
      ),
    ];
  }

  Future<void> _checkForUpdates() async {
    setState(() {
      isCheckingUpdates = true;
    });

    // Simulate checking for updates
    await Future.delayed(const Duration(seconds: 2));

    // Randomly update some components
    for (int i = 0; i < updateComponents.length; i++) {
      if (!updateComponents[i].hasUpdate && DateTime.now().millisecond % 3 == 0) {
        updateComponents[i] = UpdateInfo(
          component: updateComponents[i].component,
          currentVersion: updateComponents[i].currentVersion,
          availableVersion: _incrementVersion(updateComponents[i].currentVersion),
          hasUpdate: true,
          description: updateComponents[i].description,
          sizeKB: updateComponents[i].sizeKB,
          releaseDate: DateTime.now(),
          icon: updateComponents[i].icon,
        );
      }
    }

    setState(() {
      isCheckingUpdates = false;
    });

    final availableUpdates = updateComponents.where((c) => c.hasUpdate).length;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            availableUpdates > 0 
                ? '$availableUpdates güncelleme mevcut' 
                : 'Tüm bileşenler güncel',
          ),
          backgroundColor: availableUpdates > 0 ? Colors.orange : Colors.green,
        ),
      );
    }
  }

  String _incrementVersion(String version) {
    final parts = version.split('.');
    if (parts.length >= 3) {
      final patch = int.parse(parts[2]) + 1;
      return '${parts[0]}.${parts[1]}.$patch';
    }
    return version;
  }

  Future<void> _updateComponent(UpdateInfo component) async {
    setState(() {
      isUpdating = true;
      currentlyUpdating = component.component;
      updateProgress = 0.0;
    });

    // Simulate download and installation progress
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() {
          updateProgress = i / 100.0;
        });
      }
    }

    // Update the component
    final index = updateComponents.indexOf(component);
    updateComponents[index] = UpdateInfo(
      component: component.component,
      currentVersion: component.availableVersion,
      availableVersion: component.availableVersion,
      hasUpdate: false,
      description: component.description,
      sizeKB: component.sizeKB,
      releaseDate: component.releaseDate,
      icon: component.icon,
    );

    setState(() {
      isUpdating = false;
      currentlyUpdating = null;
      updateProgress = 0.0;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${component.component} güncellendi'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _updateAll() async {
    final componentsToUpdate = updateComponents.where((c) => c.hasUpdate).toList();
    
    for (final component in componentsToUpdate) {
      await _updateComponent(component);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tüm güncellemeler tamamlandı'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableUpdates = updateComponents.where((c) => c.hasUpdate).length;
    final totalSize = updateComponents.where((c) => c.hasUpdate).fold<int>(
      0, (sum, component) => sum + component.sizeKB);

    return Scaffold(
      backgroundColor: const Color(0xFF2C2C54),
      appBar: AppBar(
        title: const Text('Güncelleme'),
        backgroundColor: const Color(0xFF8B1538),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: isCheckingUpdates
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: isCheckingUpdates || isUpdating ? null : _checkForUpdates,
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
                        const Icon(Icons.update, color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Sistem Güncellemeleri',
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
                      'Uygulama veritabanını ve kod kütüphanesini günceller. Yeni DTC kodları, bakım önerileri ve sensör listeleri indirilir.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildUpdateChip('Mevcut', availableUpdates, 
                            availableUpdates > 0 ? Colors.orange : Colors.green),
                        const SizedBox(width: 8),
                        _buildUpdateChip('Toplam', updateComponents.length, Colors.blue),
                        if (totalSize > 0) ...[
                          const SizedBox(width: 8),
                          _buildUpdateChip('${(totalSize / 1024).toStringAsFixed(1)} MB', 0, Colors.purple),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Update progress
            if (isUpdating) ...[
              Card(
                color: const Color(0xFF1E1E2F),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B1538)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Güncelleniyor: $currentlyUpdating',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: updateProgress,
                        backgroundColor: Colors.grey.shade700,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B1538)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(updateProgress * 100).toInt()}% tamamlandı',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Action buttons
            if (availableUpdates > 0 && !isUpdating)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _checkForUpdates,
                      icon: const Icon(Icons.search),
                      label: const Text('Güncellemeleri Kontrol Et'),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _updateAll,
                      icon: const Icon(Icons.download),
                      label: const Text('Tümünü Güncelle'),
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
                ],
              ),
            
            const SizedBox(height: 16),
            
            // Components list
            const Text(
              'Bileşenler',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Expanded(
              child: ListView.builder(
                itemCount: updateComponents.length,
                itemBuilder: (context, index) {
                  final component = updateComponents[index];
                  return Card(
                    color: const Color(0xFF1E1E2F),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: component.hasUpdate 
                            ? Colors.orange.shade700 
                            : Colors.green.shade700,
                        child: Icon(
                          component.icon,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              component.component,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (component.hasUpdate)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade800,
                                borderRadius: BorderRadius.circular(8),
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
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            component.hasUpdate 
                                ? '${component.currentVersion} → ${component.availableVersion}'
                                : 'Mevcut: ${component.currentVersion}',
                            style: TextStyle(
                              color: component.hasUpdate ? Colors.orange : Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            component.description,
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (component.hasUpdate)
                            Text(
                              '${(component.sizeKB / 1024).toStringAsFixed(1)} MB - ${_formatDate(component.releaseDate)}',
                              style: const TextStyle(color: Colors.white54, fontSize: 10),
                            ),
                        ],
                      ),
                      trailing: component.hasUpdate
                          ? IconButton(
                              icon: const Icon(Icons.download, color: Colors.white),
                              onPressed: isUpdating ? null : () => _updateComponent(component),
                            )
                          : const Icon(Icons.check_circle, color: Colors.green),
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

  Widget _buildUpdateChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count > 0 ? '$label: $count' : label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} dakika önce';
      }
      return '${difference.inHours} saat önce';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}