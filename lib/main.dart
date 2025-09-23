import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/screens/home_screen.dart' as menu;
import 'ui/screens/settings.dart';
import 'ui/theme.dart';
import 'ui/screens/scan.dart';
import 'ui/screens/placeholders.dart';
import 'ui/screens/welcome.dart';

void main() {
  runApp(const StrcarApp());
}

class StrcarApp extends StatelessWidget {
  const StrcarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: _AppRoot());
  }
}

class _AppRoot extends ConsumerWidget {
  const _AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    return MaterialApp(
      title: 'Strcar OBD Scanner',
      theme: AppThemes.light(colorblind: settings.colorblindFriendly),
      darkTheme: AppThemes.dark(colorblind: settings.colorblindFriendly),
      themeMode: settings.themeMode,
      supportedLocales: const [Locale('tr'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/welcome',
      routes: {
        '/welcome': (_) => const WelcomeScreen(),
        '/home': (_) => const menu.HomeScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/scan': (_) => const ScanScreen(),
        '/clear': (_) => const PlaceholderScreen(title: 'Arıza Kodu Temizleme'),
        '/battery': (_) => const PlaceholderScreen(title: 'Akü Ömrü'),
        '/realtime': (_) => const PlaceholderScreen(title: 'Gerçek Zamanlı Veri'),
        '/display': (_) => const PlaceholderScreen(title: 'Görünen Bilgiler'),
        '/maintenance': (_) => const PlaceholderScreen(title: 'Muayene ve Bakım'),
        '/o2sensor': (_) => const PlaceholderScreen(title: 'O2 Sensörü İzleme'),
        '/vin': (_) => const PlaceholderScreen(title: 'Araç Kimlik Numarası (VIN)'),
        '/dtc_list': (_) => const PlaceholderScreen(title: 'Genel DTC Listesi'),
      },
    );
  }
}

 

