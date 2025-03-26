import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime timestamp;
  final String type;
  final bool isRead;
  final String? referenceId;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    required this.isRead,
    this.referenceId,
  });

  // Convert NotificationModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type,
      'isRead': isRead,
      'referenceId': referenceId,
    };
  }

  // Create NotificationModel from Firestore document
  factory NotificationModel.fromMap(Map<String, dynamic> map, String documentId) {
    return NotificationModel(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      type: map['type'] ?? '',
      isRead: map['isRead'] ?? false,
      referenceId: map['referenceId'],
    );
  }
}

