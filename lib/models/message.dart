import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String text;
  final String userId;
  final String displayName;
  final DateTime? createdAt;

  Message({
    required this.id,
    required this.text,
    required this.userId,
    required this.displayName,
    this.createdAt,
  });

  factory Message.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final createdAt = data['createdAt'];

    return Message(
      id: doc.id,
      text: data['text'] ?? '',
      userId: data['userId'] ?? '',
      displayName: data['displayName'] ?? 'Unknown',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
    );
  }
}