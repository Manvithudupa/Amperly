import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/user_messages.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/repository_result.dart';
import '../../../data/repositories/reservation_repository.dart';
import '../../../data/repositories/station_repository.dart';
import '../../auth/application/profile_providers.dart';

/// Everything the booking form needs in one read: the live station, its ports,
/// its published schedules and the caller's own reservations (to avoid
/// offering a slot this account already holds).
final class StationBookingData {
  const StationBookingData({
    required this.entry,
    required this.schedules,
    required this.reservations,
  });

  final StationCatalogueEntry entry;
  final List<AvailabilitySchedule> schedules;
  final List<Reservation> reservations;
}

final bookingDataProvider =
    FutureProvider.family<RepositoryResult<StationBookingData>, String>((
      Ref ref,
      String stationId,
    ) async {
      final RepositoryResult<AppUser> profile = await ref.watch(
        currentProfileProvider.future,
      );
      final RepositoryFailure<AppUser>? profileFailure = profile.failureOrNull;
      if (profileFailure != null) {
        return RepositoryFailure<StationBookingData>(
          kind: profileFailure.kind,
          message: profileFailure.message,
          cause: profileFailure.cause,
        );
      }

      final StationRepository? stationRepository = ref.watch(
        stationRepositoryProvider,
      );
      final ReservationRepository? reservationRepository = ref.watch(
        reservationRepositoryProvider,
      );
      if (stationRepository == null || reservationRepository == null) {
        return RepositoryFailure<StationBookingData>(
          kind: UserMessageKind.sessionExpired,
          message: UserMessages.messageFor(UserMessageKind.sessionExpired),
        );
      }

      final RepositoryResult<StationCatalogueEntry> detail =
          await stationRepository.detail(stationId);
      final RepositoryFailure<StationCatalogueEntry>? detailFailure =
          detail.failureOrNull;
      if (detailFailure != null) {
        return RepositoryFailure<StationBookingData>(
          kind: detailFailure.kind,
          message: detailFailure.message,
          cause: detailFailure.cause,
        );
      }

      final RepositoryResult<List<AvailabilitySchedule>> schedules =
          await stationRepository.schedules(stationId);
      final RepositoryFailure<List<AvailabilitySchedule>>? scheduleFailure =
          schedules.failureOrNull;
      if (scheduleFailure != null) {
        return RepositoryFailure<StationBookingData>(
          kind: scheduleFailure.kind,
          message: scheduleFailure.message,
          cause: scheduleFailure.cause,
        );
      }

      final AppUser user = profile.valueOrNull!;
      final RepositoryResult<List<Reservation>> reservations =
          await reservationRepository.forConsumer(user.id);
      final RepositoryFailure<List<Reservation>>? reservationFailure =
          reservations.failureOrNull;
      if (reservationFailure != null) {
        return RepositoryFailure<StationBookingData>(
          kind: reservationFailure.kind,
          message: reservationFailure.message,
          cause: reservationFailure.cause,
        );
      }

      return RepositorySuccess<StationBookingData>(
        StationBookingData(
          entry: detail.valueOrNull!,
          schedules: schedules.valueOrNull!,
          reservations: reservations.valueOrNull!,
        ),
      );
    });

/// The signed-in consumer's real reservations, newest slot first.
final FutureProvider<RepositoryResult<List<Reservation>>>
consumerReservationsProvider =
    FutureProvider<RepositoryResult<List<Reservation>>>((Ref ref) async {
      final RepositoryResult<AppUser> profile = await ref.watch(
        currentProfileProvider.future,
      );
      final RepositoryFailure<AppUser>? profileFailure = profile.failureOrNull;
      if (profileFailure != null) {
        return RepositoryFailure<List<Reservation>>(
          kind: profileFailure.kind,
          message: profileFailure.message,
          cause: profileFailure.cause,
        );
      }

      final ReservationRepository? repository = ref.watch(
        reservationRepositoryProvider,
      );
      if (repository == null) {
        return RepositoryFailure<List<Reservation>>(
          kind: UserMessageKind.sessionExpired,
          message: UserMessages.messageFor(UserMessageKind.sessionExpired),
        );
      }

      return repository.forConsumer(profile.valueOrNull!.id);
    });
