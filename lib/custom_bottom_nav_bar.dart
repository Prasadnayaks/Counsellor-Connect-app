import 'package:flutter/material.dart';
import 'app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTap, // Now optional
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
      backgroundColor: AppTheme.surfaceColor,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.mood),
          label: 'Mood',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Journal',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.spa),
          label: 'Relax',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}