import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AIAnalysisScreen extends ConsumerStatefulWidget {
  const AIAnalysisScreen({super.key});

  @override
  ConsumerState<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class AIRecommendation {
  final String faultCode;
  final String problem;
  final String solution;
  final String severity;
  final double confidence;
  final List<String> tools;
  final String estimatedTime;
  final String estimatedCost;

  AIRecommendation({
    required this.faultCode,
    required this.problem,
    required this.solution,
    required this.severity,
    required this.confidence,
    required this.tools,
    required this.estimatedTime,
    required this.estimatedCost,
  });
}

class _AIAnalysisScreenState extends ConsumerState<AIAnalysisScreen> {
  bool isAnalyzing = false;
  List<AIRecommendation> recommendations = [];
  Map<String, int> faultStatistics = {
    'P0300': 15,
    'P0171': 12,
    'P0420': 8,
    'P0128': 6,
    'P0442': 4,
  };
  
  Map<String, int> solutionStatistics = {
    'Ateşleme bobini değişimi': 18,
    'Hava filtresi temizliği': 15,
    'Katalitik konvertör kontrolü': 12,
    'Termostat değişimi': 8,
    'Yakıt deposu kapağı kontrolü': 5,
  };

  @override
  void initState() {
    super.initState();
    _loadMockRecommendations();
  }

  void _loadMockRecommendations() {
    recommendations = [
      AIRecommendation(
        faultCode: 'P0300',
        problem: 'Rastgele Silindir Ateşleme Hatası',
        solution: 'Ateşleme bobinlerini kontrol edin ve gerekirse değiştirin. Bujilerin durumunu kontrol edin.',
        severity: 'Yüksek',
        confidence: 0.92,
        tools: ['Multimetre', 'Bujiler anahtarı', 'Tornavida seti'],
        estimatedTime: '45-60 dakika',
        estimatedCost: '₺200-400',
      ),
      AIRecommendation(
        faultCode: 'P0171',
        problem: 'Sistem Çok Zayıf (Bank 1)',
        solution: 'Hava filtresi kontrol edin, vakum hortumlarını inceleyin. MAF sensörü temizliği yapın.',
        severity: 'Orta',
        confidence: 0.87,
        tools: ['Hava filtresi', 'MAF temizleyici', 'Vakum test cihazı'],
        estimatedTime: '30-45 dakika',
        estimatedCost: '₺150-300',
      ),
      AIRecommendation(
        faultCode: 'P0420',
        problem: 'Katalitik Konvertör Verimliliği Düşük',
        solution: 'Katalitik konvertörün performansını test edin. O2 sensörlerini kontrol edin.',
        severity: 'Orta',
        confidence: 0.78,
        tools: ['OBD tarayıcı', 'Egzoz gazı analizörü'],
        estimatedTime: '60-90 dakika',
        estimatedCost: '₺800-1500',
      ),
    ];
  }

  Future<void> _performAIAnalysis() async {
    setState(() {
      isAnalyzing = true;
    });

    // Simulate AI analysis
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      isAnalyzing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI analizi tamamlandı - Çözüm önerileri güncellendi'),
          backgroundColor: Colors.green,
        ),
      );
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
                    const Text(
                      'Okunan arıza kodlarını analiz ederek çözüm önerileri verir ve geçmiş verilerden tekrar eden arızaları tahmin eder.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
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

  Widget _buildRecommendationCard(AIRecommendation rec) {
    return Card(
      color: const Color(0xFF1E1E2F),
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getSeverityColor(rec.severity),
          child: const Icon(Icons.lightbulb, color: Colors.white, size: 20),
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
                const Text(
                  'Çözüm Önerisi:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rec.solution,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                
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
                  children: rec.tools.map((tool) => _buildChip(tool, Colors.grey)).toList(),
                ),
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