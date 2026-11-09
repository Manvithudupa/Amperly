import 'package:flutter/material.dart';

import '../../app/theme/amp_colors.dart';
import '../../app/theme/amp_theme.dart';

enum TextActionTone { ink, primary, danger }

/// A secondary action in words.
///
/// No filled container, no icon. The line under the word is the affordance.
class TextAction extends StatelessWidget {
  const TextAction(
    this.label, {
    required this.onPressed,
    super.key,
    this.tone = TextActionTone.ink,
    this.underline = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final TextActionTone tone;
  final bool underline;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final Color color = switch (tone) {
      TextActionTone.ink => colors.ink,
      TextActionTone.primary => colors.primary,
      TextActionTone.danger => colors.error,
    };
    final Color resolved = onPressed == null
        ? color.withValues(alpha: 0.45)
        : color;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1,
                  heightFactor: 1,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: AmpTheme.uiFont,
                      fontSize: 13,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                      color: resolved,
                      decoration: underline
                          ? TextDecoration.underline
                          : TextDecoration.none,
                      decorationColor: resolved.withValues(alpha: 0.45),
                      decorationThickness: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
