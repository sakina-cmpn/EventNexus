import 'package:flutter/material.dart';

class EventNexusLogo extends StatelessWidget {
  final double width;
  final Color color;

  const EventNexusLogo({
    super.key,
    required this.width,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final height = width * 0.55;
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _EventNexusLogoPainter(color: color),
      ),
    );
  }
}

class _EventNexusLogoPainter extends CustomPainter {
  final Color color;

  _EventNexusLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final solid = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(
      size.width * 0.04,
      size.height * 0.08,
      size.width * 0.92,
      size.height * 0.84,
    );
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(rect.height * 0.18),
    );
    canvas.drawRRect(rrect, border);

    // Perforation line (dashes).
    final perfX = rect.left + rect.width * 0.72;
    final dashH = rect.height * 0.07;
    final gap = rect.height * 0.04;
    var y = rect.top + rect.height * 0.16;
    while (y < rect.bottom - rect.height * 0.16) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(perfX, y, rect.width * 0.03, dashH),
          Radius.circular(dashH * 0.35),
        ),
        solid,
      );
      y += dashH + gap;
    }

    // "EN" text on left.
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'EN',
        style: TextStyle(
          color: color,
          fontSize: rect.height * 0.62,
          fontWeight: FontWeight.w900,
          letterSpacing: -2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        rect.left + rect.width * 0.14,
        rect.top + (rect.height - textPainter.height) / 2,
      ),
    );

    // Calendar mark on right.
    final calW = rect.width * 0.16;
    final calH = rect.height * 0.46;
    final calRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        rect.left + rect.width * 0.80,
        rect.top + rect.height * 0.27,
        calW,
        calH,
      ),
      Radius.circular(calH * 0.12),
    );

    canvas.drawRRect(calRect, border);

    final barPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = border.strokeWidth * 0.7
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(calRect.left + calW * 0.12, calRect.top + calH * 0.23),
      Offset(calRect.right - calW * 0.12, calRect.top + calH * 0.23),
      barPaint,
    );

    final dot = Paint()..color = color.withOpacity(0.85);
    final gridLeft = calRect.left + calW * 0.18;
    final gridTop = calRect.top + calH * 0.34;
    final cell = calW * 0.18;
    final stepX = calW * 0.24;
    final stepY = calH * 0.18;

    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 3; c++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              gridLeft + c * stepX,
              gridTop + r * stepY,
              cell,
              cell,
            ),
            Radius.circular(cell * 0.25),
          ),
          dot,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _EventNexusLogoPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

