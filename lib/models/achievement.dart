import 'package:cloud_firestore/cloud_firestore.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String category;
  final int points;
  final String iconPath;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final Map<String, dynamic> criteria;
  final int progress;
  final int targetValue;
  String? userId;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.points,
    required this.iconPath,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.criteria,
    this.progress = 0,
    required this.targetValue,
    this.userId,
  });

  // Factory constructor to create an Achievement from a Map
  factory Achievement.fromMap(Map<String, dynamic> map, String documentId) {
    return Achievement(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      points: map['points'] ?? 0,
      iconPath: map['iconPath'] ?? '',
      isUnlocked: map['isUnlocked'] ?? false,
      unlockedAt: map['unlockedAt'] != null
          ? (map['unlockedAt'] as Timestamp).toDate()
          : null,
      criteria: map['criteria'] ?? {},
      progress: map['progress'] ?? 0,
      targetValue: map['targetValue'] ?? 1,
      userId: map['userId'],
    );
  }

  // Convert an Achievement to a Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'points': points,
      'iconPath': iconPath,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
      'criteria': criteria,
      'progress': progress,
      'targetValue': targetValue,
      'userId': userId,
    };
  }

  // Factory constructor to create an Achievement from a DocumentSnapshot
  factory Achievement.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Achievement.fromMap(data, snapshot.id);
  }

  get icon => null;

  get color => null;

  get dateUnlocked => null;
}

