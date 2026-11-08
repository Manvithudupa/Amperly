import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/amp_colors.dart';

/// Hand-drawn empty-state art. Simple line drawings in the brand colours,
/// with amber used only where something is missing or waiting.
enum AmpIllustrationKind { unpluggedCable, carQuestion, offline }

class AmpIllustration extends StatelessWidget {
  const AmpIllustration(
    this.kind, {
    super.key,
    this.width = 132,
    this.height = 96,
  });

  final AmpIllustrationKind kind;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _IllustrationPainter(kind: kind, colors: context.amp),
        isComplex: true,
      ),
    );
  }
}

class _IllustrationPainter extends CustomPainter {
  const _IllustrationPainter({required this.kind, required this.colors});

  final AmpIllustrationKind kind;
  final AmpColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 132, size.height / 96);

    final Paint line = Paint()
      ..color = colors.inkSecondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final Paint soft = Paint()
      ..color = colors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final Paint amber = Paint()
      ..color = colors.energy
      ..style = PaintingStyle.fill;
    final Paint amberLine = Paint()
      ..color = colors.energy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    switch (kind) {
      case AmpIllustrationKind.unpluggedCable:
        // A cable that has come apart, with a small spark between the ends.
        canvas.drawPath(
          Path()
            ..moveTo(8, 78)
            ..cubicTo(28, 78, 30, 58, 46, 58)
            ..cubicTo(56, 58, 58, 62, 63, 66),
          soft,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(60, 56, 14, 20),
            const Radius.circular(4),
          ),
          line,
        );
        canvas.drawLine(const Offset(64, 56), const Offset(64, 49), line);
        canvas.drawLine(const Offset(70, 56), const Offset(70, 49), line);
        canvas.drawPath(
          Path()
            ..moveTo(124, 78)
            ..cubicTo(106, 78, 104, 58, 88, 58)
            ..cubicTo(80, 58, 76, 60, 73, 63),
          soft,
        );
        canvas.drawPath(
          Path()
            ..moveTo(79, 47)
            ..lineTo(79, 41)
            ..arcToPoint(
              const Offset(91, 41),
              radius: const Radius.circular(6),
              clockwise: false,
            )
            ..lineTo(91, 47),
          line,
        );
        canvas.drawCircle(const Offset(76.5, 54), 3.2, amber);
        canvas.drawLine(const Offset(88, 28), const Offset(88, 34), amberLine);
        canvas.drawLine(const Offset(101, 38), const Offset(96, 42), amberLine);
        canvas.drawLine(const Offset(75, 38), const Offset(80, 42), amberLine);
        canvas.drawLine(const Offset(18, 88), const Offset(114, 88), soft);
      case AmpIllustrationKind.carQuestion:
        canvas.drawPath(
          Path()
            ..moveTo(26, 72)
            ..lineTo(26, 62)
            ..cubicTo(26, 58, 29, 55, 34, 54)
            ..lineTo(40, 38)
            ..cubicTo(42, 33, 46, 31, 52, 31)
            ..lineTo(84, 31)
            ..cubicTo(90, 31, 94, 33, 96, 38)
            ..lineTo(102, 54)
            ..cubicTo(107, 55, 110, 58, 110, 62)
            ..lineTo(110, 72),
          line,
        );
        canvas.drawLine(const Offset(26, 62), const Offset(110, 62), soft);
        canvas.drawCircle(const Offset(42, 73), 7, line);
        canvas.drawCircle(const Offset(94, 73), 7, line);
        canvas.drawCircle(const Offset(42, 73), 2, amber);
        canvas.drawCircle(const Offset(94, 73), 2, amber);
        canvas.drawLine(const Offset(34, 44), const Offset(40, 40), soft);
        canvas.drawLine(const Offset(48, 96), const Offset(88, 96), soft);
        // A question mark in amber, floating above the roof.
        canvas.drawArc(
          const Rect.fromLTWH(59, 8, 18, 16),
          math.pi * 0.9,
          math.pi * 1.4,
          false,
          amberLine,
        );
        canvas.drawLine(const Offset(68, 24), const Offset(68, 29), amberLine);
        canvas.drawCircle(const Offset(68, 34), 1.6, amber);
      case AmpIllustrationKind.offline:
        canvas.drawArc(
          const Rect.fromLTWH(26, 26, 80, 60),
          math.pi * 1.2,
          math.pi * 0.6,
          false,
          soft,
        );
        canvas.drawArc(
          const Rect.fromLTWH(42, 42, 48, 40),
          math.pi * 1.2,
          math.pi * 0.6,
          false,
          soft,
        );
        canvas.drawCircle(const Offset(66, 76), 3, line);
        canvas.drawLine(const Offset(30, 22), const Offset(102, 84), amberLine);
        canvas.drawLine(const Offset(20, 88), const Offset(112, 88), soft);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IllustrationPainter oldDelegate) {
    return oldDelegate.kind != kind || oldDelegate.colors != colors;
  }
}
