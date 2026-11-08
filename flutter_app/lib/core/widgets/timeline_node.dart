import 'package:flutter/material.dart';

import '../../app/theme/amp_colors.dart';
import '../../app/theme/amp_theme.dart';
import 'amp_icon.dart';

/// What a journey node represents. Filled means a real stop, hollow means a
/// backup that is not part of the planned route.
enum TimelineNodeKind { start, chargingStop, backupStop, arrival }

/// One node on the journey strip: a rail, a marker and a content block.
class TimelineNode extends StatelessWidget {
  const TimelineNode({
    required this.title,
    required this.kind,
    super.key,
    this.subtitle,
    this.detail,
    this.trailing,
    this.child,
    this.isFirst = false,
    this.isLast = false,
  });

  final String title;
  final TimelineNodeKind kind;
  final String? subtitle;
  final String? detail;
  final Widget? trailing;
  final Widget? child;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final AmpColors c = context.amp;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: 30,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 12,
                  child: Center(
                    child: Container(
                      width: 2,
                      color: isFirst ? Colors.transparent : c.divider,
                    ),
                  ),
                ),
                _marker(c),
                Expanded(
                  child: Center(
                    child: Container(
                      width: 2,
                      color: isLast ? Colors.transparent : c.divider,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AmpTheme.spaceL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      if (trailing != null) ...<Widget>[
                        const SizedBox(width: AmpTheme.spaceS),
                        trailing!,
                      ],
                    ],
                  ),
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (detail != null) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      detail!,
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: c.ink),
                    ),
                  ],
                  if (child != null) ...<Widget>[
                    const SizedBox(height: AmpTheme.spaceS),
                    child!,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _marker(AmpColors c) {
    return switch (kind) {
      TimelineNodeKind.start || TimelineNodeKind.arrival => Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: kind == TimelineNodeKind.arrival ? c.primaryDark : c.primary,
          shape: BoxShape.circle,
          border: Border.all(color: c.background, width: 2),
        ),
      ),
      TimelineNodeKind.chargingStop => Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: c.primary,
          shape: BoxShape.circle,
          border: Border.all(color: c.background, width: 2),
        ),
        child: Center(
          child: AmpIcon(AmpIconName.bolt, size: 13, color: c.onPrimary),
        ),
      ),
      TimelineNodeKind.backupStop => Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: c.surface,
          shape: BoxShape.circle,
          border: Border.all(color: c.outline, width: 1.5),
        ),
        child: Center(
          child: AmpIcon(AmpIconName.bolt, size: 12, color: c.inkSecondary),
        ),
      ),
    };
  }
}
