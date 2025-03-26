import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'support_style.dart';

class ChallengeSelection extends StatefulWidget {
  const ChallengeSelection({super.key});

  @override
  State<ChallengeSelection> createState() => _ChallengeSelectionState();
}

class _ChallengeSelectionState extends State<ChallengeSelection> {
  // List of all challenges
  final List<ChallengeItem> challenges = [
    ChallengeItem(title: 'Anxiety', icon: Icons.sentiment_dissatisfied, color: Color(0xFFFFB5A7), isSelected: false),
    ChallengeItem(title: 'Motivation', icon: Icons.emoji_objects, color: Color(0xFFBDE0FE), isSelected: false),
    ChallengeItem(title: 'Confidence', icon: Icons.trending_up, color: Color(0xFFFCD5CE), isSelected: false),
    ChallengeItem(title: 'Sleep', icon: Icons.nightlight_round, color: Color(0xFFA2D2FF), isSelected: false),
    ChallengeItem(title: 'Depression', icon: Icons.cloud, color: Color(0xFFCCD5AE), isSelected: false),
    ChallengeItem(title: 'Work Stress', icon: Icons.work, color: Color(0xFFDDB892), isSelected: false),
    ChallengeItem(title: 'Relationships', icon: Icons.people, color: Color(0xFFFFE5D9), isSelected: false),
    ChallengeItem(title: 'Exam Stress', icon: Icons.school, color: Color(0xFFCFBCDF), isSelected: false),
    ChallengeItem(title: 'Social Anxiety', icon: Icons.group, color: Color(0xFFF4A9A8), isSelected: false),
    ChallengeItem(title: 'Self-Esteem', icon: Icons.favorite, color: Color(0xFF98D8AA), isSelected: false),
    ChallengeItem(title: 'Procrastination', icon: Icons.access_time, color: Color(0xFFFBF8CC), isSelected: false),
    ChallengeItem(title: 'Burnout', icon: Icons.local_fire_department, color: Color(0xFFFFCFD2), isSelected: false),
  ];

  int _currentStep = 0;
  int _selectedCount = 0;
  String _name = '';
  String _age = '';
  String _goal = '';

  // Page controller for step navigation
  final PageController _pageController = PageController();

  // Text controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();

  // Steps in the selection process
  final List<SelectionStep> _steps = [
    SelectionStep(
      title: 'Select Your Challenges',
      subtitle: 'Choose the areas you want to focus on',
    ),
    SelectionStep(
      title: 'Set Your Priorities',
      subtitle: 'Arrange your challenges by importance',
    ),
    SelectionStep(
      title: 'Add Personal Details',
      subtitle: 'Help us tailor solutions to your needs',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Load user data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user != null) {
        _nameController.text = userProvider.user?.name ?? '';
        _ageController.text = userProvider.user?.age?.toString() ?? '';
        _goalController.text = userProvider.user?.goal ?? '';

        // Load selected challenges
        final savedChallenges = userProvider.selectedChallenges;
        if (savedChallenges.isNotEmpty) {
          for (var challenge in challenges) {
            if (savedChallenges.contains(challenge.title)) {
              challenge.isSelected = true;
            }
          }
          _selectedCount = savedChallenges.length;
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Add method to move to next step based on whether onboarding is complete
  void _continueOnboarding() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Save selected challenges
    final selectedChallenges = challenges
        .where((c) => c.isSelected)
        .map((c) => c.title)
        .toList();

    await userProvider.updateUserChallenges(selectedChallenges);

    // Save user details
    if (_nameController.text.isNotEmpty || _ageController.text.isNotEmpty || _goalController.text.isNotEmpty) {
      await userProvider.updateUserDetails(
        name: _nameController.text.isNotEmpty ? _nameController.text : null,
        age: _ageController.text.isNotEmpty ? int.tryParse(_ageController.text) : null,
        goal: _goalController.text.isNotEmpty ? _goalController.text : null,
      );
    }

    // Navigate to next screen
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SupportStyle()),
    );
  }

  // Update the _saveAndContinue method to call the new method
  void _saveAndContinue() {
    _continueOnboarding();
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
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildChallengeSelectionStep(),
                  _buildPriorityStep(),
                  _buildPersonalDetailsStep(),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _steps[_currentStep].title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3D5A80),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _steps[_currentStep].subtitle,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Only show selected count on the first step
              _currentStep == 0
                  ? Text(
                '$_selectedCount selected',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              )
                  : const SizedBox(),
              Text(
                'Step ${_currentStep + 1} of ${_steps.length}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentStep + 1) / _steps.length,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE07A5F)),
            minHeight: 6,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeSelectionStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        itemCount: (challenges.length / 2).ceil(),
        itemBuilder: (context, index) {
          final int startIndex = index * 2;
          final int endIndex = startIndex + 1 < challenges.length ? startIndex + 1 : startIndex;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: _ChallengeCard(
                    item: challenges[startIndex],
                    onTap: () {
                      setState(() {
                        challenges[startIndex].isSelected = !challenges[startIndex].isSelected;
                        _selectedCount = challenges.where((c) => c.isSelected).length;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: endIndex != startIndex
                      ? _ChallengeCard(
                    item: challenges[endIndex],
                    onTap: () {
                      setState(() {
                        challenges[endIndex].isSelected = !challenges[endIndex].isSelected;
                        _selectedCount = challenges.where((c) => c.isSelected).length;
                      });
                    },
                  )
                      : const SizedBox(), // Empty space if odd number of challenges
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriorityStep() {
    final selectedChallenges = challenges.where((c) => c.isSelected).toList();

    return selectedChallenges.isEmpty
        ? _buildEmptyStateMessage('Please select at least one challenge to continue')
        : Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Drag to reorder your challenges by priority',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = selectedChallenges.removeAt(oldIndex);
                  selectedChallenges.insert(newIndex, item);
                });
              },
              children: selectedChallenges.map((item) {
                return _PriorityItem(
                  key: ValueKey(item.title),
                  item: item,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetailsStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Almost there! A few more details will help us personalize your experience.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          _buildTextField(
            label: 'Name',
            hint: 'Enter your name',
            icon: Icons.person_outline,
            controller: _nameController,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Age',
            hint: 'Enter your age',
            icon: Icons.calendar_today,
            keyboardType: TextInputType.number,
            controller: _ageController,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Goal',
            hint: 'What do you hope to achieve?',
            icon: Icons.flag_outlined,
            maxLines: 3,
            controller: _goalController,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF3D5A80),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(icon, color: const Color(0xFFE07A5F)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateMessage(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
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
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SupportStyle()),
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
              onPressed: _currentStep == _steps.length - 1
                  ? _saveAndContinue
                  : (_currentStep == 0 && _selectedCount == 0)
                  ? null  // Disable if no challenges selected on first step
                  : _nextStep,
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
                _currentStep == _steps.length - 1 ? 'Submit' : 'Next',
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

class ChallengeItem {
  final String title;
  final IconData icon;
  final Color color;
  bool isSelected;

  ChallengeItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.isSelected,
  });
}

class SelectionStep {
  final String title;
  final String subtitle;

  SelectionStep({
    required this.title,
    required this.subtitle,
  });
}

class _ChallengeCard extends StatelessWidget {
  final ChallengeItem item;
  final VoidCallback onTap;

  const _ChallengeCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: item.isSelected ? item.color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: item.color,
            width: 2,
          ),
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.icon,
                    size: 32,
                    color: item.isSelected ? Colors.white : item.color,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: item.isSelected ? Colors.white : Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            if (item.isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: item.color,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PriorityItem extends StatelessWidget {
  final ChallengeItem item;

  const _PriorityItem({
    required Key key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: item.color, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              color: item.color,
            ),
          ),
          title: Text(
            item.title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(
            Icons.drag_handle,
            color: Colors.grey,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
      ),
    );
  }
}

