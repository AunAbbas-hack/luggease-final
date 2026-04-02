import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String paymentId;
  final String bookingId;
  final double amount;
  final String method;
  final String status;
  final DateTime timestamp;

  PaymentModel({
    required this.paymentId,
    required this.bookingId,
    required this.amount,
    required this.method,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'paymentId': paymentId,
      'bookingId': bookingId,
      'amount': amount,
      'method': method,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      paymentId: map['paymentId'] ?? '',
      bookingId: map['bookingId'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      method: map['method'] ?? '',
      status: map['status'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
