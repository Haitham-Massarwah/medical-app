import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Custom painter for logo1 - H.M with gradient letters and integrated calendar/cross
class HMLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(size.width, size.height),
        [
          Color(0xFF00C6FB), // Cyan
          Color(0xFF005BEA), // Blue
          Color(0xFF667EEA), // Purple
        ],
      );

    // Draw rounded rectangle background
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.width * 0.15),
    );
    canvas.drawRRect(rect, paint);

    // Draw H.M text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'H.M',
        style: TextStyle(
          fontSize: size.width * 0.35,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: size.width * 0.02,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );

    // Draw calendar icon overlay (top-right of M)
    final calendarPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final calendarRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.65,
        size.height * 0.2,
        size.width * 0.2,
        size.width * 0.2,
      ),
      Radius.circular(3),
    );
    canvas.drawRRect(calendarRect, calendarPaint);
    
    // Calendar rings
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.2), 2, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 2, Paint()..color = Colors.white);

    // Medical cross inside calendar
    final crossPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    final centerX = size.width * 0.75;
    final centerY = size.height * 0.3;
    final crossSize = size.width * 0.08;
    
    canvas.drawLine(
      Offset(centerX - crossSize, centerY),
      Offset(centerX + crossSize, centerY),
      crossPaint,
    );
    canvas.drawLine(
      Offset(centerX, centerY - crossSize),
      Offset(centerX, centerY + crossSize),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}




