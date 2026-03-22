import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaveClipper extends CustomClipper<Path> {
  final double animationValue;

  WaveClipper({required this.animationValue});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);

    final firstControlPoint = Offset(
      size.width * 0.25,
      size.height - 40 + math.sin(animationValue * math.pi) * 30,
    );
    final firstEndPoint = Offset(size.width * 0.5, size.height - 40);

    final secondControlPoint = Offset(
      size.width * 0.75,
      size.height - 40 - math.sin(animationValue * math.pi) * 30,
    );
    final secondEndPoint = Offset(size.width, size.height - 40);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) =>
      oldClipper.animationValue != animationValue;
}