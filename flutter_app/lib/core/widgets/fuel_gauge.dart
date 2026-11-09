import 'package:flutter/material.dart';

import '../../app/theme/amp_colors.dart';
import '../../app/theme/amp_theme.dart';
import '../ui/strings.dart';

/// A horizontal battery gauge with ten-percent ticks.
///
/// The driver's reading is the amber fill; the estimate is a separate marker,
/// never merged into the fill. The reserve line is always visible.
class FuelGauge extends StatelessWidget {
  const FuelGauge({
    required this.percent,
    super.key,
    this.estimatePercent,
    this.reservePercent = 15,
    this.showLabels = true,
  });

  final int percent;
  final int? estimatePercent;
  final int reservePercent;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final int shown = percent.clamp(0, 100);
    final int? estimate = estimatePercent?.clamp(0, 100);
    final int reserve = reservePercent.clamp(0, 100);

    final String semantics = AmpStrings.fuelGaugeSemantics(
      shown,
      reserve,
      estimate,
    );

    return Tooltip(
      message: semantics,
      child: Semantics(
        label: semantics,
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (showLabels) ...<Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        AmpStrings.fuelGaugeYouSaid(shown),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AmpType.eyebrow(context, color: colors.ink),
                      ),
                    ),
                    if (estimate != null) ...<Widget>[
                      const SizedBox(width: AmpTheme.spaceS),
                      Flexible(
                        child: Text(
                          AmpStrings.fuelGaugeEstimate(estimate),
                          maxLines: 2,
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          style: AmpType.eyebrow(context),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 7),
              ],
              SizedBox(
                height: 30,
                child: CustomPaint(
                  painter: _FuelGaugePainter(
                    percent: shown.toDouble(),
                    estimatePercent: estimate?.toDouble(),
                    reservePercent: reserve.toDouble(),
                    track: colors.surfaceVariant,
                    fill: colors.energy,
                    marker: colors.inkSecondary,
                    tick: colors.surface,
                    reserve: colors.ink,
                  ),
                ),
              ),
              if (showLabels) ...<Widget>[
                const SizedBox(height: 3),
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        AmpStrings.fuelGaugeReserve(reserve),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AmpType.eyebrow(context),
                      ),
                    ),
                    const Spacer(),
                    Text('0', style: AmpType.eyebrow(context)),
                    const SizedBox(width: 4),
                    Container(width: 1, height: 8, color: colors.divider),
                    const SizedBox(width: 4),
                    Text('100', style: AmpType.eyebrow(context)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FuelGaugePainter extends CustomPainter {
  const _FuelGaugePainter({
    required this.percent,
    required this.estimatePercent,
    required this.reservePercent,
    required this.track,
    required this.fill,
    required this.marker,
    required this.tick,
    required this.reserve,
  });

  final double percent;
  final double? estimatePercent;
  final double reservePercent;
  final Color track;
  final Color fill;
  final Color marker;
  final Color tick;
  final Color reserve;

  @override
  void paint(Canvas canvas, Size size) {
    const double barHeight = 10;
    final double top = (size.height - barHeight) / 2;
    final Rect bar = Rect.fromLTWH(0, top, size.width, barHeight);
    final RRect rounded = RRect.fromRectAndRadius(
      bar,
      const Radius.circular(2),
    );

    canvas.drawRRect(rounded, Paint()..color = track);
    canvas.save();
    canvas.clipRRect(rounded);
    canvas.drawRect(
      Rect.fromLTWH(0, top, size.width * (percent / 100), barHeight),
      Paint()..color = fill,
    );

    final Paint tickPaint = Paint()
      ..color = tick.withValues(alpha: 0.72)
      ..strokeWidth = 1;
    for (int value = 10; value < 100; value += 10) {
      final double x = size.width * (value / 100);
      canvas.drawLine(Offset(x, top), Offset(x, top + barHeight), tickPaint);
    }
    canvas.restore();

    final double reserveX = size.width * (reservePercent / 100);
    canvas.drawLine(
      Offset(reserveX, top - 4),
      Offset(reserveX, top + barHeight + 4),
      Paint()
        ..color = reserve
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );

    if (estimatePercent != null) {
      final double x = size.width * (estimatePercent! / 100);
      final Path markerPath = Path()
        ..moveTo(x, top - 7)
        ..lineTo(x - 4, top - 1)
        ..lineTo(x + 4, top - 1)
        ..close();
      canvas.drawPath(markerPath, Paint()..color = marker);
      canvas.drawLine(
        Offset(x, top - 1),
        Offset(x, top + barHeight + 2),
        Paint()
          ..color = marker
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FuelGaugePainter oldDelegate) {
    return oldDelegate.percent != percent ||
        oldDelegate.estimatePercent != estimatePercent ||
        oldDelegate.reservePercent != reservePercent ||
        oldDelegate.track != track ||
        oldDelegate.fill != fill ||
        oldDelegate.marker != marker ||
        oldDelegate.tick != tick ||
        oldDelegate.reserve != reserve;
  }
}
