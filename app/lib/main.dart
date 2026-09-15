import 'package:flutter/material.dart';

import 'app/splash_auto_app.dart';
import 'features/availability/wait_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await WaitService.initialize();
  } catch (_) {
    // Public screens remain available if the backend cannot initialize.
  }
  runApp(const SplashAutoApp());
}
