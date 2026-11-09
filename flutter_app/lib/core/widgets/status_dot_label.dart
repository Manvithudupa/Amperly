import 'package:flutter/material.dart';

import '../../app/theme/amp_colors.dart';

enum StatusDotTone { available, busy, neutral, error }

/// A six-pixel dot and a word.
///
/// Colour never carries the message on its own. There is deliberately no
/// filled badge behind it.
class StatusDotLabel extends StatelessWidget {
  const StatusDotLabel(
    this.label, {
    super.key,
    this.detail,
    this.tone = StatusDotTone.available,
  });

  final String label;
  final String? detail;
  final StatusDotTone tone;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final Color dot = switch (tone) {
      StatusDotTone.available => colors.available,
      StatusDotTone.busy => colors.busy,
      StatusDotTone.neutral => colors.inkSecondary,
      StatusDotTone.error => colors.error,
    };
    final String semantics = detail == null ? label : '$label, $detail';

    return Tooltip(
      message: semantics,
      child: Semantics(
        label: semantics,
        child: ExcludeSemantics(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  detail == null ? label : '$label · $detail',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.inkSecondary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
