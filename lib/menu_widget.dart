import 'package:flutter/material.dart';
import 'app_theme.dart';

class MenuWidget extends StatelessWidget {
  final Animation<double> animation;
  final VoidCallback toggleMenu;
  final VoidCallback onMoodCheckIn;
  final VoidCallback onVoiceNote;
  final VoidCallback onAddPhoto;

  const MenuWidget({
    super.key,
    required this.animation,
    required this.toggleMenu,
    required this.onMoodCheckIn,
    required this.onVoiceNote,
    required this.onAddPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Positioned(
          bottom: 72.0 + (1 - animation.value) * 72.0,
          left: 16.0,
          right: 16.0,
          child: Opacity(
            opacity: animation.value,
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMenuItem(
                    icon: Icons.mood,
                    label: 'Mood check-in',
                    onTap: onMoodCheckIn,
                  ),
                  _buildMenuItem(
                    icon: Icons.mic,
                    label: 'Voice note',
                    onTap: onVoiceNote,
                  ),
                  _buildMenuItem(
                    icon: Icons.camera_alt,
                    label: 'Add photo',
                    onTap: onAddPhoto,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(label),
      onTap: onTap,
    );
  }
}// TODO Implement this library.