import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/navigation_provider.dart';
import 'mood_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/counselor_provider.dart';
import 'custom_bottom_navigation.dart';
import 'cbt_techniques_screen.dart';
import 'relaxation_screen.dart';
import 'appointment_screen.dart';
import 'profile_screen.dart';
import 'challenge_selection.dart';
import 'mood_tracker_screen.dart';
import 'journal_screen.dart';
import 'chat_list_screen.dart';
import 'notifications_screen.dart';
import 'package:intl/intl.dart';
// Add imports for the new screens
import 'goals_screen.dart';
import 'achievements_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final List<Widget> _screens = [
    const HomeTab(),
    const CBTTechniquesScreen(),
    const RelaxationScreen(),
    const AppointmentScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Set user online when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final counselorProvider = Provider.of<CounselorProvider>(context, listen: false);
      counselorProvider.setUserOnline();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final counselorProvider = Provider.of<CounselorProvider>(context, listen: false);

    if (state == AppLifecycleState.resumed) {
      // App in foreground
      counselorProvider.setUserOnline();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      // App in background or closed
      counselorProvider.setUserOffline();
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      body: _screens[navigationProvider.currentIndex],
      bottomNavigationBar: const CustomBottomNavigation(),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();

    // Refresh counselor list when home tab is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final counselorProvider = Provider.of<CounselorProvider>(context, listen: false);
      counselorProvider.refreshCounselors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final moodProvider = Provider.of<MoodProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final counselorProvider = Provider.of<CounselorProvider>(context);
    final userName = userProvider.userName;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(context, userName, notificationProvider),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildMoodTracker(context, moodProvider),
              ),
              const SizedBox(height: 25),
              if (userProvider.userRole == 'student')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildCounselorStatus(context, counselorProvider),
                ),
              if (userProvider.userRole == 'student')
                const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildQuickActions(context, userProvider),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildDailyChallenge(context),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildDailyThought(context),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildJournalPrompt(context),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounselorStatus(BuildContext context, CounselorProvider counselorProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.teal.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Counselor Availability',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.teal),
                onPressed: () {
                  counselorProvider.refreshCounselors();
                },
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.people,
                  color: Colors.teal,
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${counselorProvider.onlineCounselorCount} Counselors Online',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Available for chat and appointments',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AppointmentScreen()),
                );
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text('Book Appointment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Update the header section to use the user's name
  Widget _buildHeaderSection(BuildContext context, String userName, NotificationProvider notificationProvider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
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
                    'Hello, ${userName.isEmpty ? 'User' : userName}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'How are you feeling today?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsScreen(),
                            ),
                          );
                        },
                      ),
                      if (notificationProvider.unreadCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              notificationProvider.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatListScreen(),
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _getFormattedDate(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMMM d');
    return formatter.format(now);
  }

  Widget _buildMoodTracker(BuildContext context, MoodProvider moodProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Track Your Mood',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MoodTrackerScreen()),
                  );
                },
                icon: const Icon(Icons.history, size: 16),
                label: const Text('History'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMoodOption(context, '😢', 'Sad', moodProvider),
              _buildMoodOption(context, '😐', 'Okay', moodProvider),
              _buildMoodOption(context, '🙂', 'Good', moodProvider),
              _buildMoodOption(context, '😄', 'Great', moodProvider),
              _buildMoodOption(context, '🤩', 'Amazing', moodProvider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodOption(BuildContext context, String emoji, String label, MoodProvider moodProvider) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            // Save mood entry
            moodProvider.addMoodEntry(label, "Feeling $label today");

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Mood saved: $label'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, UserProvider userProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildActionCardHorizontal(
                context,
                title: 'CBT',
                icon: Icons.psychology,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CBTTechniquesScreen()),
                  );
                },
              ),
              _buildActionCardHorizontal(
                context,
                title: 'Relaxation',
                icon: Icons.spa,
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RelaxationScreen()),
                  );
                },
              ),
              _buildActionCardHorizontal(
                context,
                title: 'Goals',
                icon: Icons.flag,
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GoalsScreen()),
                  );
                },
              ),
              _buildActionCardHorizontal(
                context,
                title: 'Achievements',
                icon: Icons.emoji_events,
                color: Colors.amber,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AchievementsScreen()),
                  );
                },
              ),
              _buildActionCardHorizontal(
                context,
                title: 'Appointments',
                icon: Icons.calendar_today,
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AppointmentScreen()),
                  );
                },
              ),
              _buildActionCardHorizontal(
                context,
                title: 'Journal',
                icon: Icons.book,
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const JournalScreen()),
                  );
                },
              ),
              _buildActionCardHorizontal(
                context,
                title: 'Chat',
                icon: Icons.chat,
                color: Colors.indigo,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatListScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCardHorizontal(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyChallenge(BuildContext context) {
    // Get a daily challenge based on the day of the year
    final challenge = _getDailyChallenge();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Challenge',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              InkWell(
                onTap: () {
                  // Navigate to challenge selection
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChallengeSelection()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Change',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: challenge.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: challenge.color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: challenge.color.withOpacity(0.3),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    challenge.icon,
                    color: challenge.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: challenge.color,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        challenge.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                // Mark challenge as complete
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Challenge completed! Great job!'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: challenge.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Mark as Complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: challenge.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DailyChallenge _getDailyChallenge() {
    // List of challenges
    final challenges = [
      DailyChallenge(
        title: 'Practice Mindfulness',
        description: 'Take 5 minutes to focus on your breathing and be present in the moment.',
        icon: Icons.self_improvement,
        color: Colors.purple,
      ),
      DailyChallenge(
        title: 'Express Gratitude',
        description: 'Write down three things you are grateful for today.',
        icon: Icons.favorite,
        color: Colors.red,
      ),
      DailyChallenge(
        title: 'Physical Activity',
        description: 'Take a 15-minute walk outside to boost your mood and energy.',
        icon: Icons.directions_walk,
        color: Colors.green,
      ),
      DailyChallenge(
        title: 'Connect with Someone',
        description: 'Reach out to a friend or family member you haven\'t spoken to in a while.',
        icon: Icons.people,
        color: Colors.blue,
      ),
      DailyChallenge(
        title: 'Digital Detox',
        description: 'Take a 2-hour break from all screens and social media.',
        icon: Icons.phonelink_erase,
        color: Colors.orange,
      ),
      DailyChallenge(
        title: 'Try Something New',
        description: 'Step out of your comfort zone and try one new activity today.',
        icon: Icons.explore,
        color: Colors.teal,
      ),
      DailyChallenge(
        title: 'Practice Self-Compassion',
        description: 'Speak to yourself with kindness and understanding today.',
        icon: Icons.favorite_border,
        color: Colors.pink,
      ),
    ];

    // Get a challenge based on the day of the year
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return challenges[dayOfYear % challenges.length];
  }

  Widget _buildDailyThought(BuildContext context) {
    // Get a daily thought based on the day of the year
    final thought = _getDailyThought();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        image: DecorationImage(
          image: AssetImage('assets/images/thought_bg.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.85),
            BlendMode.lighten,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thought of the Day',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            '"${thought.quote}"',
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '- ${thought.author}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                // Share the thought
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Thought saved to favorites!'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.favorite_border),
              label: const Text('Save to Favorites'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DailyThought _getDailyThought() {
    // List of thoughts
    final thoughts = [
      DailyThought(
        quote: "The greatest glory in living lies not in never falling, but in rising every time we fall.",
        author: "Nelson Mandela",
      ),
      DailyThought(
        quote: "The way to get started is to quit talking and begin doing.",
        author: "Walt Disney",
      ),
      DailyThought(
        quote: "Your time is limited, so don't waste it living someone else's life.",
        author: "Steve Jobs",
      ),
      DailyThought(
        quote: "If life were predictable it would cease to be life, and be without flavor.",
        author: "Eleanor Roosevelt",
      ),
      DailyThought(
        quote: "If you look at what you have in life, you'll always have more. If you look at what you don't have in life, you'll never have enough.",
        author: "Oprah Winfrey",
      ),
      DailyThought(
        quote: "If you set your goals ridiculously high and it's a failure, you will fail above everyone else's success.",
        author: "James Cameron",
      ),
      DailyThought(
        quote: "Life is what happens when you're busy making other plans.",
        author: "John Lennon",
      ),
    ];

    // Get a thought based on the day of the year
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return thoughts[dayOfYear % thoughts.length];
  }

  Widget _buildJournalPrompt(BuildContext context) {
    // Get a journal prompt based on the day of the year
    final prompt = _getJournalPrompt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.purple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Journal Prompt',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const JournalScreen()),
                  );
                },
                icon: const Icon(Icons.book, size: 16),
                label: const Text('View Journal'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.purple.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              prompt,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to journal entry screen with this prompt
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JournalScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Write in Journal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getJournalPrompt() {
    // List of journal prompts
    final prompts = [
      "What are three things you're grateful for today?",
      "Describe a moment that made you smile recently.",
      "What's something you're looking forward to this week?",
      "Write about a challenge you're facing and how you plan to overcome it.",
      "What's something you've learned about yourself recently?",
      "Describe your ideal day. What would you do?",
      "What are your top three priorities right now?",
      "Write about someone who has positively influenced your life.",
      "What's a goal you're working towards? What steps are you taking?",
      "Reflect on a mistake you made and what you learned from it.",
      "What are three things you love about yourself?",
      "Describe a place where you feel most at peace.",
      "What boundaries do you need to set or maintain in your life?",
      "Write about a time when you felt proud of yourself.",
    ];

    // Get a prompt based on the day of the year
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return prompts[dayOfYear % prompts.length];
  }
}

// Add these classes at the end of the file
class DailyChallenge {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  DailyChallenge({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class DailyThought {
  final String quote;
  final String author;

  DailyThought({
    required this.quote,
    required this.author,
  });
}

