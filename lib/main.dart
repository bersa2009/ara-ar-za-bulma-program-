import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/screens/home.dart';
import 'ui/screens/settings.dart';

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
    // For brevity, using defaults; Settings screen controls theme/lang.
    return MaterialApp(
      title: 'Strcar OBD Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      supportedLocales: const [Locale('tr'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeScreen(),
      routes: {
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}

 

