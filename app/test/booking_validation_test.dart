import 'package:flutter_test/flutter_test.dart';
import 'package:splash_auto_app/features/booking/domain/booking_validation.dart';

void main() {
  group('BookingValidation', () {
    test('rejects missing and whitespace-only required text', () {
      expect(BookingValidation.hasRequiredText(null), isFalse);
      expect(BookingValidation.hasRequiredText('   '), isFalse);
      expect(BookingValidation.hasRequiredText('Tesla Model 3'), isTrue);
    });

    test('extracts digits from a formatted phone number', () {
      expect(
        BookingValidation.phoneDigits('(619) 555-0123'),
        '6195550123',
      );
    });

    test('requires at least ten phone digits', () {
      expect(BookingValidation.hasValidPhone('619-555'), isFalse);
      expect(BookingValidation.hasValidPhone('(619) 555-0123'), isTrue);
    });
  });
}
