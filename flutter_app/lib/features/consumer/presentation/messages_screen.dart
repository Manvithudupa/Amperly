import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/amp_colors.dart';
import '../../../app/theme/amp_theme.dart';
import '../../../core/errors/user_messages.dart';
import '../../../core/formatting/amp_format.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/hairline.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/status_dot_label.dart';
import '../../../core/widgets/text_action.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_result.dart';
import '../application/chat_providers.dart';
import '../application/chat_rules.dart';
import 'consumer_tab_bar.dart';

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
      tabBar: const ConsumerTabBar(currentIndex: 3),
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
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(chatInboxProvider);
        await ref.read(chatInboxProvider.future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: AmpTheme.spaceS),
        children: <Widget>[
          if (data.threads.isEmpty)
            const _MessagesEmpty()
          else ...<Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AmpTheme.screenPadding,
              ),
              child: Text(
                AmpStrings.chatMaskedNote,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: AmpTheme.spaceS),
            const Hairline(),
            for (final CommunicationThread thread in data.threads)
              _ThreadRow(data: data, thread: thread),
          ],
        ],
      ),
    );
  }
}

class _MessagesEmpty extends StatelessWidget {
  const _MessagesEmpty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AmpTheme.screenPadding,
        AmpTheme.spaceXl,
        AmpTheme.screenPadding,
        AmpTheme.spaceXxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Eyebrow(AmpStrings.chatTitle),
          const SizedBox(height: AmpTheme.spaceM),
          Text(
            AmpStrings.chatEmptyTitle,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: AmpTheme.spaceS),
          Text(
            AmpStrings.chatEmptyBody,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AmpTheme.spaceM),
          TextAction(
            AmpStrings.chatOpenBookings,
            onPressed: () => context.go('/bookings'),
          ),
        ],
      ),
    );
  }
}

class _ThreadRow extends StatelessWidget {
  const _ThreadRow({required this.data, required this.thread});

  final ChatInboxData data;
  final CommunicationThread thread;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
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
    final DateTime? date = stamp > 0
        ? DateTime.fromMillisecondsSinceEpoch(stamp)
        : null;
    final String? age = date == null ? null : AmpFormat.relative(date);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/messages/${thread.id}'),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AmpTheme.screenPadding,
                vertical: 14,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 46,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          date == null ? '—' : AmpFormat.dayNumber(date),
                          style: AmpType.metric(context, size: 24),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          date == null ? '' : AmpFormat.monthShort(date),
                          style: AmpType.eyebrow(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          ChatRules.title(thread, data.viewerId),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colors.ink,
                              ),
                        ),
                        if (stationName.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 2),
                          Text(
                            AmpStrings.chatAboutStation(stationName),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                        const SizedBox(height: 5),
                        Text(
                          ChatRules.preview(latest?.messageText),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 7),
                        StatusDotLabel(
                          closed
                              ? AmpStrings.chatClosedBadge
                              : AmpStrings.chatOpen,
                          detail: age,
                          tone: closed
                              ? StatusDotTone.busy
                              : StatusDotTone.available,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Hairline(),
          ],
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
      padding: const EdgeInsets.only(top: AmpTheme.spaceS),
      children: const <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AmpTheme.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SkeletonLine(widthFactor: 0.24, height: 9),
              SizedBox(height: 10),
              SkeletonLine(widthFactor: 0.52, height: 22),
              SizedBox(height: 8),
              SkeletonLine(widthFactor: 0.7),
              SizedBox(height: 16),
              Hairline(),
              SizedBox(height: 16),
              SkeletonLine(widthFactor: 0.24, height: 9),
              SizedBox(height: 10),
              SkeletonLine(widthFactor: 0.46, height: 22),
              SizedBox(height: 8),
              SkeletonLine(widthFactor: 0.64),
              SizedBox(height: 16),
              Hairline(),
            ],
          ),
        ),
      ],
    );
  }
}
