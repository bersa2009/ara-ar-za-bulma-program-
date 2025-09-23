import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MaintenanceScreen extends ConsumerStatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  ConsumerState<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class MaintenanceItem {
  final String name;
  final int intervalKm;
  final int lastServiceKm;
  final DateTime? lastServiceDate;
  final String description;
  final String urgency;
  final IconData icon;
  final bool isOverdue;

  MaintenanceItem({
    required this.name,
    required this.intervalKm,
    required this.lastServiceKm,
    this.lastServiceDate,
    required this.description,
    required this.urgency,
    required this.icon,
    required this.isOverdue,
  });

  int get nextServiceKm => lastServiceKm + intervalKm;
  int remainingKm(int currentKm) => nextServiceKm - currentKm;
}

class _MaintenanceScreenState extends ConsumerState<MaintenanceScreen> {
  int currentKm = 85420; // Current vehicle mileage
  List<MaintenanceItem> maintenanceItems = [];

  @override
  void initState() {
    super.initState();
    _loadMaintenanceData();
  }

  void _loadMaintenanceData() {
    maintenanceItems = [
      MaintenanceItem(
        name: 'Motor Yağı Değişimi',
        intervalKm: 10000,
        lastServiceKm: 80000,
        lastServiceDate: DateTime(2024, 8, 15),
        description: 'Motor yağı ve yağ filtresi değişimi',
        urgency: 'Yaklaşıyor',
        icon: Icons.oil_barrel,
        isOverdue: false,
      ),
      MaintenanceItem(
        name: 'Hava Filtresi',
        intervalKm: 20000,
        lastServiceKm: 70000,
        lastServiceDate: DateTime(2024, 5, 20),
        description: 'Motor hava filtresi değişimi',
        urgency: 'Geçmiş',
        icon: Icons.air,
        isOverdue: true,
      ),
      MaintenanceItem(
        name: 'Fren Balata',
        intervalKm: 30000,
        lastServiceKm: 60000,
        lastServiceDate: DateTime(2024, 2, 10),
        description: 'Ön fren balata kontrolü ve değişimi',
        urgency: 'Normal',
        icon: Icons.car_crash,
        isOverdue: false,
      ),
      MaintenanceItem(
        name: 'Yakıt Filtresi',
        intervalKm: 40000,
        lastServiceKm: 60000,
        lastServiceDate: DateTime(2023, 12, 5),
        description: 'Yakıt filtresi değişimi',
        urgency: 'Geçmiş',
        icon: Icons.local_gas_station,
        isOverdue: true,
      ),
      MaintenanceItem(
        name: 'Triger Kayışı',
        intervalKm: 80000,
        lastServiceKm: 40000,
        lastServiceDate: DateTime(2023, 3, 15),
        description: 'Triger kayışı ve gergi rulmanı değişimi',
        urgency: 'Yaklaşıyor',
        icon: Icons.settings,
        isOverdue: false,
      ),
      MaintenanceItem(
        name: 'Buji Değişimi',
        intervalKm: 30000,
        lastServiceKm: 75000,
        lastServiceDate: DateTime(2024, 6, 8),
        description: 'Ateşleme bujileri değişimi',
        urgency: 'Normal',
        icon: Icons.electrical_services,
        isOverdue: false,
      ),
      MaintenanceItem(
        name: 'Klima Filtresi',
        intervalKm: 15000,
        lastServiceKm: 75000,
        lastServiceDate: DateTime(2024, 7, 12),
        description: 'Kabin hava filtresi değişimi',
        urgency: 'Normal',
        icon: Icons.ac_unit,
        isOverdue: false,
      ),
      MaintenanceItem(
        name: 'Amortisör Kontrolü',
        intervalKm: 50000,
        lastServiceKm: 50000,
        lastServiceDate: DateTime(2023, 8, 22),
        description: 'Ön ve arka amortisör kontrolü',
        urgency: 'Yaklaşıyor',
        icon: Icons.height,
        isOverdue: false,
      ),
    ];

    // Sort by urgency and remaining km
    maintenanceItems.sort((a, b) {
      if (a.isOverdue && !b.isOverdue) return -1;
      if (!a.isOverdue && b.isOverdue) return 1;
      return a.remainingKm(currentKm).compareTo(b.remainingKm(currentKm));
    });
  }

  void _updateMileage() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: currentKm.toString());
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2F),
          title: const Text(
            'Kilometre Güncelle',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Mevcut kilometre değerini girin:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Kilometre',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF8B1538)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                final newKm = int.tryParse(controller.text);
                if (newKm != null && newKm > 0) {
                  setState(() {
                    currentKm = newKm;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kilometre güncellendi'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B1538),
              ),
              child: const Text('Güncelle', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final overdueItems = maintenanceItems.where((item) => item.isOverdue).length;
    final upcomingItems = maintenanceItems.where((item) => 
        !item.isOverdue && item.remainingKm(currentKm) <= 5000).length;

    return Scaffold(
      backgroundColor: const Color(0xFF2C2C54),
      appBar: AppBar(
        title: const Text('Km Bakım'),
        backgroundColor: const Color(0xFF8B1538),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _updateMileage,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card with current mileage
            Card(
              color: const Color(0xFF8B1538),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.build, color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Bakım Takvimi',
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
                      'Kilometreye göre bakım takvimi ve yaklaşan bakım bildirimleri.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.speed, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Mevcut: ${currentKm.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} km',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Status summary
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    'Geçmiş',
                    overdueItems,
                    Colors.red,
                    Icons.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusCard(
                    'Yaklaşan',
                    upcomingItems,
                    Colors.orange,
                    Icons.schedule,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusCard(
                    'Toplam',
                    maintenanceItems.length,
                    Colors.blue,
                    Icons.build_circle,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Maintenance items list
            const Text(
              'Bakım Listesi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Expanded(
              child: ListView.builder(
                itemCount: maintenanceItems.length,
                itemBuilder: (context, index) {
                  final item = maintenanceItems[index];
                  final remainingKm = item.remainingKm(currentKm);
                  
                  return Card(
                    color: const Color(0xFF1E1E2F),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getUrgencyColor(item.urgency),
                        child: Icon(
                          item.icon,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getUrgencyColor(item.urgency),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.urgency.toUpperCase(),
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
                            item.description,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (remainingKm > 0) ...[
                                Text(
                                  '${remainingKm.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} km kaldı',
                                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                                ),
                              ] else ...[
                                Text(
                                  '${(-remainingKm).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} km geçmiş',
                                  style: const TextStyle(color: Colors.red, fontSize: 11),
                                ),
                              ],
                              const SizedBox(width: 8),
                              Text(
                                'Her ${item.intervalKm.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} km',
                                style: const TextStyle(color: Colors.white38, fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.white54,
                      ),
                      onTap: () => _showMaintenanceDetails(context, item),
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

  Widget _buildStatusCard(String label, int count, Color color, IconData icon) {
    return Card(
      color: const Color(0xFF1E1E2F),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'Geçmiş':
        return Colors.red.shade700;
      case 'Yaklaşıyor':
        return Colors.orange.shade700;
      case 'Normal':
        return Colors.green.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  void _showMaintenanceDetails(BuildContext context, MaintenanceItem item) {
    final remainingKm = item.remainingKm(currentKm);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2F),
        title: Row(
          children: [
            Icon(item.icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Açıklama', item.description),
            _buildDetailRow('Periyot', '${item.intervalKm} km'),
            _buildDetailRow('Son Bakım', '${item.lastServiceKm} km'),
            if (item.lastServiceDate != null)
              _buildDetailRow('Son Tarih', 
                '${item.lastServiceDate!.day}/${item.lastServiceDate!.month}/${item.lastServiceDate!.year}'),
            _buildDetailRow('Sonraki Bakım', '${item.nextServiceKm} km'),
            _buildDetailRow('Durum', 
              remainingKm > 0 
                  ? '$remainingKm km kaldı' 
                  : '${-remainingKm} km geçmiş'),
            const SizedBox(height: 12),
            if (item.isOverdue)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bu bakım süresi geçmiş!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (remainingKm <= 2000)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Yakında bakım zamanı!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
          if (item.isOverdue || remainingKm <= 1000)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _markAsCompleted(item);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Yapıldı İşaretle', style: TextStyle(color: Colors.white)),
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
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _markAsCompleted(MaintenanceItem item) {
    setState(() {
      final index = maintenanceItems.indexOf(item);
      maintenanceItems[index] = MaintenanceItem(
        name: item.name,
        intervalKm: item.intervalKm,
        lastServiceKm: currentKm,
        lastServiceDate: DateTime.now(),
        description: item.description,
        urgency: 'Normal',
        icon: item.icon,
        isOverdue: false,
      );
      _loadMaintenanceData(); // Re-sort the list
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} tamamlandı olarak işaretlendi'),
        backgroundColor: Colors.green,
      ),
    );
  }
}