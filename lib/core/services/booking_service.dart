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

  /// Single booking document stream (customer listens after create; tracking screen).
  Stream<BookingModel?> watchBooking(String bookingId) {
    return _db.collection('bookings').doc(bookingId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return BookingModel.fromMap(snap.data()!);
    });
  }

  /// Driver public profile fields for UI (name, phone, vehicle, photo).
  Future<Map<String, dynamic>?> getDriverProfileMap(String driverUid) async {
    final doc = await _db.collection('drivers').doc(driverUid).get();
    if (!doc.exists) return null;
    return doc.data();
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

  /// Open requests: `pending` (current writes) and legacy `searching` docs.
  Stream<List<BookingModel>> getAvailableBookings() {
    return _db
        .collection('bookings')
        .where('status', whereIn: [
          BookingStatus.pending.name,
          BookingStatus.searching.name,
        ])
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

  /// Cancels booking with audit fields (customer or driver).
  Future<void> cancelBooking(
    String bookingId, {
    required String cancelledByUid,
    String? reason,
  }) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.cancelled.name,
      'cancelledBy': cancelledByUid,
      'cancelReason': reason ?? 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }

  /// Writes live driver position (assigned driver only — enforce in app + rules).
  Future<void> updateDriverLocation(
    String bookingId,
    double lat,
    double lng,
  ) async {
    await _db.collection('bookings').doc(bookingId).update({
      'driverLat': lat,
      'driverLng': lng,
      'locationUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Allowed next status for assigned driver after accept (no `started` in this flow).
  static bool _isDriverAdvanceAllowed(BookingStatus current, BookingStatus next) {
    return (current == BookingStatus.accepted && next == BookingStatus.onTheWay) ||
        (current == BookingStatus.onTheWay && next == BookingStatus.arrived);
  }

  /// Driver-only: `accepted` → `onTheWay` → `arrived`.
  Future<void> advanceDriverBookingStatus({
    required String bookingId,
    required String driverUid,
    required BookingStatus nextStatus,
  }) async {
    final snap = await _db.collection('bookings').doc(bookingId).get();
    if (!snap.exists || snap.data() == null) {
      throw StateError('Booking not found');
    }
    final booking = BookingModel.fromMap(snap.data()!);
    if (booking.driverId != driverUid) {
      throw StateError('Not the assigned driver');
    }
    if (!_isDriverAdvanceAllowed(booking.status, nextStatus)) {
      throw StateError('Invalid status transition');
    }
    await _db.collection('bookings').doc(bookingId).update({
      'status': nextStatus.name,
    });
  }
}
