import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../mood_entry.dart';
import '../journal_entry.dart';
import '../appointment.dart';
import '../models/chat_message.dart';
import '../models/chat_conversation.dart';
import '../models/notification.dart';
import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/achievement.dart';
import '../models/cbt_session.dart';
import 'dart:async';

class FirebaseService {
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  late CollectionReference _usersCollection;
  late CollectionReference _moodEntriesCollection;
  late CollectionReference _journalEntriesCollection;
  late CollectionReference _appointmentsCollection;
  late CollectionReference _chatMessagesCollection;
  late CollectionReference _chatConversationsCollection;
  late CollectionReference _notificationsCollection;
  late CollectionReference _goalsCollection;
  late CollectionReference _milestonesCollection;
  late CollectionReference _achievementsCollection;
  late CollectionReference _cbtSessionsCollection;
  late CollectionReference _counselorStatusCollection;

  // Current user ID
  String? _currentUserId;
  String get currentUserId => _currentUserId ?? 'demo_user';

  // Initialization flag
  bool _isInitialized = false;
  final Completer<void> _initCompleter = Completer<void>();
  Future<void> get initialized => _initCompleter.future;

  // Initialize Firebase
  Future<void> init() async {
    if (_isInitialized) {
      return _initCompleter.future;
    }

    _isInitialized = true;

    try {
      await Firebase.initializeApp();

      // Initialize collections
      _usersCollection = _firestore.collection('users');
      _moodEntriesCollection = _firestore.collection('mood_entries');
      _journalEntriesCollection = _firestore.collection('journal_entries');
      _appointmentsCollection = _firestore.collection('appointments');
      _chatMessagesCollection = _firestore.collection('chat_messages');
      _chatConversationsCollection = _firestore.collection('chat_conversations');
      _notificationsCollection = _firestore.collection('notifications');
      _goalsCollection = _firestore.collection('goals');
      _milestonesCollection = _firestore.collection('milestones');
      _achievementsCollection = _firestore.collection('achievements');
      _cbtSessionsCollection = _firestore.collection('cbt_sessions');
      _counselorStatusCollection = _firestore.collection('counselor_status');

      // Check if user is signed in
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        _currentUserId = currentUser.uid;
        debugPrint('User already signed in with ID: $_currentUserId');
      } else {
        // Try to create anonymous user if not signed in
        try {
          final anonymousUser = await _auth.signInAnonymously();
          _currentUserId = anonymousUser.user?.uid;
          debugPrint('Anonymous sign-in successful with ID: $_currentUserId');
        } catch (authError) {
          // If anonymous auth fails, use a demo user ID
          debugPrint('Anonymous sign-in failed: $authError');
          _currentUserId = 'demo_user';
          debugPrint('Using demo user ID: $_currentUserId');
        }
      }

      debugPrint('Firebase initialized with user ID: $_currentUserId');
      _initCompleter.complete();
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
      // Set a default user ID to allow the app to function in demo mode
      _currentUserId = 'demo_user';
      debugPrint('Using demo user ID after error: $_currentUserId');
      _initCompleter.complete();
    }
  }

  // User methods
  Future<UserModel?> getUser() async {
    try {
      final doc = await _usersCollection.doc(currentUserId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }

      // If user doesn't exist yet, create a default user
      final defaultUser = UserModel(
          id: currentUserId,
          role: 'student',
          name: 'User',
          onboardingCompleted: false
      );
      await saveUser(defaultUser);
      return defaultUser;
    } catch (e) {
      debugPrint('Error getting user: $e');
      // Return a default user if there's an error
      return UserModel(
          id: currentUserId,
          role: 'student',
          name: 'User',
          onboardingCompleted: false
      );
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user by ID: $e');
      return null;
    }
  }

  // Get all counselors
  Future<List<UserModel>> getAllCounselors() async {
    try {
      final snapshot = await _usersCollection
          .where('role', isEqualTo: 'counselor')
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting all counselors: $e');
      return [];
    }
  }

  // Get all non-counselors (students, staff, etc.)
  Future<List<UserModel>> getAllNonCounselors() async {
    try {
      final snapshot = await _usersCollection
          .where('role', isNotEqualTo: 'counselor')
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting all non-counselors: $e');
      return [];
    }
  }

  // Get all staff
  Future<List<UserModel>> getAllStaff() async {
    try {
      final snapshot = await _usersCollection
          .where('role', whereIn: ['teaching_staff', 'non_teaching_staff'])
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting all staff: $e');
      return [];
    }
  }

  // Rest of the methods remain unchanged
  Future<void> saveUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toMap());
    } catch (e) {
      debugPrint('Error saving user: $e');
      // Don't rethrow in demo mode
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  Future<void> updateUserRole(String role) async {
    try {
      final user = await getUser();
      if (user != null) {
        // If user was a counselor before, update status to offline
        if (user.role == 'counselor') {
          await updateCounselorStatus(false);
        }

        user.role = role;
        await saveUser(user);

        // If role is counselor, update counselor status
        if (role == 'counselor') {
          await updateCounselorStatus(true);
        }
      } else {
        await saveUser(UserModel(
            id: currentUserId,
            role: role,
            name: 'User',
            onboardingCompleted: false
        ));

        // If role is counselor, update counselor status
        if (role == 'counselor') {
          await updateCounselorStatus(true);
        }
      }
    } catch (e) {
      debugPrint('Error updating user role: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  Future<void> updateUserName(String name) async {
    try {
      final user = await getUser();
      if (user != null) {
        user.name = name;
        await saveUser(user);

        // If user is a counselor, update the name in counselor status
        if (user.role == 'counselor') {
          await _counselorStatusCollection.doc(currentUserId).update({
            'name': name,
          });
        }
      }
    } catch (e) {
      debugPrint('Error updating user name: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  Future<void> updateUserDetails({
    String? name,
    int? age,
    String? goal,
  }) async {
    try {
      final user = await getUser();
      if (user != null) {
        if (name != null) user.name = name;
        if (age != null) user.age = age;
        if (goal != null) user.goal = goal;
        await saveUser(user);

        // If user is a counselor and name was updated, update counselor status
        if (user.role == 'counselor' && name != null) {
          await _counselorStatusCollection.doc(currentUserId).update({
            'name': name,
          });
        }
      }
    } catch (e) {
      debugPrint('Error updating user details: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  Future<void> updateUserChallenges(List<String> challenges) async {
    try {
      final user = await getUser();
      if (user != null) {
        user.selectedChallenges = challenges;
        await saveUser(user);
      }
    } catch (e) {
      debugPrint('Error updating user challenges: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  Future<void> updateUserSupportStyle(String style) async {
    try {
      final user = await getUser();
      if (user != null) {
        user.supportStyle = style;
        await saveUser(user);
      }
    } catch (e) {
      debugPrint('Error updating user support style: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  Future<void> updateUserSupportResponses(Map<String, dynamic> responses) async {
    try {
      final user = await getUser();
      if (user != null) {
        user.supportResponses = responses;
        await saveUser(user);
      }
    } catch (e) {
      debugPrint('Error updating user support responses: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  Future<void> clearUserData() async {
    try {
      await _usersCollection.doc(currentUserId).delete();
    } catch (e) {
      debugPrint('Error clearing user data: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  // Mood methods
  Future<List<MoodEntry>> getAllMoodEntries() async {
    try {
      final snapshot = await _moodEntriesCollection
          .where('userId', isEqualTo: currentUserId)
          .get();

      return snapshot.docs
          .map((doc) => MoodEntry.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting mood entries: $e');
      return [];
    }
  }

  Future<void> saveMoodEntry(MoodEntry entry) async {
    try {
      final entryMap = entry.toMap();
      entryMap['userId'] = currentUserId;

      await _moodEntriesCollection.doc(entry.id).set(entryMap);
    } catch (e) {
      debugPrint('Error saving mood entry: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  Future<void> deleteMoodEntry(String id) async {
    try {
      await _moodEntriesCollection.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting mood entry: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  // Journal methods
  Future<List<JournalEntry>> getAllJournalEntries() async {
    try {
      final snapshot = await _journalEntriesCollection
          .where('userId', isEqualTo: currentUserId)
          .get();

      return snapshot.docs
          .map((doc) => JournalEntry.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting journal entries: $e');
      return [];
    }
  }

  Future<void> saveJournalEntry(JournalEntry entry) async {
    try {
      final entryMap = entry.toMap();
      entryMap['userId'] = currentUserId;

      await _journalEntriesCollection.doc(entry.id).set(entryMap);
    } catch (e) {
      debugPrint('Error saving journal entry: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  Future<void> deleteJournalEntry(String id) async {
    try {
      await _journalEntriesCollection.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting journal entry: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  // Appointment methods
  Future<List<Appointment>> getAllAppointments() async {
    try {
      final snapshot = await _appointmentsCollection
          .where('userId', isEqualTo: currentUserId)
          .get();

      return snapshot.docs
          .map((doc) => Appointment.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting appointments: $e');
      return [];
    }
  }

  // Get appointments for counselor
  Future<List<Appointment>> getCounselorAppointments() async {
    try {
      final snapshot = await _appointmentsCollection
          .where('counselorId', isEqualTo: currentUserId)
          .get();

      return snapshot.docs
          .map((doc) => Appointment.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting counselor appointments: $e');
      return [];
    }
  }

  Future<void> saveAppointment(Appointment appointment) async {
    try {
      final appointmentMap = appointment.toMap();

      await _appointmentsCollection.doc(appointment.id).set(appointmentMap);

      // Create notification for the counselor
      if (appointment.counselorId != currentUserId) {
        final notification = NotificationModel(
          id: 'appt_${appointment.id}',
          userId: appointment.counselorId,
          title: 'New Appointment',
          body: 'You have a new appointment on ${appointment.dateTime}', // Changed 'message' to 'body'
          timestamp: DateTime.now(),
          type: 'appointment',
          isRead: false,
          referenceId: appointment.id, // Changed 'relatedId' to 'referenceId'
        );

        await saveNotification(notification);
      }

      // Create notification for the user if appointment was created by counselor
      if (appointment.userId != currentUserId) {
        final notification = NotificationModel(
          id: 'appt_user_${appointment.id}',
          userId: appointment.userId,
          title: 'New Appointment',
          body: 'You have a new appointment with ${appointment.counselorName} on ${appointment.dateTime}',
          timestamp: DateTime.now(),
          type: 'appointment',
          isRead: false,
          referenceId: appointment.id,
        );

        await saveNotification(notification);
      }
    } catch (e) {
      debugPrint('Error saving appointment: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  Future<void> deleteAppointment(String id) async {
    try {
      // Get the appointment first to notify both parties
      final doc = await _appointmentsCollection.doc(id).get();
      if (doc.exists) {
        final appointment = Appointment.fromMap(doc.data() as Map<String, dynamic>);

        // Create cancellation notification for the counselor
        if (appointment.counselorId != currentUserId) {
          final notification = NotificationModel(
            id: 'cancel_${appointment.id}',
            userId: appointment.counselorId,
            title: 'Appointment Cancelled',
            body: 'An appointment scheduled for ${appointment.dateTime} has been cancelled',
            timestamp: DateTime.now(),
            type: 'appointment_cancelled',
            isRead: false,
            referenceId: appointment.id,
          );

          await saveNotification(notification);
        }

        // Create cancellation notification for the user
        if (appointment.userId != currentUserId) {
          final notification = NotificationModel(
            id: 'cancel_user_${appointment.id}',
            userId: appointment.userId,
            title: 'Appointment Cancelled',
            body: 'Your appointment with ${appointment.counselorName} on ${appointment.dateTime} has been cancelled',
            timestamp: DateTime.now(),
            type: 'appointment_cancelled',
            isRead: false,
            referenceId: appointment.id,
          );

          await saveNotification(notification);
        }
      }

      await _appointmentsCollection.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting appointment: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  // Chat message methods
  Future<List<ChatMessage>> getAllChatMessages() async {
    try {
      final snapshot = await _chatMessagesCollection
          .where('userId', isEqualTo: currentUserId)
          .get();

      return snapshot.docs
          .map((doc) => ChatMessage.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting chat messages: $e');
      return [];
    }
  }

  // Get messages for a specific conversation
  Future<List<ChatMessage>> getMessagesForConversation(String conversationId) async {
    try {
      final snapshot = await _chatMessagesCollection
          .where('conversationId', isEqualTo: conversationId)
          .orderBy('timestamp', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => ChatMessage.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting messages for conversation: $e');
      return [];
    }
  }

  Future<void> saveChatMessage(ChatMessage message) async {
    try {
      final messageMap = message.toMap();
      messageMap['userId'] = currentUserId;

      await _chatMessagesCollection.doc(message.id).set(messageMap);

      // Update conversation with last message
      final conversation = await _chatConversationsCollection.doc(message.conversationId).get();
      if (conversation.exists) {
        await _chatConversationsCollection.doc(message.conversationId).update({
          'lastMessageContent': message.content,
          'lastMessageTime': Timestamp.fromDate(message.timestamp),
          'hasUnreadMessages': true,
        });
      }

      // Create notification for the receiver
      if (message.receiverId != currentUserId) {
        final notification = NotificationModel(
          id: 'msg_${message.id}',
          userId: message.receiverId,
          title: 'New Message',
          body: 'You have a new message', // Changed 'message' to 'body'
          timestamp: DateTime.now(),
          type: 'message',
          isRead: false,
          referenceId: message.conversationId, // Changed 'relatedId' to 'referenceId'
        );

        await saveNotification(notification);
      }
    } catch (e) {
      debugPrint('Error saving chat message: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  Future<void> deleteChatMessage(String id) async {
    try {
      await _chatMessagesCollection.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting chat message: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  // Chat conversation methods
  Future<List<ChatConversation>> getAllChatConversations() async {
    try {
      final snapshot = await _chatConversationsCollection
          .where('participantIds', arrayContains: currentUserId)
          .get();

      return snapshot.docs
          .map((doc) => ChatConversation.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting chat conversations: $e');
      return [];
    }
  }

  Future<String?> createConversation(String otherUserId) async {
    try {
      // Check if conversation already exists
      final existingConversations = await _chatConversationsCollection
          .where('participantIds', arrayContains: currentUserId)
          .get();

      for (var doc in existingConversations.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final participantIds = List<String>.from(data['participantIds'] ?? []);

        if (participantIds.contains(otherUserId)) {
          return doc.id;
        }
      }

      // Create new conversation
      final conversationId = 'conv_${DateTime.now().millisecondsSinceEpoch}';
      final conversation = ChatConversation(
        id: conversationId,
        participantIds: [currentUserId, otherUserId],
        lastMessageContent: '',
        lastMessageTime: DateTime.now(),
        hasUnreadMessages: false,
      );

      await saveChatConversation(conversation);
      return conversationId;
    } catch (e) {
      debugPrint('Error creating conversation: $e');
      return null;
    }
  }

  Future<void> saveChatConversation(ChatConversation conversation) async {
    try {
      final conversationMap = conversation.toMap();

      await _chatConversationsCollection.doc(conversation.id).set(conversationMap);
    } catch (e) {
      debugPrint('Error saving chat conversation: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  Future<void> markConversationAsRead(String conversationId) async {
    try {
      await _chatConversationsCollection.doc(conversationId).update({
        'hasUnreadMessages': false,
      });

      // Mark all messages in this conversation as read
      final snapshot = await _chatMessagesCollection
          .where('conversationId', isEqualTo: conversationId)
          .where('receiverId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error marking conversation as read: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  Future<void> deleteChatConversation(String id) async {
    try {
      await _chatConversationsCollection.doc(id).delete();

      // Delete all messages in this conversation
      final snapshot = await _chatMessagesCollection
          .where('conversationId', isEqualTo: id)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error deleting chat conversation: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  // Notification methods
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final snapshot = await _notificationsCollection
          .where('userId', isEqualTo: currentUserId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting notifications: $e');
      return [];
    }
  }

  Future<void> saveNotification(NotificationModel notification) async {
    try {
      final notificationMap = notification.toMap();

      await _notificationsCollection.doc(notification.id).set(notificationMap);
    } catch (e) {
      debugPrint('Error saving notification: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  Future<void> markNotificationAsRead(String id) async {
    try {
      await _notificationsCollection.doc(id).update({
        'isRead': true,
      });
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _notificationsCollection.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _notificationsCollection
          .where('userId', isEqualTo: currentUserId)
          .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error clearing all notifications: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  // Goal methods
  Future<List<Goal>> getAllGoals() async {
    try {
      final snapshot = await _goalsCollection
          .where('userId', isEqualTo: currentUserId)
          .get();

      return snapshot.docs
          .map((doc) => Goal.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting goals: $e');
      return [];
    }
  }

  Future<void> saveGoal(Goal goal) async {
    try {
      final goalMap = goal.toMap();
      goalMap['userId'] = currentUserId;

      await _goalsCollection.doc(goal.id).set(goalMap);
    } catch (e) {
      debugPrint('Error saving goal: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  Future<void> deleteGoal(String id) async {
    try {
      await _goalsCollection.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting goal: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  // Milestone methods
  Future<List<Milestone>> getAllMilestones() async {
    try {
      final snapshot = await _milestonesCollection
          .where('userId', isEqualTo: currentUserId)
          .get();

      return snapshot.docs
          .map((doc) => Milestone.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting milestones: $e');
      return [];
    }
  }

  Future<List<Milestone>> getMilestonesForGoal(String goalId) async {
    try {
      final snapshot = await _milestonesCollection
          .where('userId', isEqualTo: currentUserId)
          .where('goalId', isEqualTo: goalId)
          .get();

      return snapshot.docs
          .map((doc) => Milestone.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting milestones for goal: $e');
      return [];
    }
  }

  Future<void> saveMilestone(Milestone milestone) async {
    try {
      final milestoneMap = milestone.toMap();
      milestoneMap['userId'] = currentUserId;

      await _milestonesCollection.doc(milestone.id).set(milestoneMap);
    } catch (e) {
      debugPrint('Error saving milestone: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  Future<void> deleteMilestone(String id) async {
    try {
      await _milestonesCollection.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting milestone: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  // Achievement methods
  Future<List<Achievement>> getAllAchievements() async {
    try {
      final snapshot = await _achievementsCollection
          .where('userId', isEqualTo: currentUserId)
          .get();

      return snapshot.docs
          .map((doc) => Achievement.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting achievements: $e');
      return [];
    }
  }

  Future<void> saveAchievement(Achievement achievement) async {
    try {
      final achievementMap = achievement.toMap();
      achievementMap['userId'] = currentUserId;

      await _achievementsCollection.doc(achievement.id).set(achievementMap);
    } catch (e) {
      debugPrint('Error saving achievement: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  Future<void> deleteAchievement(String id) async {
    try {
      await _achievementsCollection.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting achievement: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  // CBT Session methods
  Future<List<CBTSession>> getAllCBTSessions() async {
    try {
      final snapshot = await _cbtSessionsCollection
          .where('userId', isEqualTo: currentUserId)
          .get();

      return snapshot.docs
          .map((doc) => CBTSession.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting CBT sessions: $e');
      return [];
    }
  }

  Future<void> saveCBTSession(CBTSession session) async {
    try {
      final sessionMap = session.toMap();
      sessionMap['userId'] = currentUserId;

      await _cbtSessionsCollection.doc(session.id).set(sessionMap);
    } catch (e) {
      debugPrint('Error saving CBT session: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  Future<void> deleteCBTSession(String id) async {
    try {
      await _cbtSessionsCollection.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting CBT session: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  // Add method to update onboarding status
  Future<void> updateOnboardingStatus(bool completed) async {
    try {
      final user = await getUser();
      if (user != null) {
        user.onboardingCompleted = completed;
        await saveUser(user);
      }
    } catch (e) {
      debugPrint('Error updating onboarding status: $e');
      if (currentUserId != 'demo_user') {
        rethrow;
      }
    }
  }

  // Counselor status methods
  Future<void> updateCounselorStatus(bool isOnline) async {
    try {
      if (currentUserId == 'demo_user') return;

      final user = await getUser();
      if (user?.role != 'counselor') return;

      await _counselorStatusCollection.doc(currentUserId).set({
        'userId': currentUserId,
        'isOnline': isOnline,
        'lastSeen': Timestamp.now(),
        'name': user?.name ?? 'Counselor',
      });
    } catch (e) {
      debugPrint('Error updating counselor status: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getOnlineCounselors() async {
    try {
      final snapshot = await _counselorStatusCollection
          .where('isOnline', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint('Error getting online counselors: $e');
      return [];
    }
  }

  Future<int> getOnlineCounselorCount() async {
    try {
      final snapshot = await _counselorStatusCollection
          .where('isOnline', isEqualTo: true)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error getting online counselor count: $e');
      return 0;
    }
  }

  // App lifecycle methods
  Future<void> setUserOnline() async {
    try {
      final user = await getUser();
      if (user?.role == 'counselor') {
        await updateCounselorStatus(true);
      }
    } catch (e) {
      debugPrint('Error setting user online: $e');
    }
  }

  Future<void> setUserOffline() async {
    try {
      final user = await getUser();
      if (user?.role == 'counselor') {
        await updateCounselorStatus(false);
      }
    } catch (e) {
      debugPrint('Error setting user offline: $e');
    }
  }
}

