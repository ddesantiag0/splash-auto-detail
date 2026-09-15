enum DetailService {
  exterior('Exterior detail'),
  interior('Interior detail'),
  complete('Complete detail'),
  paintCorrection('Paint correction'),
  protection('Paint protection');

  const DetailService(this.label);

  final String label;
}

class BookingDraft {
  const BookingDraft({
    required this.service,
    required this.vehicle,
    required this.customerName,
    required this.phone,
    required this.preferredDate,
    this.notes = '',
  });

  final DetailService service;
  final String vehicle;
  final String customerName;
  final String phone;
  final DateTime preferredDate;
  final String notes;

  bool get isComplete =>
      vehicle.trim().isNotEmpty &&
      customerName.trim().isNotEmpty &&
      phone.replaceAll(RegExp(r'\D'), '').length >= 10;
}
