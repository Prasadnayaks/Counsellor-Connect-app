// TODO Implement this library.
import 'package:flutter/material.dart';
import 'bubble_type.dart';

class ChatBubbleClipper1 extends CustomClipper<Path> {
  final BubbleType type;

  ChatBubbleClipper1({required this.type});

  @override
  Path getClip(Size size) {
    final path = Path();

    if (type == BubbleType.sendBubble) {
      // Sender bubble (right-aligned)
      path.moveTo(size.width * 0.75, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width * 0.75, size.height);
      path.lineTo(size.width * 0.75, size.height * 0.5);
      path.lineTo(0, size.height * 0.5);
      path.close();
    } else {
      // Receiver bubble (left-aligned)
      path.moveTo(size.width * 0.25, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width * 0.25, size.height);
      path.lineTo(size.width * 0.25, size.height * 0.5);
      path.lineTo(0, size.height * 0.5);
      path.close();
    }

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
