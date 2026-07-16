/// Minimal result of `POST /bookings` — enough to drive the payment step.
class CreatedBooking {
  final String id;
  final double totalPrice;
  final String? transactionUuid;
  final String status; // PENDING | CONFIRMED | ...
  final String paymentMethod; // ESEWA | PAY_AT_HOTEL
  final String paymentStatus; // PENDING | PAID | FAILED

  const CreatedBooking({
    required this.id,
    required this.totalPrice,
    required this.transactionUuid,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
  });

  factory CreatedBooking.fromJson(Map<String, dynamic> json) {
    return CreatedBooking(
      id: (json['_id'] ?? json['id']).toString(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      transactionUuid: json['transactionUuid'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      paymentMethod: json['paymentMethod'] as String? ?? 'PAY_AT_HOTEL',
      paymentStatus: json['paymentStatus'] as String? ?? 'PENDING',
    );
  }
}

/// Signed eSewa form payload returned by `POST /payments/esewa/initiate`.
class EsewaInitiation {
  final String formUrl;
  final Map<String, String> fields;

  const EsewaInitiation({required this.formUrl, required this.fields});

  factory EsewaInitiation.fromJson(Map<String, dynamic> json) {
    final rawFields = json['fields'] as Map<String, dynamic>? ?? {};
    return EsewaInitiation(
      formUrl: json['formUrl'] as String? ?? '',
      fields: rawFields.map((k, v) => MapEntry(k, v.toString())),
    );
  }
}
