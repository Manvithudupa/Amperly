import 'package:flutter/material.dart';

import '../../app/theme/amp_theme.dart';
import '../formatting/amp_format.dart';

/// A price with the rupee symbol attached and tabular figures, so a column of
/// prices lines up and a changing total does not jitter.
class PriceText extends StatelessWidget {
  const PriceText(
    this.amount, {
    super.key,
    this.perUnit,
    this.style,
    this.suffixStyle,
    this.showPaise = false,
  });

  final num amount;
  final String? perUnit;
  final TextStyle? style;
  final TextStyle? suffixStyle;
  final bool showPaise;

  @override
  Widget build(BuildContext context) {
    final TextStyle base = AmpType.tabular(
      style ?? Theme.of(context).textTheme.titleMedium ?? const TextStyle(),
    );
    final TextStyle suffix =
        suffixStyle ??
        (Theme.of(context).textTheme.labelLarge ?? const TextStyle());

    return Text.rich(
      TextSpan(
        text: AmpFormat.rupees(amount, showPaise: showPaise),
        children: <InlineSpan>[
          if (perUnit != null) TextSpan(text: perUnit, style: suffix),
        ],
      ),
      style: base,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
