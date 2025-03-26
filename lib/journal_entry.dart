import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final List<String>? tags;
  final String mood;
  String? userId;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    this.tags = const [],
    this.mood = '',
    this.userId,
  });

  // Factory constructor to create a JournalEntry from a Map
  factory JournalEntry.fromMap(Map<String, dynamic> map, String documentId) {
    return JournalEntry(
      id: documentId,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      tags: map['tags'] != null ? List<String>.from(map['tags']) : [],
      mood: map['mood'] ?? '',
      userId: map['userId'],
    );
  }

  // Convert a JournalEntry to a Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'tags': tags,
      'mood': mood,
      'userId': userId,
    };
  }

  // Factory constructor to create a JournalEntry from a DocumentSnapshot
  factory JournalEntry.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return JournalEntry.fromMap(data, snapshot.id);
  }
}

