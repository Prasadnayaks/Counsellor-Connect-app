import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../models/chat_conversation.dart';
import '../services/firebase_service.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  List<ChatMessage> _messages = [];
  List<ChatConversation> _conversations = [];
  bool _isLoading = true;

  ChatProvider(this._firebaseService) {
    _loadData();
  }

  List<ChatMessage> get messages => _messages;
  List<ChatConversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String get currentUserId => _firebaseService.currentUserId;

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await refreshConversations();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading chat data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshConversations() async {
    try {
      _conversations = await _firebaseService.getAllChatConversations();
      _conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading chat conversations: $e');
      rethrow;
    }
  }

  Future<List<ChatMessage>> getMessagesForConversation(String conversationId) async {
    try {
      _messages = await _firebaseService.getMessagesForConversation(conversationId);
      notifyListeners();
      return _messages;
    } catch (e) {
      debugPrint('Error loading chat messages: $e');
      rethrow;
    }
  }

  Future<void> sendMessage(
      String conversationId,
      String receiverId,
      String content,
      ) async {
    try {
      final message = ChatMessage(
        id: const Uuid().v4(),
        conversationId: conversationId,
        senderId: _firebaseService.currentUserId,
        receiverId: receiverId,
        content: content,
        timestamp: DateTime.now(),
      );

      await _firebaseService.saveChatMessage(message);

      // Reload messages for this conversation
      await getMessagesForConversation(conversationId);
      await refreshConversations();
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  Future<String?> createConversation(String otherUserId) async {
    try {
      final conversationId = await _firebaseService.createConversation(otherUserId);
      await refreshConversations();
      return conversationId;
    } catch (e) {
      debugPrint('Error creating conversation: $e');
      return null;
    }
  }

  Future<void> markConversationAsRead(String conversationId) async {
    try {
      await _firebaseService.markConversationAsRead(conversationId);
      await refreshConversations();
    } catch (e) {
      debugPrint('Error marking conversation as read: $e');
      rethrow;
    }
  }

  int getUnreadMessageCount() {
    return _conversations
        .where((conversation) => conversation.hasUnreadMessages)
        .length;
  }
}

