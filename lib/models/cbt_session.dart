import 'package:cloud_firestore/cloud_firestore.dart';

class CBTSession {
  final String id;
  final String title;
  final String technique;
  final Map<String, dynamic> data;
  final DateTime dateTime;
  final String userId;
  final int durationMinutes;
  final String notes;
  final String insights;

  CBTSession({
    required this.id,
    required this.title,
    required this.technique,
    required this.data,
    required this.dateTime,
    required this.userId,
    required this.durationMinutes,
    required this.notes,
    required this.insights,
  });

  // Convert CBTSession to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'technique': technique,
      'data': data,
      'dateTime': Timestamp.fromDate(dateTime),
      'userId': userId,
      'durationMinutes': durationMinutes,
      'notes': notes,
      'insights': insights,
    };
  }

  // Create CBTSession from Firestore document
  factory CBTSession.fromMap(Map<String, dynamic> map, String id) {
    return CBTSession(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      technique: map['technique'] ?? '',
      data: map['data'] ?? {},
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
      durationMinutes: map['durationMinutes'] ?? 0,
      notes: map['notes'] ?? '',
      insights: map['insights'] ?? '',
    );
  }

  DateTime get timestamp => timestamp;
}

