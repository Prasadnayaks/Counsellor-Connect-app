import 'package:cloud_firestore/cloud_firestore.dart';

class Goal {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime targetDate;
  final List<String> milestoneIds;
  final bool isCompleted;
  final String category;
  String? userId;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.targetDate,
    this.milestoneIds = const [],
    this.isCompleted = false,
    required this.category,
    this.userId,
  });

  // Factory constructor to create a Goal from a Map
  factory Goal.fromMap(Map<String, dynamic> map, String documentId) {
    return Goal(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      targetDate: (map['targetDate'] as Timestamp).toDate(),
      milestoneIds: map['milestoneIds'] != null
          ? List<String>.from(map['milestoneIds'])
          : [],
      isCompleted: map['isCompleted'] ?? false,
      category: map['category'] ?? '',
      userId: map['userId'],
    );
  }

  // Convert a Goal to a Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'targetDate': Timestamp.fromDate(targetDate),
      'milestoneIds': milestoneIds,
      'isCompleted': isCompleted,
      'category': category,
      'userId': userId,
    };
  }

  // Factory constructor to create a Goal from a DocumentSnapshot
  factory Goal.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Goal.fromMap(data, snapshot.id);
  }
}

