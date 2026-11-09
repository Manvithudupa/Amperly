import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app/theme/amp_colors.dart';
import '../../../app/theme/amp_theme.dart';
import '../../../core/errors/user_messages.dart';
import '../../../core/formatting/amp_format.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_button.dart';
import '../../../core/widgets/amp_icon.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/hairline.dart';
import '../../../core/widgets/receipt_rows.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/status_dot_label.dart';
import '../../../core/widgets/text_action.dart';
import '../../../core/widgets/ticket_card.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_result.dart';
import '../../../domain/engines/reservation_engine.dart';
import '../../../domain/policy.dart';
import '../application/booking_providers.dart';
import 'booking_actions.dart';

/// The server-confirmed booking code, shown at the station.
class BookingCodeScreen extends ConsumerWidget {
  const BookingCodeScreen({required this.reservationId, super.key});

  final String reservationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<RepositoryResult<List<Reservation>>> bookings = ref.watch(
      consumerReservationsProvider,
    );
    final Reservation? reservation = _find(
      bookings.asData?.value,
      reservationId,
    );

    return AmpScaffold(
      title: AmpStrings.bookingCodeTitle,
      body: bookings.when(
        loading: () => const _BookingCodeLoading(),
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
          final Reservation? found = _find(result, reservationId);
          if (found == null) {
            return EmptyState(
              title: AmpStrings.bookingNotFoundTitle,
              message: AmpStrings.bookingNotFoundBody,
              action: AmpButton(
                label: AmpStrings.bookingViewBookings,
                icon: AmpIconName.ticket,
                expand: false,
                onPressed: () => context.go('/bookings'),
              ),
            );
          }
          return _BookingCodeBody(
            reservation: found,
            onCancel: found.status == AmpPolicy.statusReserved
                ? () => confirmBookingCancellation(context, ref, found)
                : null,
          );
        },
      ),
      bottomBar: reservation == null ? null : _bottomBar(context, reservation),
    );
  }

  Widget _bottomBar(BuildContext context, Reservation reservation) {
    final String status = (reservation.status ?? '').toUpperCase();
    if (status == AmpPolicy.statusReserved ||
        status == AmpPolicy.statusCheckedIn ||
        status == AmpPolicy.statusCharging) {
      return AmpButton(
        label: status == AmpPolicy.statusReserved
            ? AmpStrings.sessionOpenAction
            : AmpStrings.sessionContinueAction,
        icon: AmpIconName.bolt,
        onPressed: () => context.push('/sessions/${reservation.id}'),
      );
    }
    if (status == AmpPolicy.statusCompleted) {
      return AmpButton(
        label: AmpStrings.sessionViewReceipt,
        icon: AmpIconName.ticket,
        variant: AmpButtonVariant.quiet,
        onPressed: () => context.push('/sessions/${reservation.id}'),
      );
    }
    return AmpButton(
      label: AmpStrings.bookingViewBookings,
      icon: AmpIconName.ticket,
      variant: AmpButtonVariant.quiet,
      onPressed: () => context.go('/bookings'),
    );
  }

  Reservation? _find(RepositoryResult<List<Reservation>>? result, String id) {
    for (final Reservation reservation
        in result?.valueOrNull ?? const <Reservation>[]) {
      if (reservation.id == id) {
        return reservation;
      }
    }
    return null;
  }
}

class _BookingCodeBody extends StatelessWidget {
  const _BookingCodeBody({required this.reservation, required this.onCancel});

  final Reservation reservation;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final TextTheme text = Theme.of(context).textTheme;
    final String stationName = (reservation.stationName ?? '').trim();
    final String portLabel = (reservation.portLabel ?? '').trim();
    final String code = (reservation.bookingCode ?? '').trim();
    final String status = AmpFormat.bookingStatus(reservation.status);
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    final bool freeCancellation = reservation.isInFreeCancellationWindow(nowMs);
    final String resolvedStation = stationName.isEmpty
        ? AmpStrings.bookingStationFallback
        : stationName;
    final String slot = reservation.startTimeMs > 0
        ? '${AmpFormat.dayLabel(DateTime.fromMillisecondsSinceEpoch(reservation.startTimeMs))}, '
              '${AmpFormat.timeRange(reservation.startTimeMs, reservation.endTimeMs)}'
        : AmpStrings.availabilityUnknown;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AmpTheme.screenPadding,
        AmpTheme.spaceS,
        AmpTheme.screenPadding,
        AmpTheme.spaceXxl,
      ),
      children: <Widget>[
        StatusDotLabel(
          status.isEmpty ? AmpStrings.labelUnknown : status,
          tone: _statusTone(reservation.status),
        ),
        const SizedBox(height: 10),
        Text(
          reservation.isActive
              ? AmpStrings.bookingSuccessTitle
              : AmpStrings.bookingCodeTitle,
          style: text.displayMedium,
        ),
        const SizedBox(height: AmpTheme.spaceM),
        if (code.isEmpty)
          Text(AmpStrings.bookingCodeHint, style: text.bodyMedium)
        else ...<Widget>[
          TicketCard(
            notchOffset: 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Eyebrow(AmpStrings.bookingStationDetail),
                const SizedBox(height: 4),
                Text(
                  resolvedStation,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.displaySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  portLabel.isEmpty ? AmpStrings.labelUnknown : portLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  slot,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall,
                ),
                const SizedBox(height: 28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Eyebrow(AmpStrings.bookingCodeLabel),
                          const SizedBox(height: 6),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              code,
                              maxLines: 1,
                              style: AmpType.metric(
                                context,
                                size: 32,
                              ).copyWith(letterSpacing: 1.2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AmpTheme.spaceM),
                    _QrPanel(
                      payload: ReservationEngine.bookingQrPayload(reservation),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AmpTheme.spaceS),
          Text(AmpStrings.bookingCodeHint, style: text.bodySmall),
          const SizedBox(height: 2),
          Text(AmpStrings.bookingQrHint, style: text.bodySmall),
        ],
        const _SectionHeading(AmpStrings.bookingPriceTitle),
        ReceiptRows(
          lines: <ReceiptLine>[
            ReceiptLine(
              label: AmpStrings.bookingTariffDetail,
              value: '${AmpFormat.rupees(reservation.pricePerKwh)}/kWh',
            ),
            ReceiptLine(
              label: AmpStrings.bookingServiceDetail,
              value: AmpFormat.rupees(reservation.serviceFee),
            ),
            ReceiptLine(
              label: AmpStrings.bookingGatewayDetail,
              value: AmpFormat.rupees(reservation.gatewayFee),
            ),
          ],
        ),
        const SizedBox(height: AmpTheme.spaceS),
        Text(AmpStrings.bookingPriceNote, style: text.bodySmall),
        if (reservation.status == AmpPolicy.statusReserved) ...<Widget>[
          const _SectionHeading(AmpStrings.bookingPolicyTitle),
          _PolicyLine(
            message: freeCancellation
                ? AmpStrings.bookingFreeCancellation
                : AmpStrings.bookingLateCancellation,
            free: freeCancellation,
            colors: colors,
          ),
          if (onCancel != null) ...<Widget>[
            const SizedBox(height: AmpTheme.spaceS),
            TextAction(
              AmpStrings.bookingCancelAction,
              tone: TextActionTone.danger,
              onPressed: onCancel,
            ),
          ],
        ],
      ],
    );
  }
}

class _QrPanel extends StatelessWidget {
  const _QrPanel({required this.payload});

  final String payload;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: AmpStrings.bookingQrHint,
      child: ExcludeSemantics(
        child: Container(
          width: 96,
          height: 96,
          padding: const EdgeInsets.all(6),
          color: Colors.white,
          child: QrImageView(
            data: payload,
            size: 84,
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _PolicyLine extends StatelessWidget {
  const _PolicyLine({
    required this.message,
    required this.free,
    required this.colors,
  });

  final String message;
  final bool free;
  final AmpColors colors;

  @override
  Widget build(BuildContext context) {
    final Color dot = free ? colors.available : colors.busy;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: AmpTheme.spaceS),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: free ? colors.inkSecondary : colors.busyInk,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: AmpTheme.spaceL),
        const Hairline(),
        Padding(
          padding: const EdgeInsets.only(
            top: AmpTheme.spaceL,
            bottom: AmpTheme.spaceS,
          ),
          child: Eyebrow(label),
        ),
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

class _BookingCodeLoading extends StatelessWidget {
  const _BookingCodeLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AmpTheme.screenPadding),
      children: const <Widget>[
        SkeletonLine(widthFactor: 0.32, height: 12),
        SizedBox(height: AmpTheme.spaceS),
        SkeletonLine(widthFactor: 0.7, height: 26),
        SizedBox(height: AmpTheme.spaceL),
        Skeleton(height: 270, radius: AmpTheme.radiusCard),
        SizedBox(height: AmpTheme.spaceL),
        Skeleton(height: 120, radius: AmpTheme.radiusCard),
      ],
    );
  }
}
