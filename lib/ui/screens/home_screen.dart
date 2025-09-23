import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/connection_manager.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<Map<String, dynamic>> menuItems = const [
    {'icon': Icons.search, 'text': 'Arıza\nTespiti', 'route': '/scan'},
    {'icon': Icons.wifi, 'text': 'Canlı\nVeri', 'route': '/realtime'},
    {'icon': Icons.sensors, 'text': 'Sensör\nBilgisi', 'route': '/sensors'},
    {'icon': Icons.psychology, 'text': 'Yapay\nZeka', 'route': '/ai'},
    {'icon': Icons.battery_charging_full, 'text': 'Batarya\nTesti', 'route': '/battery'},
    {'icon': Icons.speed, 'text': 'Km\nBakım', 'route': '/maintenance'},
    {'icon': Icons.badge, 'text': 'Araç\nKimlik No', 'route': '/vin'},
    {'icon': Icons.file_download, 'text': 'Hataları\nKaydet', 'route': '/reports'},
    {'icon': Icons.system_update, 'text': 'Güncelleme', 'route': '/update'},
  ];

  int _bottomIndex = 0;

  @override
  Widget build(BuildContext context) {
    final conn = ref.watch(connectionStateProvider);
    final connected = conn.connectedDevice != null;
    return Scaffold(
      backgroundColor: const Color(0xFF13161A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7A1010),
        title: const Text('Strcar'),
        centerTitle: true,
        leading: const Icon(Icons.directions_car_filled),
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: Icon(Icons.directions_car_filled))],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomIndex,
        onTap: (i) {
          setState(() => _bottomIndex = i);
          switch (i) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, '/performance');
              break;
            case 2:
              Navigator.pushNamed(context, '/reports');
              break;
            case 3:
              Navigator.pushNamed(context, '/settings');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Menü'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Performans'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Raporlar'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ayarlar'),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF1B1E22),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.directions_car, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Renault Clio 2018 — ${connected ? 'Bağlı' : 'Bağlı değil'}',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return Card(
                  color: const Color(0xFF7A1010),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, item['route'] as String),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item['icon'] as IconData, color: Colors.white, size: 42),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            item['text'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, height: 1.1),
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

