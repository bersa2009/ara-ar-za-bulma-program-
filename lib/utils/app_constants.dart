class AppConstants {
  // App bilgileri
  static const String appName = 'Strcar';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'OBD-II Araç Tanı Uygulaması';
  
  // Renkler
  static const int primaryRedValue = 0xFF8B1538;
  static const int darkBackgroundValue = 0xFF2C2C54;
  static const int cardBackgroundValue = 0xFF1E1E2F;
  
  // OBD Sabitleri
  static const int obdTimeoutMs = 5000;
  static const int obdRetryCount = 3;
  static const String obdPrompt = '>';
  
  // ELM327 Komutları
  static const String elmReset = 'ATZ';
  static const String elmEcho = 'ATE0';
  static const String elmLinefeed = 'ATL0';
  static const String elmHeaders = 'ATH0';
  static const String elmSpaces = 'ATS0';
  static const String elmProtocol = 'ATSP0';
  static const String elmVoltage = 'ATRV';
  
  // DTC Komutları
  static const String dtcRead = '03';
  static const String dtcPending = '07';
  static const String dtcPermanent = '0A';
  static const String dtcClear = '04';
  
  // PID Komutları
  static const String pidRpm = '010C';
  static const String pidSpeed = '010D';
  static const String pidThrottle = '0111';
  static const String pidEngineTemp = '0105';
  static const String pidIntakeTemp = '010F';
  static const String pidMaf = '0110';
  static const String pidFuelPressure = '010A';
  static const String pidO2Sensor = '0114';
  
  // Bluetooth UUIDs
  static const String nordicUartServiceUuid = '6e400001-b5a3-f393-e0a9-e50e24dcca9e';
  static const String nordicUartRxUuid = '6e400002-b5a3-f393-e0a9-e50e24dcca9e';
  static const String nordicUartTxUuid = '6e400003-b5a3-f393-e0a9-e50e24dcca9e';
  
  // WiFi Sabitleri
  static const int defaultWifiPort = 35000;
  static const String defaultWifiHost = '192.168.0.10';
  
  // Veritabanı
  static const String dbName = 'strcar.db';
  static const int dbVersion = 1;
  
  // Dosya yolları
  static const String assetsPath = 'assets/';
  static const String dtcSeedTr = 'assets/dtc_seed_tr.json';
  static const String dtcSeedEn = 'assets/dtc_seed_en.json';
  static const String brandsModels = 'assets/brands_models.json';
  
  // Bakım aralıkları (km)
  static const Map<String, int> maintenanceIntervals = {
    'oil_change': 10000,
    'air_filter': 20000,
    'fuel_filter': 40000,
    'brake_pads': 30000,
    'spark_plugs': 30000,
    'timing_belt': 80000,
    'coolant': 60000,
    'transmission_oil': 80000,
  };
  
  // AI Sabitleri
  static const double aiMinConfidence = 0.7;
  static const double aiMaxConfidence = 0.95;
  static const int aiAnalysisTimeoutMs = 3000;
  
  // UI Sabitleri
  static const double cardRadius = 12.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Animasyon süreleri
  static const int shortAnimationMs = 200;
  static const int mediumAnimationMs = 500;
  static const int longAnimationMs = 1000;
  
  // Hata mesajları
  static const Map<String, String> errorMessages = {
    'connection_failed': 'OBD cihazına bağlanılamadı',
    'no_data': 'Araçtan veri alınamadı',
    'invalid_response': 'Geçersiz yanıt alındı',
    'timeout': 'İşlem zaman aşımına uğradı',
    'permission_denied': 'Gerekli izinler verilmedi',
    'device_not_found': 'OBD cihazı bulunamadı',
    'unsupported_protocol': 'Desteklenmeyen protokol',
  };
  
  // Başarı mesajları
  static const Map<String, String> successMessages = {
    'connection_established': 'OBD bağlantısı kuruldu',
    'data_received': 'Veri başarıyla alındı',
    'dtc_cleared': 'Arıza kodları temizlendi',
    'analysis_complete': 'Analiz tamamlandı',
    'report_saved': 'Rapor kaydedildi',
    'update_complete': 'Güncelleme tamamlandı',
  };
  
  // Desteklenen diller
  static const List<String> supportedLanguages = ['tr', 'en'];
  static const String defaultLanguage = 'tr';
  
  // Tema modları
  static const String lightTheme = 'light';
  static const String darkTheme = 'dark';
  static const String systemTheme = 'system';
  
  // SharedPreferences anahtarları
  static const String prefLanguage = 'language';
  static const String prefTheme = 'theme_mode';
  static const String prefTransport = 'preferred_transport';
  static const String prefTts = 'tts_enabled';
  static const String prefColorblind = 'colorblind_friendly';
  static const String prefPrivacyConsent = 'privacy_consent';
  static const String prefLastVin = 'last_vin';
  static const String prefLastMileage = 'last_mileage';
  
  // Export formatları
  static const String exportPdf = 'pdf';
  static const String exportExcel = 'excel';
  static const String exportJson = 'json';
  static const String exportCsv = 'csv';
}