import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cbt_provider.dart';

class ThoughtRecordScreen extends StatefulWidget {
  const ThoughtRecordScreen({Key? key}) : super(key: key);

  @override
  _ThoughtRecordScreenState createState() => _ThoughtRecordScreenState();
}

class _ThoughtRecordScreenState extends State<ThoughtRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  // Thought record fields
  final _situationController = TextEditingController();
  final _automaticThoughtController = TextEditingController();
  final _emotionsController = TextEditingController();
  final _evidenceForController = TextEditingController();
  final _evidenceAgainstController = TextEditingController();
  final _alternativeThoughtController = TextEditingController();

  // Mood tracking
  int _moodBefore = 5;
  int _moodAfter = 5;
  bool _showMoodAfter = false;

  // Notes
  final _notesController = TextEditingController();
  final _insightsController = TextEditingController();

  @override
  void dispose() {
    _situationController.dispose();
    _automaticThoughtController.dispose();
    _emotionsController.dispose();
    _evidenceForController.dispose();
    _evidenceAgainstController.dispose();
    _alternativeThoughtController.dispose();
    _notesController.dispose();
    _insightsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thought Record'),
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
              _buildSituationSection(),
              const SizedBox(height: 24),
              _buildThoughtSection(),
              const SizedBox(height: 24),
              _buildEvidenceSection(),
              const SizedBox(height: 24),
              _buildAlternativeThoughtSection(),
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
              'Thought Record',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'A thought record helps you identify and challenge negative automatic thoughts. By examining the evidence for and against these thoughts, you can develop more balanced perspectives.',
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

  Widget _buildSituationSection() {
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
              'Situation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Describe the situation that triggered your negative thoughts. When and where did it happen? Who was involved? What was happening?',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _situationController,
              decoration: const InputDecoration(
                hintText: 'Describe the situation...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please describe the situation';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThoughtSection() {
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
              'Automatic Thought',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'What thoughts automatically went through your mind in this situation?',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _automaticThoughtController,
              decoration: const InputDecoration(
                hintText: 'Write your automatic thought...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your automatic thought';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Emotions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'What emotions did you feel when you had this thought? Rate the intensity (0-100%).',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emotionsController,
              decoration: const InputDecoration(
                hintText: 'e.g., Anxiety (80%), Sadness (60%)...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please describe your emotions';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenceSection() {
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
              'Evidence For the Thought',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'What facts or evidence support this thought?',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _evidenceForController,
              decoration: const InputDecoration(
                hintText: 'List evidence supporting your thought...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please list evidence for your thought';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Evidence Against the Thought',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'What facts or evidence contradict this thought?',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _evidenceAgainstController,
              decoration: const InputDecoration(
                hintText: 'List evidence against your thought...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please list evidence against your thought';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlternativeThoughtSection() {
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
              'Alternative Thought',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Based on the evidence, what is a more balanced or realistic thought?',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _alternativeThoughtController,
              decoration: const InputDecoration(
                hintText: 'Write a more balanced thought...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an alternative thought';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _showMoodAfter = true;
                });
              },
              icon: const Icon(Icons.check),
              label: const Text('Complete Thought Record'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
              ),
            ),
          ],
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
              'How are you feeling after completing the thought record?',
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

  void _saveSession() {
    if (_formKey.currentState!.validate()) {
      final cbtProvider = Provider.of<CBTProvider>(context, listen: false);

      // Create session data
      final sessionData = {
        'situation': _situationController.text,
        'automaticThought': _automaticThoughtController.text,
        'emotions': _emotionsController.text,
        'evidenceFor': _evidenceForController.text,
        'evidenceAgainst': _evidenceAgainstController.text,
        'alternativeThought': _alternativeThoughtController.text,
        'moodBefore': _moodBefore,
        'moodAfter': _moodAfter,
      };

      // Save the session
      cbtProvider.saveSession(
        title: 'Thought Record',
        technique: 'thought_record',
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

