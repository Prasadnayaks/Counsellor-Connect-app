import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedProgressRing extends StatefulWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color backgroundColor;
  final Color foregroundColor;
  final Widget? child;
  final Duration animationDuration;
  final Curve animationCurve;

  const AnimatedProgressRing({
    Key? key,
    required this.progress,
    this.size = 100.0,
    this.strokeWidth = 10.0,
    this.backgroundColor = Colors.grey,
    this.foregroundColor = Colors.blue,
    this.child,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeInOut,
  }) : super(key: key);

  @override
  State<AnimatedProgressRing> createState() => _AnimatedProgressRingState();
}

class _AnimatedProgressRingState extends State<AnimatedProgressRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = Tween<double>(begin: 0.0, end: widget.progress)
        .animate(CurvedAnimation(parent: _controller, curve: widget.animationCurve));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _oldProgress = oldWidget.progress;
      _animation = Tween<double>(begin: _oldProgress, end: widget.progress)
          .animate(CurvedAnimation(parent: _controller, curve: widget.animationCurve));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _ProgressRingPainter(
                  progress: _animation.value,
                  strokeWidth: widget.strokeWidth,
                  backgroundColor: widget.backgroundColor,
                  foregroundColor: widget.foregroundColor,
                ),
              ),
              if (widget.child != null) widget.child!,
            ],
          ),
        );
      },
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color foregroundColor;

  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final foregroundPaint = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final startAngle = -pi / 2; // Start from top
    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, foregroundPaint);
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.foregroundColor != foregroundColor;
  }
}

