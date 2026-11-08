import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/amp_colors.dart';
import '../../../app/theme/amp_theme.dart';
import '../../../core/errors/user_messages.dart';
import '../../../core/formatting/amp_format.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_badge.dart';
import '../../../core/widgets/amp_button.dart';
import '../../../core/widgets/amp_icon.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_result.dart';
import '../application/chat_providers.dart';
import '../application/chat_rules.dart';

/// Every consumer-to-host conversation on this account.
class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<RepositoryResult<ChatInboxData>> chats = ref.watch(
      chatInboxProvider,
    );

    return AmpScaffold(
      title: AmpStrings.chatTitle,
      subtitle: AmpStrings.chatSubtitle,
      body: chats.when(
        loading: () => const _MessagesLoading(),
        error: (Object error, StackTrace stack) => ErrorState(
          message: UserMessages.from(error),
          onRetry: () => ref.invalidate(chatInboxProvider),
        ),
        data: (RepositoryResult<ChatInboxData> result) {
          final RepositoryFailure<ChatInboxData>? failure =
              result.failureOrNull;
          if (failure != null) {
            return ErrorState(
              message: failure.message,
              onRetry: () => ref.invalidate(chatInboxProvider),
            );
          }
          return _MessagesBody(data: result.valueOrNull!);
        },
      ),
    );
  }
}

class _MessagesBody extends ConsumerWidget {
  const _MessagesBody({required this.data});

  final ChatInboxData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme text = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(chatInboxProvider);
        await ref.read(chatInboxProvider.future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AmpTheme.screenPadding,
          AmpTheme.spaceM,
          AmpTheme.screenPadding,
          AmpTheme.spaceXxl,
        ),
        children: <Widget>[
          if (data.threads.isEmpty)
            EmptyState(
              title: AmpStrings.chatEmptyTitle,
              message: AmpStrings.chatEmptyBody,
              action: AmpButton(
                label: AmpStrings.chatOpenBookings,
                icon: AmpIconName.ticket,
                expand: false,
                onPressed: () => context.go('/bookings'),
              ),
            )
          else ...<Widget>[
            Text(AmpStrings.chatMaskedNote, style: text.bodySmall),
            const SizedBox(height: AmpTheme.spaceM),
            for (final CommunicationThread thread in data.threads) ...<Widget>[
              _ThreadCard(data: data, thread: thread),
              const SizedBox(height: AmpTheme.spaceM),
            ],
          ],
        ],
      ),
    );
  }
}

class _ThreadCard extends StatelessWidget {
  const _ThreadCard({required this.data, required this.thread});

  final ChatInboxData data;
  final CommunicationThread thread;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final TextTheme text = Theme.of(context).textTheme;
    final Reservation? reservation = thread.reservationId == null
        ? null
        : data.reservations[thread.reservationId];
    final String stationName = (reservation?.stationName ?? '').trim();
    final ChatMessage? latest = data.latestMessages[thread.id];
    final bool closed =
        ChatRules.closureMessage(
          thread,
          DateTime.now().millisecondsSinceEpoch,
        ) !=
        null;
    final int stamp = latest?.createdAtMs ?? thread.createdAtMs;

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
        side: BorderSide(color: colors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/messages/${thread.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AmpTheme.spaceM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      ChatRules.title(thread, data.viewerId),
                      style: text.titleMedium,
                    ),
                  ),
                  if (closed) ...<Widget>[
                    const SizedBox(width: AmpTheme.spaceS),
                    const AmpBadge(
                      AmpStrings.chatClosedBadge,
                      tone: AmpBadgeTone.warning,
                    ),
                  ],
                ],
              ),
              if (stationName.isNotEmpty) ...<Widget>[
                const SizedBox(height: 2),
                Text(
                  AmpStrings.chatAboutStation(stationName),
                  style: text.bodySmall,
                ),
              ],
              const SizedBox(height: AmpTheme.spaceS),
              Text(
                ChatRules.preview(latest?.messageText),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text.bodyMedium,
              ),
              const SizedBox(height: AmpTheme.spaceS),
              Row(
                children: <Widget>[
                  if (stamp > 0)
                    Text(
                      AmpFormat.relative(
                        DateTime.fromMillisecondsSinceEpoch(stamp),
                      ),
                      style: text.labelSmall,
                    ),
                  const Spacer(),
                  AmpIcon(
                    AmpIconName.chevronRight,
                    size: 18,
                    color: colors.inkSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessagesLoading extends StatelessWidget {
  const _MessagesLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AmpTheme.screenPadding,
        AmpTheme.spaceM,
        AmpTheme.screenPadding,
        AmpTheme.spaceXxl,
      ),
      children: const <Widget>[
        Skeleton(height: 118, radius: AmpTheme.radiusCard),
        SizedBox(height: AmpTheme.spaceM),
        Skeleton(height: 118, radius: AmpTheme.radiusCard),
        SizedBox(height: AmpTheme.spaceM),
        Skeleton(height: 118, radius: AmpTheme.radiusCard),
      ],
    );
  }
}
