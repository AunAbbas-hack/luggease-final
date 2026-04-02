import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<MessageModel>> getMessages(String bookingId) {
    return _db
        .collection('bookings')
        .doc(bookingId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> sendMessage(String bookingId, MessageModel message) async {
    try {
      await _db
          .collection('bookings')
          .doc(bookingId)
          .collection('messages')
          .add(message.toMap());
    } catch (e) {
      rethrow;
    }
  }
}
