import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splash_auto_app/features/booking/presentation/booking_screen.dart';

void main() {
  Future<void> openPicker(WidgetTester tester) async {
    final button = find.byIcon(Icons.event_outlined);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets('Saturday opens on Monday and cancel leaves date unset',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: BookingScreen(now: () => DateTime(2026, 9, 19))),
    ));
    await openPicker(tester);
    final picker = tester.widget<CalendarDatePicker>(find.byType(CalendarDatePicker));
    expect(picker.initialDate, DateTime(2026, 9, 21));
    expect(picker.selectableDayPredicate!(DateTime(2026, 9, 20)), isFalse);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a date'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('selecting a date clears its inline error and preserves it',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: BookingScreen(now: () => DateTime(2026, 9, 19))),
    ));
    await tester.ensureVisible(find.text('Review request'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review request'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a preferred appointment date.'), findsOneWidget);
    await openPicker(tester);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a preferred appointment date.'), findsNothing);
    expect(find.text('9/21/2026'), findsOneWidget);
    await openPicker(tester);
    expect(
      tester.widget<CalendarDatePicker>(find.byType(CalendarDatePicker)).initialDate,
      DateTime(2026, 9, 21),
    );
  });

  testWidgets('outdated selection does not prevent reopening the calendar',
      (tester) async {
    var today = DateTime(2026, 9, 19);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: BookingScreen(now: () => today)),
    ));
    await openPicker(tester);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    today = DateTime(2026, 9, 22);
    await openPicker(tester);
    expect(
      tester.widget<CalendarDatePicker>(find.byType(CalendarDatePicker)).initialDate,
      DateTime(2026, 9, 23),
    );
    expect(tester.takeException(), isNull);
  });
}
