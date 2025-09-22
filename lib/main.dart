import 'package:flutter/material.dart';
import 'ui/screens/home.dart';

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

 

