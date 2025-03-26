import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../role_selection_screen.dart';

class CounselorProfileCreation extends StatefulWidget {
  const CounselorProfileCreation({Key? key}) : super(key: key);

  @override
  State<CounselorProfileCreation> createState() => _CounselorProfileScreenState();
}

class _CounselorProfileScreenState extends State<CounselorProfileCreation> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=32'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          // Handle profile picture update
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Dr. Jessica Parker',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Clinical Psychologist',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle('Personal Information'),
            const SizedBox(height: 16),
            _buildInfoCard(
              children: [
                _buildInfoItem(
                  icon: Icons.email,
                  title: 'Email',
                  value: 'jessica.parker@example.com',
                ),
                const Divider(),
                _buildInfoItem(
                  icon: Icons.phone,
                  title: 'Phone',
                  value: '+1 (555) 123-4567',
                ),
                const Divider(),
                _buildInfoItem(
                  icon: Icons.location_on,
                  title: 'Office',
                  value: 'Room 302, Building B',
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildSectionTitle('Specializations'),
            const SizedBox(height: 16),
            _buildInfoCard(
              children: [
                _buildSpecializationItem('Anxiety Disorders'),
                _buildSpecializationItem('Depression'),
                _buildSpecializationItem('Stress Management'),
                _buildSpecializationItem('Academic Counseling'),
                _buildSpecializationItem('Career Guidance'),
              ],
            ),
            const SizedBox(height: 30),
            _buildSectionTitle('Settings'),
            const SizedBox(height: 16),
            _buildInfoCard(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: _isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      _isDarkMode = value;
                    });
                    // Apply theme change
                  },
                  secondary: Icon(
                    _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Notifications'),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    // Apply notification settings
                  },
                  secondary: Icon(
                    Icons.notifications,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  leading: Icon(
                    Icons.lock,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () {
                    // Navigate to change password screen
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  leading: Icon(
                    Icons.privacy_tip,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () {
                    // Navigate to privacy policy screen
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  leading: Icon(
                    Icons.description,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () {
                    // Navigate to terms of service screen
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                // Log out
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('user_role');

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                      (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecializationItem(String specialization) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Text(
            specialization,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// TODO Implement this library.