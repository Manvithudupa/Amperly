import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/amp_colors.dart';
import '../ui/connector_kind.dart';

/// A schematic, drawn connector. Not a photo, not a stock icon.
class ConnectorGlyph extends StatelessWidget {
  const ConnectorGlyph(
    this.kind, {
    super.key,
    this.size = 28,
    this.color,
    this.strokeWidth = 1.75,
  });

  final ConnectorKind kind;
  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _ConnectorPainter(
          kind: kind,
          color: color ?? context.amp.ink,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  const _ConnectorPainter({
    required this.kind,
    required this.color,
    required this.strokeWidth,
  });

  final ConnectorKind kind;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.shortestSide / 32;
    canvas.save();
    canvas.scale(scale);
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final Paint dot = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (kind) {
      case ConnectorKind.type2:
        canvas.drawCircle(const Offset(16, 16), 11, stroke);
        _pins(canvas, dot, const Offset(16, 16), 6.4, 7);
      case ConnectorKind.ccs2:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(3, 2, 26, 18),
            const Radius.circular(9),
          ),
          stroke,
        );
        _pins(canvas, dot, const Offset(16, 11), 5.2, 7);
        canvas.drawCircle(const Offset(12, 25.5), 2.6, dot);
        canvas.drawCircle(const Offset(20, 25.5), 2.6, dot);
      case ConnectorKind.chademo:
        canvas.drawCircle(const Offset(16, 16), 12, stroke);
        canvas.drawCircle(const Offset(12, 13), 2.4, dot);
        canvas.drawCircle(const Offset(20, 13), 2.4, dot);
        canvas.drawCircle(const Offset(12, 20), 2.4, dot);
        canvas.drawCircle(const Offset(20, 20), 2.4, dot);
      case ConnectorKind.plug:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(8, 10, 16, 13),
            const Radius.circular(4),
          ),
          stroke,
        );
        canvas.drawLine(const Offset(12, 10), const Offset(12, 4), stroke);
        canvas.drawLine(const Offset(20, 10), const Offset(20, 4), stroke);
        canvas.drawLine(const Offset(16, 23), const Offset(16, 28), stroke);
        canvas.drawCircle(const Offset(12, 16), 1.6, dot);
        canvas.drawCircle(const Offset(20, 16), 1.6, dot);
    }
    canvas.restore();
  }

  void _pins(
    Canvas canvas,
    Paint dot,
    Offset centre,
    double radius,
    int count,
  ) {
    for (int i = 0; i < count; i++) {
      final double angle = (math.pi * 2 / count) * i - math.pi / 2;
      canvas.drawCircle(
        centre + Offset(math.cos(angle), math.sin(angle)) * radius,
        1.35,
        dot,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectorPainter oldDelegate) {
    return oldDelegate.kind != kind ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
