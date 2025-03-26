import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Mock data for chats
  final List<Map<String, dynamic>> _recentChats = [
  {
  'name': 'Emily Davis',
  'message': 'Thank you for your help yesterday...',
  'time': '9:45 AM',
  'unread': true,
  'avatar': 'https://i.pravatar.cc/150?img=5',
  'role': 'Student',
},
{
'name': 'David Wilson',
'message': 'Can we reschedule our appointment?',
'time': 'Yesterday',
'unread': false,
'avatar': 'https://i.pravatar.cc/150?img=8',
'role': 'Teaching Staff',
},
{
'name': 'Sophia Martinez',
'message': ' Ive been feeling much better since...',
'time': 'Yesterday',
'unread': false,
'avatar': 'https://i.pravatar.cc/150?img=9',
'role': 'Student',
},
{
'name': 'James Johnson',
'message': 'Thanks for the resources you shared',
'time': 'Monday',
'unread': false,
'avatar': 'https://i.pravatar.cc/150?img=12',
'role': 'Non-Teaching Staff',
},
{
'name': 'Olivia Brown',
'message': 'Ill try the techniques you suggested',
'time': 'Monday',
'unread': false,
'avatar': 'https://i.pravatar.cc/150?img=15',
'role': 'Student',
},
];

@override
void initState() {
  super.initState();
  _tabController = TabController(length: 3, vsync: this);
}

@override
void dispose() {
  _tabController.dispose();
  _searchController.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Messages'),
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Students'),
          Tab(text: 'Staff'),
        ],
      ),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search conversations',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildChatList(_recentChats),
              _buildChatList(_recentChats.where((chat) => chat['role'] == 'Student').toList()),
              _buildChatList(_recentChats.where((chat) => chat['role'] != 'Student').toList()),
            ],
          ),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        // Show new message dialog
        _showNewMessageDialog();
      },
      child: const Icon(Icons.chat),
    ),
  );
}

Widget _buildChatList(List<Map<String, dynamic>> chats) {
  return chats.isEmpty
      ? Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.chat_bubble_outline,
          size: 80,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 20),
        Text(
          'No conversations yet',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    ),
  )
      : ListView.builder(
    itemCount: chats.length,
    itemBuilder: (context, index) {
      final chat = chats[index];
      return ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(chat['avatar']),
            ),
            if (chat['unread'] as bool)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          chat['name'],
          style: TextStyle(
            fontWeight: chat['unread'] as bool ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                chat['role'],
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                chat['message'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: chat['unread'] as bool ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        trailing: Text(
          chat['time'],
          style: TextStyle(
            fontSize: 12,
            color: chat['unread'] as bool ? Theme.of(context).colorScheme.primary : Colors.grey,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                name: chat['name'],
                avatar: chat['avatar'],
                role: chat['role'],
              ),
            ),
          );
        },
      );
    },
  );
}

void _showNewMessageDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('New Message'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Search for a user',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 300,
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                final users = [
                  {
                    'name': 'John Smith',
                    'role': 'Student',
                    'avatar': 'https://i.pravatar.cc/150?img=1',
                  },
                  {
                    'name': 'Sarah Johnson',
                    'role': 'Teaching Staff',
                    'avatar': 'https://i.pravatar.cc/150?img=2',
                  },
                  {
                    'name': 'Michael Brown',
                    'role': 'Student',
                    'avatar': 'https://i.pravatar.cc/150?img=3',
                  },
                  {
                    'name': 'Emma Wilson',
                    'role': 'Student',
                    'avatar': 'https://i.pravatar.cc/150?img=4',
                  },
                  {
                    'name': 'Robert Taylor',
                    'role': 'Non-Teaching Staff',
                    'avatar': 'https://i.pravatar.cc/150?img=6',
                  },
                ];

                final user = users[index];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user['avatar']!),
                  ),
                  title: Text(user['name']!),
                  subtitle: Text(user['role']!),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          name: user['name']!,
                          avatar: user['avatar']!,
                          role: user['role']!,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}
}

// TODO Implement this library.