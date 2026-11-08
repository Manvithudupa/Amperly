import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/amp_colors.dart';
import '../../app/theme/amp_theme.dart';
import '../ui/strings.dart';

/// The battery percentage as a ring.
///
/// A second, short marker sits where an estimate said the battery would be.
/// The driver's own reading is the filled arc; the estimate is never drawn as
/// if it were measured.
class BatteryRing extends StatelessWidget {
  const BatteryRing({
    required this.percent,
    super.key,
    this.estimatePercent,
    this.size = 132,
    this.color,
    this.caption,
    this.semanticsLabel,
  });

  final int percent;
  final int? estimatePercent;
  final double size;
  final Color? color;
  final String? caption;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final AmpColors c = context.amp;
    final int shown = percent.clamp(0, 100);
    final int? estimate = estimatePercent?.clamp(0, 100);
    final Color arcColor = color ?? (shown <= 15 ? c.error : c.primary);
    final String semantics =
        semanticsLabel ??
        (estimate == null
            ? AmpStrings.batteryRingSemantics
            : '${AmpStrings.batteryRingSemantics} '
                  '${AmpStrings.batteryEstimateSemantics(shown, estimate)}');

    return Semantics(
      label: semantics,
      image: true,
      child: ExcludeSemantics(
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              CustomPaint(
                size: Size.square(size),
                painter: _BatteryRingPainter(
                  percent: shown.toDouble(),
                  estimatePercent: estimate?.toDouble(),
                  track: c.surfaceVariant,
                  arc: arcColor,
                  marker: c.inkSecondary,
                  strokeWidth: (size * 0.075).clamp(8, 12),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '$shown%',
                    style: AmpType.metric(context, size: size * 0.25),
                  ),
                  if (caption != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        caption!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BatteryRingPainter extends CustomPainter {
  const _BatteryRingPainter({
    required this.percent,
    required this.estimatePercent,
    required this.track,
    required this.arc,
    required this.marker,
    required this.strokeWidth,
  });

  final double percent;
  final double? estimatePercent;
  final Color track;
  final Color arc;
  final Color marker;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset centre = size.center(Offset.zero);
    final double radius = (size.shortestSide - strokeWidth) / 2;
    final Rect rect = Rect.fromCircle(center: centre, radius: radius);

    final Paint trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final Paint arcPaint = Paint()
      ..color = arc
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(centre, radius, trackPaint);
    const double start = -math.pi / 2;
    canvas.drawArc(rect, start, math.pi * 2 * (percent / 100), false, arcPaint);

    if (estimatePercent != null) {
      final double angle = start + math.pi * 2 * (estimatePercent! / 100);
      final Offset direction = Offset(math.cos(angle), math.sin(angle));
      final Paint tick = Paint()
        ..color = marker
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        centre + direction * (radius - strokeWidth * 0.85),
        centre + direction * (radius + strokeWidth * 0.85),
        tick,
      );
      canvas.drawCircle(
        centre + direction * (radius + strokeWidth * 1.35),
        2.2,
        Paint()..color = marker,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BatteryRingPainter oldDelegate) {
    return oldDelegate.percent != percent ||
        oldDelegate.estimatePercent != estimatePercent ||
        oldDelegate.track != track ||
        oldDelegate.arc != arc ||
        oldDelegate.marker != marker ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
