import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String pspReference;
  final String resultCode;
  final String status;
  final DateTime updatedAt;

  Payment({
    required this.pspReference,
    required this.resultCode,
    required this.status,
    required this.updatedAt,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      pspReference: map['pspReference'] ?? '',
      resultCode: map['resultCode'] ?? '',
      status: map['status'] ?? '',
      updatedAt:
          map['updatedAt'] != null
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Payment('
        'pspReference: $pspReference, '
        'resultCode: $resultCode, '
        'status: $status, '
        'updatedAt: $updatedAt'
        ')';
  }
}
