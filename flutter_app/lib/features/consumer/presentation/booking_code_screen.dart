import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
import '../../../core/widgets/receipt_row.dart';
import '../../../core/widgets/skeleton.dart';
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
        variant: AmpButtonVariant.tonal,
        onPressed: () => context.push('/sessions/${reservation.id}'),
      );
    }
    return AmpButton(
      label: AmpStrings.bookingViewBookings,
      icon: AmpIconName.ticket,
      variant: AmpButtonVariant.tonal,
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AmpTheme.screenPadding,
        AmpTheme.spaceL,
        AmpTheme.screenPadding,
        AmpTheme.spaceXxl,
      ),
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text(
                reservation.isActive
                    ? AmpStrings.bookingSuccessTitle
                    : AmpStrings.bookingCodeTitle,
                style: text.displaySmall,
              ),
            ),
            const SizedBox(width: AmpTheme.spaceS),
            AmpBadge(
              status.isEmpty ? AmpStrings.labelUnknown : status,
              tone: _statusTone(reservation.status),
            ),
          ],
        ),
        const SizedBox(height: AmpTheme.spaceS),
        Text(
          stationName.isEmpty ? AmpStrings.bookingStationFallback : stationName,
          style: text.titleMedium,
        ),
        const SizedBox(height: 2),
        Text(
          reservation.startTimeMs > 0
              ? '${AmpFormat.dayLabel(DateTime.fromMillisecondsSinceEpoch(reservation.startTimeMs))}, '
                    '${AmpFormat.timeRange(reservation.startTimeMs, reservation.endTimeMs)}'
              : AmpStrings.availabilityUnknown,
          style: text.bodyMedium,
        ),
        if (code.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AmpTheme.spaceM),
            child: Text(AmpStrings.bookingCodeHint, style: text.bodySmall),
          )
        else ...<Widget>[
          const SizedBox(height: AmpTheme.spaceL),
          Text(AmpStrings.bookingCodeLabel, style: text.labelLarge),
          const SizedBox(height: AmpTheme.spaceS),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AmpTheme.spaceM),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
            ),
            child: Column(
              children: <Widget>[
                Semantics(
                  image: true,
                  label: AmpStrings.bookingQrHint,
                  child: QrImageView(
                    data: ReservationEngine.bookingQrPayload(reservation),
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: AmpTheme.spaceS),
                Text(
                  code,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AmpTheme.uiFont,
                    fontSize: 24,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AmpTheme.spaceS),
          Text(AmpStrings.bookingCodeHint, style: text.bodySmall),
          const SizedBox(height: 2),
          Text(AmpStrings.bookingQrHint, style: text.bodySmall),
        ],
        _SectionTitle(AmpStrings.bookingTimeDetail),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AmpTheme.spaceM),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
            border: Border.all(color: colors.divider),
          ),
          child: Column(
            children: <Widget>[
              _DetailLine(
                label: AmpStrings.bookingStationDetail,
                value: stationName.isEmpty
                    ? AmpStrings.bookingStationFallback
                    : stationName,
              ),
              _DetailLine(
                label: AmpStrings.bookingPortDetail,
                value: portLabel.isEmpty ? AmpStrings.labelUnknown : portLabel,
              ),
              _DetailLine(
                label: AmpStrings.bookingTimeDetail,
                value: reservation.startTimeMs > 0
                    ? '${AmpFormat.dayLabel(DateTime.fromMillisecondsSinceEpoch(reservation.startTimeMs))}, '
                          '${AmpFormat.timeRange(reservation.startTimeMs, reservation.endTimeMs)}'
                    : AmpStrings.availabilityUnknown,
              ),
            ],
          ),
        ),
        _SectionTitle(AmpStrings.bookingPriceTitle),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AmpTheme.spaceM),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
            border: Border.all(color: colors.divider),
          ),
          child: Column(
            children: <Widget>[
              ReceiptRow(
                label: AmpStrings.bookingTariffDetail,
                value: '${AmpFormat.rupees(reservation.pricePerKwh)}/kWh',
              ),
              ReceiptRow(
                label: AmpStrings.bookingServiceDetail,
                value: AmpFormat.rupees(reservation.serviceFee),
              ),
              ReceiptRow(
                label: AmpStrings.bookingGatewayDetail,
                value: AmpFormat.rupees(reservation.gatewayFee),
              ),
            ],
          ),
        ),
        const SizedBox(height: AmpTheme.spaceS),
        Text(AmpStrings.bookingPriceNote, style: text.bodySmall),
        if (reservation.status == AmpPolicy.statusReserved) ...<Widget>[
          _SectionTitle(AmpStrings.bookingPolicyTitle),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AmpTheme.spaceM),
            decoration: BoxDecoration(
              color: freeCancellation ? colors.availableTint : colors.busyTint,
              borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AmpIcon(
                  freeCancellation ? AmpIconName.check : AmpIconName.alert,
                  size: 18,
                  color: freeCancellation ? colors.available : colors.busyInk,
                ),
                const SizedBox(width: AmpTheme.spaceS),
                Expanded(
                  child: Text(
                    freeCancellation
                        ? AmpStrings.bookingFreeCancellation
                        : AmpStrings.bookingLateCancellation,
                    style: text.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          if (onCancel != null) ...<Widget>[
            const SizedBox(height: AmpTheme.spaceL),
            AmpButton(
              label: AmpStrings.bookingCancelAction,
              variant: AmpButtonVariant.danger,
              onPressed: onCancel,
            ),
          ],
        ],
      ],
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AmpTheme.spaceS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: text.labelLarge),
          const SizedBox(height: 2),
          Text(value, style: text.bodyMedium),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AmpTheme.spaceL,
        bottom: AmpTheme.spaceS,
      ),
      child: Text(label, style: Theme.of(context).textTheme.titleMedium),
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

class _BookingCodeLoading extends StatelessWidget {
  const _BookingCodeLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AmpTheme.screenPadding),
      children: const <Widget>[
        SkeletonLine(widthFactor: 0.7, height: 26),
        SizedBox(height: AmpTheme.spaceS),
        SkeletonLine(widthFactor: 0.45),
        SizedBox(height: AmpTheme.spaceL),
        Skeleton(height: 260, radius: AmpTheme.radiusCard),
        SizedBox(height: AmpTheme.spaceL),
        Skeleton(height: 120, radius: AmpTheme.radiusCard),
      ],
    );
  }
}
