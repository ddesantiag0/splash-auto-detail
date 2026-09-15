import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splash_auto_app/app/splash_auto_app.dart';

void main() {
  testWidgets('customer can open the appointment request flow', (tester) async {
    await tester.pumpWidget(const SplashAutoApp());

    expect(find.text('Professional care for your vehicle.'), findsOneWidget);
    await tester.tap(find.text('Request wax or polishing'));
    await tester.pumpAndSettle();

    expect(find.text('Request wax or polishing'), findsOneWidget);
    expect(find.byType(Form), findsOneWidget);
  });
}
