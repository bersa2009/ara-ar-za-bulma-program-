import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ComprehensiveErrorHandler {
  static void initialize() {
    // Global error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError('Flutter Error', details.exception.toString(), details.stack);
    };

    // Platform dispatcher error handling
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError('Platform Error', error.toString(), stack);
      return true;
    };
  }

  static void _logError(String type, String error, StackTrace? stack) {
    debugPrint('=== $type ===');
    debugPrint('Error: $error');
    if (stack != null) {
      debugPrint('Stack: $stack');
    }
    debugPrint('================');
  }

  static void handleOBDError(BuildContext context, String error) {
    String localizedError = _localizeOBDError(error);
    
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                localizedError,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Yeniden Dene',
          textColor: Colors.white,
          onPressed: () {
            // Retry logic burada implement edilebilir
          },
        ),
      ),
    );
  }

  static String _localizeOBDError(String error) {
    final errorMap = {
      'BLE not open': 'Bluetooth Low Energy bağlantısı açık değil',
      'Socket not open': 'Ağ bağlantısı kurulamadı',
      'SPP not open': 'Bluetooth seri port bağlantısı açık değil',
      'Transport not open': 'OBD cihazı bağlantısı açık değil',
      'Unknown error': 'Bilinmeyen hata oluştu',
      'Connection timeout': 'Bağlantı zaman aşımına uğradı',
      'Device not found': 'OBD cihazı bulunamadı',
      'Permission denied': 'Gerekli izinler verilmedi',
      'NO DATA': 'Araçtan veri alınamadı',
      'UNABLE TO CONNECT': 'Araç ECU\'suna bağlanılamadı',
      'BUS INIT... OK': 'Araç iletişim protokolü başlatıldı',
      'SEARCHING...': 'Araç protokolü aranıyor',
      'CAN ERROR': 'CAN bus iletişim hatası',
      'BUFFER FULL': 'Veri tamponu doldu',
      'STOPPED': 'İşlem durduruldu',
    };

    for (final entry in errorMap.entries) {
      if (error.toUpperCase().contains(entry.key.toUpperCase())) {
        return entry.value;
      }
    }

    return 'OBD Hatası: $error';
  }

  static Widget buildErrorScreen({
    required String title,
    required String message,
    VoidCallback? onRetry,
    VoidCallback? onGoBack,
  }) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C54),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onGoBack != null) ...[
                    ElevatedButton.icon(
                      onPressed: onGoBack,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Geri Dön'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (onRetry != null)
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Yeniden Dene'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B1538),
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showConnectionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2F),
        title: const Row(
          children: [
            Icon(Icons.bluetooth_searching, color: Colors.blue),
            SizedBox(width: 8),
            Text('OBD Bağlantısı', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B1538)),
            ),
            SizedBox(height: 16),
            Text(
              'OBD cihazına bağlanılıyor...\nLütfen bekleyin.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }
}