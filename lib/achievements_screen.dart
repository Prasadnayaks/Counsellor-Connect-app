import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/achievement_provider.dart';
import '../models/achievement.dart';
import '../widgets/achievement_badge.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  _AchievementsScreenState createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  @override
  Widget build(BuildContext context) {
    final achievementProvider = Provider.of<AchievementProvider>(context);
    final totalPoints = achievementProvider.getTotalPoints();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        elevation: 0,
      ),
      body: achievementProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildPointsHeader(totalPoints),
          Expanded(
            child: achievementProvider.achievements.isEmpty
                ? _buildEmptyState()
                : _buildAchievementsList(achievementProvider.achievements),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsHeader(int points) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Text(
            '$points',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          Text(
            'Total Points',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No achievements yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete activities to earn achievements',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsList(List<Achievement> achievements) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _buildAchievementCard(achievement);
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showAchievementDetails(achievement),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AchievementBadge(
                title: achievement.title,
                icon: achievement.icon,
                color: achievement.color,
                isUnlocked: achievement.isUnlocked,
              ),
              const SizedBox(height: 12),
              Text(
                achievement.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${achievement.points} points',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAchievementDetails(Achievement achievement) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AchievementBadge(
              title: achievement.title,
              icon: achievement.icon,
              color: achievement.color,
              isUnlocked: achievement.isUnlocked,
            ),
            const SizedBox(height: 16),
            Text(
              achievement.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Earned: ${achievement.isUnlocked ? achievement.dateUnlocked?.toString().split(' ')[0] ?? 'Unknown' : 'Not yet'}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${achievement.points} points',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

