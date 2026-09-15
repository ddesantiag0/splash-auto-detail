import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splash_auto_app/features/availability/wait_service.dart';
import 'package:splash_auto_app/features/availability/owner_screen.dart';

void main() {
  test('server time controls freshness even when device clock differs', () {
    final received = DateTime.utc(2030);
    final server = DateTime.utc(2026, 9, 15, 20);
    final snapshot = WaitSnapshot({'status': 'busy', 'wait_min': 45, 'wait_max': 60, 'updated_at': server.toIso8601String(), 'expires_at': server.add(const Duration(minutes: 30)).toIso8601String()}, server, received);
    expect(snapshot.status(received), 'busy');
    expect(snapshot.status(received.add(const Duration(minutes: 30))), 'unknown');
  });
  testWidgets('unconfigured owner page never exposes working update controls', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: OwnerScreen()));
    expect(find.text('Owner access is not connected yet.'), findsOneWidget);
    expect(find.text('Update wait'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
