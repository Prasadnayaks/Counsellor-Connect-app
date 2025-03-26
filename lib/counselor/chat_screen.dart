import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final String avatar;
  final String role;

  const ChatScreen({
    Key? key,
    required this.name,
    required this.avatar,
    required this.role,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Mock data for messages
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    // Mock data - in a real app, this would come from a database
    final now = DateTime.now();

    _messages.addAll([
      {
        'text': 'Hi Dr. Parker, I\'ve been feeling anxious about my upcoming exams.',
        'isMe': false,
        'time': now.subtract(const Duration(days: 1, hours: 2)),
      },
      {
        'text': 'I understand. Exam anxiety is common. Can you tell me more about what you\'re experiencing?',
        'isMe': true,
        'time': now.subtract(const Duration(days: 1, hours: 1, minutes: 55)),
      },
      {
        'text': 'I can\'t focus when studying, and I\'m having trouble sleeping. I keep worrying that I\'ll fail.',
        'isMe': false,
        'time': now.subtract(const Duration(days: 1, hours: 1, minutes: 50)),
      },
      {
        'text': 'Those are typical symptoms of anxiety. Let\'s discuss some strategies to help you manage this. Would you be available for an appointment tomorrow?',
        'isMe': true,
        'time': now.subtract(const Duration(days: 1, hours: 1, minutes: 45)),
      },
      {
        'text': 'Yes, that would be helpful. Thank you.',
        'isMe': false,
        'time': now.subtract(const Duration(days: 1, hours: 1, minutes: 40)),
      },
      {
        'text': 'Great. In the meantime, try some deep breathing exercises when you feel anxious. Breathe in for 4 counts, hold for 4, and exhale for 6.',
        'isMe': true,
        'time': now.subtract(const Duration(days: 1, hours: 1, minutes: 35)),
      },
      {
        'text': 'I\'ll try that. I\'ve been practicing the mindfulness techniques you suggested last time, and they\'ve been helping a bit.',
        'isMe': false,
        'time': now.subtract(const Duration(minutes: 30)),
      },
      {
        'text': 'That\'s excellent progress! Keep it up, and we\'ll build on those techniques in our session tomorrow.',
        'isMe': true,
        'time': now.subtract(const Duration(minutes: 25)),
      },
    ]);

    setState(() {});

    // Scroll to bottom after messages load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
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

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'text': _messageController.text,
        'isMe': true,
        'time': DateTime.now(),
      });
      _messageController.clear();
    });

    // Scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.avatar),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  widget.role,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
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
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show user info
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['isMe'] as bool;
                final time = message['time'] as DateTime;
                final showDate = index == 0 ||
                    !DateUtils.isSameDay(time, _messages[index - 1]['time'] as DateTime);

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
                    Align(
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
                              message['text'] as String,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              DateFormat('h:mm a').format(time),
                              style: TextStyle(
                                color: isMe
                                    ? Colors.white.withOpacity(0.7)
                                    : Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
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
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatMessageDate(DateTime date) {
    final now = DateTime.now();

    if (DateUtils.isSameDay(date, now)) {
      return 'Today';
    } else if (DateUtils.isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }
}

// TODO Implement this library.