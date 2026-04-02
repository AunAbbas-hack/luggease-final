import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending,
  searching,
  accepted,
  onTheWay,
  arrived,
  started,
  completed,
  cancelled,
}

class LuggageItem {
  final String name;
  final int quantity;
  final String? imageUrl;

  LuggageItem({
    required this.name,
    required this.quantity,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }

  factory LuggageItem.fromMap(Map<String, dynamic> map) {
    return LuggageItem(
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 1,
      imageUrl: map['imageUrl'],
    );
  }
}

class BookingModel {
  final String bookingId;
  final String customerId;
  final String? driverId;
  final String pickupLocation;
  final String dropLocation;
  final String vehicleType;
  final double price;
  final BookingStatus status;
  final DateTime createdAt;

  // Updated Luggage Details
  final List<LuggageItem> items;
  
  // Real-time tracking fields
  final double? driverLat;
  final double? driverLng;

  // Cancellation fields
  final String? cancelledBy;
  final String? cancelReason;
  final DateTime? cancelledAt;

  BookingModel({
    required this.bookingId,
    required this.customerId,
    this.driverId,
    required this.pickupLocation,
    required this.dropLocation,
    required this.vehicleType,
    required this.price,
    required this.status,
    required this.createdAt,
    required this.items,
    this.driverLat,
    this.driverLng,
    this.cancelledBy,
    this.cancelReason,
    this.cancelledAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'customerId': customerId,
      'driverId': driverId,
      'pickupLocation': pickupLocation,
      'dropLocation': dropLocation,
      'vehicleType': vehicleType,
      'price': price,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'items': items.map((i) => i.toMap()).toList(),
      'driverLat': driverLat,
      'driverLng': driverLng,
      'cancelledBy': cancelledBy,
      'cancelReason': cancelReason,
      'cancelledAt': cancelledAt != null
          ? Timestamp.fromDate(cancelledAt!)
          : null,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      bookingId: map['bookingId'] ?? '',
      customerId: map['customerId'] ?? '',
      driverId: map['driverId'],
      pickupLocation: map['pickupLocation'] ?? '',
      dropLocation: map['dropLocation'] ?? '',
      vehicleType: map['vehicleType'] ?? '',
      price: (map['price'] as num).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BookingStatus.pending,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      items: (map['items'] as List? ?? [])
          .map((i) => LuggageItem.fromMap(i as Map<String, dynamic>))
          .toList(),
      driverLat: (map['driverLat'] as num?)?.toDouble(),
      driverLng: (map['driverLng'] as num?)?.toDouble(),
      cancelledBy: map['cancelledBy'],
      cancelReason: map['cancelReason'],
      cancelledAt: map['cancelledAt'] != null
          ? (map['cancelledAt'] as Timestamp).toDate()
          : null,
    );
  }
}
