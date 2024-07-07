import 'package:flutter/material.dart';

class BubblePainter extends CustomPainter {
  final Color color;

  BubblePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double tailWidth = size.width * 0.1;
    final double tailHeight = size.height * 0.2;
    final double cornerRadius = size.height * 0.2;

    final Path path = Path()
      ..moveTo(tailWidth, 0)
      ..lineTo(size.width - cornerRadius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, cornerRadius)
      ..lineTo(size.width, size.height - cornerRadius)
      ..quadraticBezierTo(
          size.width, size.height, size.width - cornerRadius, size.height)
      ..lineTo(tailWidth, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - tailHeight)
      ..lineTo(0, tailHeight)
      ..quadraticBezierTo(0, 0, tailWidth, 0)
      ..close();

    canvas.drawPath(path, paint);

    // Add shine effect
    final Paint shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final Path shinePath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.1)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.05,
          size.width * 0.6, size.height * 0.1)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.15,
          size.width * 0.9, size.height * 0.2)
      ..quadraticBezierTo(
          size.width * 0.95, size.height * 0.25, size.width, size.height * 0.3);

    canvas.drawPath(shinePath, shinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
