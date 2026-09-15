abstract final class BookingValidation {
  static bool hasRequiredText(String? value) =>
      value != null && value.trim().isNotEmpty;

  static String phoneDigits(String? value) =>
      value?.replaceAll(RegExp(r'\D'), '') ?? '';

  static bool hasValidPhone(String? value) => phoneDigits(value).length >= 10;
}
