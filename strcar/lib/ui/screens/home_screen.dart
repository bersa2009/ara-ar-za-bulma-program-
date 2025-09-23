import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> menuItems = const [
    {'icon': Icons.car_repair, 'text': 'Motor Arıza Teşhisi Yapar', 'route': '/scan'},
    {'icon': Icons.delete_sweep, 'text': 'Arıza Kodu Temizleme Yapar', 'route': '/clear'},
    {'icon': Icons.battery_full, 'text': 'Akü Ömrünü Verir', 'route': '/battery'},
    {'icon': Icons.timeline, 'text': 'Gerçek Zamanlı Veri Akışı Sağlar', 'route': '/realtime'},
    {'icon': Icons.dvr, 'text': 'Ekranda Görülen Arıza Kayıt Bilgilerini Okur', 'route': '/display'},
    {'icon': Icons.build, 'text': 'Muayene ve Bakıma Hazır Olma Durumunu Gösterir', 'route': '/maintenance'},
    {'icon': Icons.sensors, 'text': 'Oksijen Sensörü İzleme Sonuçlarını Okur', 'route': '/o2sensor'},
    {'icon': Icons.badge, 'text': 'Araç Kimlik Numarasını Okur', 'route': '/vin'},
    {'icon': Icons.list_alt, 'text': 'Tanısal Hata Kodu Genel Listesini İçerir', 'route': '/dtc_list'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2F),
      appBar: AppBar(title: const Text('Strcar - Ana Menü')),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return Card(
            color: const Color(0xFF3B5998),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, item['route'] as String),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item['icon'] as IconData, color: Colors.white, size: 40),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      item['text'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

