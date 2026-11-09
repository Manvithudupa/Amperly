import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/strings.dart';
import '../../../data/models/models.dart';
import '../../../domain/policy.dart';
import 'booking_providers.dart';
import 'session_providers.dart';

enum ActiveJourneyKind { startingSoon, charging }

/// The one reservation or session worth surfacing above the navigation bar.
class ActiveJourney {
  const ActiveJourney({
    required this.reservationId,
    required this.stationName,
    required this.kind,
    this.startTimeMs = 0,
    this.energyKwh = 0,
  });

  final String reservationId;
  final String stationName;
  final ActiveJourneyKind kind;
  final int startTimeMs;
  final double energyKwh;

  String get route => switch (kind) {
    ActiveJourneyKind.charging => '/sessions/$reservationId',
    ActiveJourneyKind.startingSoon => '/bookings/$reservationId',
  };
}

/// Finds a session in progress first, then a reservation starting within the
/// next hour. Server data only; the banner simply stays away when there is no
/// suitable booking or when the read fails.
final FutureProvider<ActiveJourney?> activeJourneyProvider =
    FutureProvider<ActiveJourney?>((Ref ref) async {
      final results = await ref.watch(consumerReservationsProvider.future);
      final List<Reservation> reservations =
          results.valueOrNull ?? const <Reservation>[];
      if (reservations.isEmpty) {
        return null;
      }

      final int nowMs = DateTime.now().millisecondsSinceEpoch;
      Reservation? inProgress;
      for (final Reservation reservation in reservations) {
        final String status = (reservation.status ?? '').toUpperCase();
        if (status == AmpPolicy.statusCheckedIn ||
            status == AmpPolicy.statusCharging) {
          inProgress = reservation;
          break;
        }
      }

      if (inProgress != null) {
        double energyKwh = 0;
        try {
          final SessionData? detail = (await ref.watch(
            sessionDataProvider(inProgress.id).future,
          )).valueOrNull;
          energyKwh = detail?.session?.verifiedKwhConsumed ?? 0;
        } on Object {
          // The session may be opening; the banner can still link to it.
        }
        return ActiveJourney(
          reservationId: inProgress.id,
          stationName: _stationName(inProgress),
          kind: ActiveJourneyKind.charging,
          startTimeMs: inProgress.startTimeMs,
          energyKwh: energyKwh,
        );
      }

      final List<Reservation> startingSoon =
          reservations
              .where((Reservation reservation) {
                return (reservation.status ?? '').toUpperCase() ==
                        AmpPolicy.statusReserved &&
                    reservation.startTimeMs > nowMs &&
                    reservation.startTimeMs - nowMs <= 60 * 60000 &&
                    (reservation.endTimeMs == 0 ||
                        reservation.endTimeMs > nowMs);
              })
              .toList(growable: false)
            ..sort(
              (Reservation a, Reservation b) =>
                  a.startTimeMs.compareTo(b.startTimeMs),
            );
      if (startingSoon.isEmpty) {
        return null;
      }

      final Reservation next = startingSoon.first;
      return ActiveJourney(
        reservationId: next.id,
        stationName: _stationName(next),
        kind: ActiveJourneyKind.startingSoon,
        startTimeMs: next.startTimeMs,
      );
    });

String _stationName(Reservation reservation) {
  final String name = (reservation.stationName ?? '').trim();
  return name.isEmpty ? AmpStrings.unnamedCharger : name;
}
