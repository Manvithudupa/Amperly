import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/amp_theme.dart';
import '../../../core/errors/user_messages.dart';
import '../../../core/formatting/amp_format.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_button.dart';
import '../../../core/widgets/amp_icon.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/amp_snackbar.dart';
import '../../../core/widgets/departure_row.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/hairline.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/status_dot_label.dart';
import '../../../core/widgets/text_action.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_result.dart';
import '../../../domain/policy.dart';
import '../application/booking_providers.dart';
import '../application/chat_providers.dart';
import 'booking_actions.dart';

/// The consumer's real reservations, confirmed by the server.
class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<RepositoryResult<List<Reservation>>> bookings = ref.watch(
      consumerReservationsProvider,
    );

    return AmpScaffold(
      title: AmpStrings.bookingListTitle,
      subtitle: AmpStrings.bookingListSubtitle,
      body: bookings.when(
        loading: () => const _BookingsLoading(),
        error: (Object error, StackTrace stack) => ErrorState(
          message: UserMessages.from(error),
          onRetry: () => ref.invalidate(consumerReservationsProvider),
        ),
        data: (RepositoryResult<List<Reservation>> result) {
          final RepositoryFailure<List<Reservation>>? failure =
              result.failureOrNull;
          if (failure != null) {
            return ErrorState(
              message: failure.message,
              onRetry: () => ref.invalidate(consumerReservationsProvider),
            );
          }
          return _BookingsBody(reservations: result.valueOrNull!);
        },
      ),
    );
  }
}

class _BookingsBody extends ConsumerWidget {
  const _BookingsBody({required this.reservations});

  final List<Reservation> reservations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(consumerReservationsProvider);
        await ref.read(consumerReservationsProvider.future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          top: AmpTheme.spaceXs,
          bottom: AmpTheme.spaceXxl,
        ),
        children: <Widget>[
          if (reservations.isEmpty)
            EmptyState(
              title: AmpStrings.bookingEmptyTitle,
              message: AmpStrings.bookingEmptyBody,
              action: AmpButton(
                label: AmpStrings.bookingFindCharger,
                icon: AmpIconName.search,
                expand: false,
                onPressed: () => context.go('/home'),
              ),
            )
          else
            for (final Reservation reservation in reservations)
              _ReservationRow(
                reservation: reservation,
                onShowCode: () => context.push('/bookings/${reservation.id}'),
                onSession:
                    reservation.isActive ||
                        reservation.status == AmpPolicy.statusCompleted
                    ? () => context.push('/sessions/${reservation.id}')
                    : null,
                onViewCharger: (reservation.stationId ?? '').trim().isEmpty
                    ? null
                    : () => context.push('/chargers/${reservation.stationId}'),
                onNavigate: (reservation.stationId ?? '').trim().isEmpty
                    ? null
                    : () => context.push(
                        '/chargers/${reservation.stationId}?directions=1',
                      ),
                onCancel: reservation.status == AmpPolicy.statusReserved
                    ? () =>
                          confirmBookingCancellation(context, ref, reservation)
                    : null,
                onMessageHost: (reservation.stationId ?? '').trim().isEmpty
                    ? null
                    : () => _openChat(context, ref, reservation.id),
              ),
        ],
      ),
    );
  }
}

Future<void> _openChat(
  BuildContext context,
  WidgetRef ref,
  String reservationId,
) async {
  ref.invalidate(chatStarterProvider(reservationId));
  RepositoryResult<CommunicationThread> result;
  try {
    result = await ref.read(chatStarterProvider(reservationId).future);
  } on Object catch (error) {
    if (!context.mounted) {
      return;
    }
    AmpSnackbar.show(
      context,
      UserMessages.from(error),
      tone: AmpSnackbarTone.error,
    );
    return;
  }
  if (!context.mounted) {
    return;
  }

  final RepositoryFailure<CommunicationThread>? failure = result.failureOrNull;
  if (failure != null) {
    AmpSnackbar.show(context, failure.message, tone: AmpSnackbarTone.error);
    return;
  }

  final CommunicationThread? thread = result.valueOrNull;
  if (thread == null) {
    AmpSnackbar.show(
      context,
      AmpStrings.chatOpeningFailed,
      tone: AmpSnackbarTone.error,
    );
    return;
  }
  ref.invalidate(chatInboxProvider);
  unawaited(context.push('/messages/${thread.id}'));
}

class _ReservationRow extends StatelessWidget {
  const _ReservationRow({
    required this.reservation,
    required this.onShowCode,
    required this.onSession,
    required this.onViewCharger,
    required this.onNavigate,
    required this.onCancel,
    this.onMessageHost,
  });

  final Reservation reservation;
  final VoidCallback onShowCode;
  final VoidCallback? onSession;
  final VoidCallback? onViewCharger;
  final VoidCallback? onNavigate;
  final VoidCallback? onCancel;
  final VoidCallback? onMessageHost;

  @override
  Widget build(BuildContext context) {
    final String stationName = (reservation.stationName ?? '').trim();
    final String portLabel = (reservation.portLabel ?? '').trim();
    final String code = (reservation.bookingCode ?? '').trim();
    final String status = AmpFormat.bookingStatus(reservation.status);
    final DateTime? start = reservation.startTimeMs > 0
        ? DateTime.fromMillisecondsSinceEpoch(reservation.startTimeMs)
        : null;
    final String metric = start == null ? '—' : AmpFormat.dayNumber(start);
    final String metricUnit = start == null
        ? AmpStrings.labelUnknown
        : AmpFormat.monthShort(start);
    final String slot = reservation.startTimeMs > 0
        ? '${AmpFormat.dayLabel(start!)}, '
              '${AmpFormat.timeRange(reservation.startTimeMs, reservation.endTimeMs)}'
        : AmpStrings.availabilityUnknown;
    final String detail = portLabel.isEmpty ? slot : '$slot · $portLabel';
    final String? price = reservation.pricePerKwh > 0
        ? AmpFormat.rupees(reservation.pricePerKwh)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DepartureRow(
          title: stationName.isEmpty
              ? AmpStrings.bookingStationFallback
              : stationName,
          metric: metric,
          metricUnit: metricUnit,
          detail: detail,
          statusLabel: status.isEmpty ? AmpStrings.labelUnknown : status,
          statusDetail: code.isEmpty ? null : code,
          statusTone: _statusTone(reservation.status),
          price: price,
          priceUnit: AmpStrings.perKwh,
          onTap: onShowCode,
          showHairline: false,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AmpTheme.screenPadding - 4,
            0,
            AmpTheme.screenPadding,
            10,
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 0,
            children: <Widget>[
              TextAction(AmpStrings.bookingShowCode, onPressed: onShowCode),
              if (onSession != null)
                TextAction(
                  reservation.status == AmpPolicy.statusCompleted
                      ? AmpStrings.sessionViewReceipt
                      : reservation.status == AmpPolicy.statusReserved
                      ? AmpStrings.sessionOpenAction
                      : AmpStrings.sessionContinueAction,
                  onPressed: onSession,
                ),
              if (onMessageHost != null)
                TextAction(
                  AmpStrings.chatMessageHost,
                  onPressed: onMessageHost,
                ),
              if (onViewCharger != null)
                TextAction(
                  AmpStrings.bookingViewCharger,
                  onPressed: onViewCharger,
                ),
              if (onNavigate != null)
                TextAction(
                  AmpStrings.bookingNavigateAction,
                  onPressed: onNavigate,
                ),
              if (onCancel != null)
                TextAction(
                  AmpStrings.bookingCancelAction,
                  tone: TextActionTone.danger,
                  onPressed: onCancel,
                ),
            ],
          ),
        ),
        const Hairline(),
      ],
    );
  }
}

StatusDotTone _statusTone(String? status) {
  return switch ((status ?? '').toUpperCase()) {
    'CHECKED_IN' || 'CHARGING' || 'COMPLETED' => StatusDotTone.available,
    'DISPUTED' || 'REFUNDED' => StatusDotTone.busy,
    _ => StatusDotTone.neutral,
  };
}

class _BookingsLoading extends StatelessWidget {
  const _BookingsLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: AmpTheme.spaceXs),
      children: <Widget>[
        for (int index = 0; index < 3; index++) ...<Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AmpTheme.screenPadding,
              vertical: 14,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 48,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Skeleton(width: 30, height: 26),
                      SizedBox(height: 3),
                      Skeleton(width: 24, height: 9),
                    ],
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Skeleton(width: 170, height: 14),
                      SizedBox(height: AmpTheme.spaceS),
                      Skeleton(width: 220, height: 10),
                      SizedBox(height: AmpTheme.spaceS),
                      Skeleton(width: 128, height: 10),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                SizedBox(
                  width: 54,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Skeleton(width: 42, height: 18),
                      SizedBox(height: 4),
                      Skeleton(width: 24, height: 9),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Hairline(),
        ],
      ],
    );
  }
}
