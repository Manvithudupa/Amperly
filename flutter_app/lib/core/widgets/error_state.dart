import 'package:flutter/material.dart';

import '../../app/theme/amp_theme.dart';
import '../ui/strings.dart';
import 'amp_button.dart';
import 'amp_icon.dart';
import 'amp_illustration.dart';

/// A failed load, in plain language.
///
/// [message] must come from `UserMessages` (or a written string), never from
/// an exception. The retry action is explicit; a failed write is never silently
/// retried in the background.
class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.message,
    super.key,
    this.title = AmpStrings.errorTitle,
    this.illustration = AmpIllustrationKind.unpluggedCable,
    this.onRetry,
    this.retryLabel = AmpStrings.retry,
  });

  final String title;
  final String message;
  final AmpIllustrationKind illustration;
  final VoidCallback? onRetry;
  final String retryLabel;

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
              if (onRetry != null) ...<Widget>[
                const SizedBox(height: AmpTheme.spaceL),
                AmpButton(
                  label: retryLabel,
                  icon: AmpIconName.refresh,
                  onPressed: onRetry,
                  variant: AmpButtonVariant.tonal,
                  expand: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
