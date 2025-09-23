import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/screens/home_screen.dart' as menu;
import 'ui/screens/settings.dart';
import 'ui/theme.dart';
import 'ui/screens/scan.dart';
import 'ui/screens/placeholders.dart';
import 'ui/screens/fault_detection_screen.dart';
import 'ui/screens/live_data_screen.dart';
import 'ui/screens/sensor_info_screen.dart';
import 'ui/screens/ai_analysis_screen.dart';
import 'ui/screens/battery_test_screen.dart';
import 'ui/screens/maintenance_screen.dart';
import 'ui/screens/vin_screen.dart';
import 'ui/screens/error_reporting_screen.dart';
import 'ui/screens/update_screen.dart';

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
      initialRoute: '/home',
      routes: {
        '/home': (_) => const menu.HomeScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/scan': (_) => const ScanScreen(),
        '/fault_detection': (_) => const FaultDetectionScreen(),
        '/live_data': (_) => const LiveDataScreen(),
        '/sensor_info': (_) => const SensorInfoScreen(),
        '/ai_analysis': (_) => const AIAnalysisScreen(),
        '/battery_test': (_) => const BatteryTestScreen(),
        '/maintenance': (_) => const MaintenanceScreen(),
        '/vin': (_) => const VinScreen(),
        '/error_reporting': (_) => const ErrorReportingScreen(),
        '/update': (_) => const UpdateScreen(),
        '/performance': (_) => const PlaceholderScreen(title: 'Performans'),
        '/reports': (_) => const PlaceholderScreen(title: 'Raporlar'),
      },
    );
  }
}

 

