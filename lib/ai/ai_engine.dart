import 'dart:math';
import '../data/vehicle_database.dart';
import '../data/dtc_repository.dart';

class AIEngine {
  static final AIEngine _instance = AIEngine._internal();
  factory AIEngine() => _instance;
  AIEngine._internal();

  final VehicleDatabase _vehicleDB = VehicleDatabase();
  final DtcRepository _dtcRepo = DtcRepository();
  final Random _random = Random();

  // AI Analiz Sonucu
  class AIAnalysisResult {
    final String faultCode;
    final String vehicleBrand;
    final String vehicleModel;
    final String problem;
    final String rootCause;
    final List<String> solutions;
    final double confidence;
    final String severity;
    final List<String> requiredTools;
    final String estimatedTime;
    final String estimatedCost;
    final List<String> preventiveMeasures;
    final Map<String, dynamic> sensorCorrelations;

    AIAnalysisResult({
      required this.faultCode,
      required this.vehicleBrand,
      required this.vehicleModel,
      required this.problem,
      required this.rootCause,
      required this.solutions,
      required this.confidence,
      required this.severity,
      required this.requiredTools,
      required this.estimatedTime,
      required this.estimatedCost,
      required this.preventiveMeasures,
      required this.sensorCorrelations,
    });
  }

  // Ana AI analiz fonksiyonu
  Future<AIAnalysisResult> analyzeFault({
    required String dtcCode,
    required String vehicleBrand,
    required String vehicleModel,
    required int vehicleYear,
    required int mileage,
    Map<String, dynamic>? sensorData,
    List<String>? historicalFaults,
  }) async {
    // Simüle edilmiş AI işlem süresi
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));

    // Araç bilgilerini al
    final vehicleInfo = _vehicleDB.getVehicleInfo(vehicleBrand, vehicleModel, vehicleYear);
    
    // DTC bilgilerini al
    final dtcInfo = await _dtcRepo.getDTCInfo(dtcCode, vehicleBrand);
    
    // AI analizi yap
    final analysis = _performAIAnalysis(
      dtcCode: dtcCode,
      vehicleInfo: vehicleInfo,
      dtcInfo: dtcInfo,
      mileage: mileage,
      sensorData: sensorData,
      historicalFaults: historicalFaults,
    );

    return analysis;
  }

  // Çoklu DTC analizi
  Future<List<AIAnalysisResult>> analyzeMultipleFaults({
    required List<String> dtcCodes,
    required String vehicleBrand,
    required String vehicleModel,
    required int vehicleYear,
    required int mileage,
    Map<String, dynamic>? sensorData,
  }) async {
    final results = <AIAnalysisResult>[];
    
    for (final code in dtcCodes) {
      final result = await analyzeFault(
        dtcCode: code,
        vehicleBrand: vehicleBrand,
        vehicleModel: vehicleModel,
        vehicleYear: vehicleYear,
        mileage: mileage,
        sensorData: sensorData,
      );
      results.add(result);
    }

    // Arızalar arası korelasyon analizi
    _analyzeCorrelations(results);
    
    return results;
  }

  // AI analiz algoritması
  AIAnalysisResult _performAIAnalysis({
    required String dtcCode,
    required Map<String, dynamic> vehicleInfo,
    required Map<String, dynamic> dtcInfo,
    required int mileage,
    Map<String, dynamic>? sensorData,
    List<String>? historicalFaults,
  }) {
    // Güven skoru hesaplama
    double confidence = _calculateConfidence(dtcCode, vehicleInfo, mileage, sensorData);
    
    // Önem derecesi belirleme
    String severity = _determineSeverity(dtcCode, sensorData, mileage);
    
    // Çözüm önerileri
    List<String> solutions = _generateSolutions(dtcCode, vehicleInfo, severity);
    
    // Gerekli araçlar
    List<String> tools = _getRequiredTools(dtcCode, solutions);
    
    // Maliyet ve süre tahmini
    Map<String, String> estimates = _estimateCostAndTime(dtcCode, vehicleInfo, severity);
    
    // Önleyici tedbirler
    List<String> preventive = _getPreventiveMeasures(dtcCode, vehicleInfo);
    
    // Sensör korelasyonları
    Map<String, dynamic> correlations = _analyzeSensorCorrelations(dtcCode, sensorData);

    return AIAnalysisResult(
      faultCode: dtcCode,
      vehicleBrand: vehicleInfo['brand'] ?? 'Bilinmiyor',
      vehicleModel: vehicleInfo['model'] ?? 'Bilinmiyor',
      problem: dtcInfo['description'] ?? _getGenericDescription(dtcCode),
      rootCause: _determineRootCause(dtcCode, vehicleInfo, sensorData),
      solutions: solutions,
      confidence: confidence,
      severity: severity,
      requiredTools: tools,
      estimatedTime: estimates['time'] ?? '30-60 dakika',
      estimatedCost: estimates['cost'] ?? '₺100-500',
      preventiveMeasures: preventive,
      sensorCorrelations: correlations,
    );
  }

  // Güven skoru hesaplama
  double _calculateConfidence(String dtcCode, Map<String, dynamic> vehicleInfo, 
                             int mileage, Map<String, dynamic>? sensorData) {
    double baseConfidence = 0.7;
    
    // DTC kodu tanımlı mı?
    if (_isKnownDTC(dtcCode)) baseConfidence += 0.15;
    
    // Araç bilgisi mevcut mu?
    if (vehicleInfo.isNotEmpty) baseConfidence += 0.1;
    
    // Sensör verileri mevcut mu?
    if (sensorData != null && sensorData.isNotEmpty) baseConfidence += 0.05;
    
    // Kilometre bazlı güven ayarlaması
    if (mileage > 100000) baseConfidence -= 0.05;
    if (mileage > 200000) baseConfidence -= 0.05;
    
    return (baseConfidence + (_random.nextDouble() * 0.1 - 0.05)).clamp(0.0, 1.0);
  }

  // Önem derecesi belirleme
  String _determineSeverity(String dtcCode, Map<String, dynamic>? sensorData, int mileage) {
    // Kritik sistem kodları
    final criticalCodes = ['P0001', 'P0016', 'P0017', 'P0020', 'P0021', 'P0087', 'P0088'];
    final engineCodes = ['P0300', 'P0301', 'P0302', 'P0303', 'P0304', 'P0305', 'P0306'];
    final emissionCodes = ['P0420', 'P0430', 'P0171', 'P0172', 'P0174', 'P0175'];
    
    if (criticalCodes.contains(dtcCode)) return 'Kritik';
    if (engineCodes.contains(dtcCode)) return 'Yüksek';
    if (emissionCodes.contains(dtcCode)) return 'Orta';
    
    // Sensör verilerine göre
    if (sensorData != null) {
      final engineTemp = sensorData['engineTemp'] as double?;
      if (engineTemp != null && engineTemp > 105) return 'Yüksek';
    }
    
    return 'Düşük';
  }

  // Çözüm önerileri oluşturma
  List<String> _generateSolutions(String dtcCode, Map<String, dynamic> vehicleInfo, String severity) {
    final solutions = <String>[];
    
    // DTC kodu bazlı çözümler
    switch (dtcCode.substring(0, 5)) {
      case 'P0300':
        solutions.addAll([
          'Ateşleme bobinlerini kontrol edin ve değiştirin',
          'Bujilerin durumunu kontrol edin',
          'Yakıt enjektörlerini temizleyin',
          'Hava filtresi kontrol edin',
          'Yakıt pompası basıncını ölçün'
        ]);
        break;
      case 'P0171':
        solutions.addAll([
          'Hava filtresi değiştirin',
          'MAF sensörünü temizleyin',
          'Vakum kaçağı kontrol edin',
          'Yakıt basıncı regülatörünü kontrol edin',
          'PCV valfi kontrol edin'
        ]);
        break;
      case 'P0420':
        solutions.addAll([
          'Katalitik konvertörü değiştirin',
          'O2 sensörlerini kontrol edin',
          'Egzoz sistemi kaçağı kontrol edin',
          'Motor yağı kalitesini kontrol edin'
        ]);
        break;
      default:
        solutions.addAll([
          'ECU hata kodlarını silin ve test sürüşü yapın',
          'İlgili sensörleri kontrol edin',
          'Elektrik bağlantılarını kontrol edin',
          'Servis kılavuzuna başvurun'
        ]);
    }
    
    return solutions;
  }

  // Gerekli araçlar
  List<String> _getRequiredTools(String dtcCode, List<String> solutions) {
    final tools = <String>{'OBD Tarayıcı', 'Multimetre'};
    
    if (solutions.any((s) => s.contains('bobin'))) {
      tools.addAll(['Bobin test cihazı', 'Tornavida seti']);
    }
    if (solutions.any((s) => s.contains('buji'))) {
      tools.add('Buji anahtarı');
    }
    if (solutions.any((s) => s.contains('filtre'))) {
      tools.add('Filtre anahtarı');
    }
    if (solutions.any((s) => s.contains('basınç'))) {
      tools.add('Yakıt basınç ölçer');
    }
    
    return tools.toList();
  }

  // Maliyet ve süre tahmini
  Map<String, String> _estimateCostAndTime(String dtcCode, Map<String, dynamic> vehicleInfo, String severity) {
    final brand = vehicleInfo['brand']?.toString().toLowerCase() ?? '';
    final isLuxury = ['bmw', 'mercedes', 'audi', 'lexus', 'infiniti'].contains(brand);
    
    String cost, time;
    
    switch (severity) {
      case 'Kritik':
        cost = isLuxury ? '₺1000-3000' : '₺500-1500';
        time = '2-4 saat';
        break;
      case 'Yüksek':
        cost = isLuxury ? '₺500-1500' : '₺200-800';
        time = '1-2 saat';
        break;
      case 'Orta':
        cost = isLuxury ? '₺300-800' : '₺150-400';
        time = '30-90 dakika';
        break;
      default:
        cost = isLuxury ? '₺200-500' : '₺100-300';
        time = '20-45 dakika';
    }
    
    return {'cost': cost, 'time': time};
  }

  // Önleyici tedbirler
  List<String> _getPreventiveMeasures(String dtcCode, Map<String, dynamic> vehicleInfo) {
    return [
      'Düzenli servis bakımlarını aksatmayın',
      'Kaliteli yakıt kullanın',
      'Motor yağını zamanında değiştirin',
      'Hava filtresini düzenli temizleyin',
      'Aracınızı ısındırmadan zorlamayın',
      'Kısa mesafe sürüşlerden kaçının',
      'Yılda en az bir kez kapsamlı kontrol yaptırın'
    ];
  }

  // Sensör korelasyon analizi
  Map<String, dynamic> _analyzeSensorCorrelations(String dtcCode, Map<String, dynamic>? sensorData) {
    if (sensorData == null) return {};
    
    final correlations = <String, dynamic>{};
    
    // Motor sıcaklığı korelasyonu
    final engineTemp = sensorData['engineTemp'] as double?;
    if (engineTemp != null) {
      correlations['engine_temp_status'] = engineTemp > 100 ? 'Yüksek' : 'Normal';
      correlations['cooling_system_risk'] = engineTemp > 105 ? 'Yüksek' : 'Düşük';
    }
    
    // RPM korelasyonu
    final rpm = sensorData['rpm'] as double?;
    if (rpm != null) {
      correlations['idle_quality'] = rpm < 600 || rpm > 1000 ? 'Sorunlu' : 'Normal';
    }
    
    return correlations;
  }

  // Arızalar arası korelasyon
  void _analyzeCorrelations(List<AIAnalysisResult> results) {
    // Birbirleriyle ilişkili arızaları tespit et
    for (int i = 0; i < results.length; i++) {
      for (int j = i + 1; j < results.length; j++) {
        final correlation = _findCorrelation(results[i].faultCode, results[j].faultCode);
        if (correlation.isNotEmpty) {
          results[i].sensorCorrelations['related_fault'] = results[j].faultCode;
          results[j].sensorCorrelations['related_fault'] = results[i].faultCode;
        }
      }
    }
  }

  // Yardımcı fonksiyonlar
  bool _isKnownDTC(String code) => code.startsWith('P') && code.length == 5;
  
  String _getGenericDescription(String dtcCode) {
    return 'DTC $dtcCode: Sistem arızası tespit edildi';
  }
  
  String _determineRootCause(String dtcCode, Map<String, dynamic> vehicleInfo, Map<String, dynamic>? sensorData) {
    // Basitleştirilmiş kök neden analizi
    final causes = {
      'P0300': 'Ateşleme sistemi arızası veya yakıt sistemi problemi',
      'P0171': 'Hava-yakıt karışımında dengesizlik (zayıf karışım)',
      'P0420': 'Katalitik konvertör verimliliği düşük',
      'P0128': 'Motor soğutma sistemi termostat arızası',
    };
    
    return causes[dtcCode] ?? 'Sistem bileşeni arızası';
  }
  
  String _findCorrelation(String code1, String code2) {
    final correlations = {
      'P0300-P0171': 'Yakıt sistemi problemi',
      'P0420-P0171': 'Emisyon sistemi arızası',
    };
    
    return correlations['$code1-$code2'] ?? correlations['$code2-$code1'] ?? '';
  }

  // İstatistik fonksiyonları
  Future<Map<String, int>> getMostCommonFaults() async {
    return {
      'P0300': 156,
      'P0171': 134,
      'P0420': 98,
      'P0128': 76,
      'P0442': 54,
      'P0301': 45,
      'P0172': 38,
      'P0430': 32,
    };
  }

  Future<Map<String, int>> getMostRecommendedSolutions() async {
    return {
      'Ateşleme bobini değişimi': 89,
      'Hava filtresi temizliği/değişimi': 76,
      'MAF sensörü temizliği': 65,
      'Katalitik konvertör kontrolü': 54,
      'Yakıt enjektörü temizliği': 43,
      'Termostat değişimi': 38,
      'O2 sensörü değişimi': 32,
    };
  }
}