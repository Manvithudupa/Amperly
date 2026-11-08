import 'package:flutter/material.dart';

import '../../app/theme/amp_colors.dart';
import '../../app/theme/amp_theme.dart';
import 'amp_icon.dart';

enum AmpSnackbarTone { success, error, info }

/// Themed feedback. One place decides the icon, the colour and the duration, so
/// a screen cannot accidentally show a raw error in a default Snackbar.
abstract final class AmpSnackbar {
  static void show(
    BuildContext context,
    String message, {
    AmpSnackbarTone tone = AmpSnackbarTone.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    final AmpColors c = context.amp;
    final (AmpIconName icon, Color marker) = switch (tone) {
      AmpSnackbarTone.success => (AmpIconName.check, c.available),
      AmpSnackbarTone.error => (AmpIconName.alert, c.error),
      AmpSnackbarTone.info => (AmpIconName.info, c.info),
    };

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 3,
                height: 20,
                decoration: BoxDecoration(
                  color: marker,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              AmpIcon(icon, size: 18, color: c.onInverseSurface),
              const SizedBox(width: AmpTheme.spaceS),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: c.onInverseSurface,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          action: actionLabel == null
              ? null
              : SnackBarAction(
                  label: actionLabel,
                  onPressed: onAction ?? () {},
                ),
        ),
      );
  }

  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}
