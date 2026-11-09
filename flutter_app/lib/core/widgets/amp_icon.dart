import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/amp_colors.dart';

/// The one line-icon set.
///
/// Every glyph is drawn on the same 24-unit grid with a 1.75-unit stroke,
/// round caps and round joins. Material's filled icons are deliberately not
/// mixed in: a row of them looks assembled, not designed.
enum AmpIconName {
  bolt,
  plug,
  battery,
  pin,
  search,
  close,
  chevronRight,
  chevronDown,
  check,
  alert,
  offline,
  qr,
  ticket,
  clock,
  plus,
  minus,
  arrowRight,
  info,
  chat,
  refresh,
  shield,
  compass,
  route,
  user,
  list,
  flag,
  bell,
}

class AmpIcon extends StatelessWidget {
  const AmpIcon(
    this.name, {
    super.key,
    this.size = 20,
    this.color,
    this.strokeWidth = 1.75,
  });

  final AmpIconName name;
  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final Color resolved = color ?? context.amp.ink;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _AmpIconPainter(
          name: name,
          color: resolved,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _AmpIconPainter extends CustomPainter {
  const _AmpIconPainter({
    required this.name,
    required this.color,
    required this.strokeWidth,
  });

  final AmpIconName name;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.shortestSide / 24;
    canvas.save();
    canvas.scale(scale);
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final Paint fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (name) {
      case AmpIconName.bolt:
        final Path path = Path()
          ..moveTo(13, 2)
          ..lineTo(5, 14)
          ..lineTo(11, 14)
          ..lineTo(9, 22)
          ..lineTo(19, 10)
          ..lineTo(13, 10)
          ..close();
        canvas.drawPath(path, stroke);
      case AmpIconName.plug:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(7, 8, 10, 9),
            const Radius.circular(2.5),
          ),
          stroke,
        );
        canvas.drawLine(const Offset(10, 8), const Offset(10, 4), stroke);
        canvas.drawLine(const Offset(14, 8), const Offset(14, 4), stroke);
        canvas.drawLine(const Offset(12, 17), const Offset(12, 22), stroke);
      case AmpIconName.battery:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(2, 8, 18, 9),
            const Radius.circular(2.5),
          ),
          stroke,
        );
        canvas.drawLine(const Offset(22, 10.5), const Offset(22, 14.5), stroke);
        canvas.drawLine(const Offset(6, 10.5), const Offset(6, 14.5), stroke);
        canvas.drawLine(const Offset(10, 10.5), const Offset(10, 14.5), stroke);
      case AmpIconName.pin:
        final Path pin = Path()
          ..moveTo(12, 22)
          ..cubicTo(12, 22, 19, 15.4, 19, 9.5)
          ..cubicTo(19, 5.4, 15.9, 2, 12, 2)
          ..cubicTo(8.1, 2, 5, 5.4, 5, 9.5)
          ..cubicTo(5, 15.4, 12, 22, 12, 22)
          ..close();
        canvas.drawPath(pin, stroke);
        canvas.drawCircle(const Offset(12, 9.4), 2.3, stroke);
      case AmpIconName.search:
        canvas.drawCircle(const Offset(11, 11), 6.2, stroke);
        canvas.drawLine(const Offset(15.6, 15.6), const Offset(21, 21), stroke);
      case AmpIconName.close:
        canvas.drawLine(const Offset(6, 6), const Offset(18, 18), stroke);
        canvas.drawLine(const Offset(18, 6), const Offset(6, 18), stroke);
      case AmpIconName.chevronRight:
        canvas.drawLine(const Offset(9, 5), const Offset(16, 12), stroke);
        canvas.drawLine(const Offset(16, 12), const Offset(9, 19), stroke);
      case AmpIconName.chevronDown:
        canvas.drawLine(const Offset(5, 9), const Offset(12, 16), stroke);
        canvas.drawLine(const Offset(12, 16), const Offset(19, 9), stroke);
      case AmpIconName.check:
        canvas.drawLine(const Offset(4, 12.5), const Offset(9.5, 18), stroke);
        canvas.drawLine(const Offset(9.5, 18), const Offset(20, 6), stroke);
      case AmpIconName.alert:
        final Path triangle = Path()
          ..moveTo(12, 3)
          ..lineTo(21.5, 20)
          ..lineTo(2.5, 20)
          ..close();
        canvas.drawPath(triangle, stroke);
        canvas.drawLine(const Offset(12, 9), const Offset(12, 14), stroke);
        canvas.drawCircle(const Offset(12, 17.2), 0.9, fill);
      case AmpIconName.offline:
        canvas.drawArc(
          const Rect.fromLTWH(2, 8, 20, 20),
          math.pi * 1.15,
          math.pi * 0.7,
          false,
          stroke,
        );
        canvas.drawArc(
          const Rect.fromLTWH(7, 10, 10, 12),
          math.pi * 1.15,
          math.pi * 0.7,
          false,
          stroke,
        );
        canvas.drawCircle(const Offset(12, 20), 1, fill);
        canvas.drawLine(const Offset(4, 3), const Offset(20, 21), stroke);
      case AmpIconName.qr:
        void corner(Offset topLeft) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(topLeft.dx, topLeft.dy, 7, 7),
              const Radius.circular(1.5),
            ),
            stroke,
          );
          canvas.drawRect(
            Rect.fromLTWH(topLeft.dx + 2.2, topLeft.dy + 2.2, 2.6, 2.6),
            fill,
          );
        }

        corner(const Offset(3, 3));
        corner(const Offset(14, 3));
        corner(const Offset(3, 14));
        canvas.drawRect(const Rect.fromLTWH(14, 14, 3, 3), fill);
        canvas.drawRect(const Rect.fromLTWH(18, 14, 3, 3), fill);
        canvas.drawRect(const Rect.fromLTWH(14, 18, 3, 3), fill);
      case AmpIconName.ticket:
        final Path ticket = Path()
          ..moveTo(3, 6)
          ..lineTo(21, 6)
          ..lineTo(21, 10)
          ..arcToPoint(
            const Offset(21, 14),
            radius: const Radius.circular(2.4),
            clockwise: false,
          )
          ..lineTo(21, 18)
          ..lineTo(3, 18)
          ..lineTo(3, 14)
          ..arcToPoint(
            const Offset(3, 10),
            radius: const Radius.circular(2.4),
            clockwise: false,
          )
          ..close();
        canvas.drawPath(ticket, stroke);
        canvas.drawLine(const Offset(15, 8), const Offset(15, 10), stroke);
        canvas.drawLine(const Offset(15, 12), const Offset(15, 13), stroke);
        canvas.drawLine(const Offset(15, 15), const Offset(15, 16), stroke);
      case AmpIconName.clock:
        canvas.drawCircle(const Offset(12, 12), 9, stroke);
        canvas.drawLine(const Offset(12, 7), const Offset(12, 12), stroke);
        canvas.drawLine(const Offset(12, 12), const Offset(16, 14), stroke);
      case AmpIconName.plus:
        canvas.drawLine(const Offset(12, 5), const Offset(12, 19), stroke);
        canvas.drawLine(const Offset(5, 12), const Offset(19, 12), stroke);
      case AmpIconName.minus:
        canvas.drawLine(const Offset(5, 12), const Offset(19, 12), stroke);
      case AmpIconName.arrowRight:
        canvas.drawLine(const Offset(3, 12), const Offset(20, 12), stroke);
        canvas.drawLine(const Offset(14, 6), const Offset(20, 12), stroke);
        canvas.drawLine(const Offset(20, 12), const Offset(14, 18), stroke);
      case AmpIconName.info:
        canvas.drawCircle(const Offset(12, 12), 9, stroke);
        canvas.drawLine(const Offset(12, 11), const Offset(12, 17), stroke);
        canvas.drawCircle(const Offset(12, 7.5), 0.9, fill);
      case AmpIconName.chat:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(3, 4, 18, 13),
            const Radius.circular(3),
          ),
          stroke,
        );
        canvas.drawLine(const Offset(8, 17), const Offset(8, 21), stroke);
        canvas.drawLine(const Offset(8, 21), const Offset(13, 17), stroke);
        canvas.drawLine(const Offset(7.5, 9), const Offset(16.5, 9), stroke);
        canvas.drawLine(
          const Offset(7.5, 12.5),
          const Offset(13.5, 12.5),
          stroke,
        );
      case AmpIconName.refresh:
        canvas.drawArc(
          const Rect.fromLTWH(4, 4, 16, 16),
          -math.pi * 0.35,
          math.pi * 1.55,
          false,
          stroke,
        );
        canvas.drawLine(const Offset(19, 3), const Offset(20, 8), stroke);
        canvas.drawLine(const Offset(20, 8), const Offset(15, 8), stroke);
      case AmpIconName.shield:
        final Path shield = Path()
          ..moveTo(12, 2)
          ..lineTo(20, 5.5)
          ..lineTo(20, 11.5)
          ..cubicTo(20, 17, 16.6, 20.6, 12, 22)
          ..cubicTo(7.4, 20.6, 4, 17, 4, 11.5)
          ..lineTo(4, 5.5)
          ..close();
        canvas.drawPath(shield, stroke);
        canvas.drawLine(const Offset(8.5, 11.5), const Offset(11, 14), stroke);
        canvas.drawLine(const Offset(11, 14), const Offset(16, 8.5), stroke);
      case AmpIconName.compass:
        canvas.drawCircle(const Offset(12, 12), 9, stroke);
        final Path needle = Path()
          ..moveTo(15.8, 8.2)
          ..lineTo(13.6, 13.6)
          ..lineTo(8.2, 15.8)
          ..lineTo(10.4, 10.4)
          ..close();
        canvas.drawPath(needle, stroke);
      case AmpIconName.route:
        canvas.drawCircle(const Offset(5, 19), 2.2, stroke);
        canvas.drawCircle(const Offset(19, 5), 2.2, stroke);
        final Path route = Path()
          ..moveTo(5, 16.4)
          ..cubicTo(5, 11.5, 12, 13.5, 12, 9.5)
          ..cubicTo(12, 6.5, 17.2, 7.2, 19, 5.8);
        canvas.drawPath(route, stroke);
      case AmpIconName.user:
        canvas.drawCircle(const Offset(12, 8), 3.7, stroke);
        final Path shoulders = Path()
          ..moveTo(4.8, 20.5)
          ..cubicTo(5.5, 16.6, 8.3, 15, 12, 15)
          ..cubicTo(15.7, 15, 18.5, 16.6, 19.2, 20.5);
        canvas.drawPath(shoulders, stroke);
      case AmpIconName.list:
        for (final double y in <double>[6, 12, 18]) {
          canvas.drawCircle(Offset(4, y), 1.2, fill);
          canvas.drawLine(Offset(8, y), Offset(20, y), stroke);
        }
      case AmpIconName.flag:
        canvas.drawLine(const Offset(6, 21), const Offset(6, 3), stroke);
        final Path pennant = Path()
          ..moveTo(6, 4)
          ..cubicTo(9, 2.6, 12, 2.6, 15, 4)
          ..cubicTo(17.4, 5.1, 19.3, 5.1, 21, 4)
          ..lineTo(21, 12)
          ..cubicTo(19.3, 13.1, 17.4, 13.1, 15, 12)
          ..cubicTo(12, 10.6, 9, 10.6, 6, 12)
          ..close();
        canvas.drawPath(pennant, stroke);
      case AmpIconName.bell:
        final Path bell = Path()
          ..moveTo(5, 17)
          ..cubicTo(6.6, 15.7, 6.7, 12.6, 6.7, 9.6)
          ..cubicTo(6.7, 6.2, 8.8, 3.5, 12, 3.5)
          ..cubicTo(15.2, 3.5, 17.3, 6.2, 17.3, 9.6)
          ..cubicTo(17.3, 12.6, 17.4, 15.7, 19, 17)
          ..close();
        canvas.drawPath(bell, stroke);
        canvas.drawArc(
          const Rect.fromLTWH(9.8, 17.2, 4.4, 3.2),
          0,
          math.pi,
          false,
          stroke,
        );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AmpIconPainter oldDelegate) {
    return oldDelegate.name != name ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
