import 'package:flutter/material.dart';

import '../../app/theme/amp_colors.dart';

/// The main graphic device: a single printed hairline.
class Hairline extends StatelessWidget {
  const Hairline({super.key, this.indent = 0, this.endIndent = 0, this.color});

  final double indent;
  final double endIndent;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: indent, end: endIndent),
      child: SizedBox(
        height: 1,
        width: double.infinity,
        child: ColoredBox(color: color ?? context.amp.divider),
      ),
    );
  }
}
