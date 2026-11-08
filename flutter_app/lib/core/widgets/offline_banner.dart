import 'package:flutter/material.dart';

import '../../app/theme/amp_colors.dart';
import '../../app/theme/amp_theme.dart';
import '../ui/strings.dart';
import 'amp_icon.dart';

/// A quiet warning that the device has no connection.
///
/// It never promises that a booking will be queued: writes that move a slot or
/// money need a connection, and the app says so before the user tries.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    required this.visible,
    super.key,
    this.message = AmpStrings.offlineBannerText,
    this.onRetry,
  });

  final bool visible;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final AmpColors c = context.amp;
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: !visible
          ? const SizedBox.shrink()
          : Semantics(
              liveRegion: true,
              label: message,
              child: ExcludeSemantics(
                child: Container(
                  width: double.infinity,
                  color: c.busyTint,
                  padding: const EdgeInsets.fromLTRB(
                    AmpTheme.screenPadding,
                    AmpTheme.spaceS,
                    AmpTheme.spaceS,
                    AmpTheme.spaceS,
                  ),
                  child: Row(
                    children: <Widget>[
                      AmpIcon(AmpIconName.offline, size: 18, color: c.busyInk),
                      const SizedBox(width: AmpTheme.spaceS),
                      Expanded(
                        child: Text(
                          message,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: c.busyInk, fontSize: 12.5),
                        ),
                      ),
                      if (onRetry != null)
                        TextButton(
                          onPressed: onRetry,
                          style: TextButton.styleFrom(
                            foregroundColor: c.busyInk,
                            minimumSize: const Size(44, 40),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            AmpStrings.retry,
                            style: TextStyle(
                              fontFamily: AmpTheme.uiFont,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: c.busyInk,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
