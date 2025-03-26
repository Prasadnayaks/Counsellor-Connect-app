import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/navigation_provider.dart';
import 'home_screen.dart';

class SupportStyle extends StatefulWidget {
  const SupportStyle({super.key});

  @override
  State<SupportStyle> createState() => _SupportStyleState();
}

class _SupportStyleState extends State<SupportStyle> {
  // Selected support style
  String? _selectedStyle;

  // Current step in the information collection process
  int _currentStep = 0;

  // User responses to questions
  Map<String, dynamic> _userResponses = {};

  // Questions for each step after style selection
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'How often do you experience your challenges?',
      'options': [
        'Daily',
        'A few times a week',
        'Occasionally',
        'Rarely',
      ],
    },
    {
      'question': 'What have you tried so far to address your challenges?',
      'options': [
        'Nothing yet',
        'Self-help resources',
        'Talking with friends/family',
        'Professional support',
      ],
    },
    {
      'question': 'How do these challenges affect your academics?',
      'options': [
        'Significantly impacts my performance',
        'Sometimes affects my concentration',
        'Makes it harder to meet deadlines',
        'Minimal impact on academics',
      ],
    },
    {
      'question': 'What are your goals for seeking support?',
      'options': [
        'Better manage my emotions',
        'Improve academic performance',
        'Enhance relationships',
        'Build coping strategies',
      ],
    },
  ];

  // Text controller for the final notes field
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load user data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user != null) {
        if (userProvider.user?.supportStyle != null) {
          setState(() {
            _selectedStyle = userProvider.user?.supportStyle;
            _currentStep = 1;
          });
        }

        if (userProvider.user?.supportResponses != null) {
          setState(() {
            _userResponses = Map<String, dynamic>.from(userProvider.user!.supportResponses!);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _selectSupportStyle(String style) {
    setState(() {
      _selectedStyle = style;
      _currentStep = 1;
    });

    // Save the selected style
    Provider.of<UserProvider>(context, listen: false).updateUserSupportStyle(style);
  }

  void _answerQuestion(String answer) {
    setState(() {
      _userResponses[_questions[_currentStep - 1]['question']] = answer;
      _currentStep++;
    });

    // Save responses after each answer
    Provider.of<UserProvider>(context, listen: false).updateUserSupportResponses(_userResponses);
  }

  void _previousStep() {
    setState(() {
      _currentStep--;
    });
  }

  void _submitInformation() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Add notes to responses
    if (_notesController.text.isNotEmpty) {
      _userResponses['Additional Notes'] = _notesController.text;
      userProvider.updateUserSupportResponses(_userResponses);
    }

    // Mark onboarding as completed
    userProvider.completeOnboarding();

    // Reset navigation to home
    Provider.of<NavigationProvider>(context, listen: false).setCurrentIndex(0);

    // Navigate to the home screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressIndicator(),
            Expanded(
              child: _currentStep == 0
                  ? _buildStyleSelection()
                  : _currentStep <= _questions.length
                  ? _buildQuestionStep()
                  : _buildFinalNotes(),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String title;
    String subtitle;

    if (_currentStep == 0) {
      title = 'Adding to your space...';
      subtitle = 'Choose a style which works best for you';
    } else if (_currentStep <= _questions.length) {
      title = 'Tell us more...';
      subtitle = 'This helps your counselor understand your needs better';
    } else {
      title = 'Almost done!';
      subtitle = 'Add any additional information that might be helpful';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3D5A80),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    // Total steps includes style selection, questions, and final notes
    final totalSteps = _questions.length + 2;
    final currentProgress = _currentStep == 0 ? 1 : _currentStep + 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedStyle ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                'Step $currentProgress of $totalSteps',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: currentProgress / totalSteps,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE07A5F)),
            minHeight: 6,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          _SupportCard(
            title: 'Self-care',
            description: 'I prefer working on challenges by myself',
            color: const Color(0xFFFFE5D9),
            isSelected: _selectedStyle == 'Self-care',
            onTap: () => _selectSupportStyle('Self-care'),
          ),
          const SizedBox(height: 16),
          _SupportCard(
            title: 'Guided support',
            description: 'I would work with a therapist if it was affordable',
            color: const Color(0xFFBDE0FE),
            isSelected: _selectedStyle == 'Guided support',
            onTap: () => _selectSupportStyle('Guided support'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionStep() {
    final questionData = _questions[_currentStep - 1];
    final question = questionData['question'] as String;
    final options = questionData['options'] as List<String>;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _OptionCard(
                    title: option,
                    onTap: () => _answerQuestion(option),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalNotes() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Anything else your counselor should know?',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _notesController,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: 'Share any thoughts, concerns, or specific goals...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE7F5FD),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.privacy_tip_outlined,
                  color: Colors.blue[700],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your information will be shared only with your assigned counselor to provide better support.',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button (hidden on first step)
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // Reset navigation to home
                  Provider.of<NavigationProvider>(context, listen: false).setCurrentIndex(0);

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _currentStep == 0 && _selectedStyle == null
                  ? null // Disable if no style selected
                  : _currentStep > _questions.length
                  ? _submitInformation // Submit on final step
                  : () {
                if (_currentStep == 0) {
                  // Move to first question if we're on style selection
                  setState(() {
                    _currentStep = 1;
                  });
                } else {
                  // Move to next step
                  setState(() {
                    _userResponses[_questions[_currentStep - 1]['question']] = 'Skipped';
                    _currentStep++;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE07A5F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
                disabledBackgroundColor: const Color(0xFFE07A5F).withOpacity(0.5),
              ),
              child: Text(
                _currentStep > _questions.length ? 'Submit' : 'Continue',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _SupportCard({
    required this.title,
    required this.description,
    required this.color,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: Colors.black, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

