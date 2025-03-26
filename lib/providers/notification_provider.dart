import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:wysa_app/appointment.dart';
import '../models/notification.dart';
import '../services/firebase_service.dart';

class NotificationProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  NotificationProvider(this._firebaseService) {
    _loadNotifications();
  }

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> _loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _firebaseService.getAllNotifications();
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNotification({
    required String userId, // Added userId
    required String title,
    required String body,
    required String type,
    String? referenceId, // Changed to referenceId
  }) async {
    try {
      final notification = NotificationModel(
        id: const Uuid().v4(),
        userId: userId, // Added userId
        title: title,
        body: body,
        type: type,
        referenceId: referenceId, // Changed to referenceId
        timestamp: DateTime.now(),
        isRead: false, // Added isRead
      );

      await _firebaseService.saveNotification(notification);
      await _loadNotifications();
    } catch (e) {
      debugPrint('Error adding notification: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final notification = _notifications[index];
        final updatedNotification = NotificationModel(
          id: notification.id,
          userId: notification.userId, // Added userId
          title: notification.title,
          body: notification.body,
          type: notification.type,
          referenceId: notification.referenceId, // Changed to referenceId
          timestamp: notification.timestamp,
          isRead: true, // Set isRead to true
        );

        await _firebaseService.saveNotification(updatedNotification);
        await _loadNotifications();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      for (var notification in _notifications.where((n) => !n.isRead)) {
        final updatedNotification = NotificationModel(
          id: notification.id,
          userId: notification.userId, // Added userId
          title: notification.title,
          body: notification.body,
          type: notification.type,
          referenceId: notification.referenceId, // Changed to referenceId
          timestamp: notification.timestamp,
          isRead: true, // Set isRead to true
        );

        await _firebaseService.saveNotification(updatedNotification);
      }

      await _loadNotifications();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _firebaseService.deleteNotification(id);
      await _loadNotifications();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      await _firebaseService.clearAllNotifications();
      await _loadNotifications();
    } catch (e) {
      debugPrint('Error clearing all notifications: $e');
    }
  }

  void scheduleAppointmentReminder(Appointment appointment) {}

  void cancelAppointmentReminder(String id) {}
}