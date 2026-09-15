import 'package:flutter_test/flutter_test.dart';
import 'package:splash_auto_app/features/booking/domain/booking_draft.dart';

void main() {
  group('BookingDraft', () {
    test('is complete with customer, vehicle, and a valid phone number', () {
      final draft = BookingDraft(
        service: DetailService.wax,
        vehicle: '2022 Tesla Model 3',
        customerName: 'David',
        phone: '(619) 555-0123',
        preferredDate: DateTime(2026, 9, 20),
      );

      expect(draft.isComplete, isTrue);
    });

    test('is incomplete when the phone number is too short', () {
      final draft = BookingDraft(
        service: DetailService.polishing,
        vehicle: '2016 Kia Optima',
        customerName: 'David',
        phone: '619-555',
        preferredDate: DateTime(2026, 9, 20),
      );

      expect(draft.isComplete, isFalse);
    });

    test('is incomplete when required text fields contain only spaces', () {
      final draft = BookingDraft(
        service: DetailService.wax,
        vehicle: '   ',
        customerName: '   ',
        phone: '(619) 555-0123',
        preferredDate: DateTime(2026, 9, 20),
      );

      expect(draft.isComplete, isFalse);
    });
  });
}
