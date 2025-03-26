import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/notification_provider.dart';
import '../models/notification.dart';
import 'chat_screen.dart';
import 'appointment_screen.dart';
import 'mood_tracker_screen.dart';
import 'journal_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () {
              Provider.of<NotificationProvider>(context, listen: false).markAllAsRead();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear all notifications',
            onPressed: () {
              _showClearConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          final notifications = notificationProvider.notifications;

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'re all caught up!',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationItem(context, notification);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationModel notification) {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        notificationProvider.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: ListTile(
        leading: _getNotificationIcon(notification.type),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatNotificationTime(notification.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          notificationProvider.markAsRead(notification.id);
          _navigateBasedOnType(context, notification);
        },
        tileColor: notification.isRead ? null : Colors.blue.withOpacity(0.05),
      ),
    );
  }

  Widget _getNotificationIcon(String type) {
    switch (type) {
      case 'chat':
        return CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: const Icon(Icons.chat, color: Colors.blue),
        );
      case 'appointment':
        return CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.1),
          child: const Icon(Icons.calendar_today, color: Colors.green),
        );
      case 'mood':
        return CircleAvatar(
          backgroundColor: Colors.orange.withOpacity(0.1),
          child: const Icon(Icons.mood, color: Colors.orange),
        );
      case 'journal':
        return CircleAvatar(
          backgroundColor: Colors.purple.withOpacity(0.1),
          child: const Icon(Icons.book, color: Colors.purple),
        );
      default:
        return CircleAvatar(
          backgroundColor: Colors.grey.withOpacity(0.1),
          child: const Icon(Icons.notifications, color: Colors.grey),
        );
    }
  }

  void _navigateBasedOnType(BuildContext context, NotificationModel notification) {
    switch (notification.type) {
      case 'chat':
        if (notification.referenceId != null) {
          // In a real app, you would fetch user details from a database
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                receiverId: notification.referenceId!,
                receiverName: 'User', // Replace with actual user name
                receiverAvatar: null, conversationId: '', // Replace with actual avatar
              ),
            ),
          );
        }
        break;
      case 'appointment':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AppointmentScreen(),
          ),
        );
        break;
      case 'mood':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MoodTrackerScreen(),
          ),
        );
        break;
      case 'journal':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const JournalScreen(),
          ),
        );
        break;
      default:
      // Do nothing or show a generic screen
        break;
    }
  }

  String _formatNotificationTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(time.year, time.month, time.day);

    if (notificationDate == today) {
      return 'Today, ${DateFormat('h:mm a').format(time)}';
    } else if (notificationDate == yesterday) {
      return 'Yesterday, ${DateFormat('h:mm a').format(time)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(time);
    }
  }

  void _showClearConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to clear all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<NotificationProvider>(context, listen: false).clearAllNotifications();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

