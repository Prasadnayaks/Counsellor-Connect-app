import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'role_selection_screen.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';
import '../services/analytics_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserAndNavigate();
  }

  Future<void> _checkUserAndNavigate() async {
    // Short delay for splash effect
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Wait for user to load
    while (userProvider.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }

    // Decide navigation based on user state
    if (userProvider.user == null) {
      // No user, go to role selection
      _navigateToRoleSelection();
    } else if (!userProvider.isUserInitialized || !userProvider.isOnboardingCompleted) {
      // User exists but role not set or onboarding not completed
      _navigateToRoleSelection();
    } else {
      // User exists and initialized, go to home
      _navigateToHome();
    }
  }

  void _navigateToRoleSelection() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
    );
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite,
              color: Colors.white,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              'MindfulMe',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your Mental Wellness Companion',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

