import 'package:flutter/material.dart';
import 'dart:math' as math;

class MoodAnimationWidget extends StatefulWidget {
  final String emoji;
  final Color color;
  final double size;

  const MoodAnimationWidget({
    Key? key,
    required this.emoji,
    required this.color,
    this.size = 100.0,
  }) : super(key: key);

  @override
  _MoodAnimationWidgetState createState() => _MoodAnimationWidgetState();
}

class _MoodAnimationWidgetState extends State<MoodAnimationWidget> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _bounceController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    // Rotation animation
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.easeInOut,
      ),
    );

    // Bounce animation
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.elasticOut,
      ),
    );

    // Start animations
    _scaleController.forward();
    _rotationController.repeat(reverse: true);

    // Start bounce after scale completes
    _scaleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _bounceController.repeat(reverse: true);
      }
      {
        if (status == AnimationStatus.completed) {
          _bounceController.repeat(reverse: true);
        }
      }
    });
    }

        @override
        void dispose() {
      _scaleController.dispose();
      _rotationController.dispose();
      _bounceController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _rotationAnimation, _bounceAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Transform.translate(
                offset: Offset(0, -5 * _bounceAnimation.value),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.emoji,
                      style: TextStyle(fontSize: widget.size * 0.5),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }

