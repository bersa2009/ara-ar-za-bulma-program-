import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Global scaffold messenger key
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = 
      GlobalKey<ScaffoldMessengerState>();

  // Show success notification
  static void showSuccess(String message, {Duration? duration}) {
    _showSnackBar(
      message: message,
      backgroundColor: Colors.green.shade700,
      icon: Icons.check_circle,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  // Show error notification
  static void showError(String message, {Duration? duration}) {
    _showSnackBar(
      message: message,
      backgroundColor: Colors.red.shade700,
      icon: Icons.error,
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  // Show warning notification
  static void showWarning(String message, {Duration? duration}) {
    _showSnackBar(
      message: message,
      backgroundColor: Colors.orange.shade700,
      icon: Icons.warning,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  // Show info notification
  static void showInfo(String message, {Duration? duration}) {
    _showSnackBar(
      message: message,
      backgroundColor: Colors.blue.shade700,
      icon: Icons.info,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  // Show OBD specific notifications
  static void showOBDConnected() {
    showSuccess(AppConstants.successMessages['connection_established']!);
  }

  static void showOBDDisconnected() {
    showWarning('OBD bağlantısı kesildi');
  }

  static void showOBDError(String error) {
    showError('OBD Hatası: $error');
  }

  static void showDataReceived(int count) {
    showInfo('$count veri paketi alındı');
  }

  static void showDTCCleared() {
    showSuccess(AppConstants.successMessages['dtc_cleared']!);
  }

  static void showAnalysisComplete(int faultCount) {
    showSuccess('$faultCount arıza analiz edildi');
  }

  static void showReportSaved(String format) {
    showSuccess('Rapor $format formatında kaydedildi');
  }

  static void showUpdateAvailable() {
    showInfo('Yeni güncelleme mevcut');
  }

  static void showMaintenanceReminder(String item, int remainingKm) {
    showWarning('$item: $remainingKm km kaldı');
  }

  // Private helper method
  static void _showSnackBar({
    required String message,
    required Color backgroundColor,
    required IconData icon,
    required Duration duration,
  }) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'Kapat',
          textColor: Colors.white70,
          onPressed: () => messenger.hideCurrentSnackBar(),
        ),
      ),
    );
  }

  // Show loading dialog
  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(AppConstants.cardBackgroundValue),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(AppConstants.primaryRedValue),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // Show confirmation dialog
  static Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Evet',
    String cancelText = 'Hayır',
    Color confirmColor = Colors.red,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(AppConstants.cardBackgroundValue),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText,
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
            ),
            child: Text(
              confirmText,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Show maintenance notification
  static void showMaintenanceNotification({
    required String item,
    required int currentKm,
    required int nextServiceKm,
  }) {
    final remainingKm = nextServiceKm - currentKm;
    
    if (remainingKm <= 0) {
      showError('$item bakımı gecikmiş! (${-remainingKm} km geçmiş)');
    } else if (remainingKm <= 1000) {
      showWarning('$item bakımı yaklaştı! ($remainingKm km kaldı)');
    } else if (remainingKm <= 2000) {
      showInfo('$item bakımını unutmayın ($remainingKm km kaldı)');
    }
  }
}