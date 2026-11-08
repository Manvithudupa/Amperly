import 'package:flutter/material.dart';

import '../../app/theme/amp_colors.dart';
import '../../app/theme/amp_theme.dart';
import 'amp_icon.dart';

/// The four action weights. There is no fifth.
enum AmpButtonVariant {
  /// One solid green action per screen.
  primary,

  /// A quieter action on a tinted surface.
  tonal,

  /// Text only: navigation inside a flow, never a commitment.
  quiet,

  /// Irreversible. Never the default.
  danger,
}

class AmpButton extends StatelessWidget {
  const AmpButton({
    required this.label,
    super.key,
    this.onPressed,
    this.variant = AmpButtonVariant.primary,
    this.loading = false,
    this.icon,
    this.expand = true,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final AmpButtonVariant variant;
  final bool loading;
  final AmpIconName? icon;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final AmpColors c = context.amp;
    final Color foreground = switch (variant) {
      AmpButtonVariant.primary => c.onPrimary,
      AmpButtonVariant.tonal => c.ink,
      AmpButtonVariant.quiet => c.primary,
      AmpButtonVariant.danger => c.onError,
    };
    final Color background = switch (variant) {
      AmpButtonVariant.primary => c.primary,
      AmpButtonVariant.tonal => c.surfaceVariant,
      AmpButtonVariant.quiet => Colors.transparent,
      AmpButtonVariant.danger => c.error,
    };

    final Widget content = AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: loading
          ? SizedBox(
              key: const ValueKey<String>('loading'),
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(foreground),
              ),
            )
          : Row(
              key: const ValueKey<String>('label'),
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  AmpIcon(icon!, size: 19, color: foreground),
                  const SizedBox(width: AmpTheme.spaceS),
                ],
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AmpTheme.uiFont,
                      fontSize: 15,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
                  ),
                ),
              ],
            ),
    );

    final ButtonStyle style = styleFrom(
      variant: variant,
      foreground: foreground,
      background: background,
      minimumHeight: height,
    );

    final Widget button = switch (variant) {
      AmpButtonVariant.quiet => TextButton(
        style: style,
        onPressed: loading ? null : onPressed,
        child: content,
      ),
      _ => FilledButton(
        style: style,
        onPressed: loading ? null : onPressed,
        child: content,
      ),
    };

    return SizedBox(
      width: expand ? double.infinity : null,
      height: height,
      child: Semantics(
        button: true,
        enabled: onPressed != null && !loading,
        label: label,
        child: ExcludeSemantics(child: button),
      ),
    );
  }

  ButtonStyle styleFrom({
    required AmpButtonVariant variant,
    required Color foreground,
    required Color background,
    required double minimumHeight,
  }) {
    final Color disabledForeground = foreground.withValues(alpha: 0.55);
    final Color disabledBackground = variant == AmpButtonVariant.quiet
        ? Colors.transparent
        : background.withValues(alpha: 0.45);
    final RoundedRectangleBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AmpTheme.radiusField),
    );
    if (variant == AmpButtonVariant.quiet) {
      return TextButton.styleFrom(
        foregroundColor: foreground,
        disabledForegroundColor: disabledForeground,
        minimumSize: Size(0, minimumHeight),
        padding: const EdgeInsets.symmetric(horizontal: AmpTheme.spaceM),
        shape: shape,
        elevation: 0,
        textStyle: const TextStyle(
          fontFamily: AmpTheme.uiFont,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      );
    }
    return FilledButton.styleFrom(
      foregroundColor: foreground,
      backgroundColor: background,
      disabledForegroundColor: disabledForeground,
      disabledBackgroundColor: disabledBackground,
      minimumSize: Size(0, minimumHeight),
      padding: const EdgeInsets.symmetric(horizontal: AmpTheme.spaceL),
      shape: shape,
      elevation: 0,
      textStyle: const TextStyle(
        fontFamily: AmpTheme.uiFont,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
