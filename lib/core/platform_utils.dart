import 'dart:io';
import 'package:flutter/foundation.dart';

class PlatformUtils {
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isMobile => isAndroid || isIOS;
  static bool get isWeb => kIsWeb;
  static bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  // Bluetooth desteği kontrolü
  static bool get supportsBluetoothClassic => isAndroid;
  static bool get supportsBLE => isMobile;
  static bool get supportsWiFi => true;

  // Platform özel özellikler
  static String get platformName {
    if (kIsWeb) return 'Web';
    return Platform.operatingSystem;
  }

  static String get platformVersion {
    if (kIsWeb) return 'Web';
    return Platform.operatingSystemVersion;
  }

  // OBD bağlantı türü önerileri
  static List<String> get recommendedConnectionTypes {
    final types = <String>[];
    
    if (supportsBLE) types.add('BLE');
    if (supportsBluetoothClassic) types.add('Classic Bluetooth');
    if (supportsWiFi) types.add('WiFi');
    
    return types;
  }

  // Platform özel konfigürasyon
  static Map<String, dynamic> get platformConfig {
    return {
      'platform': platformName,
      'version': platformVersion,
      'isMobile': isMobile,
      'isWeb': isWeb,
      'isDesktop': isDesktop,
      'bluetooth_classic': supportsBluetoothClassic,
      'bluetooth_le': supportsBLE,
      'wifi': supportsWiFi,
    };
  }
}