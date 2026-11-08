import 'package:flutter/material.dart';

import '../../app/theme/amp_theme.dart';
import 'amp_illustration.dart';

/// A designed empty state: a drawing from the brand, a plain sentence, and
/// one optional action. Never a stock illustration, never a shrug emoji.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    required this.message,
    super.key,
    this.illustration = AmpIllustrationKind.unpluggedCable,
    this.action,
  });

  final String title;
  final String message;
  final AmpIllustrationKind illustration;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AmpTheme.spaceL),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AmpIllustration(illustration),
              const SizedBox(height: AmpTheme.spaceL),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AmpTheme.spaceS),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (action != null) ...<Widget>[
                const SizedBox(height: AmpTheme.spaceL),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
