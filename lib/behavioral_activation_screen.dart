import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cbt_provider.dart';
import '../models/cbt_session.dart';

class BehavioralActivationScreen extends StatefulWidget {
  const BehavioralActivationScreen({Key? key}) : super(key: key);

  @override
  _BehavioralActivationScreenState createState() => _BehavioralActivationScreenState();
}

class _BehavioralActivationScreenState extends State<BehavioralActivationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Activity planning
  final List<Map<String, dynamic>> _activities = [];
  final _activityController = TextEditingController();
  final _enjoymentController = TextEditingController();
  final _importanceController = TextEditingController();

  // Mood tracking
  int _moodBefore = 5;
  int _moodAfter = 5;
  bool _showMoodAfter = false;

  // Notes
  final _notesController = TextEditingController();
  final _insightsController = TextEditingController();

  @override
  void dispose() {
    _activityController.dispose();
    _enjoymentController.dispose();
    _importanceController.dispose();
    _notesController.dispose();
    _insightsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Behavioral Activation'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIntroduction(),
              const SizedBox(height: 24),
              _buildMoodTracking(),
              const SizedBox(height: 24),
              _buildActivityPlanning(),
              const SizedBox(height: 24),
              if (_showMoodAfter) ...[
                _buildMoodAfterTracking(),
                const SizedBox(height: 24),
              ],
              _buildNotes(),
              const SizedBox(height: 24),
              _buildInsights(),
              const SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroduction() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Behavioral Activation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Behavioral activation helps you engage in activities that bring enjoyment and a sense of accomplishment. This can help improve your mood and energy levels.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodTracking() {
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
              'How are you feeling right now?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Slider(
              value: _moodBefore.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: _getMoodLabel(_moodBefore),
              onChanged: (value) {
                setState(() {
                  _moodBefore = value.round();
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Very Bad'),
                Text('Neutral'),
                Text('Very Good'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityPlanning() {
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
              'Plan Activities',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _activityController,
              decoration: const InputDecoration(
                labelText: 'Activity',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an activity';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _enjoymentController,
                    decoration: const InputDecoration(
                      labelText: 'Enjoyment (1-10)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final rating = int.tryParse(value);
                      if (rating == null || rating < 1 || rating > 10) {
                        return 'Enter 1-10';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _importanceController,
                    decoration: const InputDecoration(
                      labelText: 'Importance (1-10)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final rating = int.tryParse(value);
                      if (rating == null || rating < 1 || rating > 10) {
                        return 'Enter 1-10';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addActivity,
              icon: const Icon(Icons.add),
              label: const Text('Add Activity'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 16),
            if (_activities.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Planned Activities:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._activities.map((activity) => _buildActivityItem(activity)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showMoodAfter = true;
                  });
                },
                icon: const Icon(Icons.check),
                label: const Text('Complete Activities'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(activity['activity']),
        subtitle: Text(
          'Enjoyment: ${activity['enjoyment']} | Importance: ${activity['importance']}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            setState(() {
              _activities.remove(activity);
            });
          },
        ),
      ),
    );
  }

  Widget _buildMoodAfterTracking() {
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
              'How are you feeling after completing activities?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Slider(
              value: _moodAfter.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: _getMoodLabel(_moodAfter),
              onChanged: (value) {
                setState(() {
                  _moodAfter = value.round();
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Very Bad'),
                Text('Neutral'),
                Text('Very Good'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotes() {
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
              'Notes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Add any notes about your experience...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsights() {
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
              'Insights',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _insightsController,
              decoration: const InputDecoration(
                hintText: 'What did you learn from this exercise?',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveSession,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Save Session',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  void _addActivity() {
    if (_activityController.text.isEmpty ||
        _enjoymentController.text.isEmpty ||
        _importanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _activities.add({
        'activity': _activityController.text,
        'enjoyment': int.parse(_enjoymentController.text),
        'importance': int.parse(_importanceController.text),
      });
      _activityController.clear();
      _enjoymentController.clear();
      _importanceController.clear();
    });
  }

  void _saveSession() {
    if (_formKey.currentState!.validate()) {
      if (_activities.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one activity')),
        );
        return;
      }

      final cbtProvider = Provider.of<CBTProvider>(context, listen: false);

      // Create session data
      final sessionData = {
        'activities': _activities,
        'moodBefore': _moodBefore,
        'moodAfter': _moodAfter,
        'notes': _notesController.text,
        'insights': _insightsController.text,
      };

      // Save the session
      cbtProvider.saveSession(
        title: 'Behavioral Activation',
        technique: 'behavioral_activation',
        data: sessionData,
        durationMinutes: 30,
        notes: _notesController.text,
        insights: _insightsController.text,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session saved successfully')),
      );

      // Navigate back
      Navigator.pop(context);
    }
  }

  String _getMoodLabel(int value) {
    switch (value) {
      case 1:
      case 2:
        return 'Very Bad';
      case 3:
      case 4:
        return 'Bad';
      case 5:
      case 6:
        return 'Neutral';
      case 7:
      case 8:
        return 'Good';
      case 9:
      case 10:
        return 'Very Good';
      default:
        return 'Neutral';
    }
  }
}

