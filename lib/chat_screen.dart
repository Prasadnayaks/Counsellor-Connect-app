import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../models/chat_message.dart';
import '../services/firebase_service.dart';
import 'models/user_model.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    Key? key,
    required this.conversationId,
    required this.receiverId,
    required this.receiverName, required receiverAvatar,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    try {
      // Mark conversation as read
      await chatProvider.markConversationAsRead(widget.conversationId);

      // Load messages
      final messages = await chatProvider.getMessagesForConversation(widget.conversationId);

      setState(() {
        _messages = messages;
        _isLoading = false;
      });

      // Scroll to bottom after messages load
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      debugPrint('Error initializing chat: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    try {
      await chatProvider.sendMessage(
        widget.conversationId,
        widget.receiverId,
        _messageController.text.trim(),
      );

      _messageController.clear();

      // Reload messages
      final messages = await chatProvider.getMessagesForConversation(widget.conversationId);

      setState(() {
        _messages = messages;
      });

      // Scroll to bottom after sending message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message')),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserId = Provider.of<FirebaseService>(context).currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                widget.receiverName.isNotEmpty ? widget.receiverName[0] : '?',
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverName,
                  style: const TextStyle(fontSize: 16),
                ),
                FutureBuilder<UserModel?>(
                  future: Provider.of<FirebaseService>(context, listen: false)
                      .getUserById(widget.receiverId),
                  builder: (context, snapshot) {
                    String role = 'User';
                    if (snapshot.hasData && snapshot.data != null) {
                      role = snapshot.data!.role ?? 'User';
                      if (role == 'counselor') {
                        role = 'Counselor';
                      } else if (role == 'teaching_staff') {
                        role = 'Teaching Staff';
                      } else if (role == 'non_teaching_staff') {
                        role = 'Non-Teaching Staff';
                      } else {
                        role = 'Student';
                      }
                    }
                    return Text(
                      role,
                      style: const TextStyle(fontSize: 12),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              // Handle video call
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Video call feature coming soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show user info
              _showUserInfo();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text('No messages yet'),
                  const SizedBox(height: 8),
                  const Text('Start a conversation!'),
                ],
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.senderId == currentUserId;
                final time = message.timestamp;
                final showDate = index == 0 ||
                    !_isSameDay(time, _messages[index - 1].timestamp);

                return Column(
                  children: [
                    if (showDate)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          _formatMessageDate(time),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    _buildMessageBubble(message, isMe),
                  ],
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatMessageTime(message.timestamp),
                  style: TextStyle(
                    color: isMe
                        ? Colors.white.withOpacity(0.7)
                        : Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {
              // Handle attachment
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Attachment feature coming soon')),
              );
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              maxLines: 5,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: Theme.of(context).colorScheme.primary,
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  String _formatMessageDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatMessageTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showUserInfo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FutureBuilder<UserModel?>(
          future: Provider.of<FirebaseService>(context, listen: false)
              .getUserById(widget.receiverId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = snapshot.data;

            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      widget.receiverName.isNotEmpty ? widget.receiverName[0] : '?',
                      style: TextStyle(
                        fontSize: 30,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.receiverName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.role ?? 'User',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: const Icon(Icons.call),
                    title: const Text('Voice Call'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Voice call feature coming soon')),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.videocam),
                    title: const Text('Video Call'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Video call feature coming soon')),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.block),
                    title: const Text('Block User'),
                    onTap: () {
                      Navigator.pop(context);
                      _showBlockUserDialog();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showBlockUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: Text('Are you sure you want to block ${widget.receiverName}?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User blocked successfully')),
              );
              Navigator.pop(context); // Go back to chat list
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }
}

