import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_settings.dart';

final appSettingsProvider = ChangeNotifierProvider<AppSettings>((ref) {
  final settings = AppSettings();
  settings.load();
  return settings;
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          ListTile(title: const Text('Dil'), subtitle: Text(settings.locale.languageCode.toUpperCase())),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(spacing: 8, children: [
              ChoiceChip(
                label: const Text('TR'),
                selected: settings.locale.languageCode == 'tr',
                onSelected: (_) => settings.setLocale(const Locale('tr')),
              ),
              ChoiceChip(
                label: const Text('EN'),
                selected: settings.locale.languageCode == 'en',
                onSelected: (_) => settings.setLocale(const Locale('en')),
              ),
            ]),
          ),
          const Divider(),
          ListTile(title: const Text('Tema')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(spacing: 8, children: [
              ChoiceChip(
                label: const Text('Sistem'),
                selected: settings.themeMode == ThemeMode.system,
                onSelected: (_) => settings.setThemeMode(ThemeMode.system),
              ),
              ChoiceChip(
                label: const Text('Açık'),
                selected: settings.themeMode == ThemeMode.light,
                onSelected: (_) => settings.setThemeMode(ThemeMode.light),
              ),
              ChoiceChip(
                label: const Text('Koyu'),
                selected: settings.themeMode == ThemeMode.dark,
                onSelected: (_) => settings.setThemeMode(ThemeMode.dark),
              ),
            ]),
          ),
          const Divider(),
          ListTile(title: const Text('Tercih edilen bağlantı')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(spacing: 8, children: [
              ChoiceChip(
                label: const Text('BLE'),
                selected: settings.preferredTransport == PreferredTransport.ble,
                onSelected: (_) => settings.setPreferredTransport(PreferredTransport.ble),
              ),
              ChoiceChip(
                label: const Text('Classic'),
                selected: settings.preferredTransport == PreferredTransport.classic,
                onSelected: (_) => settings.setPreferredTransport(PreferredTransport.classic),
              ),
              ChoiceChip(
                label: const Text('WiFi'),
                selected: settings.preferredTransport == PreferredTransport.wifi,
                onSelected: (_) => settings.setPreferredTransport(PreferredTransport.wifi),
              ),
            ]),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('TTS (Sesli okuma)'),
            value: settings.ttsEnabled,
            onChanged: (v) => settings.setTtsEnabled(v),
          ),
        ],
      ),
    );
  }
}

