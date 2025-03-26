import 'package:flutter/material.dart';
import 'bubble_type.dart';

class ChatBubble extends StatelessWidget {
  final CustomClipper<Path> clipper;
  final Alignment alignment;
  final EdgeInsets margin;
  final Color backGroundColor;
  final Widget child;

  const ChatBubble({
    Key? key,
    required this.clipper,
    required this.alignment,
    required this.margin,
    required this.backGroundColor,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        margin: margin,
        child: ClipPath(
          clipper: clipper,
          child: Container(
            color: backGroundColor,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
} // TODO Implement this library.
