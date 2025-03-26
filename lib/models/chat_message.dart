import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? attachmentUrl;
  final String messageType;
  final String? conversationId;
  String? userId;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.attachmentUrl,
    this.messageType = 'text',
    this.conversationId,
    this.userId,
  });

  // Factory constructor to create a ChatMessage from a Map
  factory ChatMessage.fromMap(Map<String, dynamic> map, String documentId) {
    return ChatMessage(
      id: documentId,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      attachmentUrl: map['attachmentUrl'],
      messageType: map['messageType'] ?? 'text',
      conversationId: map['conversationId'],
      userId: map['userId'],
    );
  }

  // Convert a ChatMessage to a Map
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'attachmentUrl': attachmentUrl,
      'messageType': messageType,
      'conversationId': conversationId,
      'userId': userId,
    };
  }

  // Factory constructor to create a ChatMessage from a DocumentSnapshot
  factory ChatMessage.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return ChatMessage.fromMap(data, snapshot.id);
  }
}

