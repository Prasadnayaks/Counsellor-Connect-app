import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'mood_provider.dart';
import 'mood_entry.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({Key? key}) : super(key: key);

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'History'),
            Tab(text: 'Insights'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MoodHistoryTab(),
          _MoodInsightsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddMoodDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddMoodDialog() {
    String selectedMood = 'Good';
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('How are you feeling?'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMoodOption('😢', 'Sad', selectedMood, (mood) {
                          setState(() {
                            selectedMood = mood;
                          });
                        }),
                        _buildMoodOption('😐', 'Okay', selectedMood, (mood) {
                          setState(() {
                            selectedMood = mood;
                          });
                        }),
                        _buildMoodOption('🙂', 'Good', selectedMood, (mood) {
                          setState(() {
                            selectedMood = mood;
                          });
                        }),
                        _buildMoodOption('😄', 'Great', selectedMood, (mood) {
                          setState(() {
                            selectedMood = mood;
                          });
                        }),
                        _buildMoodOption('🤩', 'Amazing', selectedMood, (mood) {
                          setState(() {
                            selectedMood = mood;
                          });
                        }),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: 'Add a note (optional)',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
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
                    final moodProvider = Provider.of<MoodProvider>(context, listen: false);

                    moodProvider.addMoodEntry(
                      selectedMood,
                      noteController.text.isEmpty ? "Feeling $selectedMood" : noteController.text,
                    );

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Mood saved: $selectedMood')),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMoodOption(String emoji, String label, String selectedMood, Function(String) onSelect) {
    final isSelected = selectedMood == label;

    return Column(
      children: [
        InkWell(
          onTap: () => onSelect(label),
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: isSelected
                  ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                  : null,
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
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[800],
          ),
        ),
      ],
    );
  }
}

class _MoodHistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, child) {
        final entries = moodProvider.moodEntries;

        if (entries.isEmpty) {
          return _buildEmptyState();
        }

        // Group entries by date
        final Map<String, List<MoodEntry>> entriesByDate = {};

        for (var entry in entries) {
          final dateStr = DateFormat('yyyy-MM-dd').format(entry.timestamp);

          if (!entriesByDate.containsKey(dateStr)) {
            entriesByDate[dateStr] = [];
          }

          entriesByDate[dateStr]!.add(entry);
        }

        // Sort dates in descending order
        final sortedDates = entriesByDate.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            final dateStr = sortedDates[index];
            final dateEntries = entriesByDate[dateStr]!;
            final date = DateFormat('yyyy-MM-dd').parse(dateStr);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    DateFormat('EEEE, MMMM d').format(date),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                ...dateEntries.map((entry) => _buildMoodEntryCard(context, entry)).toList(),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_neutral,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No mood entries yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your mood to see your history',
            style: TextStyle(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMoodEntryCard(BuildContext context, MoodEntry entry) {
    final Map<String, Color> moodColors = {
      'Sad': Colors.blue,
      'Okay': Colors.amber,
      'Good': Colors.green,
      'Great': Colors.orange,
      'Amazing': Colors.purple,
    };

    final color = moodColors[entry.mood] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                  _getMoodEmoji(entry.mood),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.mood,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        DateFormat('h:mm a').format(entry.timestamp),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  if (entry.note.isNotEmpty && entry.note != "Feeling ${entry.mood}")
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        entry.note,
                        style: TextStyle(
                          color: Colors.grey[800],
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

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'Sad':
        return '😢';
      case 'Okay':
        return '😐';
      case 'Good':
        return '🙂';
      case 'Great':
        return '😄';
      case 'Amazing':
        return '🤩';
      default:
        return '🙂';
    }
  }
}

class _MoodInsightsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, child) {
        final entries = moodProvider.moodEntries;

        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.insights,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No data available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track your mood to see insights and patterns',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Get mood distribution
        final distribution = moodProvider.getMoodDistribution();

        // Calculate percentages
        final total = distribution.values.fold(0, (sum, count) => sum + count);
        final percentages = <String, double>{};

        distribution.forEach((mood, count) {
          percentages[mood] = (count / total) * 100;
        });

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMoodDistributionChart(context, percentages),
              const SizedBox(height: 24),
              _buildMoodSummary(context, distribution, total),
              const SizedBox(height: 24),
              _buildWeeklyTrendChart(context, moodProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoodDistributionChart(BuildContext context, Map<String, double> percentages) {
    final Map<String, Color> moodColors = {
      'Sad': Colors.blue,
      'Okay': Colors.amber,
      'Good': Colors.green,
      'Great': Colors.orange,
      'Amazing': Colors.purple,
    };

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mood Distribution',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: percentages.entries.map((entry) {
                    return PieChartSectionData(
                      color: moodColors[entry.key] ?? Colors.grey,
                      value: entry.value,
                      title: '${entry.value.toStringAsFixed(1)}%',
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: percentages.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: moodColors[entry.key] ?? Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${entry.value.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSummary(BuildContext context, Map<String, int> distribution, int total) {
    // Find most common mood
    String? mostCommonMood;
    int mostCommonCount = 0;

    distribution.forEach((mood, count) {
      if (count > mostCommonCount) {
        mostCommonCount = count;
        mostCommonMood = mood;
      }
    });

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You have recorded your mood $total times.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            if (mostCommonMood != null)
              Text(
                'Your most common mood is "$mostCommonMood".',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyTrendChart(BuildContext context, MoodProvider moodProvider) {
    // Get entries for the last 7 days
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final weekEntries = moodProvider.getMoodEntriesForRange(weekAgo, now);

    // Map moods to numeric values for the chart
    final Map<String, double> moodValues = {
      'Sad': 1,
      'Okay': 2,
      'Good': 3,
      'Great': 4,
      'Amazing': 5,
    };

    // Group entries by day
    final Map<int, List<MoodEntry>> entriesByDay = {};

    for (var i = 0; i < 7; i++) {
      entriesByDay[i] = [];
    }

    for (var entry in weekEntries) {
      final daysAgo = now.difference(entry.timestamp).inDays;
      if (daysAgo < 7) {
        entriesByDay[daysAgo]!.add(entry);
      }
    }

    // Calculate average mood for each day
    final List<FlSpot> spots = [];

    for (var i = 6; i >= 0; i--) {
      final dayEntries = entriesByDay[i]!;
      if (dayEntries.isNotEmpty) {
        double sum = 0;
        for (var entry in dayEntries) {
          sum += moodValues[entry.mood] ?? 3;
        }
        spots.add(FlSpot(6 - i.toDouble(), sum / dayEntries.length));
      } else {
        // Add null spot for days with no entries
        // This ensures the line doesn't connect across days with no data
        if (spots.isNotEmpty && i < 6) {
          // Only add null spots between existing data points
          spots.add(FlSpot.nullSpot);
        }
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Trend',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: spots.isEmpty
                  ? Center(
                child: Text(
                  'Not enough data for weekly trend',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              )
                  : LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < 0 || value.toInt() > 6) {
                            return const SideTitleWidget(
                              axisSide: AxisSide.bottom,
                              child: Text(''),
                            );
                          }
                          final weekday = now.subtract(Duration(days: 6 - value.toInt())).weekday;
                          final day = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][weekday - 1];
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              day,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < 1 || value.toInt() > 5) {
                            return const SideTitleWidget(
                              axisSide: AxisSide.left,
                              child: Text(''),
                            );
                          }
                          String mood = '';
                          switch (value.toInt()) {
                            case 1:
                              mood = 'Sad';
                              break;
                            case 2:
                              mood = 'Okay';
                              break;
                            case 3:
                              mood = 'Good';
                              break;
                            case 4:
                              mood = 'Great';
                              break;
                            case 5:
                              mood = 'Amazing';
                              break;
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              mood,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                        reservedSize: 60,
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 6,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
