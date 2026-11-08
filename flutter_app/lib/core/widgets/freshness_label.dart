import 'package:flutter/material.dart';

import '../../app/theme/amp_colors.dart';
import '../ui/strings.dart';

/// How old an availability reading is, in words.
///
/// Availability is never presented as live hardware data. The dot is only a
/// second cue; the sentence always says the age, and stale data says so.
class FreshnessLabel extends StatelessWidget {
  const FreshnessLabel({
    required this.updatedAt,
    super.key,
    this.now,
    this.staleAfter = const Duration(hours: 2),
  });

  final DateTime updatedAt;
  final DateTime? now;
  final Duration staleAfter;

  @override
  Widget build(BuildContext context) {
    final AmpColors c = context.amp;
    final DateTime reference = now ?? DateTime.now();
    final Duration age = reference.difference(updatedAt);
    final bool stale = age > staleAfter;

    final String label;
    if (age.isNegative || age.inMinutes < 1) {
      label = AmpStrings.updatedJustNow;
    } else if (age.inMinutes < 60) {
      label = AmpStrings.updatedMinutes(age.inMinutes);
    } else if (age.inHours < 24) {
      label = AmpStrings.updatedHours(age.inHours);
    } else {
      label = AmpStrings.updatedDays(age.inDays);
    }

    final String text = stale ? '$label · ${AmpStrings.stale}' : label;
    final Color dotColor = stale ? c.busy : c.available;
    final TextStyle style =
        Theme.of(context).textTheme.bodySmall ?? const TextStyle();

    return Semantics(
      label: text,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: style.copyWith(
                  color: stale ? c.busyInk : c.inkSecondary,
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
