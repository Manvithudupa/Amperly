import 'package:flutter/material.dart';

import '../../app/theme/amp_colors.dart';

/// `●●○○` — free ports first, then occupied ones.
///
/// The count is not inferred. Callers pass what the station published, and the
/// semantics spell the same fact out in words.
class PortDots extends StatelessWidget {
  const PortDots({
    required this.available,
    required this.total,
    super.key,
    this.dotSize = 6,
  });

  final int available;
  final int total;
  final double dotSize;

  static const int _maxDots = 6;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final int free = available.clamp(0, total);
    final String semantics = total == 0
        ? 'No ports published'
        : '$free of $total free';

    return Semantics(
      label: semantics,
      child: ExcludeSemantics(
        child: total > _maxDots
            ? Text(
                '$free/$total',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  height: 1,
                  fontWeight: FontWeight.w600,
                  color: colors.inkSecondary,
                  fontFeatures: const <FontFeature>[
                    FontFeature.tabularFigures(),
                  ],
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (int index = 0; index < total; index++) ...<Widget>[
                    if (index > 0) const SizedBox(width: 3),
                    Container(
                      width: dotSize,
                      height: dotSize,
                      decoration: BoxDecoration(
                        color: index < free ? colors.available : colors.outline,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
