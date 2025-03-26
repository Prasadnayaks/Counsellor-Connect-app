import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class CounselorChatScreen extends StatefulWidget {
  const CounselorChatScreen({super.key});

  @override
  _CounselorChatScreenState createState() => _CounselorChatScreenState();
}

class _CounselorChatScreenState extends State<CounselorChatScreen> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: '82091008-a484-4a97-8c03-034b7508a345');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat with Counselor"),
      ),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
      ),
    );
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch, // Convert DateTime to int
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message.text,
    );

    _addMessage(textMessage);
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.add(message); // Add new messages to the end of the list
    });
  }
}
