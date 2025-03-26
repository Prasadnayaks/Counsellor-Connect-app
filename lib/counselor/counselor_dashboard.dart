import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'appointments_screen.dart';
import 'chat_list_screen.dart';
import 'analytics_screen.dart';
import 'counselor_profile_screen.dart';

class CounselorDashboard extends StatefulWidget {
  const CounselorDashboard({Key? key}) : super(key: key);

  @override
  State<CounselorDashboard> createState() => _CounselorDashboardState();
}

class _CounselorDashboardState extends State<CounselorDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      CounselorHomeTab(
        selectedIndex: _selectedIndex,
        onIndexChange: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      const AppointmentScreen(),
      const ChatListScreen(),
      const AnalyticsScreen(),
      const CounselorProfileCreation(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Appointments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class CounselorHomeTab extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChange;

  const CounselorHomeTab({
    Key? key,
    required this.selectedIndex,
    required this.onIndexChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM d');

    // Mock data for upcoming appointments
    final List<Map<String, dynamic>> upcomingAppointments = [
      {
        'name': 'John Smith',
        'role': 'Student',
        'time': '10:00 AM',
        'issue': 'Anxiety',
        'avatar': 'https://i.pravatar.cc/150?img=1',
      },
      {
        'name': 'Sarah Johnson',
        'role': 'Teaching Staff',
        'time': '11:30 AM',
        'issue': 'Work Stress',
        'avatar': 'https://i.pravatar.cc/150?img=2',
      },
      {
        'name': 'Michael Brown',
        'role': 'Student',
        'time': '2:15 PM',
        'issue': 'Depression',
        'avatar': 'https://i.pravatar.cc/150?img=3',
      },
    ];

    // Mock data for recent messages
    final List<Map<String, dynamic>> recentMessages = [
      {
        'name': 'Emily Davis',
        'message': 'Thank you for your help yesterday...',
        'time': '9:45 AM',
        'unread': true,
        'avatar': 'https://i.pravatar.cc/150?img=5',
      },
      {
        'name': 'David Wilson',
        'message': 'Can we reschedule our appointment?',
        'time': 'Yesterday',
        'unread': false,
        'avatar': 'https://i.pravatar.cc/150?img=8',
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Dr. Jessica Parker',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=32'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateFormat.format(today),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${upcomingAppointments.length} appointments today',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Appointments",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      onIndexChange(1); // Navigate to Appointments screen
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: upcomingAppointments.length,
                itemBuilder: (context, index) {
                  final appointment = upcomingAppointments[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(appointment['avatar'] as String),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appointment['name'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${appointment['role'] as String} • ${appointment['issue'] as String}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                appointment['time'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.videocam, color: Colors.green),
                                    onPressed: () {
                                      // Handle video call
                                    },
                                    constraints: const BoxConstraints.tightFor(width: 30, height: 30),
                                    padding: EdgeInsets.zero,
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: const Icon(Icons.chat, color: Colors.blue),
                                    onPressed: () {
                                      // Handle chat
                                    },
                                    constraints: const BoxConstraints.tightFor(width: 30, height: 30),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Messages',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      onIndexChange(2); // Navigate to Chat screen
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentMessages.length,
                itemBuilder: (context, index) {
                  final message = recentMessages[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundImage: NetworkImage(message['avatar'] as String),
                              ),
                              if (message['unread'] as bool)
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
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message['name'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  message['message'] as String,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            message['time'] as String,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickActionCard(
                    context,
                    icon: Icons.add_circle,
                    title: 'New Appointment',
                    color: Colors.blue,
                    onTap: () {
                      // Handle new appointment
                    },
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.note_add,
                    title: 'Add Notes',
                    color: Colors.orange,
                    onTap: () {
                      // Handle add notes
                    },
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.analytics,
                    title: 'Reports',
                    color: Colors.purple,
                    onTap: () {
                      // Handle reports
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.28,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 30,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}