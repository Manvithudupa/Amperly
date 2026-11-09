import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/amp_theme.dart';
import '../../../core/errors/user_messages.dart';
import '../../../core/formatting/amp_format.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/departure_row.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/hairline.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/status_dot_label.dart';
import '../../../core/widgets/text_action.dart';
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
        padding: const EdgeInsets.only(top: AmpTheme.spaceS),
        children: <Widget>[
          if (sessions.isEmpty)
            const _HistoryEmpty()
          else
            for (final ChargingSession session in sessions)
              _SessionRow(session: session),
        ],
      ),
    );
  }
}

class _HistoryEmpty extends StatelessWidget {
  const _HistoryEmpty();

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
          const Eyebrow(AmpStrings.sessionHistoryTitle),
          const SizedBox(height: AmpTheme.spaceM),
          Text(
            AmpStrings.sessionHistoryEmptyTitle,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: AmpTheme.spaceS),
          Text(
            AmpStrings.sessionHistoryEmptyBody,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AmpTheme.spaceM),
          TextAction(
            AmpStrings.bookingFindCharger,
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session});

  final ChargingSession session;

  @override
  Widget build(BuildContext context) {
    final String stationName = (session.stationName ?? '').trim();
    final String status = AmpFormat.bookingStatus(session.status);
    final bool completed =
        (session.status ?? '').toUpperCase() == AmpPolicy.statusCompleted;
    final String? reservationId = session.reservationId;
    final bool canOpen =
        reservationId != null && reservationId.trim().isNotEmpty;
    final DateTime? start = session.startTimeMs > 0
        ? DateTime.fromMillisecondsSinceEpoch(session.startTimeMs)
        : null;
    final String when = start == null
        ? AmpStrings.availabilityUnknown
        : session.endTimeMs > 0
        ? AmpFormat.timeRange(session.startTimeMs, session.endTimeMs)
        : AmpFormat.clock(session.startTimeMs);
    final VoidCallback? open = canOpen
        ? () => context.push('/sessions/$reservationId')
        : null;

    return Column(
      children: <Widget>[
        DepartureRow(
          metric: start == null ? '—' : AmpFormat.dayNumber(start),
          metricUnit: start == null ? '' : AmpFormat.monthShort(start),
          title: stationName.isEmpty
              ? AmpStrings.bookingStationFallback
              : stationName,
          detail: when,
          statusLabel: status.isEmpty ? AmpStrings.labelUnknown : status,
          statusDetail: completed
              ? AmpFormat.kWh(session.verifiedKwhConsumed)
              : null,
          statusTone: _statusTone(session.status),
          price: completed ? AmpFormat.rupees(session.totalPaid) : null,
          priceUnit: completed ? AmpStrings.receiptTotal : '',
          showHairline: false,
          onTap: open,
        ),
        Padding(
          padding: const EdgeInsets.only(
            right: AmpTheme.screenPadding,
            bottom: AmpTheme.spaceXs,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextAction(
              completed
                  ? AmpStrings.sessionViewReceipt
                  : AmpStrings.sessionContinueAction,
              onPressed: open,
            ),
          ),
        ),
        const Hairline(),
      ],
    );
  }
}

StatusDotTone _statusTone(String? status) {
  return switch ((status ?? '').toUpperCase()) {
    AmpPolicy.statusCompleted => StatusDotTone.available,
    AmpPolicy.statusCharging => StatusDotTone.available,
    AmpPolicy.statusCheckedIn => StatusDotTone.neutral,
    AmpPolicy.statusCancelled || AmpPolicy.statusExpired => StatusDotTone.busy,
    _ => StatusDotTone.neutral,
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
        SkeletonLine(widthFactor: 0.18, height: 9),
        SizedBox(height: 8),
        SkeletonLine(widthFactor: 0.7, height: 24),
        SizedBox(height: 8),
        SkeletonLine(widthFactor: 0.5, height: 12),
        SizedBox(height: 16),
        Hairline(),
        SizedBox(height: 16),
        SkeletonLine(widthFactor: 0.18, height: 9),
        SizedBox(height: 8),
        SkeletonLine(widthFactor: 0.62, height: 24),
        SizedBox(height: 8),
        SkeletonLine(widthFactor: 0.46, height: 12),
        SizedBox(height: 16),
        Hairline(),
      ],
    );
  }
}
