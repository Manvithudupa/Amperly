import 'dart:async';

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
import '../../../core/widgets/amp_chip.dart';
import '../../../core/widgets/amp_icon.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/amp_snackbar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/skeleton.dart';
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
        padding: const EdgeInsets.fromLTRB(
          AmpTheme.screenPadding,
          AmpTheme.spaceM,
          AmpTheme.screenPadding,
          AmpTheme.spaceXxl,
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
            for (final Reservation reservation in reservations) ...<Widget>[
              _ReservationCard(
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
                onCancel: reservation.status == AmpPolicy.statusReserved
                    ? () =>
                          confirmBookingCancellation(context, ref, reservation)
                    : null,
                onMessageHost: (reservation.stationId ?? '').trim().isEmpty
                    ? null
                    : () => _openChat(context, ref, reservation.id),
              ),
              const SizedBox(height: AmpTheme.spaceM),
            ],
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

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.reservation,
    required this.onShowCode,
    required this.onSession,
    required this.onViewCharger,
    required this.onCancel,
    this.onMessageHost,
  });

  final Reservation reservation;
  final VoidCallback onShowCode;
  final VoidCallback? onSession;
  final VoidCallback? onViewCharger;
  final VoidCallback? onCancel;
  final VoidCallback? onMessageHost;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final TextTheme text = Theme.of(context).textTheme;
    final String stationName = (reservation.stationName ?? '').trim();
    final String portLabel = (reservation.portLabel ?? '').trim();
    final String code = (reservation.bookingCode ?? '').trim();
    final String status = AmpFormat.bookingStatus(reservation.status);
    final String payment = reservation.isPaid
        ? AmpStrings.bookingTariffLine(
            AmpFormat.rupees(reservation.pricePerKwh),
            AmpFormat.rupees(reservation.serviceFee),
            AmpFormat.rupees(reservation.gatewayFee),
          )
        : AmpStrings.bookingNoPayment;

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
        side: BorderSide(color: colors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onShowCode,
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
                    tone: _statusTone(reservation.status),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                reservation.startTimeMs > 0
                    ? '${AmpFormat.dayLabel(DateTime.fromMillisecondsSinceEpoch(reservation.startTimeMs))}, '
                          '${AmpFormat.timeRange(reservation.startTimeMs, reservation.endTimeMs)}'
                    : AmpStrings.availabilityUnknown,
                style: text.bodyMedium,
              ),
              if (portLabel.isNotEmpty) ...<Widget>[
                const SizedBox(height: 2),
                Text(portLabel, style: text.bodySmall),
              ],
              if (code.isNotEmpty) ...<Widget>[
                const SizedBox(height: AmpTheme.spaceS),
                Align(
                  alignment: Alignment.centerLeft,
                  child: AmpChip(
                    label: code,
                    icon: AmpIconName.qr,
                    selected: true,
                    onTap: onShowCode,
                  ),
                ),
              ],
              const SizedBox(height: AmpTheme.spaceS),
              Text(payment, style: text.bodySmall),
              const Divider(height: AmpTheme.spaceL),
              Wrap(
                spacing: AmpTheme.spaceS,
                runSpacing: 2,
                children: <Widget>[
                  TextButton(
                    onPressed: onShowCode,
                    child: const Text(AmpStrings.bookingShowCode),
                  ),
                  if (onSession != null)
                    TextButton(
                      onPressed: onSession,
                      child: Text(
                        reservation.status == AmpPolicy.statusCompleted
                            ? AmpStrings.sessionViewReceipt
                            : reservation.status == AmpPolicy.statusReserved
                            ? AmpStrings.sessionOpenAction
                            : AmpStrings.sessionContinueAction,
                      ),
                    ),
                  if (onMessageHost != null)
                    TextButton(
                      onPressed: onMessageHost,
                      child: const Text(AmpStrings.chatMessageHost),
                    ),
                  if (onViewCharger != null)
                    TextButton(
                      onPressed: onViewCharger,
                      child: const Text(AmpStrings.bookingViewCharger),
                    ),
                  if (onCancel != null)
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: colors.error,
                      ),
                      onPressed: onCancel,
                      child: const Text(AmpStrings.bookingCancelAction),
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

AmpBadgeTone _statusTone(String? status) {
  return switch ((status ?? '').toUpperCase()) {
    'RESERVED' => AmpBadgeTone.info,
    'CHECKED_IN' || 'CHARGING' => AmpBadgeTone.success,
    'DISPUTED' || 'REFUNDED' => AmpBadgeTone.warning,
    _ => AmpBadgeTone.neutral,
  };
}

class _BookingsLoading extends StatelessWidget {
  const _BookingsLoading();

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
        Skeleton(height: 158, radius: AmpTheme.radiusCard),
        SizedBox(height: AmpTheme.spaceM),
        Skeleton(height: 158, radius: AmpTheme.radiusCard),
        SizedBox(height: AmpTheme.spaceM),
        Skeleton(height: 158, radius: AmpTheme.radiusCard),
      ],
    );
  }
}
