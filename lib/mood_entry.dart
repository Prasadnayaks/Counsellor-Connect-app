import 'package:cloud_firestore/cloud_firestore.dart';

class MoodEntry {
  final String id;
  final String mood;
  final String note;
  final DateTime timestamp;
  String? userId;

  MoodEntry({
    required this.id,
    required this.mood,
    required this.note,
    required this.timestamp,
    this.userId,
  });

  // Factory constructor to create a MoodEntry from a Map
  factory MoodEntry.fromMap(Map<String, dynamic> map, String documentId) {
    return MoodEntry(
      id: documentId,
      mood: map['mood'] ?? '',
      note: map['note'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      userId: map['userId'],
    );
  }

  // Convert a MoodEntry to a Map
  Map<String, dynamic> toMap() {
    return {
      'mood': mood,
      'note': note,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId,
    };
  }

  // Factory constructor to create a MoodEntry from a DocumentSnapshot
  factory MoodEntry.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return MoodEntry.fromMap(data, snapshot.id);
  }
}

