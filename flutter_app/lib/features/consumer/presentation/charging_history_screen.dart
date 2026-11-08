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
import '../../../domain/policy.dart';
import '../application/session_providers.dart';

/// Every server charging session for the signed-in consumer.
class ChargingHistoryScreen extends ConsumerWidget {
  const ChargingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<RepositoryResult<List<ChargingSession>>> sessions = ref
        .watch(consumerSessionsProvider);

    return AmpScaffold(
      title: AmpStrings.sessionHistoryTitle,
      subtitle: AmpStrings.sessionHistorySubtitle,
      body: sessions.when(
        loading: () => const _HistoryLoading(),
        error: (Object error, StackTrace stack) => ErrorState(
          message: UserMessages.from(error),
          onRetry: () => ref.invalidate(consumerSessionsProvider),
        ),
        data: (RepositoryResult<List<ChargingSession>> result) {
          final RepositoryFailure<List<ChargingSession>>? failure =
              result.failureOrNull;
          if (failure != null) {
            return ErrorState(
              message: failure.message,
              onRetry: () => ref.invalidate(consumerSessionsProvider),
            );
          }
          return _HistoryBody(sessions: result.valueOrNull!);
        },
      ),
    );
  }
}

class _HistoryBody extends ConsumerWidget {
  const _HistoryBody({required this.sessions});

  final List<ChargingSession> sessions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(consumerSessionsProvider);
        await ref.read(consumerSessionsProvider.future);
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
          if (sessions.isEmpty)
            EmptyState(
              title: AmpStrings.sessionHistoryEmptyTitle,
              message: AmpStrings.sessionHistoryEmptyBody,
              action: AmpButton(
                label: AmpStrings.bookingFindCharger,
                icon: AmpIconName.search,
                expand: false,
                onPressed: () => context.go('/home'),
              ),
            )
          else
            for (final ChargingSession session in sessions) ...<Widget>[
              _SessionCard(session: session),
              const SizedBox(height: AmpTheme.spaceM),
            ],
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final ChargingSession session;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final TextTheme text = Theme.of(context).textTheme;
    final String stationName = (session.stationName ?? '').trim();
    final String status = AmpFormat.bookingStatus(session.status);
    final bool completed =
        (session.status ?? '').toUpperCase() == AmpPolicy.statusCompleted;
    final String? reservationId = session.reservationId;
    final bool canOpen =
        reservationId != null && reservationId.trim().isNotEmpty;
    final String when = session.startTimeMs > 0
        ? session.endTimeMs > 0
              ? '${AmpFormat.dayLabel(DateTime.fromMillisecondsSinceEpoch(session.startTimeMs))}, '
                    '${AmpFormat.timeRange(session.startTimeMs, session.endTimeMs)}'
              : '${AmpFormat.dayLabel(DateTime.fromMillisecondsSinceEpoch(session.startTimeMs))}, '
                    '${AmpFormat.clock(session.startTimeMs)}'
        : AmpStrings.availabilityUnknown;

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
        side: BorderSide(color: colors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: canOpen ? () => context.push('/sessions/$reservationId') : null,
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
                      stationName.isEmpty
                          ? AmpStrings.bookingStationFallback
                          : stationName,
                      style: text.titleMedium,
                    ),
                  ),
                  const SizedBox(width: AmpTheme.spaceS),
                  AmpBadge(
                    status.isEmpty ? AmpStrings.labelUnknown : status,
                    tone: _statusTone(session.status),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(when, style: text.bodySmall),
              const SizedBox(height: AmpTheme.spaceS),
              if (completed)
                Text(
                  '${AmpFormat.kWh(session.verifiedKwhConsumed)} · '
                  '${AmpFormat.rupees(session.totalPaid)}',
                  style: text.labelLarge,
                )
              else
                Text(AmpStrings.sessionReadingsPending, style: text.bodySmall),
              const Divider(height: AmpTheme.spaceL),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: canOpen
                      ? () => context.push('/sessions/$reservationId')
                      : null,
                  child: Text(
                    completed
                        ? AmpStrings.sessionViewReceipt
                        : AmpStrings.sessionContinueAction,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

AmpBadgeTone _statusTone(String? status) {
  return switch ((status ?? '').toUpperCase()) {
    'CHECKED_IN' => AmpBadgeTone.info,
    'CHARGING' => AmpBadgeTone.success,
    'COMPLETED' => AmpBadgeTone.success,
    'CANCELLED' || 'EXPIRED' => AmpBadgeTone.warning,
    _ => AmpBadgeTone.neutral,
  };
}

class _HistoryLoading extends StatelessWidget {
  const _HistoryLoading();

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
        Skeleton(height: 150, radius: AmpTheme.radiusCard),
        SizedBox(height: AmpTheme.spaceM),
        Skeleton(height: 150, radius: AmpTheme.radiusCard),
        SizedBox(height: AmpTheme.spaceM),
        Skeleton(height: 150, radius: AmpTheme.radiusCard),
      ],
    );
  }
}
