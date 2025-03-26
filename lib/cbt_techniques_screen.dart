import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../providers/cbt_provider.dart';
import 'models/cbt_session.dart';
import 'thought_record_screen.dart';
import 'cognitive_restructuring_screen.dart';
import 'behavioral_activation_screen.dart';
import 'dart:math';

class CBTTechniquesScreen extends StatefulWidget {
  const CBTTechniquesScreen({Key? key}) : super(key: key);

  @override
  State<CBTTechniquesScreen> createState() => _CBTTechniquesScreenState();
}

class _CBTTechniquesScreenState extends State<CBTTechniquesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ConfettiController _confettiController;
  bool _showMoodBoost = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    // Show mood boost card with 30% probability when opening the screen
    if (Random().nextDouble() < 0.3) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _showMoodBoost = true;
        });
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CBTProvider>(
        builder: (context, cbtProvider, child) {
          final sessionCount = cbtProvider.allSessions.length;
          final streak = cbtProvider.currentStreak;

          return Stack(
            children: [
              NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 200.0,
                      floating: false,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        title: const Text(
                          'CBT Toolkit',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        background: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.purple[800]!,
                                Colors.blue[700]!,
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: 20,
                                bottom: 20,
                                child: Row(
                                  children: [
                                    _buildStatBadge(
                                      icon: Icons.check_circle,
                                      value: sessionCount.toString(),
                                      label: 'Sessions',
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 12),
                                    _buildStatBadge(
                                      icon: Icons.local_fire_department,
                                      value: '$streak',
                                      label: 'Streak',
                                      color: Colors.orange,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      bottom: TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.white,
                        tabs: const [
                          Tab(text: 'Exercises'),
                          Tab(text: 'Progress'),
                          Tab(text: 'Learn'),
                        ],
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildExercisesTab(context),
                    _buildProgressTab(context, cbtProvider),
                    _buildLearnTab(context),
                  ],
                ),
              ),

              // Confetti effect for achievements
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: pi / 2,
                  maxBlastForce: 5,
                  minBlastForce: 1,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  gravity: 0.1,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple
                  ],
                ),
              ),

              // Quick mood boost card
              if (_showMoodBoost)
                _buildMoodBoostCard(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showQuickExerciseDialog(context);
        },
        backgroundColor: Colors.purple[700],
        child: const Icon(Icons.psychology, color: Colors.white),
        tooltip: 'Quick Exercise',
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Daily recommendation
          _buildDailyRecommendation(context),
          const SizedBox(height: 24),

          // Main exercises
          const Text(
            'CBT Exercises',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _buildExerciseCard(
            context,
            title: 'Thought Reframing',
            description: 'Challenge negative thoughts and develop more balanced perspectives',
            icon: Icons.psychology,
            color: Colors.blue[700]!,
            duration: '5-10 min',
            difficulty: 'Beginner',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CognitiveRestructuringScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 16),
          _buildExerciseCard(
            context,
            title: 'Thought Record',
            description: 'Identify and analyze thoughts, emotions, and behaviors',
            icon: Icons.note_alt,
            color: Colors.green[700]!,
            duration: '5-10 min',
            difficulty: 'Intermediate',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ThoughtRecordScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 16),
          _buildExerciseCard(
            context,
            title: 'Behavioral Activation',
            description: 'Increase engagement in positive and rewarding activities',
            icon: Icons.directions_run,
            color: Colors.orange[700]!,
            duration: '10-15 min',
            difficulty: 'Intermediate',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BehavioralActivationScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Quick exercises section
          const Text(
            'Quick Exercises',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildQuickExerciseCard(
                  title: 'Gratitude',
                  icon: Icons.favorite,
                  color: Colors.pink[400]!,
                  onTap: () => _showGratitudeExercise(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickExerciseCard(
                  title: 'Deep Breathing',
                  icon: Icons.air,
                  color: Colors.teal[400]!,
                  onTap: () => _showBreathingExercise(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickExerciseCard(
                  title: 'Grounding',
                  icon: Icons.spa,
                  color: Colors.amber[700]!,
                  onTap: () => _showGroundingExercise(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRecommendation(BuildContext context) {
    // Randomly select a recommendation
    final recommendations = [
      {
        'title': 'Feeling stressed?',
        'exercise': 'Thought Reframing',
        'icon': Icons.psychology,
        'color': Colors.blue[700]!,
        'screen': const CognitiveRestructuringScreen(),
      },
      {
        'title': 'Feeling down?',
        'exercise': 'Behavioral Activation',
        'icon': Icons.directions_run,
        'color': Colors.orange[700]!,
        'screen': const BehavioralActivationScreen(),
      },
      {
        'title': 'Overthinking?',
        'exercise': 'Thought Record',
        'icon': Icons.note_alt,
        'color': Colors.green[700]!,
        'screen': const ThoughtRecordScreen(),
      },
    ];

    final recommendation = recommendations[DateTime.now().day % recommendations.length];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            recommendation['color'] as Color,
            (recommendation['color'] as Color).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => recommendation['screen'] as Widget,
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  recommendation['icon'] as IconData,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation['title'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Try ${recommendation['exercise']} today',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
      BuildContext context, {
        required String title,
        required String description,
        required IconData icon,
        required Color color,
        required String duration,
        required String difficulty,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        duration,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.fitness_center, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        difficulty,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Start'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickExerciseCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                '1 min',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressTab(BuildContext context, CBTProvider cbtProvider) {
    final sessions = cbtProvider.allSessions;
    final recentSessions = cbtProvider.recentSessions;

    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology_alt,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No CBT sessions yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your first exercise to see progress',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _tabController.animateTo(0);
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start an Exercise'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress summary
          _buildProgressSummary(cbtProvider),
          const SizedBox(height: 24),

          // Recent sessions
          const Text(
            'Recent Sessions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          ...recentSessions.map((session) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getTechniqueColor(session.technique).withOpacity(0.2),
                  child: Icon(
                    _getTechniqueIcon(session.technique),
                    color: _getTechniqueColor(session.technique),
                  ),
                ),
                title: Text(session.technique),
                subtitle: Text(
                  '${_formatDate(session.timestamp)} • ${session.durationMinutes} min',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showSessionDetails(context, session);
                },
              ),
            );
          }).toList(),

          const SizedBox(height: 24),

          // Technique breakdown
          const Text(
            'Technique Breakdown',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _buildTechniqueBreakdown(cbtProvider),
        ],
      ),
    );
  }

  Widget _buildProgressSummary(CBTProvider cbtProvider) {
    final sessionCount = cbtProvider.allSessions.length;
    final streak = cbtProvider.currentStreak;
    final mostUsed = cbtProvider.mostUsedTechnique;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple[700]!,
            Colors.blue[700]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
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
          const Text(
            'Your Progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressStat(
                value: sessionCount.toString(),
                label: 'Total Sessions',
                icon: Icons.check_circle,
              ),
              _buildProgressStat(
                value: streak.toString(),
                label: 'Day Streak',
                icon: Icons.local_fire_department,
              ),
              _buildProgressStat(
                value: mostUsed,
                label: 'Most Used',
                icon: Icons.star,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTechniqueBreakdown(CBTProvider cbtProvider) {
    final sessions = cbtProvider.allSessions;

    // Count sessions by technique
    final techniqueCounts = <String, int>{};
    for (var session in sessions) {
      if (techniqueCounts.containsKey(session.technique)) {
        techniqueCounts[session.technique] = techniqueCounts[session.technique]! + 1;
      } else {
        techniqueCounts[session.technique] = 1;
      }
    }

    // Sort techniques by count
    final sortedTechniques = techniqueCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedTechniques.map((entry) {
        final technique = entry.key;
        final count = entry.value;
        final percentage = (count / sessions.length * 100).round();

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getTechniqueIcon(technique),
                        color: _getTechniqueColor(technique),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        technique,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$count sessions ($percentage%)',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: count / sessions.length,
                backgroundColor: Colors.grey[200],
                color: _getTechniqueColor(technique),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLearnTab(BuildContext context) {
    final articles = [
      {
        'title': 'What is CBT?',
        'description': 'Learn the basics of Cognitive Behavioral Therapy',
        'icon': Icons.psychology,
        'color': Colors.blue[700]!,
      },
      {
        'title': 'Identifying Cognitive Distortions',
        'description': 'Common thinking patterns that can lead to negative emotions',
        'icon': Icons.lightbulb,
        'color': Colors.amber[700]!,
      },
      {
        'title': 'The ABC Model',
        'description': 'Understanding the connection between thoughts, feelings, and behaviors',
        'icon': Icons.account_tree,
        'color': Colors.green[700]!,
      },
      {
        'title': 'Building Healthy Habits',
        'description': 'How to create and maintain positive behavioral changes',
        'icon': Icons.fitness_center,
        'color': Colors.purple[700]!,
      },
      {
        'title': 'Managing Stress with CBT',
        'description': 'Practical techniques to reduce stress and anxiety',
        'icon': Icons.spa,
        'color': Colors.teal[700]!,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Learn About CBT',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          ...articles.map((article) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  _showArticleDialog(context, article);
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          article['icon'] as IconData,
                          color: article['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article['title'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              article['description'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 24),
          const Text(
            'Video Tutorials',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _buildVideoCard(
            title: 'Introduction to CBT',
            duration: '3:45',
            thumbnail: 'https://via.placeholder.com/300x200',
          ),
          const SizedBox(height: 16),
          _buildVideoCard(
            title: 'How to Challenge Negative Thoughts',
            duration: '5:20',
            thumbnail: 'https://via.placeholder.com/300x200',
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard({
    required String title,
    required String duration,
    required String thumbnail,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Play video
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  thumbnail,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          duration,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodBoostCard() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quick Mood Boost',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _showMoodBoost = false;
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Take a moment to practice gratitude. What\'s one thing you appreciate today?',
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showMoodBoost = false;
                      });
                    },
                    child: const Text('Later'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showMoodBoost = false;
                      });
                      _showGratitudeExercise(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[700],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Try Now'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickExerciseDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Exercises',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose a quick exercise to improve your mood',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildQuickExerciseOption(
                    context,
                    title: 'Gratitude Practice',
                    description: 'Reflect on things you\'re thankful for',
                    icon: Icons.favorite,

                    color: Colors.pink[400]!,
                    onTap: () {
                      Navigator.pop(context);
                      _showGratitudeExercise(context);
                    },
                  ),

                  const SizedBox(height: 16),
                  _buildQuickExerciseOption(
                    context,
                    title: 'Deep Breathing',
                    description: 'Calm your mind with guided breathing',
                    icon: Icons.air,
                    color: Colors.teal[400]!,
                    onTap: () {
                      Navigator.pop(context);
                      _showBreathingExercise(context);
                    },
                  ),

                  const SizedBox(height: 16),
                  _buildQuickExerciseOption(
                    context,
                    title: '5-4-3-2-1 Grounding',
                    description: 'Connect with your senses to reduce anxiety',
                    icon: Icons.spa,
                    color: Colors.amber[700]!,
                    onTap: () {
                      Navigator.pop(context);
                      _showGroundingExercise(context);
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

  Widget _buildQuickExerciseOption(
      BuildContext context, {
        required String title,
        required String description,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  void _showGratitudeExercise(BuildContext context) {
    final gratitudeController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: Colors.pink[400],
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Gratitude Practice',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'What are you grateful for today?',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: gratitudeController,
                decoration: const InputDecoration(
                  hintText: 'I am grateful for...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                autofocus: true,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (gratitudeController.text.isNotEmpty) {
                        Navigator.pop(context);
                        _saveQuickExercise('Gratitude Practice');
                        _showCompletionDialog(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[400],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showBreathingExercise(BuildContext context) {
    int secondsRemaining = 60;
    bool isBreathingIn = true;
    int breathCount = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Start the timer
            Future.delayed(const Duration(seconds: 1), () {
              if (secondsRemaining > 0 && Navigator.of(context).canPop()) {
                setState(() {
                  secondsRemaining--;
                  if (isBreathingIn && secondsRemaining % 8 == 0) {
                    isBreathingIn = false;
                  } else if (!isBreathingIn && secondsRemaining % 4 == 0) {
                    isBreathingIn = true;
                    breathCount++;
                  }
                });
              } else if (secondsRemaining == 0 && Navigator.of(context).canPop()) {
                Navigator.pop(context);
                _saveQuickExercise('Deep Breathing');
                _showCompletionDialog(context);
              }
            });

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Deep Breathing',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedContainer(
                    duration: const Duration(seconds: 4),
                    width: isBreathingIn ? 150 : 100,
                    height: isBreathingIn ? 150 : 100,
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        isBreathingIn ? 'Breathe In' : 'Breathe Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Time remaining: $secondsRemaining seconds',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Breaths completed: $breathCount',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Stop'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showGroundingExercise(BuildContext context) {
    final steps = [
      {
        'title': '5 Things You Can See',
        'description': 'Look around and name 5 things you can see right now.',
        'icon': Icons.visibility,
      },
      {
        'title': '4 Things You Can Touch',
        'description': 'Notice 4 things you can physically feel.',
        'icon': Icons.touch_app,
      },
      {
        'title': '3 Things You Can Hear',
        'description': 'Listen for 3 sounds in your environment.',
        'icon': Icons.hearing,
      },
      {
        'title': '2 Things You Can Smell',
        'description': 'Notice 2 scents around you.',
        'icon': Icons.air,
      },
      {
        'title': '1 Thing You Can Taste',
        'description': 'Notice 1 taste in your mouth.',
        'icon': Icons.restaurant,
      },
    ];

    int currentStep = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Grounding Exercise',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (currentStep + 1) / steps.length,
                    backgroundColor: Colors.grey[200],
                    color: Colors.amber[700],
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 24),
                  Icon(
                    steps[currentStep]['icon'] as IconData,
                    size: 48,
                    color: Colors.amber[700],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    steps[currentStep]['title'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    steps[currentStep]['description'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
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
                ElevatedButton(
                  onPressed: () {
                    if (currentStep < steps.length - 1) {
                      setState(() {
                        currentStep++;
                      });
                    } else {
                      Navigator.pop(context);
                      _saveQuickExercise('Grounding Exercise');
                      _showCompletionDialog(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    foregroundColor: Colors.white,
                  ),
                  child: Text(currentStep < steps.length - 1 ? 'Next' : 'Finish'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showArticleDialog(BuildContext context, Map<String, dynamic> article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          article['title'] as String,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Article content would go here
                  const Text(
                    'This is a placeholder for the article content. In a real app, this would contain the full article text with formatting, images, and other elements.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  // More placeholder content
                  const Text(
                    'Cognitive Behavioral Therapy (CBT) is a form of psychological treatment that has been demonstrated to be effective for a range of problems including depression, anxiety disorders, alcohol and drug use problems, marital problems, eating disorders, and severe mental illness.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Numerous research studies suggest that CBT leads to significant improvement in functioning and quality of life. In many studies, CBT has been demonstrated to be as effective as, or more effective than, other forms of psychological therapy or psychiatric medications.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _saveQuickExercise(String technique) {
    final cbtProvider = Provider.of<CBTProvider>(context, listen: false);

    cbtProvider.addSession(
      technique: technique,
      durationMinutes: 1,
      notes: 'Quick exercise completed',
      insights: 'Used for immediate mood improvement',
    );

    // Check if this is the first exercise - if so, trigger confetti
    if (cbtProvider.allSessions.length == 1) {
      _confettiController.play();
    }
  }

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Great Job!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You\'ve completed your exercise. Keep up the good work!',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showSessionDetails(BuildContext context, CBTSession session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getTechniqueIcon(session.technique),
                            color: _getTechniqueColor(session.technique),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            session.technique,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_formatDate(session.timestamp)} • ${session.durationMinutes} minutes',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Divider(height: 32),
                  if (session.notes.isNotEmpty) ...[
                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      session.notes,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (session.insights.isNotEmpty) ...[
                    const Text(
                      'Insights',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      session.insights,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _getTechniqueIcon(String technique) {
    switch (technique) {
      case 'Thought Record':
        return Icons.note_alt;
      case 'Cognitive Restructuring':
        return Icons.psychology;
      case 'Behavioral Activation':
        return Icons.directions_run;
      case 'Gratitude Practice':
        return Icons.favorite;
      case 'Deep Breathing':
        return Icons.air;
      case 'Grounding Exercise':
        return Icons.spa;
      default:
        return Icons.psychology_alt;
    }
  }

  Color _getTechniqueColor(String technique) {
    switch (technique) {
      case 'Thought Record':
        return Colors.green[700]!;
      case 'Cognitive Restructuring':
        return Colors.blue[700]!;
      case 'Behavioral Activation':
        return Colors.orange[700]!;
      case 'Gratitude Practice':
        return Colors.pink[400]!;
      case 'Deep Breathing':
        return Colors.teal[400]!;
      case 'Grounding Exercise':
        return Colors.amber[700]!;
      default:
        return Colors.purple[700]!;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}

