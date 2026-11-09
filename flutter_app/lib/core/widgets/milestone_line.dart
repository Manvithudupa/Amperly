import 'package:flutter/material.dart';

import '../../app/theme/amp_colors.dart';
import '../../app/theme/amp_theme.dart';
import '../ui/strings.dart';

/// One charging stop on a route, set as a highway kilometre stone.
final class MilestoneStop {
  const MilestoneStop({
    required this.distanceKm,
    required this.title,
    this.detail,
    this.batteryPercent,
    this.backup = false,
  });

  final double distanceKm;
  final String title;
  final String? detail;
  final int? batteryPercent;
  final bool backup;
}

/// A vertical road line with measured stops.
///
/// Planned stops are solid ink stones; backups are hollow and quieter. The
/// battery at each point is shown beside the stop, not painted onto the line.
class MilestoneLine extends StatelessWidget {
  const MilestoneLine({
    required this.stops,
    super.key,
    this.lineColor,
    this.animate = false,
  });

  final List<MilestoneStop> stops;
  final Color? lineColor;

  /// Draws the road line once, top to bottom. Used on a fresh trip result.
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final bool drawLine = animate && !MediaQuery.disableAnimationsOf(context);
    final String semantics = stops
        .map(
          (MilestoneStop stop) => AmpStrings.milestoneSemantics(
            _distance(stop.distanceKm),
            stop.title,
          ),
        )
        .join(' ');

    return Tooltip(
      message: semantics,
      child: Semantics(
        container: true,
        label: semantics,
        child: ExcludeSemantics(
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 25.5,
                top: 18,
                bottom: 30,
                child: SizedBox(
                  width: 1,
                  child: drawLine
                      ? TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutCubic,
                          builder:
                              (
                                BuildContext context,
                                double value,
                                Widget? child,
                              ) => FractionallySizedBox(
                                alignment: Alignment.topCenter,
                                heightFactor: value,
                                child: child,
                              ),
                          child: ColoredBox(color: lineColor ?? colors.divider),
                        )
                      : ColoredBox(color: lineColor ?? colors.divider),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (int index = 0; index < stops.length; index++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: index == stops.length - 1 ? 0 : 22,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: 52,
                            child: _KmStone(stop: stops[index]),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    stops[index].title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: stops[index].backup
                                              ? colors.inkSecondary
                                              : colors.ink,
                                          fontWeight: stops[index].backup
                                              ? FontWeight.w500
                                              : FontWeight.w600,
                                        ),
                                  ),
                                  if (stops[index].detail != null) ...<Widget>[
                                    const SizedBox(height: 3),
                                    Text(
                                      stops[index].detail!,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                  if (stops[index].batteryPercent !=
                                      null) ...<Widget>[
                                    const SizedBox(height: 2),
                                    Text(
                                      '${stops[index].batteryPercent}%',
                                      style: AmpType.tabular(
                                        Theme.of(
                                              context,
                                            ).textTheme.labelLarge ??
                                            const TextStyle(),
                                      ).copyWith(color: colors.inkSecondary),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
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

  static String _distance(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }
}

class _KmStone extends StatelessWidget {
  const _KmStone({required this.stop});

  final MilestoneStop stop;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final Color border = stop.backup ? colors.outline : colors.ink;
    final Color text = stop.backup ? colors.inkSecondary : colors.ink;

    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: border, width: stop.backup ? 1 : 1.2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            MilestoneLine._distance(stop.distanceKm),
            maxLines: 1,
            style: AmpType.metric(
              context,
              size: 13,
              color: text,
            ).copyWith(height: 1),
          ),
          const SizedBox(height: 1),
          Text(
            'KM',
            style: AmpType.eyebrow(
              context,
              color: text,
            ).copyWith(fontSize: 7, letterSpacing: 0.6, height: 1),
          ),
        ],
      ),
    );
  }
}
