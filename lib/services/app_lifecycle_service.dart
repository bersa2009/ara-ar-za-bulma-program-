import 'package:flutter/material.dart';
import '../utils/memory_manager.dart';
import '../core/connection_manager.dart';
import 'notification_service.dart';

class AppLifecycleService extends WidgetsBindingObserver {
  static final AppLifecycleService _instance = AppLifecycleService._internal();
  factory AppLifecycleService() => _instance;
  AppLifecycleService._internal();

  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;
    WidgetsBinding.instance.addObserver(this);
    _isInitialized = true;
  }

  void dispose() {
    if (!_isInitialized) return;
    WidgetsBinding.instance.removeObserver(this);
    _isInitialized = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      case AppLifecycleState.inactive:
        _onAppInactive();
        break;
      case AppLifecycleState.detached:
        _onAppDetached();
        break;
      case AppLifecycleState.hidden:
        _onAppHidden();
        break;
    }
  }

  void _onAppResumed() {
    debugPrint('App resumed');
    // App geri geldiğinde yapılacaklar
    // - OBD bağlantısını kontrol et
    // - Bekleyen bildirimleri göster
  }

  void _onAppPaused() {
    debugPrint('App paused');
    // App arka plana geçtiğinde yapılacaklar
    // - Timer'ları durdur
    // - OBD bağlantısını koru ama veri akışını durdur
    MemoryManager.cancelAllTimers();
  }

  void _onAppInactive() {
    debugPrint('App inactive');
    // App geçici olarak devre dışı
  }

  void _onAppDetached() {
    debugPrint('App detached');
    // App tamamen kapatılıyor
    _cleanup();
  }

  void _onAppHidden() {
    debugPrint('App hidden');
    // App gizlendi
  }

  void _cleanup() {
    // Tüm kaynakları temizle
    MemoryManager.dispose();
    
    // OBD bağlantısını kapat
    // ConnectionManager dispose işlemi burada yapılabilir
    
    debugPrint('App cleanup completed');
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Ekran boyutu değişikliklerini handle et
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    // Sistem tema değişikliklerini handle et
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);
    // Dil değişikliklerini handle et
  }
}