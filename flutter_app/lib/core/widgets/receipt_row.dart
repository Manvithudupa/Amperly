import 'package:flutter/material.dart';

import '../../app/theme/amp_colors.dart';
import '../../app/theme/amp_theme.dart';

/// A receipt line: label, dashed leader, tabular value.
///
/// The leader is drawn, not typed as dots, so it stretches to the column and
/// stays crisp at every text scale.
class ReceiptRow extends StatelessWidget {
  const ReceiptRow({
    required this.label,
    required this.value,
    super.key,
    this.emphasis = false,
    this.showLeader = true,
  });

  final String label;
  final String value;
  final bool emphasis;
  final bool showLeader;

  @override
  Widget build(BuildContext context) {
    final AmpColors c = context.amp;
    final TextStyle labelStyle =
        (emphasis
            ? Theme.of(context).textTheme.titleSmall
            : Theme.of(context).textTheme.bodyMedium) ??
        const TextStyle();
    final TextStyle valueStyle =
        (emphasis
            ? Theme.of(context).textTheme.titleMedium
            : Theme.of(context).textTheme.bodyMedium) ??
        const TextStyle();

    return Semantics(
      label: '$label, $value',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Flexible(
                child: Text(
                  label,
                  style: labelStyle.copyWith(
                    color: emphasis ? c.ink : c.inkSecondary,
                  ),
                ),
              ),
              if (showLeader) ...<Widget>[
                const SizedBox(width: AmpTheme.spaceS),
                Expanded(
                  child: SizedBox(
                    height: 16,
                    child: CustomPaint(
                      painter: _LeaderPainter(color: c.divider),
                    ),
                  ),
                ),
                const SizedBox(width: AmpTheme.spaceS),
              ] else
                const SizedBox(width: AmpTheme.spaceM),
              Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFeatures: valueStyle.fontFeatures,
                  fontFamily: valueStyle.fontFamily,
                  fontSize: valueStyle.fontSize,
                  height: valueStyle.height,
                  fontWeight: emphasis ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: valueStyle.letterSpacing,
                  color: c.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaderPainter extends CustomPainter {
  const _LeaderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    final double y = size.height - 4;
    double x = 0;
    while (x < size.width) {
      final double end = (x + 3).clamp(0, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
      x += 6;
    }
  }

  @override
  bool shouldRepaint(covariant _LeaderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
