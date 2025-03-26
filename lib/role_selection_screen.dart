import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/navigation_provider.dart';
import 'challenge_selection.dart';
import 'home_screen.dart';
import 'counselor/counselor_dashboard.dart';
import '../services/analytics_service.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _nameEntered = false;
  bool _isLoading = false;
  bool _isTeachingStaff = true;

  @override
  void initState() {
    super.initState();
    // Pre-fill name if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user?.name != null) {
        _nameController.text = userProvider.user!.name!;
        setState(() {
          _nameEntered = _nameController.text.isNotEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveRoleAndNavigate(String role) async {
    if (!_nameEntered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Save name
    await userProvider.updateUserName(_nameController.text);

    // Save role
    await userProvider.updateUserRole(role);

    // Setup navigation
    Provider.of<NavigationProvider>(context, listen: false).setCurrentIndex(0);

    setState(() {
      _isLoading = false;
    });

    // Navigate to proper screen based on role
    if (role == 'counselor') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const CounselorDashboard()),
      );
    } else if (role == 'student') {
      // Check if user has completed onboarding
      if (userProvider.isOnboardingCompleted) {
        // If onboarding is complete, go to home
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
        );
      } else {
        // Start onboarding flow
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ChallengeSelection()),
        );
      }
    } else {
      // For staff roles, go directly to home
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
      );
    }
  }

  void _showStaffTypeSelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Staff Type',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  title: const Text('Teaching Staff'),
                  leading: Radio<bool>(
                    value: true,
                    groupValue: _isTeachingStaff,
                    onChanged: (value) {
                      setState(() {
                        _isTeachingStaff = value!;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Non-Teaching Staff'),
                  leading: Radio<bool>(
                    value: false,
                    groupValue: _isTeachingStaff,
                    onChanged: (value) {
                      setState(() {
                        _isTeachingStaff = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _saveRoleAndNavigate(_isTeachingStaff ? 'teaching_staff' : 'non_teaching_staff');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                'Welcome to MindWell',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Please enter your name and select your role to continue',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  hintText: 'Enter your full name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: (value) {
                  setState(() {
                    _nameEntered = value.isNotEmpty;
                  });
                },
              ),
              const SizedBox(height: 30),
              Text(
                'Select your role:',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                child: GridView.count(
                  crossAxisCount: 1,
                  childAspectRatio: 2.5,
                  mainAxisSpacing: 20,
                  children: [
                    _buildRoleCard(
                      title: 'Counselor',
                      description: 'Manage appointments and support students/staff',
                      icon: Icons.psychology,
                      onTap: () => _saveRoleAndNavigate('counselor'),
                    ),
                    _buildRoleCard(
                      title: 'Student',
                      description: 'Access mental health resources and support',
                      icon: Icons.school,
                      onTap: () => _saveRoleAndNavigate('student'),
                    ),
                    _buildRoleCard(
                      title: 'Staff',
                      description: 'Access mental health resources and support',
                      icon: Icons.work,
                      onTap: _showStaffTypeSelection,
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

  Widget _buildRoleCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

