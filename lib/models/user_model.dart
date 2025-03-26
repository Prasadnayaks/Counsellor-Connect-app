import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? id;
  String? name;
  String? role;
  int? age;
  String? goal;
  List<String>? selectedChallenges;
  String? supportStyle;
  Map<String, dynamic>? supportResponses;
  bool? onboardingCompleted;

  UserModel({
    this.id,
    this.name,
    this.role,
    this.age,
    this.goal,
    this.selectedChallenges,
    this.supportStyle,
    this.supportResponses,
    this.onboardingCompleted = false,
  });

// Factory constructor to create a UserModel from a Map
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'],
      role: map['role'],
      age: map['age'],
      goal: map['goal'],
      selectedChallenges: map['selectedChallenges'] != null
          ? List<String>.from(map['selectedChallenges'])
          : null,
      supportStyle: map['supportStyle'],
      supportResponses: map['supportResponses'],
      onboardingCompleted: map['onboardingCompleted'] ?? false,
    );
  }

// Convert a UserModel to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'age': age,
      'goal': goal,
      'selectedChallenges': selectedChallenges,
      'supportStyle': supportStyle,
      'supportResponses': supportResponses,
      'onboardingCompleted': onboardingCompleted,
    };
  }

// Factory constructor to create a UserModel from a DocumentSnapshot
  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserModel.fromMap(data, snapshot.id);
  }
}

