import 'package:flutter/material.dart';

import '../../app/theme/amp_colors.dart';
import '../../app/theme/amp_theme.dart';
import 'amp_icon.dart';

/// A quiet text chip for filters and small choices.
///
/// 36 tall, 14 horizontal, fully round. The tap target is padded to 48 by the
/// Material wrapper around it, so a filter row stays comfortable without
/// looking heavy.
class AmpChip extends StatelessWidget {
  const AmpChip({
    required this.label,
    super.key,
    this.selected = false,
    this.onTap,
    this.icon,
    this.leading,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final AmpIconName? icon;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final AmpColors c = context.amp;
    final Color background = selected ? c.primaryTint : c.surface;
    final Color border = selected ? c.primary : c.divider;
    final Color foreground = selected ? c.onPrimaryTint : c.inkSecondary;

    return Semantics(
      button: onTap != null,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AmpTheme.radiusPill),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
            child: Center(
              child: Ink(
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(AmpTheme.radiusPill),
                  border: Border.all(color: border),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (leading != null) ...<Widget>[
                      leading!,
                      const SizedBox(width: 6),
                    ] else if (icon != null) ...<Widget>[
                      AmpIcon(icon!, size: 15, color: foreground),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: AmpTheme.uiFont,
                        fontSize: 13,
                        height: 1.2,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
