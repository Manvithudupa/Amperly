import 'package:flutter/material.dart';

import '../../app/theme/amp_colors.dart';
import '../../app/theme/amp_theme.dart';
import 'amp_icon.dart';

/// The only status tones. Every badge carries a word; colour is never the
/// whole message, so `Discovery only` still reads without colour vision.
enum AmpBadgeTone { neutral, success, warning, danger, info, energy }

class AmpBadge extends StatelessWidget {
  const AmpBadge(
    this.label, {
    super.key,
    this.tone = AmpBadgeTone.neutral,
    this.icon,
  });

  final String label;
  final AmpBadgeTone tone;
  final AmpIconName? icon;

  @override
  Widget build(BuildContext context) {
    final AmpColors c = context.amp;
    final (Color background, Color foreground) = switch (tone) {
      AmpBadgeTone.neutral => (c.surfaceVariant, c.inkSecondary),
      AmpBadgeTone.success => (c.availableTint, c.availableInk),
      AmpBadgeTone.warning => (c.busyTint, c.busyInk),
      AmpBadgeTone.danger => (c.errorTint, c.error),
      AmpBadgeTone.info => (c.infoTint, c.info),
      AmpBadgeTone.energy => (c.energyTint, c.busyInk),
    };

    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AmpTheme.radiusPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                AmpIcon(icon!, size: 13, color: foreground),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AmpTheme.uiFont,
                  fontSize: 11.5,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
