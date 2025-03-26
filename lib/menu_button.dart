import 'package:flutter/material.dart';
import 'app_theme.dart';

class MenuButton extends StatelessWidget {
  final VoidCallback onPressed;

  const MenuButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppTheme.primaryColor,
      child: const Icon(Icons.add),
    );
  }
}// TODO Implement this library.