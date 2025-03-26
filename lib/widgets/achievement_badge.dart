import 'package:flutter/material.dart';
import 'dart:math' as math;

class AchievementBadge extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const AchievementBadge({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.isUnlocked,
    this.onTap,
  }) : super(key: key);

  @override
  _AchievementBadgeState createState() => _AchievementBadgeState();
}

class _AchievementBadgeState extends State<AchievementBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isUnlocked) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AchievementBadge oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isUnlocked && widget.isUnlocked) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isUnlocked ? _scaleAnimation.value : 1.0,
            child: Transform.rotate(
              angle: widget.isUnlocked ? _rotationAnimation.value : 0.0,
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isUnlocked
                ? widget.color.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.isUnlocked
                  ? widget.color
                  : Colors.grey.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: widget.isUnlocked
                ? [
              BoxShadow(
                color: widget.color.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: widget.isUnlocked ? widget.color : Colors.grey,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                widget.title,
                style: TextStyle(
                  color: widget.isUnlocked ? widget.color : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

