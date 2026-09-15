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

  testWidgets('invalid request shows required-field guidance', (tester) async {
    await tester.pumpWidget(const SplashAutoApp());

    await tester.tap(find.text('Request wax or polishing'));
    await tester.pumpAndSettle();
    final reviewButton = find.text('Review request');
    await tester.ensureVisible(reviewButton);
    await tester.pumpAndSettle();
    await tester.tap(reviewButton);
    await tester.pump();

    expect(
      find.text('Enter the vehicle year, make, and model.'),
      findsOneWidget,
    );
    expect(find.text('Enter your name.'), findsOneWidget);
    expect(find.text('Enter a valid 10-digit phone number.'), findsOneWidget);
    expect(find.text('Choose a preferred appointment date.'), findsOneWidget);
  });

  testWidgets('wide layout uses persistent navigation', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1100, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const SplashAutoApp());

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('compact layout uses bottom navigation', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const SplashAutoApp());

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });
}
