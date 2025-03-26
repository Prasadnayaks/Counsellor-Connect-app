import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';

class CustomBottomNavigation extends StatelessWidget {
  const CustomBottomNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home,
                label: 'Home',
                index: 0,
                navigationProvider: navigationProvider,
              ),
              _buildNavItem(
                context,
                icon: Icons.psychology,
                label: 'CBT',
                index: 1,
                navigationProvider: navigationProvider,
              ),
              _buildNavItem(
                context,
                icon: Icons.spa,
                label: 'Relax',
                index: 2,
                navigationProvider: navigationProvider,
              ),
              _buildNavItem(
                context,
                icon: Icons.calendar_today,
                label: 'Appointment',
                index: 3,
                navigationProvider: navigationProvider,
              ),
              _buildNavItem(
                context,
                icon: Icons.person,
                label: 'Profile',
                index: 4,
                navigationProvider: navigationProvider,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required int index,
        required NavigationProvider navigationProvider,
      }) {
    final isSelected = navigationProvider.currentIndex == index;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: () => navigationProvider.setCurrentIndex(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isSelected ? primaryColor : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? primaryColor : Colors.grey,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}