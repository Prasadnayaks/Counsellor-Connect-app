import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/navigation_provider.dart';
import 'role_selection_screen.dart';
import 'challenge_selection.dart';
import 'support_style.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.userName;
    final userRole = userProvider.userRole ?? 'User';
    final age = userProvider.user?.age;
    final goal = userProvider.user?.goal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(context, userName, userRole),
            const SizedBox(height: 15),
            // Display additional user info if available
            if (age != null || goal != null)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (age != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Icon(Icons.cake, color: Colors.grey[600], size: 20),
                              const SizedBox(width: 10),
                              Text('Age: $age'),
                            ],
                          ),
                        ),
                      if (goal != null)
                        Row(
                          children: [
                            Icon(Icons.flag, color: Colors.grey[600], size: 20),
                            const SizedBox(width: 10),
                            Expanded(child: Text('Goal: $goal')),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 30),
            _buildSectionTitle(context, 'Your Preferences'),
            const SizedBox(height: 15),
            _buildPreferenceCard(
              context,
              title: 'Your Challenges',
              description: 'Manage the challenges you want to focus on',
              icon: Icons.psychology,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ChallengeSelection()),
                );
              },
            ),
            const SizedBox(height: 15),
            _buildPreferenceCard(
              context,
              title: 'Support Style',
              description: 'Change how you prefer to receive support',
              icon: Icons.support_agent,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SupportStyle()),
                );
              },
            ),
            const SizedBox(height: 30),
            _buildSectionTitle(context, 'App Settings'),
            const SizedBox(height: 15),
            _buildSettingsCard(
              context,
              title: 'Notifications',
              icon: Icons.notifications,
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // Toggle notifications
                },
              ),
            ),
            _buildSettingsCard(
              context,
              title: 'Dark Mode',
              icon: Icons.dark_mode,
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  // Toggle dark mode
                },
              ),
            ),
            _buildSettingsCard(
              context,
              title: 'Privacy Policy',
              icon: Icons.privacy_tip,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to privacy policy
              },
            ),
            _buildSettingsCard(
              context,
              title: 'Terms of Service',
              icon: Icons.description,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to terms of service
              },
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Clear user data and navigate to role selection
                  await userProvider.clearUserData();
                  Provider.of<NavigationProvider>(context, listen: false).setCurrentIndex(0);

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                        (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Change Role'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String name, String role) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            child: Icon(
              Icons.person,
              size: 50,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              role,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPreferenceCard(
      BuildContext context, {
        required String title,
        required String description,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 15),
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
                  const SizedBox(height: 5),
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
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Widget trailing,
        VoidCallback? onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.2),
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

