import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splash_auto_app/app/splash_auto_app.dart';
import 'package:splash_auto_app/core/localization/app_text.dart';

void main() {
  test('locale resolution respects language preference order', () {
    const supported = [Locale('en'), Locale('es')];
    expect(resolveAppLocale([const Locale('es', 'MX')], supported), const Locale('es'));
    expect(resolveAppLocale([const Locale('fr'), const Locale('es')], supported), const Locale('es'));
    expect(resolveAppLocale([const Locale('ja')], supported), const Locale('en'));
  });

  for (final brightness in Brightness.values) {
    for (final width in [390.0, 1100.0]) {
      testWidgets('Spanish interface at $width in $brightness', (tester) async {
        final platform = tester.binding.platformDispatcher;
        platform.localesTestValue = [const Locale('es', 'MX')];
        platform.platformBrightnessTestValue = brightness;
        await tester.binding.setSurfaceSize(Size(width, 844));
        addTearDown(() {
          platform.clearLocalesTestValue();
          platform.clearPlatformBrightnessTestValue();
          tester.binding.setSurfaceSize(null);
        });
        await tester.pumpWidget(const SplashAutoApp());
        await tester.pumpAndSettle();
        expect(find.text('Cuidado profesional para tu vehículo.'), findsOneWidget);
        final context = tester.element(find.byType(Scaffold).first);
        expect(Theme.of(context).brightness, brightness);
        await tester.tap(find.text('Solicitar encerado o pulido'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Revisar solicitud'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Revisar solicitud'));
        await tester.pumpAndSettle();
        expect(find.text('Ingresa tu nombre.'), findsOneWidget);
        await tester.ensureVisible(find.byIcon(Icons.event_outlined));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.event_outlined));
        await tester.pumpAndSettle();
        expect(find.text('Cancelar'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('device changes update language and theme without restarting', (tester) async {
    final platform = tester.binding.platformDispatcher;
    platform.localesTestValue = [const Locale('en')];
    platform.platformBrightnessTestValue = Brightness.light;
    addTearDown(() {
      platform.clearLocalesTestValue();
      platform.clearPlatformBrightnessTestValue();
    });
    await tester.pumpWidget(const SplashAutoApp());
    await tester.pumpAndSettle();
    expect(find.text('Professional care for your vehicle.'), findsOneWidget);
    platform.localesTestValue = [const Locale('es')];
    platform.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(find.text('Cuidado profesional para tu vehículo.'), findsOneWidget);
    expect(Theme.of(tester.element(find.byType(Scaffold).first)).brightness, Brightness.dark);
  });
}
