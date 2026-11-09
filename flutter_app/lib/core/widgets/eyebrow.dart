import 'package:flutter/material.dart';

import '../../app/theme/amp_theme.dart';

/// A section label, set small and spaced.
///
/// Used sparingly: it names the thing below it, it does not decorate it.
class Eyebrow extends StatelessWidget {
  const Eyebrow(
    this.label, {
    super.key,
    this.color,
    this.maxLines = 2,
    this.textAlign = TextAlign.left,
  });

  final String label;
  final Color? color;
  final int maxLines;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      style: AmpType.eyebrow(context, color: color),
    );
  }
}
