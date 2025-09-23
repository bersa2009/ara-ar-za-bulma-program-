import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:math';

class BatteryTestScreen extends ConsumerStatefulWidget {
  const BatteryTestScreen({super.key});

  @override
  ConsumerState<BatteryTestScreen> createState() => _BatteryTestScreenState();
}

class BatteryTestResult {
  final double voltage;
  final double chargingVoltage;
  final int chargePercentage;
  final String health;
  final int estimatedLifeMonths;
  final bool alternatorWorking;
  final double alternatorVoltage;
  final String recommendation;

  BatteryTestResult({
    required this.voltage,
    required this.chargingVoltage,
    required this.chargePercentage,
    required this.health,
    required this.estimatedLifeMonths,
    required this.alternatorWorking,
    required this.alternatorVoltage,
    required this.recommendation,
  });
}

class _BatteryTestScreenState extends ConsumerState<BatteryTestScreen> {
  bool isTesting = false;
  BatteryTestResult? testResult;
  Timer? _testTimer;
  int testProgress = 0;

  @override
  void dispose() {
    _testTimer?.cancel();
    super.dispose();
  }

  Future<void> _performBatteryTest() async {
    setState(() {
      isTesting = true;
      testProgress = 0;
      testResult = null;
    });

    // Simulate progressive test
    _testTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        testProgress += 5;
      });

      if (testProgress >= 100) {
        timer.cancel();
        _completeTest();
      }
    });
  }

  void _completeTest() {
    // Generate realistic battery test results
    final random = Random();
    final baseVoltage = 11.5 + random.nextDouble() * 1.5; // 11.5-13.0V
    final chargingVoltage = 13.8 + random.nextDouble() * 0.8; // 13.8-14.6V
    
    String health;
    String recommendation;
    int estimatedLife;
    
    if (baseVoltage < 12.0) {
      health = 'Zayıf';
      recommendation = 'Akü değişimi önerilir. Voltaj çok düşük.';
      estimatedLife = 1;
    } else if (baseVoltage < 12.4) {
      health = 'Orta';
      recommendation = 'Akü performansı düşük. Yakın takipte tutun.';
      estimatedLife = 6;
    } else {
      health = 'İyi';
      recommendation = 'Akü sağlıklı durumda. Düzenli kontrol yapın.';
      estimatedLife = 24;
    }

    final chargePercentage = ((baseVoltage - 11.5) / 1.5 * 100).clamp(0, 100).toInt();
    final alternatorWorking = chargingVoltage > 13.5;

    setState(() {
      isTesting = false;
      testResult = BatteryTestResult(
        voltage: baseVoltage,
        chargingVoltage: chargingVoltage,
        chargePercentage: chargePercentage,
        health: health,
        estimatedLifeMonths: estimatedLife,
        alternatorWorking: alternatorWorking,
        alternatorVoltage: chargingVoltage,
        recommendation: recommendation,
      );
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Akü testi tamamlandı - Durum: $health'),
          backgroundColor: _getHealthColor(health),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C54),
      appBar: AppBar(
        title: const Text('Batarya Testi'),
        backgroundColor: const Color(0xFF8B1538),
        foregroundColor: Colors.white,
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
                        const Icon(Icons.battery_charging_full, color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Akü Sağlık Testi',
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
                      'Akü voltajı, şarj durumu ve alternatör performansı ölçülür. Akü ömrü tahmini yapılır.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isTesting ? null : _performBatteryTest,
                icon: isTesting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(isTesting ? 'Test Ediliyor... %$testProgress' : 'Akü Testini Başlat'),
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
            
            // Progress bar
            if (isTesting) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: testProgress / 100,
                backgroundColor: Colors.grey.shade700,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B1538)),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Test results
            if (testResult != null) ...[
              const Text(
                'Test Sonuçları',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Battery status card
              Card(
                color: _getHealthColor(testResult!.health),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getHealthIcon(testResult!.health),
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Akü Durumu: ${testResult!.health}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Şarj: %${testResult!.chargePercentage}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Detailed measurements
              Row(
                children: [
                  Expanded(
                    child: _buildMeasurementCard(
                      'Akü Voltajı',
                      '${testResult!.voltage.toStringAsFixed(1)} V',
                      Icons.battery_std,
                      _getVoltageColor(testResult!.voltage),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMeasurementCard(
                      'Şarj Voltajı',
                      '${testResult!.chargingVoltage.toStringAsFixed(1)} V',
                      Icons.electrical_services,
                      testResult!.alternatorWorking ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildMeasurementCard(
                      'Tahmini Ömür',
                      '${testResult!.estimatedLifeMonths} ay',
                      Icons.schedule,
                      _getLifeColor(testResult!.estimatedLifeMonths),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMeasurementCard(
                      'Alternatör',
                      testResult!.alternatorWorking ? 'Çalışıyor' : 'Arızalı',
                      Icons.settings,
                      testResult!.alternatorWorking ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Recommendation card
              Card(
                color: const Color(0xFF1E1E2F),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lightbulb, color: Colors.amber),
                          const SizedBox(width: 8),
                          const Text(
                            'Öneri',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        testResult!.recommendation,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      if (testResult!.health == 'Zayıf') ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade800,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning, color: Colors.white),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'UYARI: Zayıf akü nedeniyle araç çalışmayabilir!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ] else ...[
              // No results yet
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.battery_unknown,
                        size: 64,
                        color: Colors.white54,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Akü Testi Bekleniyor',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Akü sağlığını öğrenmek için test başlatın',
                        style: TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: const Color(0xFF1E1E2F),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getHealthColor(String health) {
    switch (health) {
      case 'İyi':
        return Colors.green.shade700;
      case 'Orta':
        return Colors.orange.shade700;
      case 'Zayıf':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _getHealthIcon(String health) {
    switch (health) {
      case 'İyi':
        return Icons.battery_full;
      case 'Orta':
        return Icons.battery_3_bar;
      case 'Zayıf':
        return Icons.battery_1_bar;
      default:
        return Icons.battery_unknown;
    }
  }

  Color _getVoltageColor(double voltage) {
    if (voltage < 12.0) return Colors.red;
    if (voltage < 12.4) return Colors.orange;
    return Colors.green;
  }

  Color _getLifeColor(int months) {
    if (months < 3) return Colors.red;
    if (months < 12) return Colors.orange;
    return Colors.green;
  }
}