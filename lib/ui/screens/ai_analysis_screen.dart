import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/connection_manager.dart';
import '../../data/dtc_repository.dart';
import '../../elm/elm327_client.dart';

class AIAnalysisScreen extends ConsumerStatefulWidget {
  const AIAnalysisScreen({super.key});

  @override
  ConsumerState<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends ConsumerState<AIAnalysisScreen> {
  final DtcRepository _dtcRepository = DtcRepository();
  Timer? _analysisTimer;
  Map<String, dynamic> _aiAnalysis = {};
  List<Map<String, dynamic>> _currentFaults = [];
  bool _isAnalyzing = false;
  bool _isConnected = false;

  // Mock historical data for demonstration
  final List<Map<String, dynamic>> _historicalFaults = [
    {'code': 'P0300', 'title': 'Rastgele Silindir Ateşleme Hatası', 'count': 5, 'lastSeen': '2024-01-15'},
    {'code': 'P0420', 'title': 'Katalitik Konvertör Verimliliği Düşük', 'count': 3, 'lastSeen': '2024-01-10'},
    {'code': 'P0171', 'title': 'Yakıt Sistemi Çok Zayıf', 'count': 2, 'lastSeen': '2024-01-05'},
    {'code': 'P0135', 'title': 'O2 Sensörü Isıtıcısı Devresi', 'count': 1, 'lastSeen': '2023-12-20'},
  ];

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _startAIAnalysis();
    _initializeDtcRepository();
  }

  @override
  void dispose() {
    _analysisTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeDtcRepository() async {
    await _dtcRepository.ensureSeeded(['tr', 'en']);
  }

  void _checkConnection() {
    final elmClient = ref.read(elmClientProvider);
    setState(() {
      _isConnected = elmClient != null;
    });
  }

  void _startAIAnalysis() {
    _analysisTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isConnected) {
        _performAIAnalysis();
      }
    });
  }

  Future<void> _performAIAnalysis() async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Get current faults
      await _getCurrentFaults();

      // Analyze patterns
      final analysis = await _analyzeFaultPatterns();

      setState(() {
        _aiAnalysis = analysis;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _getCurrentFaults() async {
    try {
      final elmClient = ref.read(elmClientProvider);
      if (elmClient == null) return;

      // Read current DTC codes
      final response = await elmClient.sendCommand('03');
      final faultCodes = _parseCurrentFaults(response);

      // Get detailed information for each fault
      final faults = <Map<String, dynamic>>[];
      for (final code in faultCodes) {
        final dtcInfo = await _dtcRepository.getDtc(code, lang: 'tr');
        if (dtcInfo != null) {
          faults.add(dtcInfo);
        }
      }

      setState(() {
        _currentFaults = faults;
      });
    } catch (e) {
      // Handle error
    }
  }

  List<String> _parseCurrentFaults(String response) {
    // Simplified parsing - actual implementation would be more robust
    return ['P0300', 'P0420']; // Mock data for demonstration
  }

  Future<Map<String, dynamic>> _analyzeFaultPatterns() async {
    // Analyze current faults and historical data
    final mostCommonFault = _historicalFaults.reduce((a, b) =>
        a['count'] > b['count'] ? a : b);

    final recentFaults = _historicalFaults.where((fault) {
      final lastSeen = DateTime.parse(fault['lastSeen']);
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      return lastSeen.isAfter(thirtyDaysAgo);
    }).toList();

    // Generate AI recommendations
    final recommendations = _generateRecommendations(_currentFaults);

    // Calculate risk level
    final riskLevel = _calculateRiskLevel(_currentFaults);

    return {
      'mostCommonFault': mostCommonFault,
      'recentFaults': recentFaults,
      'recommendations': recommendations,
      'riskLevel': riskLevel,
      'totalFaults': _historicalFaults.length,
      'analysisTimestamp': DateTime.now(),
    };
  }

  List<String> _generateRecommendations(List<Map<String, dynamic>> faults) {
    final recommendations = <String>[];

    for (final fault in faults) {
      final code = fault['code'];
      switch (code) {
        case 'P0300':
          recommendations.addAll([
            'Buji kontrolleri yapın',
            'Yakıt sistemi basıncını kontrol edin',
            'Hava filtresini temizleyin veya değiştirin',
          ]);
          break;
        case 'P0420':
          recommendations.addAll([
            'Katalitik konvertörü inceleyin',
            'O2 sensörlerini test edin',
            'Egzoz sistemini kontrol edin',
          ]);
          break;
        case 'P0171':
          recommendations.addAll([
            'Yakıt hattında sızıntı kontrolü yapın',
            'MAF sensörünü temizleyin',
            'PCV valfini kontrol edin',
          ]);
          break;
        case 'P0135':
          recommendations.addAll([
            'O2 sensörü bağlantılarını kontrol edin',
            'Sigortaları kontrol edin',
            'Sensör kablolarında kopukluk arayın',
          ]);
          break;
      }
    }

    return recommendations;
  }

  String _calculateRiskLevel(List<Map<String, dynamic>> faults) {
    if (faults.isEmpty) return 'Düşük';
    if (faults.length >= 3) return 'Yüksek';
    if (faults.length >= 2) return 'Orta';
    return 'Düşük';
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
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

  String _getRiskIcon(String riskLevel) {
    switch (riskLevel) {
      case 'Yüksek':
        return '⚠️';
      case 'Orta':
        return '⚡';
      case 'Düşük':
        return '✅';
      default:
        return '❓';
    }
  }

  @override
  Widget build(BuildContext context) {
    final riskLevel = _aiAnalysis['riskLevel'] ?? 'Bilinmiyor';
    final riskColor = _getRiskColor(riskLevel);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yapay Zeka'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Connection and Analysis Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF2D2D3D),
            child: Row(
              children: [
                Icon(
                  Icons.smart_toy,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  _isConnected ? 'AI Analizi Çalışıyor...' : 'Bağlı Değil',
                  style: TextStyle(
                    color: _isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: riskColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_getRiskIcon(riskLevel)} $riskLevel Risk',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Risk Analysis Summary
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1E1E2F),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Risk Analizi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sistem ${_currentFaults.length} aktif arıza ve ${_historicalFaults.length} geçmiş kayıt analiz etti.',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                if (_isAnalyzing) ...[
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(
                    backgroundColor: Colors.grey,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Analiz ediliyor...',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Analysis Tabs
          Expanded(
            child: DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  TabBar(
                    labelColor: Colors.red,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.red,
                    tabs: const [
                      Tab(text: 'Öneriler'),
                      Tab(text: 'İstatistik'),
                      Tab(text: 'Tahminler'),
                      Tab(text: 'Geçmiş'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildRecommendationsTab(),
                        _buildStatisticsTab(),
                        _buildPredictionsTab(),
                        _buildHistoryTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isConnected ? _performAIAnalysis : null,
        backgroundColor: Colors.red,
        child: _isAnalyzing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.psychology),
      ),
    );
  }

  Widget _buildRecommendationsTab() {
    final recommendations = _aiAnalysis['recommendations'] ?? [];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recommendations.length,
      itemBuilder: (context, index) {
        return Card(
          color: const Color(0xFF2D2D3D),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              recommendations[index],
              style: const TextStyle(color: Colors.white),
            ),
            trailing: const Icon(
              Icons.arrow_forward,
              color: Colors.red,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatisticsTab() {
    final mostCommonFault = _aiAnalysis['mostCommonFault'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatCard(
            'En Sık Görülen Arıza',
            mostCommonFault['title'] ?? 'Bilinmiyor',
            '${mostCommonFault['count']} kez',
            Icons.warning,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'Toplam Kayıt',
            '${_aiAnalysis['totalFaults'] ?? 0}',
            'geçmiş arıza',
            Icons.analytics,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'Aktif Arıza',
            '${_currentFaults.length}',
            'mevcut sorun',
            Icons.error,
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPredictionCard(
          'Yaklaşan Bakım',
          '10.000 km bakım zamanı yaklaşıyor',
          '15 gün içinde',
          Icons.schedule,
        ),
        const SizedBox(height: 12),
        _buildPredictionCard(
          'Olası Arıza',
          'P0300 kodu tekrar görülebilir',
          '%75 olasılık',
          Icons.trending_up,
        ),
        const SizedBox(height: 12),
        _buildPredictionCard(
          'Sistem Sağlığı',
          'Genel durum iyi',
          'Stabil',
          Icons.health_and_safety,
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _historicalFaults.length,
      itemBuilder: (context, index) {
        final fault = _historicalFaults[index];
        return Card(
          color: const Color(0xFF2D2D3D),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                fault['code'].toString().substring(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              fault['title'],
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              '${fault['count']} kez - Son: ${fault['lastSeen']}',
              style: TextStyle(color: Colors.grey[400]),
            ),
            trailing: Text(
              '${fault['count']}',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon) {
    return Card(
      color: const Color(0xFF2D2D3D),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.red, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCard(String title, String description, String status, IconData icon) {
    return Card(
      color: const Color(0xFF2D2D3D),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.orange, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    status,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}