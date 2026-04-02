import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  final String ratingId;
  final String bookingId;
  final String customerId;
  final String driverId;
  final double ratingValue;
  final String reviewText;
  final List<String> selectedTags;
  final DateTime createdAt;

  RatingModel({
    required this.ratingId,
    required this.bookingId,
    required this.customerId,
    required this.driverId,
    required this.ratingValue,
    required this.reviewText,
    required this.selectedTags,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'ratingId': ratingId,
      'bookingId': bookingId,
      'customerId': customerId,
      'driverId': driverId,
      'ratingValue': ratingValue,
      'reviewText': reviewText,
      'selectedTags': selectedTags,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory RatingModel.fromMap(Map<String, dynamic> map) {
    return RatingModel(
      ratingId: map['ratingId'] ?? '',
      bookingId: map['bookingId'] ?? '',
      customerId: map['customerId'] ?? '',
      driverId: map['driverId'] ?? '',
      ratingValue: (map['ratingValue'] as num).toDouble(),
      reviewText: map['reviewText'] ?? '',
      selectedTags: List<String>.from(map['selectedTags'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
