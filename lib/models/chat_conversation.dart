import 'package:cloud_firestore/cloud_firestore.dart';

class ChatConversation {
  final String id;
  final List<String> participantIds;
  final String lastMessageContent;
  final DateTime lastMessageTime;
  final bool hasUnreadMessages;
  final String? conversationName;
  final String? userId;
  final String? counselorId;
  final String? lastMessage;

  ChatConversation({
    required this.id,
    this.participantIds = const [],
    this.lastMessageContent = '',
    required this.lastMessageTime,
    this.hasUnreadMessages = false,
    this.conversationName,
    this.userId,
    this.counselorId,
    this.lastMessage,
  });

  // Factory constructor to create a ChatConversation from a Map
  factory ChatConversation.fromMap(Map<String, dynamic> map, String documentId) {
    return ChatConversation(
      id: documentId,
      participantIds: map['participantIds'] != null
          ? List<String>.from(map['participantIds'])
          : [],
      lastMessageContent: map['lastMessageContent'] ?? '',
      lastMessageTime: (map['lastMessageTime'] as Timestamp).toDate(),
      hasUnreadMessages: map['hasUnreadMessages'] ?? false,
      conversationName: map['conversationName'],
      userId: map['userId'],
      counselorId: map['counselorId'],
      lastMessage: map['lastMessage'],
    );
  }

  // Convert a ChatConversation to a Map
  Map<String, dynamic> toMap() {
    return {
      'participantIds': participantIds,
      'lastMessageContent': lastMessageContent,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'hasUnreadMessages': hasUnreadMessages,
      'conversationName': conversationName,
      'userId': userId,
      'counselorId': counselorId,
      'lastMessage': lastMessage,
    };
  }

  // Factory constructor to create a ChatConversation from a DocumentSnapshot
  factory ChatConversation.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return ChatConversation.fromMap(data, snapshot.id);
  }
}

