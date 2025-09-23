import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ai/ai_engine.dart';
import '../../data/vehicle_database.dart';

class AIAnalysisScreen extends ConsumerStatefulWidget {
  const AIAnalysisScreen({super.key});

  @override
  ConsumerState<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

// AI Recommendation sınıfı AIEngine'e taşındı

class _AIAnalysisScreenState extends ConsumerState<AIAnalysisScreen> {
  bool isAnalyzing = false;
  List<AIEngine.AIAnalysisResult> recommendations = [];
  Map<String, int> faultStatistics = {};
  Map<String, int> solutionStatistics = {};
  
  final AIEngine _aiEngine = AIEngine();
  final VehicleDatabase _vehicleDB = VehicleDatabase();
  
  // Mevcut araç bilgileri (normalde kullanıcı seçimi veya OBD'den gelir)
  String currentBrand = 'renault';
  String currentModel = 'Clio';
  int currentYear = 2018;
  int currentMileage = 85420;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  void _loadStatistics() async {
    try {
      final faultStats = await _aiEngine.getMostCommonFaults();
      final solutionStats = await _aiEngine.getMostRecommendedSolutions();
      
      setState(() {
        faultStatistics = faultStats;
        solutionStatistics = solutionStats;
      });
    } catch (e) {
      // Fallback to default stats
      setState(() {
        faultStatistics = {
          'P0300': 156,
          'P0171': 134,
          'P0420': 98,
          'P0128': 76,
          'P0442': 54,
        };
        solutionStatistics = {
          'Ateşleme bobini değişimi': 89,
          'Hava filtresi temizliği': 76,
          'MAF sensörü temizliği': 65,
          'Katalitik konvertör kontrolü': 54,
        };
      });
    }
  }

  Future<void> _performAIAnalysis() async {
    setState(() {
      isAnalyzing = true;
      recommendations.clear();
    });

    try {
      // Simüle edilmiş mevcut DTC kodları (normalde OBD'den gelir)
      final mockDTCs = ['P0300', 'P0171', 'P0420'];
      
      // Mock sensör verileri
      final mockSensorData = {
        'rpm': 850.0,
        'engineTemp': 92.0,
        'batteryVoltage': 12.4,
        'speed': 0.0,
        'o2Sensor': 0.45,
      };

      // Her DTC için AI analizi yap
      final analysisResults = await _aiEngine.analyzeMultipleFaults(
        dtcCodes: mockDTCs,
        vehicleBrand: currentBrand,
        vehicleModel: currentModel,
        vehicleYear: currentYear,
        mileage: currentMileage,
        sensorData: mockSensorData,
      );

      setState(() {
        recommendations = analysisResults;
        isAnalyzing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI analizi tamamlandı - ${analysisResults.length} arıza analiz edildi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isAnalyzing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI analizi hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C54),
      appBar: AppBar(
        title: const Text('Yapay Zeka'),
        backgroundColor: const Color(0xFF8B1538),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: isAnalyzing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.psychology),
            onPressed: isAnalyzing ? null : _performAIAnalysis,
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                        const Icon(Icons.psychology, color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'AI Arıza Analizi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gelişmiş AI algoritmaları ile ${_vehicleDB.getStatistics()['total_brands']} marka, ${_vehicleDB.getStatistics()['total_models']} model araç için kapsamlı arıza analizi.',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Analysis button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isAnalyzing ? null : _performAIAnalysis,
                icon: isAnalyzing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.auto_fix_high),
                label: Text(isAnalyzing ? 'Analiz Ediliyor...' : 'AI Analizi Başlat'),
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
            
            const SizedBox(height: 24),
            
            // Statistics section
            Row(
              children: [
                Expanded(
                  child: _buildStatisticsCard(
                    'En Çok Görülen Arıza',
                    faultStatistics,
                    Icons.trending_up,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatisticsCard(
                    'En Çok Önerilen Çözüm',
                    solutionStatistics,
                    Icons.build,
                    Colors.green,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Recommendations section
            const Text(
              'AI Çözüm Önerileri',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            ...recommendations.map((rec) => _buildRecommendationCard(rec)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(String title, Map<String, int> data, IconData icon, Color color) {
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEntry = sortedEntries.first;
    
    return Card(
      color: const Color(0xFF1E1E2F),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              topEntry.key,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${topEntry.value} kez',
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(AIEngine.AIAnalysisResult rec) {
    return Card(
      color: const Color(0xFF1E1E2F),
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getSeverityColor(rec.severity),
          child: const Icon(Icons.psychology, color: Colors.white, size: 20),
        ),
        title: Text(
          '${rec.faultCode} - ${rec.problem}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                _buildChip('Güven: ${(rec.confidence * 100).toInt()}%', Colors.blue),
                const SizedBox(width: 8),
                _buildChip(rec.severity, _getSeverityColor(rec.severity)),
                const SizedBox(width: 8),
                _buildChip('${rec.vehicleBrand} ${rec.vehicleModel}', Colors.purple),
              ],
            ),
          ],
        ),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white54,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kök neden
                const Text(
                  'Kök Neden:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rec.rootCause,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                
                // Çözüm önerileri
                const Text(
                  'AI Çözüm Önerileri:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...rec.solutions.take(3).map((solution) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Colors.green)),
                      Expanded(
                        child: Text(
                          solution,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                )),
                
                const SizedBox(height: 12),
                
                // Maliyet ve süre
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tahmini Süre:',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            rec.estimatedTime,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tahmini Maliyet:',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            rec.estimatedCost,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Gerekli araçlar
                const Text(
                  'Gerekli Araçlar:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: rec.requiredTools.map((tool) => _buildChip(tool, Colors.grey)).toList(),
                ),
                
                const SizedBox(height: 12),
                
                // Önleyici tedbirler
                if (rec.preventiveMeasures.isNotEmpty) ...[
                  const Text(
                    'Önleyici Tedbirler:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...rec.preventiveMeasures.take(3).map((measure) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('✓ ', style: TextStyle(color: Colors.blue)),
                        Expanded(
                          child: Text(
                            measure,
                            style: const TextStyle(color: Colors.white60, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
                
                // Sensör korelasyonları
                if (rec.sensorCorrelations.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade900.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.analytics, color: Colors.blue, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'AI Korelasyon Analizi:',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ...rec.sensorCorrelations.entries.map((entry) => Text(
                          '${entry.key}: ${entry.value}',
                          style: const TextStyle(color: Colors.white60, fontSize: 11),
                        )),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Yüksek':
        return Colors.red;
      case 'Orta':
        return Colors.orange;
      case 'Düşük':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}