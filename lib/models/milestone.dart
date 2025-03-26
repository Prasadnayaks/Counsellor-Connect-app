import 'package:cloud_firestore/cloud_firestore.dart';

class Milestone {
  final String id;
  final String goalId;
  final String title;
  final bool isCompleted;
  final DateTime? completedAt;
  String? userId;

  Milestone({
    required this.id,
    required this.goalId,
    required this.title,
    this.isCompleted = false,
    this.completedAt,
    this.userId,
  });

  // Factory constructor to create a Milestone from a Map
  factory Milestone.fromMap(Map<String, dynamic> map, String documentId) {
    return Milestone(
      id: documentId,
      goalId: map['goalId'] ?? '',
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
      userId: map['userId'],
    );
  }

  // Convert a Milestone to a Map
  Map<String, dynamic> toMap() {
    return {
      'goalId': goalId,
      'title': title,
      'isCompleted': isCompleted,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'userId': userId,
    };
  }

  // Factory constructor to create a Milestone from a DocumentSnapshot
  factory Milestone.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Milestone.fromMap(data, snapshot.id);
  }
}

