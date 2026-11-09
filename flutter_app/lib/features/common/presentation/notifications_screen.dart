import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/amp_theme.dart';
import '../../../core/errors/user_messages.dart';
import '../../../core/formatting/amp_format.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/amp_snackbar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/hairline.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/status_dot_label.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/repository_result.dart';
import '../../auth/application/profile_providers.dart';
import '../application/notification_providers.dart';

/// The account's notification ledger. Opening an unread row marks just that row
/// read; the header action marks the whole ledger read.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<RepositoryResult<List<AppNotification>>> async = ref.watch(
      notificationsProvider,
    );
    final List<AppNotification>? list = async.asData?.value.valueOrNull;
    final bool hasUnread =
        list?.any((AppNotification item) => !item.isRead) ?? false;

    return AmpScaffold(
      title: AmpStrings.notificationsTitle,
      body: async.when(
        loading: () => const _NotificationsLoading(),
        error: (Object error, StackTrace stack) => ErrorState(
          message: UserMessages.from(error),
          onRetry: () => ref.invalidate(notificationsProvider),
        ),
        data: (RepositoryResult<List<AppNotification>> result) {
          final RepositoryFailure<List<AppNotification>>? failure =
              result.failureOrNull;
          if (failure != null) {
            return ErrorState(
              message: failure.message,
              onRetry: () => ref.invalidate(notificationsProvider),
            );
          }
          final List<AppNotification> notifications =
              result.valueOrNull ?? const <AppNotification>[];
          if (notifications.isEmpty) {
            return const EmptyState(
              title: AmpStrings.notificationsEmptyTitle,
              message: AmpStrings.notificationsEmptyBody,
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AmpTheme.screenPadding,
              AmpTheme.spaceL,
              AmpTheme.screenPadding,
              AmpTheme.spaceXxl,
            ),
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      AmpStrings.notificationsSubtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  if (hasUnread)
                    TextButton(
                      onPressed: _busy ? null : _markAll,
                      child: const Text(AmpStrings.notificationsMarkAll),
                    ),
                ],
              ),
              const SizedBox(height: AmpTheme.spaceS),
              const Hairline(),
              for (final AppNotification item in notifications)
                _NotificationRow(
                  item: item,
                  onTap: _busy ? null : () => _markOne(item),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _markAll() async {
    final AppUser? profile = ref
        .read(currentProfileProvider)
        .asData
        ?.value
        .valueOrNull;
    final repository = ref.read(notificationRepositoryProvider);
    if (profile == null || repository == null) {
      return;
    }
    setState(() => _busy = true);
    final RepositoryResult<bool> result = await repository.markAllRead(
      profile.id,
    );
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    if (result.failureOrNull != null) {
      AmpSnackbar.show(
        context,
        AmpStrings.notificationsMarkFailed,
        tone: AmpSnackbarTone.error,
      );
      return;
    }
    ref.invalidate(notificationsProvider);
    AmpSnackbar.show(
      context,
      AmpStrings.notificationsMarkedAll,
      tone: AmpSnackbarTone.success,
    );
  }

  Future<void> _markOne(AppNotification item) async {
    if (item.isRead) {
      return;
    }
    final repository = ref.read(notificationRepositoryProvider);
    if (repository == null) {
      return;
    }
    final RepositoryResult<bool> result = await repository.markRead(item.id);
    if (!mounted) {
      return;
    }
    if (result.failureOrNull != null) {
      AmpSnackbar.show(
        context,
        AmpStrings.notificationsMarkFailed,
        tone: AmpSnackbarTone.error,
      );
      return;
    }
    ref.invalidate(notificationsProvider);
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.item, required this.onTap});

  final AppNotification item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final String title = (item.title ?? '').trim().isEmpty
        ? AmpStrings.notificationsTitle
        : item.title!.trim();
    final String message = (item.message ?? '').trim();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(child: Text(title, style: text.titleSmall)),
                if (!item.isRead) ...<Widget>[
                  const SizedBox(width: AmpTheme.spaceS),
                  const StatusDotLabel(
                    AmpStrings.notificationsUnread,
                    tone: StatusDotTone.busy,
                  ),
                ],
              ],
            ),
            if (message.isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              Text(message, style: text.bodyMedium),
            ],
            if (item.createdAtMs > 0) ...<Widget>[
              const SizedBox(height: 4),
              Eyebrow(AmpFormat.messageTimestamp(item.createdAtMs)),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationsLoading extends StatelessWidget {
  const _NotificationsLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AmpTheme.screenPadding),
      children: const <Widget>[
        SkeletonLine(widthFactor: 0.42, height: 12),
        SizedBox(height: AmpTheme.spaceL),
        Hairline(),
        SizedBox(height: AmpTheme.spaceM),
        SkeletonLine(widthFactor: 0.55, height: 16),
        SizedBox(height: 6),
        SkeletonLine(widthFactor: 0.8),
        SizedBox(height: AmpTheme.spaceL),
        SkeletonLine(widthFactor: 0.5, height: 16),
        SizedBox(height: 6),
        SkeletonLine(widthFactor: 0.72),
      ],
    );
  }
}
