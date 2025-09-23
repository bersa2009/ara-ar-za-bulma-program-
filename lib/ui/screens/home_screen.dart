import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> menuItems = const [
    {'icon': Icons.search, 'text': 'Arıza\nTespit', 'route': '/fault_detection'},
    {'icon': Icons.wifi, 'text': 'Canlı\nVeri', 'route': '/live_data'},
    {'icon': Icons.bar_chart, 'text': 'Sensör\nBilgisi', 'route': '/sensor_info'},
    {'icon': Icons.psychology, 'text': 'Yapay\nZeka', 'route': '/ai_analysis'},
    {'icon': Icons.battery_charging_full, 'text': 'Batarya\nTesti', 'route': '/battery_test'},
    {'icon': Icons.build, 'text': 'Km\nBakım', 'route': '/maintenance'},
    {'icon': Icons.credit_card, 'text': 'Araç\nKimlik No', 'route': '/vin'},
    {'icon': Icons.save, 'text': 'Hataları\nKaydet', 'route': '/save_reports'},
    {'icon': Icons.update, 'text': 'Güncelleme', 'route': '/update'},
  ];

  Widget _buildMainMenu() {
    return Column(
      children: [
        // Header with car info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFF8B1538),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          child: Row(
            children: [
              const Icon(Icons.directions_car, color: Colors.white, size: 24),
              const SizedBox(width: 16),
              const Text(
                'Renault Clio 2018 — Bağlı',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              const Icon(Icons.directions_car, color: Colors.white, size: 24),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Menu grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
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
                color: const Color(0xFF8B1538),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, item['route'] as String),
                  borderRadius: BorderRadius.circular(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item['icon'] as IconData, color: Colors.white, size: 36),
                      const SizedBox(height: 8),
                      Text(
                        item['text'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 12, 
                          fontWeight: FontWeight.bold
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
    );
  }

  Widget _buildPerformanceScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.speed, size: 64, color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Performans',
            style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Canlı verilerden hız, tork, güç raporları',
            style: TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReportsScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment, size: 64, color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Raporlar',
            style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Geçmiş raporların listesi',
            style: TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 64, color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Ayarlar',
            style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Dil seçeneği, hakkında, destek/öneri',
            style: TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildMainMenu(),
      _buildPerformanceScreen(),
      _buildReportsScreen(),
      _buildSettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF2C2C54),
      appBar: AppBar(
        title: const Text(
          'Strcar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8B1538),
        centerTitle: true,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF2C2C54),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Menü',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.speed),
            label: 'Performans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Raporlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }
}

