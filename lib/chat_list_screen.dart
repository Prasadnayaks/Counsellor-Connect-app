import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../services/firebase_service.dart';
import 'chat_screen.dart';
import 'models/user_model.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>> _counselors = [];
  bool _isLoadingCounselors = true;

  @override
  void initState() {
    super.initState();
    _loadCounselors();
  }

  Future<void> _loadCounselors() async {
    setState(() {
      _isLoadingCounselors = true;
    });

    try {
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      final counselors = await firebaseService.getOnlineCounselors();

      setState(() {
        _counselors = counselors;
        _isLoadingCounselors = false;
      });
    } catch (e) {
      debugPrint('Error loading counselors: $e');
      setState(() {
        _isLoadingCounselors = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.user;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please complete your profile to access chat'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCounselors,
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final conversations = chatProvider.conversations;

          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start chatting with a counselor',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showCounselorList();
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Find a Counselor'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];

              // Determine the other participant (not the current user)
              final otherParticipantId = conversation.participantIds
                  .firstWhere((id) => id != currentUser.id, orElse: () => '');

              // Use a placeholder name if we don't have the actual name
              String otherParticipantName = 'User';

              return FutureBuilder<UserModel?>(
                future: Provider.of<FirebaseService>(context, listen: false)
                    .getUserById(otherParticipantId),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    otherParticipantName = snapshot.data!.name ?? 'User';
                  }

                  return _buildConversationTile(
                    context,
                    conversation.id,
                    otherParticipantId,
                    otherParticipantName,
                    conversation.lastMessageContent,
                    conversation.lastMessageTime,
                    conversation.hasUnreadMessages,
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCounselorList();
        },
        child: const Icon(Icons.chat),
      ),
    );
  }

  void _showCounselorList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Counselors',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${_counselors.length} counselors online',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoadingCounselors
                    ? const Center(child: CircularProgressIndicator())
                    : _counselors.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No counselors available',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please try again later',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: _counselors.length,
                  itemBuilder: (context, index) {
                    final counselor = _counselors[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          counselor['name']?.substring(0, 1) ?? 'C',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      title: Text(counselor['name'] ?? 'Counselor'),
                      subtitle: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('Online'),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          final chatProvider = Provider.of<ChatProvider>(
                            context,
                            listen: false,
                          );

                          final conversationId = await chatProvider.createConversation(
                            counselor['userId'],
                          );

                          if (conversationId != null) {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  conversationId: conversationId,
                                  receiverId: counselor['userId'],
                                  receiverName: counselor['name'] ?? 'Counselor', receiverAvatar: null,
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('Chat'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConversationTile(
      BuildContext context,
      String conversationId,
      String participantId,
      String participantName,
      String lastMessage,
      DateTime lastMessageTime,
      bool hasUnread,
      ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Text(
          participantName.isNotEmpty ? participantName[0] : '?',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
      title: Text(
        participantName,
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(lastMessageTime),
            style: TextStyle(
              fontSize: 12,
              color: hasUnread
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          if (hasUnread)
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversationId: conversationId,
              receiverId: participantId,
              receiverName: participantName, receiverAvatar: null,
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

