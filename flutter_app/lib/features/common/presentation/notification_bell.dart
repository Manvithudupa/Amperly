import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/amp_colors.dart';
import '../../../app/theme/amp_theme.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_icon.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_result.dart';
import '../application/notification_providers.dart';

/// The toolbar shortcut to the notification ledger.
///
/// The unread marker is a small dot, not a filled count badge: it follows the
/// paper-and-current system and still gets a full semantic label.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<RepositoryResult<List<AppNotification>>> async = ref.watch(
      notificationsProvider,
    );
    final List<AppNotification> notifications =
        async.asData?.value.valueOrNull ?? const <AppNotification>[];
    final int unread = notifications
        .where((AppNotification item) => !item.isRead)
        .length;
    final String label = unread > 0
        ? AmpStrings.notificationsUnreadCount(unread)
        : AmpStrings.notificationsTitle;
    final AmpColors colors = context.amp;

    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: SizedBox.square(
          dimension: 48,
          child: Material(
            color: colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AmpTheme.radiusField),
              side: BorderSide(color: colors.divider),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => context.push('/notifications'),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: <Widget>[
                  AmpIcon(
                    AmpIconName.bell,
                    size: 21,
                    color: colors.inkSecondary,
                  ),
                  if (unread > 0)
                    Positioned(
                      top: 13,
                      right: 12,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: colors.busy,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.surface, width: 1),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
