import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/shell/presentation/app_shell.dart';

class SplashAutoApp extends StatelessWidget {
  const SplashAutoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splash Auto Detail',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AppShell(),
    );
  }
}
