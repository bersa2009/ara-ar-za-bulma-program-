import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PreferredTransport { wifi, ble, classic }

class AppSettings extends ChangeNotifier {
  AppSettings();

  Locale _locale = const Locale('tr');
  ThemeMode _themeMode = ThemeMode.system;
  PreferredTransport _preferredTransport = PreferredTransport.ble;
  bool _ttsEnabled = true;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  PreferredTransport get preferredTransport => _preferredTransport;
  bool get ttsEnabled => _ttsEnabled;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final lang = sp.getString('lang') ?? 'tr';
    final theme = sp.getString('theme') ?? 'system';
    final transport = sp.getString('transport') ?? 'ble';
    _ttsEnabled = sp.getBool('tts') ?? true;
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
}

