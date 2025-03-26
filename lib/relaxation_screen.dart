import 'package:flutter/material.dart';
import 'dart:async';

class RelaxationScreen extends StatefulWidget {
  const RelaxationScreen({Key? key}) : super(key: key);

  @override
  State<RelaxationScreen> createState() => _RelaxationScreenState();
}

class _RelaxationScreenState extends State<RelaxationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showBreathingExercise = false;
  int _breathingPhase = 0; // 0: inhale, 1: hold, 2: exhale
  double _breathingProgress = 0.0;
  Timer? _breathingTimer;
  bool _isAmbientSoundPlaying = false;
  String _currentAmbientSound = "None";

  // For mood boost
  bool _showMoodBoost = false;
  String _moodBoostMessage = "";
  List<String> _moodBoostMessages = [
    "Take a moment to breathe deeply",
    "Notice 3 things you can see right now",
    "What's one small thing you're grateful for?",
    "Gently roll your shoulders to release tension",
    "Imagine a peaceful place for just 10 seconds",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Randomly show mood boost after 5 seconds
    if (DateTime.now().second % 3 == 0) { // Show randomly based on time
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _showMoodBoost = true;
            _moodBoostMessage = _moodBoostMessages[DateTime.now().second % _moodBoostMessages.length];
          });

          // Hide after 8 seconds
          Future.delayed(const Duration(seconds: 8), () {
            if (mounted) {
              setState(() {
                _showMoodBoost = false;
              });
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _breathingTimer?.cancel();
    super.dispose();
  }

  void _startBreathingExercise() {
    setState(() {
      _showBreathingExercise = true;
      _breathingPhase = 0;
      _breathingProgress = 0.0;
    });

    _breathingTimer?.cancel();
    _breathingTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _breathingProgress += 0.01;

        if (_breathingProgress >= 1.0) {
          _breathingProgress = 0.0;
          _breathingPhase = (_breathingPhase + 1) % 3;
        }
      });
    });
  }

  void _stopBreathingExercise() {
    _breathingTimer?.cancel();
    setState(() {
      _showBreathingExercise = false;
    });
  }

  void _toggleAmbientSound(String soundName) {
    setState(() {
      if (_currentAmbientSound == soundName && _isAmbientSoundPlaying) {
        _isAmbientSoundPlaying = false;
        _currentAmbientSound = "None";
      } else {
        _isAmbientSoundPlaying = true;
        _currentAmbientSound = soundName;
      }
    });

    // In a real app, you would play/stop the actual sound here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    TechniquesTab(
                      onStartBreathing: _startBreathingExercise,
                      onToggleAmbientSound: _toggleAmbientSound,
                      currentAmbientSound: _currentAmbientSound,
                      isAmbientSoundPlaying: _isAmbientSoundPlaying,
                    ),
                    VideosTab(),
                    ThoughtsTab(),
                  ],
                ),
              ),
            ],
          ),

          // Breathing exercise overlay
          if (_showBreathingExercise)
            _buildBreathingExerciseOverlay(),

          // Mood boost overlay
          if (_showMoodBoost)
            _buildMoodBoostOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
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
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Relaxation',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isAmbientSoundPlaying ? Icons.volume_up : Icons.volume_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          _toggleAmbientSound(_isAmbientSoundPlaying ? "None" : "Rain");
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_border, color: Colors.white),
                        onPressed: () {
                          // Show favorites
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Favorites coming soon!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              tabs: const [
                Tab(text: 'Techniques'),
                Tab(text: 'Videos'),
                Tab(text: 'Thoughts'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreathingExerciseOverlay() {
    String instruction = "";
    Color color;
    double size;

    switch (_breathingPhase) {
      case 0: // Inhale
        instruction = "Breathe In";
        color = Colors.blue;
        size = 150 + (100 * _breathingProgress);
        break;
      case 1: // Hold
        instruction = "Hold";
        color = Colors.green;
        size = 250;
        break;
      case 2: // Exhale
        instruction = "Breathe Out";
        color = Colors.purple;
        size = 250 - (100 * _breathingProgress);
        break;
      default:
        instruction = "Breathe";
        color = Colors.blue;
        size = 200;
    }

    return GestureDetector(
      onTap: _stopBreathingExercise,
      child: Container(
        color: Colors.black.withOpacity(0.7),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              instruction,
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            AnimatedContainer(
              duration: const Duration(milliseconds: 50),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.spa,
                  color: Colors.white,
                  size: size / 3,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              "Tap anywhere to exit",
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodBoostOverlay() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lightbulb,
                color: Colors.amber,
                size: 30,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mood Boost",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _moodBoostMessage,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _showMoodBoost = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TechniquesTab extends StatelessWidget {
  final Function onStartBreathing;
  final Function(String) onToggleAmbientSound;
  final String currentAmbientSound;
  final bool isAmbientSoundPlaying;

  const TechniquesTab({
    Key? key,
    required this.onStartBreathing,
    required this.onToggleAmbientSound,
    required this.currentAmbientSound,
    required this.isAmbientSoundPlaying,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickRelaxSection(context),
          const SizedBox(height: 25),
          _buildGuidedExercisesSection(context),
          const SizedBox(height: 25),
          _buildAmbientSoundsSection(context),
        ],
      ),
    );
  }

  Widget _buildQuickRelaxSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Relax',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildQuickRelaxCard(
                context,
                title: 'Breathing',
                icon: Icons.air,
                color: Colors.blue,
                onTap: () => onStartBreathing(),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildQuickRelaxCard(
                context,
                title: '5-4-3-2-1',
                icon: Icons.touch_app,
                color: Colors.purple,
                onTap: () {
                  _showGroundingExercise(context);
                },
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildQuickRelaxCard(
                context,
                title: 'Body Scan',
                icon: Icons.accessibility_new,
                color: Colors.teal,
                onTap: () {
                  _showBodyScanExercise(context);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickRelaxCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showGroundingExercise(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '5-4-3-2-1 Grounding',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(),
              Expanded(
                child: ListView(
                  controller: controller,
                  children: [
                    _buildGroundingStep(
                      number: "5",
                      sense: "SEE",
                      instruction: "Find 5 things you can see around you",
                      color: Colors.blue,
                      icon: Icons.visibility,
                    ),
                    _buildGroundingStep(
                      number: "4",
                      sense: "TOUCH",
                      instruction: "Find 4 things you can touch or feel",
                      color: Colors.green,
                      icon: Icons.touch_app,
                    ),
                    _buildGroundingStep(
                      number: "3",
                      sense: "HEAR",
                      instruction: "Find 3 things you can hear",
                      color: Colors.purple,
                      icon: Icons.hearing,
                    ),
                    _buildGroundingStep(
                      number: "2",
                      sense: "SMELL",
                      instruction: "Find 2 things you can smell",
                      color: Colors.orange,
                      icon: Icons.spa,
                    ),
                    _buildGroundingStep(
                      number: "1",
                      sense: "TASTE",
                      instruction: "Find 1 thing you can taste",
                      color: Colors.red,
                      icon: Icons.restaurant,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroundingStep({
    required String number,
    required String sense,
    required String instruction,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: 5),
                    Text(
                      sense,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  instruction,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBodyScanExercise(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Body Scan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Take a moment to scan your body from head to toe.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/body_scan.png',
              height: 200,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.accessibility_new,
                    size: 100,
                    color: Colors.teal,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Notice any areas of tension and consciously relax them.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Start guided body scan
            },
            child: Text('Start Guided Scan'),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidedExercisesSection(BuildContext context) {
    final List<RelaxationTechnique> _techniques = [
      RelaxationTechnique(
        title: 'Deep Breathing',
        description: 'Calm your mind with slow, deep breaths',
        icon: Icons.air,
        color: Colors.blue,
        duration: const Duration(minutes: 5),
      ),
      RelaxationTechnique(
        title: 'Progressive Muscle Relaxation',
        description: 'Release tension by tensing and relaxing muscle groups',
        icon: Icons.fitness_center,
        color: Colors.green,
        duration: const Duration(minutes: 10),
      ),
      RelaxationTechnique(
        title: 'Guided Meditation',
        description: 'Follow a guided meditation for stress relief',
        icon: Icons.self_improvement,
        color: Colors.purple,
        duration: const Duration(minutes: 15),
      ),
      RelaxationTechnique(
        title: 'Body Scan',
        description: 'Bring awareness to each part of your body',
        icon: Icons.accessibility_new,
        color: Colors.orange,
        duration: const Duration(minutes: 8),
      ),
      RelaxationTechnique(
        title: 'Visualization',
        description: 'Imagine a peaceful scene to reduce anxiety',
        icon: Icons.landscape,
        color: Colors.teal,
        duration: const Duration(minutes: 7),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Guided Exercises',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _techniques.length,
          itemBuilder: (context, index) {
            final technique = _techniques[index];
            return _buildTechniqueCard(context, technique);
          },
        ),
      ],
    );
  }

  Widget _buildTechniqueCard(BuildContext context, RelaxationTechnique technique) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RelaxationSessionScreen(technique: technique),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: technique.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  technique.icon,
                  color: technique.color,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      technique.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      technique.description,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${technique.duration.inMinutes} minutes',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
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
  }

  Widget _buildAmbientSoundsSection(BuildContext context) {
    final ambientSounds = [
      {'name': 'Rain', 'icon': Icons.water_drop, 'color': Colors.blue},
      {'name': 'Forest', 'icon': Icons.forest, 'color': Colors.green},
      {'name': 'Ocean', 'icon': Icons.waves, 'color': Colors.teal},
      {'name': 'Fire', 'icon': Icons.local_fire_department, 'color': Colors.orange},
      {'name': 'White Noise', 'icon': Icons.noise_aware, 'color': Colors.grey},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ambient Sounds',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: ambientSounds.length,
            itemBuilder: (context, index) {
              final sound = ambientSounds[index];
              final isPlaying = isAmbientSoundPlaying && currentAmbientSound == sound['name'];

              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 15),
                child: InkWell(
                  onTap: () => onToggleAmbientSound(sound['name'] as String),
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: (sound['color'] as Color).withOpacity(isPlaying ? 0.3 : 0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: (sound['color'] as Color).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              sound['icon'] as IconData,
                              color: sound['color'] as Color,
                              size: 30,
                            ),
                            if (isPlaying)
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: (sound['color'] as Color).withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          sound['name'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: sound['color'] as Color,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class VideosTab extends StatelessWidget {
  final List<RelaxationVideo> _videos = [
    RelaxationVideo(
      title: 'Calm Ocean Waves',
      description: 'Relaxing ocean sounds to help you unwind',
      thumbnailUrl: 'assets/images/ocean.jpg',
      duration: '10:15',
      category: 'Nature Sounds',
    ),
    RelaxationVideo(
      title: 'Guided Sleep Meditation',
      description: 'Fall asleep faster with this calming meditation',
      thumbnailUrl: 'assets/images/meditation.jpg',
      duration: '20:30',
      category: 'Meditation',
    ),
    RelaxationVideo(
      title: 'Relaxing Piano Music',
      description: 'Gentle piano melodies to reduce stress',
      thumbnailUrl: 'assets/images/piano.jpg',
      duration: '15:45',
      category: 'Music',
    ),
    RelaxationVideo(
      title: 'Forest Ambience',
      description: 'Immerse yourself in peaceful forest sounds',
      thumbnailUrl: 'assets/images/forest.jpg',
      duration: '12:20',
      category: 'Nature Sounds',
    ),
    RelaxationVideo(
      title: 'Breathing Exercise Tutorial',
      description: 'Learn effective breathing techniques for anxiety relief',
      thumbnailUrl: 'assets/images/breathing.jpg',
      duration: '8:45',
      category: 'Tutorial',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCategoryFilter(context),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _videos.length,
            itemBuilder: (context, index) {
              final video = _videos[index];
              return _buildVideoCard(context, video);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(context, 'All'),
          _buildFilterChip(context, 'Nature Sounds'),
          _buildFilterChip(context, 'Meditation'),
          _buildFilterChip(context, 'Music'),
          _buildFilterChip(context, 'Tutorial'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label) {
    final isSelected = label == 'All';

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {
          // Filter videos by category
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        checkmarkColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, RelaxationVideo video) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showVideoPlayer(context, video);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.asset(
                    video.thumbnailUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      video.duration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    video.description,
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      video.category,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVideoPlayer(BuildContext context, RelaxationVideo video) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(video.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.video_library,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              'Video player would appear here in a real app.',
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
      ),
    );
  }
}

class ThoughtsTab extends StatelessWidget {
  final List<RelaxationThought> _thoughts = [
    RelaxationThought(
      quote: "Breathe in peace, breathe out stress.",
      author: "Unknown",
      backgroundColor: Colors.blue.shade50,
      textColor: Colors.blue.shade800,
    ),
    RelaxationThought(
      quote: "The present moment is filled with joy and happiness. If you are attentive, you will see it.",
      author: "Thich Nhat Hanh",
      backgroundColor: Colors.green.shade50,
      textColor: Colors.green.shade800,
    ),
    RelaxationThought(
      quote: "Peace comes from within. Do not seek it without.",
      author: "Buddha",
      backgroundColor: Colors.purple.shade50,
      textColor: Colors.purple.shade800,
    ),
    RelaxationThought(
      quote: "The mind is like water. When it's turbulent, it's difficult to see. When it's calm, everything becomes clear.",
      author: "Prasad Mahes",
      backgroundColor: Colors.teal.shade50,
      textColor: Colors.teal.shade800,
    ),
    RelaxationThought(
      quote: "Tension is who you think you should be. Relaxation is who you are.",
      author: "Chinese Proverb",
      backgroundColor: Colors.orange.shade50,
      textColor: Colors.orange.shade800,
    ),
    RelaxationThought(
      quote: "Within you, there is a stillness and a sanctuary to which you can retreat at any time.",
      author: "Hermann Hesse",
      backgroundColor: Colors.pink.shade50,
      textColor: Colors.pink.shade800,
    ),
    RelaxationThought(
      quote: "The greatest weapon against stress is our ability to choose one thought over another.",
      author: "William James",
      backgroundColor: Colors.indigo.shade50,
      textColor: Colors.indigo.shade800,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _thoughts.length,
      itemBuilder: (context, index) {
        final thought = _thoughts[index];
        return _buildThoughtCard(context, thought);
      },
    );
  }

  Widget _buildThoughtCard(BuildContext context, RelaxationThought thought) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: thought.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${thought.quote}"',
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: thought.textColor,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '- ${thought.author}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: thought.textColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.favorite_border,
                    color: thought.textColor,
                  ),
                  onPressed: () {
                    // Add to favorites
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.share,
                    color: thought.textColor,
                  ),
                  onPressed: () {
                    // Share thought
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RelaxationSessionScreen extends StatefulWidget {
  final RelaxationTechnique technique;

  const RelaxationSessionScreen({
    Key? key,
    required this.technique,
  }) : super(key: key);

  @override
  State<RelaxationSessionScreen> createState() => _RelaxationSessionState();
}

class _RelaxationSessionState extends State<RelaxationSessionScreen> {
  bool _isSessionStarted = false;
  bool _isPaused = false;
  late Timer _timer;
  late Duration _remainingTime;
  int _currentStep = 0;

  // Steps for each technique
  late List<String> _steps;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.technique.duration;
    _initializeSteps();
  }

  void _initializeSteps() {
    switch (widget.technique.title) {
      case 'Deep Breathing':
        _steps = [
          'Find a comfortable position and close your eyes',
          'Breathe in slowly through your nose for 4 counts',
          'Hold your breath for 2 counts',
          'Exhale slowly through your mouth for 6 counts',
          'Repeat this breathing pattern',
        ];
        break;
      case 'Progressive Muscle Relaxation':
        _steps = [
          'Start by tensing the muscles in your feet for 5 seconds',
          'Release and relax for 10 seconds',
          'Move to your calves, tense for 5 seconds',
          'Release and relax for 10 seconds',
          'Continue up through your body: thighs, abdomen, chest, arms, hands, shoulders, neck, and face',
        ];
        break;
      case 'Guided Meditation':
        _steps = [
          'Sit or lie down in a comfortable position',
          'Close your eyes and take a few deep breaths',
          'Imagine yourself in a peaceful place',
          'Notice the details: sights, sounds, smells',
          'Feel yourself becoming more relaxed with each breath',
        ];
        break;
      case 'Body Scan':
        _steps = [
          'Lie down in a comfortable position',
          'Bring awareness to your feet, noticing any sensations',
          'Slowly move your attention up through your body',
          'Notice any areas of tension and consciously relax them',
          'Continue until you reach the top of your head',
        ];
        break;
      case 'Visualization':
        _steps = [
          'Close your eyes and take a few deep breaths',
          'Imagine a peaceful scene (beach, forest, etc.)',
          'Engage all your senses in this visualization',
          'Explore this peaceful place in your mind',
          'Feel the calm and relaxation spreading through your body',
        ];
        break;
      default:
        _steps = [
          'Find a comfortable position',
          'Close your eyes',
          'Focus on your breathing',
          'Let go of any tension',
          'Continue at your own pace',
        ];
    }
  }

  void _startSession() {
    setState(() {
      _isSessionStarted = true;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          if (_remainingTime.inSeconds > 0) {
            _remainingTime = _remainingTime - const Duration(seconds: 1);

            // Change step every minute or when time is up
            if (_remainingTime.inSeconds % 60 == 0 || _remainingTime.inSeconds == 0) {
              if (_currentStep < _steps.length - 1) {
                _currentStep++;
              }
            }
          } else {
            _timer.cancel();
            _completeSession();
          }
        });
      }
    });
  }

  void _pauseResumeSession() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _completeSession() {
    _timer.cancel();
    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Complete'),
        content: const Text('Great job! How do you feel now?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to techniques list
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (_isSessionStarted && !_remainingTime.isNegative) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.technique.title),
      ),
      body: _isSessionStarted ? _buildSessionScreen() : _buildPreSessionScreen(),
    );
  }

  Widget _buildPreSessionScreen() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: widget.technique.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.technique.icon,
                color: widget.technique.color,
                size: 50,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.technique.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.technique.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Text(
            'How to Practice:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: widget.technique.color,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _steps[index],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.technique.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Start ${widget.technique.duration.inMinutes} Minute Session',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionScreen() {
    final minutes = _remainingTime.inMinutes;
    final seconds = _remainingTime.inSeconds % 60;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$minutes:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: widget.technique.color,
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: widget.technique.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _steps[_currentStep],
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _pauseResumeSession,
                icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                label: Text(_isPaused ? 'Resume' : 'Pause'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _completeSession,
                icon: const Icon(Icons.stop),
                label: const Text('End'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RelaxationTechnique {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Duration duration;

  RelaxationTechnique({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.duration,
  });
}

class RelaxationVideo {
  final String title;
  final String description;
  final String thumbnailUrl;
  final String duration;
  final String category;

  RelaxationVideo({
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.duration,
    required this.category,
  });
}

class RelaxationThought {
  final String quote;
  final String author;
  final Color backgroundColor;
  final Color textColor;

  RelaxationThought({
    required this.quote,
    required this.author,
    required this.backgroundColor,
    required this.textColor,
  });
}

