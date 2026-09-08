import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/entry_model.dart';

class CustomFlowPainter extends CustomPainter {
  final List<MoodMetric> metrics;
  final bool isDark;
  final double animationProgress;

  CustomFlowPainter({
    required this.metrics,
    required this.isDark,
    this.animationProgress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (metrics.isEmpty) return;

    final paddingBottom = 28.0;
    final paddingTop = 20.0;
    final paddingHorizontal = 24.0;

    final usableWidth = size.width - (paddingHorizontal * 2);
    final usableHeight = size.height - paddingTop - paddingBottom;

    // Draw horizontal hairline guideline grid
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 1; i <= 5; i++) {
      final y = paddingTop + usableHeight - (usableHeight * (i / 5.0));
      canvas.drawLine(
        Offset(paddingHorizontal, y),
        Offset(size.width - paddingHorizontal, y),
        gridPaint,
      );
    }

    // Compute coordinate points
    final stepX = usableWidth / (metrics.length - 1);
    final points = <Offset>[];

    for (int i = 0; i < metrics.length; i++) {
      final x = paddingHorizontal + (i * stepX);
      // Mood score normalized (1.0 to 5.0) -> (0.0 to 1.0)
      final normalizedScore = (metrics[i].averageScore - 1.0) / 4.0;
      final targetY = paddingTop + usableHeight - (usableHeight * normalizedScore.clamp(0.0, 1.0));
      // Apply animation progress
      final currentY = (size.height - paddingBottom) -
          ((size.height - paddingBottom - targetY) * animationProgress);
      points.add(Offset(x, currentY));
    }

    if (points.length < 2) return;

    // Build smooth cubic Bézier path
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];

      final controlX1 = p0.dx + (p1.dx - p0.dx) / 2;
      final controlY1 = p0.dy;
      final controlX2 = p0.dx + (p1.dx - p0.dx) / 2;
      final controlY2 = p1.dy;

      path.cubicTo(controlX1, controlY1, controlX2, controlY2, p1.dx, p1.dy);
    }

    // Gradient Fill under the curve
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height - paddingBottom)
      ..lineTo(points.first.dx, size.height - paddingBottom)
      ..close();

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, paddingTop),
        Offset(0, size.height - paddingBottom),
        [
          AppColors.moodGreat.withOpacity(isDark ? 0.35 : 0.25),
          AppColors.moodGood.withOpacity(isDark ? 0.18 : 0.12),
          AppColors.moodGood.withOpacity(0.0),
        ],
        [0.0, 0.6, 1.0],
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Line Stroke with subtle glowing shadow
    final strokePaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(paddingHorizontal, 0),
        Offset(size.width - paddingHorizontal, 0),
        [
          AppColors.moodGood,
          AppColors.moodGreat,
        ],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);

    // Render Milestone Nodes & Day Labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      final metric = metrics[i];

      // Node Outer Halo
      final haloPaint = Paint()
        ..color = (isDark ? AppColors.darkSurfaceElevated : Colors.white)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pt, 6.0, haloPaint);

      // Node Core Circle
      final nodeColor = MoodType.fromScore(metric.averageScore.round()).color;
      final corePaint = Paint()
        ..color = nodeColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pt, 3.8, corePaint);

      // Day Label
      final dayName = _formatDayOfWeek(metric.date);
      textPainter.text = TextSpan(
        text: dayName,
        style: TextStyle(
          color: isDark ? AppColors.darkTextTertiary : AppColors.textSecondary,
          fontSize: 11,
          fontWeight: i == points.length - 1 ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: -0.2,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(pt.dx - (textPainter.width / 2), size.height - paddingBottom + 8),
      );
    }
  }

  String _formatDayOfWeek(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[d.weekday - 1];
    } catch (_) {
      return '';
    }
  }

  @override
  bool shouldRepaint(covariant CustomFlowPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.isDark != isDark ||
        oldDelegate.metrics != metrics;
  }
}
