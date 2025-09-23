import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PreferredTransport { wifi, ble, classic }

class AppSettings extends ChangeNotifier {
  AppSettings();

  Locale _locale = const Locale('tr');
  ThemeMode _themeMode = ThemeMode.system;
  PreferredTransport _preferredTransport = PreferredTransport.ble;
  bool _ttsEnabled = true;
  bool _colorblindFriendly = false;
  bool _privacyConsent = false;
  String _vehicleBrand = 'renault';
  String _vehicleModel = 'Clio';
  int _vehicleYear = 2018;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  PreferredTransport get preferredTransport => _preferredTransport;
  bool get ttsEnabled => _ttsEnabled;
  bool get colorblindFriendly => _colorblindFriendly;
  bool get privacyConsent => _privacyConsent;
  String get vehicleBrand => _vehicleBrand;
  String get vehicleModel => _vehicleModel;
  int get vehicleYear => _vehicleYear;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final lang = sp.getString('lang') ?? 'tr';
    final theme = sp.getString('theme') ?? 'system';
    final transport = sp.getString('transport') ?? 'ble';
    _ttsEnabled = sp.getBool('tts') ?? true;
    _colorblindFriendly = sp.getBool('colorblind') ?? false;
    _privacyConsent = sp.getBool('privacy_consent') ?? false;
    _vehicleBrand = sp.getString('vehicle_brand') ?? _vehicleBrand;
    _vehicleModel = sp.getString('vehicle_model') ?? _vehicleModel;
    _vehicleYear = sp.getInt('vehicle_year') ?? _vehicleYear;
    _locale = Locale(lang);
    _themeMode = switch (theme) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
    _preferredTransport = switch (transport) {
      'wifi' => PreferredTransport.wifi,
      'classic' => PreferredTransport.classic,
      _ => PreferredTransport.ble,
    };
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('lang', locale.languageCode);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('theme', switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      _ => 'system',
    });
    notifyListeners();
  }

  Future<void> setPreferredTransport(PreferredTransport t) async {
    _preferredTransport = t;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('transport', switch (t) {
      PreferredTransport.wifi => 'wifi',
      PreferredTransport.classic => 'classic',
      _ => 'ble',
    });
    notifyListeners();
  }

  Future<void> setTtsEnabled(bool enabled) async {
    _ttsEnabled = enabled;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('tts', enabled);
    notifyListeners();
  }

  Future<void> setColorblindFriendly(bool enabled) async {
    _colorblindFriendly = enabled;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('colorblind', enabled);
    notifyListeners();
  }

  Future<void> setPrivacyConsent(bool accepted) async {
    _privacyConsent = accepted;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('privacy_consent', accepted);
    notifyListeners();
  }

  Future<void> setVehicleBrand(String brand) async {
    _vehicleBrand = brand;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('vehicle_brand', brand);
    notifyListeners();
  }

  Future<void> setVehicleModel(String model) async {
    _vehicleModel = model;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('vehicle_model', model);
    notifyListeners();
  }

  Future<void> setVehicleYear(int year) async {
    _vehicleYear = year;
    final sp = await SharedPreferences.getInstance();
    await sp.setInt('vehicle_year', year);
    notifyListeners();
  }
}

