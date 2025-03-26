import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../blocs/app_bloc.dart';
import '../widgets/animated_progress_ring.dart';
import '../widgets/achievement_badge.dart';
import 'mood_provider.dart';
import '../providers/cbt_provider.dart';
import 'journal_provider.dart';
import '../providers/achievement_provider.dart';
import 'mood_tracker_screen.dart';
import 'cbt_techniques_screen.dart';
import 'journal_screen.dart';
import 'achievements_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appBloc = Provider.of<AppBloc>(context);
    final moodProvider = Provider.of<MoodProvider>(context);
    final cbtProvider = Provider.of<CBTProvider>(context);
    final journalProvider = Provider.of<JournalProvider>(context);
    final achievementProvider = Provider.of<AchievementProvider>(context);

    final userName = Provider.of<AppBloc>(context).currentUser?.name ?? 'User';
    final streak = appBloc.currentStreak;
    final achievementsCount = appBloc.achievementsCount;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, userName, streak),
              _buildProgressSection(context, moodProvider, cbtProvider, journalProvider),
              _buildMoodInsightsSection(context, moodProvider),
              _buildAchievementsSection(context, achievementProvider),
              _buildRecommendationsSection(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName, int streak) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
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
                    'Welcome back,',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$streak Day Streak',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'How are you feeling today?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickMoodButton(context, '😊', 'Happy', Colors.green),
                _buildQuickMoodButton(context, '😐', 'Okay', Colors.amber),
                _buildQuickMoodButton(context, '😔', 'Sad', Colors.blue),
                _buildQuickMoodButton(context, '😰', 'Anxious', Colors.purple),
                _buildQuickMoodButton(context, '😠', 'Angry', Colors.red),
                _buildQuickMoodButton(context, '😴', 'Tired', Colors.indigo),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMoodButton(BuildContext context, String emoji, String mood, Color color) {
    return GestureDetector(
      onTap: () {
        // Quick mood tracking
        final moodProvider = Provider.of<MoodProvider>(context, listen: false);
        moodProvider.addMoodEntry(mood, "Quick mood check-in: $mood");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mood saved: $mood'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: color,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Text(
              mood,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(
      BuildContext context,
      MoodProvider moodProvider,
      CBTProvider cbtProvider,
      JournalProvider journalProvider,
      ) {
    final moodEntries = moodProvider.moodEntries.length;
    final cbtSessions = cbtProvider.allSessions.length;
    final journalEntries = journalProvider.journalEntries.length;

    // Calculate total activities
    final totalActivities = moodEntries + cbtSessions + journalEntries;
    final targetActivities = 50; // Example target
    final progress = totalActivities / targetActivities;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Progress',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              AnimatedProgressRing(
                progress: progress.clamp(0.0, 1.0),
                size: 100,
                strokeWidth: 10,
                backgroundColor: Colors.grey.withOpacity(0.2),
                foregroundColor: Theme.of(context).colorScheme.primary,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$totalActivities',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Activities',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressItem(
                      context,
                      icon: Icons.mood,
                      title: 'Mood Entries',
                      value: moodEntries,
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MoodTrackerScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildProgressItem(
                      context,
                      icon: Icons.psychology,
                      title: 'CBT Sessions',
                      value: cbtSessions,
                      color: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CBTTechniquesScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildProgressItem(
                      context,
                      icon: Icons.book,
                      title: 'Journal Entries',
                      value: journalEntries,
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const JournalScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required int value,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              value.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodInsightsSection(BuildContext context, MoodProvider moodProvider) {
    final moodEntries = moodProvider.moodEntries;

    if (moodEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get mood distribution
    final distribution = moodProvider.getMoodDistribution();

    // Prepare data for chart
    final List<PieChartSectionData> sections = [];
    final Map<String, Color> moodColors = {
      'Happy': Colors.green,
      'Okay': Colors.amber,
      'Sad': Colors.blue,
      'Anxious': Colors.purple,
      'Angry': Colors.red,
      'Tired': Colors.indigo,
    };

    distribution.forEach((mood, count) {
      final color = moodColors[mood] ?? Colors.grey;
      sections.add(
        PieChartSectionData(
          color: color,
          value: count.toDouble(),
          title: '$count',
          radius: 60,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    });

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mood Insights',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MoodTrackerScreen(),
                    ),
                  );
                },
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                height: 180,
                width: 180,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 30,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...distribution.entries.map((entry) {
                      final mood = entry.key;
                      final count = entry.value;
                      final color = moodColors[mood] ?? Colors.grey;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              mood,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '$count entries',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context, AchievementProvider achievementProvider) {
    final achievements = achievementProvider.allAchievements;
    final unlockedAchievements = achievementProvider.unlockedAchievements;

    if (achievements.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show only a few achievements
    final displayAchievements = achievements.take(3).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AchievementsScreen(),
                    ),
                  );
                },
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: displayAchievements.map((achievement) {
              return AchievementBadge(
                title: achievement.title,
                icon: Icons.ice_skating,
                color: _getAchievementColor(achievement.category),
                isUnlocked: achievement.isUnlocked,
                onTap: () {
                  _showAchievementDetails(context, achievement);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: unlockedAchievements.length / achievements.length,
            backgroundColor: Colors.grey.withOpacity(0.2),
            color: Theme.of(context).colorScheme.primary,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            '${unlockedAchievements.length}/${achievements.length} Achievements Unlocked',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAchievementColor(String category) {
    switch (category) {
      case 'Mood Tracking':
        return Colors.blue;
      case 'Journaling':
        return Colors.green;
      case 'CBT':
        return Colors.purple;
      case 'Goals':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showAchievementDetails(BuildContext context, dynamic achievement) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                IconData(achievement.iconData, fontFamily: 'MaterialIcons'),
                size: 48,
                color: _getAchievementColor(achievement.category),
              ),
              const SizedBox(height: 16),
              Text(
                achievement.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                achievement.description,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getAchievementColor(achievement.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  achievement.category,
                  style: TextStyle(
                    color: _getAchievementColor(achievement.category),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (achievement.isUnlocked)
                Text(
                  'Unlocked on ${_formatDate(achievement.unlockedDate)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                )
              else
                const Text(
                  'Not yet unlocked',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildRecommendationsSection(BuildContext context) {
    // Example recommendations based on user data
    final recommendations = [
      {
        'title': 'Feeling stressed?',
        'description': 'Try a 5-minute breathing exercise',
        'icon': Icons.spa,
        'color': Colors.teal,
        'action': () {
          // Navigate to breathing exercise
        },
      },
      {
        'title': 'Journal Prompt',
        'description': 'What are three things youre grateful for today?',
      'icon': Icons.book,
      'color': Colors.green,
      'action': () {
        // Navigate to journal with this prompt
      },
      },
      {
        'title': 'CBT Exercise',
        'description': 'Challenge negative thoughts with cognitive restructuring',
        'icon': Icons.psychology,
        'color': Colors.purple,
        'action': () {
          // Navigate to CBT exercise
        },
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended for You',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ...recommendations.map((recommendation) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: recommendation['action'] as VoidCallback,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (recommendation['color'] as Color).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          recommendation['icon'] as IconData,
                          color: recommendation['color'] as Color,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recommendation['title'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              recommendation['description'] as String,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

