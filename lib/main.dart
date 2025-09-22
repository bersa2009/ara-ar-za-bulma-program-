import 'package:flutter/material.dart';

void main() {
  runApp(const StrcarApp());
}

class StrcarApp extends StatelessWidget {
  const StrcarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strcar OBD Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strcar - Arıza Teşhisi'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Strcar OBD Bağlantısı',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bağlantı başlatılıyor...')),
                );
              },
              child: const Text('Cihazı Bağla'),
            ),
          ],
        ),
      ),
    );
  }
}

