import 'package:flutter/material.dart';

import '../../app/theme/amp_theme.dart';
import 'eyebrow.dart';

/// The one number a screen is built around.
///
/// Fraunces, tabular figures, a small unit beside it and an optional eyebrow
/// underneath. Everything else on the screen stays quiet around it.
class BigNumber extends StatelessWidget {
  const BigNumber({
    required this.value,
    super.key,
    this.unit,
    this.label,
    this.size = 56,
    this.color,
  });

  final String value;
  final String? unit;
  final String? label;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final String semantics = <String>[value, ?unit, ?label].join(' ');

    return Semantics(
      label: semantics,
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: AmpType.metric(context, size: size, color: color),
                  ),
                ),
                if (unit != null)
                  Padding(
                    padding: EdgeInsets.only(left: 5, bottom: size * 0.1),
                    child: Eyebrow(unit!),
                  ),
              ],
            ),
            if (label != null) ...<Widget>[
              const SizedBox(height: 2),
              Eyebrow(label!),
            ],
          ],
        ),
      ),
    );
  }
}
