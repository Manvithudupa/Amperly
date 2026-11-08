import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/amp_format.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/repository_result.dart';
import '../../../data/repositories/reservation_repository.dart';
import '../../../domain/engines/billing_engine.dart';
import '../application/booking_providers.dart';
import '../application/booking_rules.dart';

/// Confirms and performs a cancellation through the server RPC.
///
/// The server decides whether the booking may still be cancelled and records
/// any late fee. A local failure never removes the card optimistically.
Future<bool> confirmBookingCancellation(
  BuildContext context,
  WidgetRef ref,
  Reservation reservation,
) async {
  final CancellationResult cancellation = BillingEngine.calculateCancellation(
    reservation,
    DateTime.now().millisecondsSinceEpoch,
  );
  final bool confirmed = await showAmpConfirmDialog(
    context,
    title: AmpStrings.bookingCancelTitle,
    message: cancellation.free
        ? AmpStrings.bookingCancelFreeBody
        : AmpStrings.bookingCancelFeeBody(AmpFormat.rupees(cancellation.fee)),
    confirmLabel: AmpStrings.bookingCancelAction,
    cancelLabel: AmpStrings.bookingKeep,
  );
  if (!confirmed || !context.mounted) {
    return false;
  }

  final ReservationRepository? repository = ref.read(
    reservationRepositoryProvider,
  );
  if (repository == null) {
    AmpSnackbar.show(
      context,
      AmpStrings.bookingServerRequired,
      tone: AmpSnackbarTone.error,
    );
    return false;
  }

  final RepositoryResult<String> result = await repository.cancel(
    reservation.id,
  );
  if (!context.mounted) {
    return false;
  }

  final RepositoryFailure<String>? failure = result.failureOrNull;
  if (failure != null) {
    AmpSnackbar.show(
      context,
      BookingRules.refusalMessage(
        failure.cause,
        fallback: AmpStrings.bookingCancelFailed,
      ),
      tone: AmpSnackbarTone.error,
    );
    return false;
  }

  ref.invalidate(consumerReservationsProvider);
  final String stationId = (reservation.stationId ?? '').trim();
  if (stationId.isNotEmpty) {
    ref.invalidate(bookingDataProvider(stationId));
  }
  AmpSnackbar.show(
    context,
    AmpStrings.bookingCancelled,
    tone: AmpSnackbarTone.success,
  );
  return true;
}
