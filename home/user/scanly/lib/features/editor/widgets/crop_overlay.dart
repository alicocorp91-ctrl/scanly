import 'package:flutter/material.dart';
import 'package:scanly/core/theme/app_colors.dart';

class CropOverlay extends StatefulWidget {
  const CropOverlay({super.key});

  @override
  State<CropOverlay> createState() => _CropOverlayState();
}

class _CropOverlayState extends State<CropOverlay> {
  // In a real implementation, these would be draggable points
  // For now, we show a fixed interactive overlay

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CropOverlayPainter(),
      child: Container(),
    );
  }
}

class CropOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Main crop rectangle (slightly inset)
    final double marginX = size.width * 0.08;
    final double marginY = size.height * 0.12;

    final rect = Rect.fromLTRB(
      marginX,
      marginY,
      size.width - marginX,
      size.height - marginY,
    );

    // Draw the crop rectangle
    canvas.drawRect(rect, paint);

    // Corner handles
    final handlePaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    final handleSize = 12.0;

    // Top-left
    canvas.drawCircle(Offset(rect.left, rect.top), handleSize, handlePaint);
    // Top-right
    canvas.drawCircle(Offset(rect.right, rect.top), handleSize, handlePaint);
    // Bottom-left
    canvas.drawCircle(Offset(rect.left, rect.bottom), handleSize, handlePaint);
    // Bottom-right
    canvas.drawCircle(Offset(rect.right, rect.bottom), handleSize, handlePaint);

    // Grid lines (rule of thirds)
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 1;

    // Vertical lines
    canvas.drawLine(
      Offset(rect.left + rect.width / 3, rect.top),
      Offset(rect.left + rect.width / 3, rect.bottom),
      gridPaint,
    );
    canvas.drawLine(
      Offset(rect.left + (rect.width * 2) / 3, rect.top),
      Offset(rect.left + (rect.width * 2) / 3, rect.bottom),
      gridPaint,
    );

    // Horizontal lines
    canvas.drawLine(
      Offset(rect.left, rect.top + rect.height / 3),
      Offset(rect.right, rect.top + rect.height / 3),
      gridPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top + (rect.height * 2) / 3),
      Offset(rect.right, rect.top + (rect.height * 2) / 3),
      gridPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}