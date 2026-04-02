import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createBooking(BookingModel booking) async {
    try {
      await _db
          .collection('bookings')
          .doc(booking.bookingId)
          .set(booking.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<BookingModel>> getCustomerBookings(String customerId) {
    return _db
        .collection('bookings')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookingModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Stream<List<BookingModel>> getAvailableBookings() {
    return _db
        .collection('bookings')
        .where('status', isEqualTo: BookingStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookingModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status, {
    String? driverId,
  }) async {
    try {
      final Map<String, dynamic> data = {'status': status.name};
      if (driverId != null) {
        data['driverId'] = driverId;
      }
      await _db.collection('bookings').doc(bookingId).update(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBookingPrice(String bookingId, double newPrice) async {
    try {
      await _db.collection('bookings').doc(bookingId).update({'price': newPrice});
    } catch (e) {
      rethrow;
    }
  }
}
