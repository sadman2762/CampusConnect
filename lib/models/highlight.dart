import 'package:cloud_firestore/cloud_firestore.dart';

class Highlight {
  final String id;
  final String messageId;
  final String userId;
  final int startOffset;
  final int endOffset;
  final String noteType; // "Quick Note" | "To Review" | "Resolved Concept"
  final String? noteText; // optional extra text the user can add
  final Timestamp createdAt;

  Highlight({
    required this.id,
    required this.messageId,
    required this.userId,
    required this.startOffset,
    required this.endOffset,
    required this.noteType,
    this.noteText,
    required this.createdAt,
  });

  factory Highlight.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Highlight(
      id: doc.id,
      messageId: data['messageId'],
      userId: data['userId'],
      startOffset: data['startOffset'],
      endOffset: data['endOffset'],
      noteType: data['noteType'],
      noteText: data['noteText'],
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toMap() => {
        'messageId': messageId,
        'userId': userId,
        'startOffset': startOffset,
        'endOffset': endOffset,
        'noteType': noteType,
        'noteText': noteText,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
