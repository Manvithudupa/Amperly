import 'package:flutter/material.dart';

import '../../app/theme/amp_colors.dart';
import '../../app/theme/amp_theme.dart';

/// A booking ticket: a surface with two punched notches and a dashed tear.
///
/// The notches sit on the real card edge, so it reads as one piece of paper
/// rather than a card with a dotted line drawn inside it.
class TicketCard extends StatelessWidget {
  const TicketCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AmpTheme.screenPadding),
    this.notchOffset = 0.64,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double notchOffset;

  @override
  Widget build(BuildContext context) {
    final AmpColors c = context.amp;
    return Semantics(
      container: true,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: CustomPaint(
              painter: _TicketPainter(
                fill: c.surface,
                border: c.divider,
                dash: c.outline,
                notchOffset: notchOffset,
              ),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

class _TicketPainter extends CustomPainter {
  const _TicketPainter({
    required this.fill,
    required this.border,
    required this.dash,
    required this.notchOffset,
  });

  final Color fill;
  final Color border;
  final Color dash;
  final double notchOffset;

  @override
  void paint(Canvas canvas, Size size) {
    const double corner = AmpTheme.radiusCard;
    const double notch = 9;
    final double y = (size.height * notchOffset).clamp(
      corner + notch,
      size.height - corner - notch,
    );

    final Path path = Path()
      ..moveTo(corner, 0)
      ..lineTo(size.width - corner, 0)
      ..arcToPoint(
        Offset(size.width, corner),
        radius: const Radius.circular(corner),
      )
      ..lineTo(size.width, y - notch)
      ..arcToPoint(
        Offset(size.width, y + notch),
        radius: const Radius.circular(notch),
        clockwise: false,
      )
      ..lineTo(size.width, size.height - corner)
      ..arcToPoint(
        Offset(size.width - corner, size.height),
        radius: const Radius.circular(corner),
      )
      ..lineTo(corner, size.height)
      ..arcToPoint(
        Offset(0, size.height - corner),
        radius: const Radius.circular(corner),
      )
      ..lineTo(0, y + notch)
      ..arcToPoint(
        Offset(0, y - notch),
        radius: const Radius.circular(notch),
        clockwise: false,
      )
      ..lineTo(0, corner)
      ..arcToPoint(Offset(corner, 0), radius: const Radius.circular(corner))
      ..close();

    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final Paint dashPaint = Paint()
      ..color = dash
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    double x = 10;
    while (x < size.width - 10) {
      canvas.drawLine(
        Offset(x, y),
        Offset((x + 5).clamp(10, size.width - 10), y),
        dashPaint,
      );
      x += 9;
    }
  }

  @override
  bool shouldRepaint(covariant _TicketPainter oldDelegate) {
    return oldDelegate.fill != fill ||
        oldDelegate.border != border ||
        oldDelegate.dash != dash ||
        oldDelegate.notchOffset != notchOffset;
  }
}
