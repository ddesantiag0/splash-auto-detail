import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/localization/app_text.dart';

import '../core/theme/app_theme.dart';
import '../features/shell/presentation/app_shell.dart';

class SplashAutoApp extends StatelessWidget {
  const SplashAutoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splash Auto Detail',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      supportedLocales: const [Locale('en'), Locale('es')],
      localeListResolutionCallback: resolveAppLocale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AppShell(),
    );
  }
}
