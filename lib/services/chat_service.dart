import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get or create a chat document between two users
  Future<String> getOrCreateChat(String user1Id, String user2Id) async {
    final chatQuery = await _firestore
        .collection('guidance_chats')
        .where('userIds', arrayContains: user1Id)
        .get();

    for (var doc in chatQuery.docs) {
      List users = doc['userIds'];
      if (users.contains(user2Id)) return doc.id;
    }

    // If no existing chat, create a new one
    final newChat = await _firestore.collection('guidance_chats').add({
      'userIds': [user1Id, user2Id],
      'createdAt': FieldValue.serverTimestamp(),
    });

    return newChat.id;
  }

  // Send a message to a chat
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    await _firestore
        .collection('guidance_chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': senderId,
      'timestamp': FieldValue.serverTimestamp(), // ✅ Added timestamp
      'seenBy': [], // 👁️ added here
      'reactions': {}, // 👈 initialize empty map for reactions
    });
  }

  // Listen to real-time messages in a chat
  Stream<QuerySnapshot> getMessagesStream(String chatId) {
    return _firestore
        .collection('guidance_chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp') // ✅ Order by timestamp
        .snapshots();
  }
}
