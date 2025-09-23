import 'package:flutter/material.dart';

class ErrorHandler {
  static void showError(BuildContext context, String error) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getLocalizedError(error),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Kapat',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static String _getLocalizedError(String error) {
    // Türkçe hata mesajları
    final errorMap = {
      'BLE not open': 'Bluetooth bağlantısı açık değil',
      'Socket not open': 'Ağ bağlantısı açık değil', 
      'SPP not open': 'Bluetooth seri bağlantısı açık değil',
      'Transport not open': 'Bağlantı açık değil',
      'Unknown error': 'Bilinmeyen hata',
      'Connection timeout': 'Bağlantı zaman aşımı',
      'Device not found': 'Cihaz bulunamadı',
      'Permission denied': 'İzin reddedildi',
    };

    for (final entry in errorMap.entries) {
      if (error.contains(entry.key)) {
        return entry.value;
      }
    }
    
    return error;
  }

  static Widget buildErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hata',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getLocalizedError(error),
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}