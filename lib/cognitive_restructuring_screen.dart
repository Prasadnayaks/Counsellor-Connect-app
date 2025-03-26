import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cbt_provider.dart';

class CognitiveRestructuringScreen extends StatefulWidget {
  const CognitiveRestructuringScreen({Key? key}) : super(key: key);

  @override
  _CognitiveRestructuringScreenState createState() => _CognitiveRestructuringScreenState();
}

class _CognitiveRestructuringScreenState extends State<CognitiveRestructuringScreen> {
  final _formKey = GlobalKey<FormState>();

  // Thought identification
  final _negativeThoughtController = TextEditingController();
  String? _selectedDistortion;
  final _distortionDescriptionController = TextEditingController();

  // Thought challenging
  final _challengeController = TextEditingController();
  final _balancedThoughtController = TextEditingController();

  // Mood tracking
  int _moodBefore = 5;
  int _moodAfter = 5;
  bool _showMoodAfter = false;

  // Notes
  final _notesController = TextEditingController();
  final _insightsController = TextEditingController();

  // Cognitive distortions
  final List<Map<String, String>> _cognitiveDistortions = [
  {
  'name': 'All-or-Nothing Thinking',
  'description': 'Seeing things in black and white categories, with no middle ground.',
},
{
'name': 'Overgeneralization',
'description': 'Viewing a negative event as a never-ending pattern of defeat.',
},
{
'name': 'Mental Filter',
'description': 'Focusing on a single negative detail and dwelling on it exclusively.',
},
{
'name': 'Disqualifying the Positive',
'description': 'Rejecting positive experiences by insisting they "dont count."',
},
{
'name': 'Jumping to Conclusions',
'description': 'Making negative interpretations without definite facts.',
},
{
'name': 'Magnification or Minimization',
'description': 'Exaggerating the importance of problems or minimizing positive qualities.',
},
{
'name': 'Emotional Reasoning',
'description': 'Assuming that negative emotions reflect the way things really are.',
},
{
'name': 'Should Statements',
'description': 'Having rigid rules about how you or others "should" behave.',
},
{
'name': 'Labeling',
'description': 'Attaching a negative label to yourself or others instead of describing behavior.',
},
{
'name': 'Personalization',
'description': 'Seeing yourself as the cause of external negative events.',
},
];

@override
void dispose() {
  _negativeThoughtController.dispose();
  _distortionDescriptionController.dispose();
  _challengeController.dispose();
  _balancedThoughtController.dispose();
  _notesController.dispose();
  _insightsController.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Cognitive Restructuring'),
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
            _buildThoughtIdentification(),
            const SizedBox(height: 24),
            _buildThoughtChallenging(),
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
            'Cognitive Restructuring',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Cognitive restructuring helps you identify and challenge negative thinking patterns and replace them with more balanced thoughts.',
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

Widget _buildThoughtIdentification() {
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
            'Identify Negative Thought',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _negativeThoughtController,
            decoration: const InputDecoration(
              labelText: 'Negative Thought',
              hintText: 'What negative thought are you having?',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a negative thought';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Identify Cognitive Distortion',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Cognitive Distortion',
              border: OutlineInputBorder(),
            ),
            hint: const Text('Select a cognitive distortion'),
            value: _selectedDistortion,
            items: _cognitiveDistortions
                .map((distortion) => DropdownMenuItem(
              value: distortion['name'],
              child: Text(distortion['name']!),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedDistortion = value;
                if (value != null) {
                  final description = _cognitiveDistortions
                      .firstWhere((d) => d['name'] == value)['description'];
                  _distortionDescriptionController.text = description ?? '';
                }
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a cognitive distortion';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _distortionDescriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            readOnly: true,
          ),
        ],
      ),
    ),
  );
}

Widget _buildThoughtChallenging() {
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
            'Challenge the Thought',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ask yourself: Is this thought based on facts or feelings? What evidence contradicts this thought? How would I advise a friend with this thought?',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _challengeController,
            decoration: const InputDecoration(
              labelText: 'Challenge',
              hintText: 'How can you challenge this negative thought?',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a challenge to the thought';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Create a Balanced Thought',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a more balanced, realistic alternative to your negative thought.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _balancedThoughtController,
            decoration: const InputDecoration(
              labelText: 'Balanced Thought',
              hintText: 'What is a more balanced way to think about this?',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a balanced thought';
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
            label: const Text('Complete Restructuring'),
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
            'How are you feeling after restructuring your thought?',
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
      'negativeThought': _negativeThoughtController.text,
      'cognitiveDistortion': _selectedDistortion,
      'distortionDescription': _distortionDescriptionController.text,
      'challenge': _challengeController.text,
      'balancedThought': _balancedThoughtController.text,
      'moodBefore': _moodBefore,
      'moodAfter': _moodAfter,
    };

    // Save the session
    cbtProvider.saveSession(
      title: 'Cognitive Restructuring',
      technique: 'cognitive_restructuring',
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

