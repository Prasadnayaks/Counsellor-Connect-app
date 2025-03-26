import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String title;
  final DateTime dateTime;
  final String userId;
  final String counselorId;
  final String counselorName;
  final String? notes;
  final bool isCompleted;
  final String? description;

  Appointment({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.userId,
    required this.counselorId,
    required this.counselorName,
    this.notes,
    this.isCompleted = false,
    this.description,
  });

  // Convert Appointment to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'dateTime': Timestamp.fromDate(dateTime),
      'userId': userId,
      'counselorId': counselorId,
      'counselorName': counselorName,
      'notes': notes,
      'isCompleted': isCompleted,
      'description': description,
    };
  }

  // Create Appointment from Firestore document
  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
      counselorId: map['counselorId'] ?? '',
      counselorName: map['counselorName'] ?? '',
      notes: map['notes'],
      isCompleted: map['isCompleted'] ?? false,
      description: map['description'],
    );
  }
}

