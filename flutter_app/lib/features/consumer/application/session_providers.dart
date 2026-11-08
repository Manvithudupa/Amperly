import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/user_messages.dart';
import '../../../core/ui/strings.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/repository_result.dart';
import '../../../data/repositories/reservation_repository.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../data/repositories/station_repository.dart';
import '../../auth/application/profile_providers.dart';

final class SessionData {
  const SessionData({
    required this.consumer,
    required this.reservation,
    required this.station,
    this.port,
    this.session,
    this.invoice,
  });

  final AppUser consumer;
  final Reservation reservation;
  final ChargerStation station;
  final ChargerPort? port;
  final ChargingSession? session;
  final Invoice? invoice;
}

RepositoryFailure<T> _propagate<T, S>(RepositoryFailure<S> failure) {
  return RepositoryFailure<T>(
    kind: failure.kind,
    message: failure.message,
    cause: failure.cause,
  );
}

/// One booking, its station and port, the server session if one exists, and the
/// issued invoice after settlement.
final sessionDataProvider =
    FutureProvider.family<RepositoryResult<SessionData>, String>((
      Ref ref,
      String reservationId,
    ) async {
      final RepositoryResult<AppUser> profile = await ref.watch(
        currentProfileProvider.future,
      );
      final RepositoryFailure<AppUser>? profileFailure = profile.failureOrNull;
      if (profileFailure != null) {
        return _propagate<SessionData, AppUser>(profileFailure);
      }

      final StationRepository? stationRepository = ref.watch(
        stationRepositoryProvider,
      );
      final ReservationRepository? reservationRepository = ref.watch(
        reservationRepositoryProvider,
      );
      final SessionRepository? sessionRepository = ref.watch(
        sessionRepositoryProvider,
      );
      if (stationRepository == null ||
          reservationRepository == null ||
          sessionRepository == null) {
        return RepositoryFailure<SessionData>(
          kind: UserMessageKind.sessionExpired,
          message: UserMessages.messageFor(UserMessageKind.sessionExpired),
        );
      }

      final AppUser consumer = profile.valueOrNull!;
      final RepositoryResult<List<Reservation>> reservations =
          await reservationRepository.forConsumer(consumer.id);
      final RepositoryFailure<List<Reservation>>? reservationFailure =
          reservations.failureOrNull;
      if (reservationFailure != null) {
        return _propagate<SessionData, List<Reservation>>(reservationFailure);
      }

      Reservation? reservation;
      for (final Reservation candidate
          in reservations.valueOrNull ?? const <Reservation>[]) {
        if (candidate.id == reservationId) {
          reservation = candidate;
          break;
        }
      }
      if (reservation == null) {
        return RepositoryFailure<SessionData>(
          kind: UserMessageKind.unknown,
          message: AmpStrings.bookingNotFoundBody,
        );
      }

      final String stationId = (reservation.stationId ?? '').trim();
      if (stationId.isEmpty) {
        return const RepositoryFailure<SessionData>(
          kind: UserMessageKind.unknown,
          message: AmpStrings.sessionStationMissing,
        );
      }

      final RepositoryResult<StationCatalogueEntry> detail =
          await stationRepository.detail(stationId);
      final RepositoryFailure<StationCatalogueEntry>? stationFailure =
          detail.failureOrNull;
      if (stationFailure != null) {
        return _propagate<SessionData, StationCatalogueEntry>(stationFailure);
      }

      final StationCatalogueEntry entry = detail.valueOrNull!;
      ChargerPort? port;
      for (final ChargerPort candidate in entry.ports) {
        if (candidate.id == reservation.portId) {
          port = candidate;
          break;
        }
      }

      final RepositoryResult<ChargingSession?> sessionResult =
          await sessionRepository.forReservation(reservation.id);
      final RepositoryFailure<ChargingSession?>? sessionFailure =
          sessionResult.failureOrNull;
      if (sessionFailure != null) {
        return _propagate<SessionData, ChargingSession?>(sessionFailure);
      }

      final ChargingSession? session = sessionResult.valueOrNull;
      Invoice? invoice;
      if (session != null) {
        final RepositoryResult<Invoice?> invoiceResult = await sessionRepository
            .invoiceForSession(session.id);
        final RepositoryFailure<Invoice?>? invoiceFailure =
            invoiceResult.failureOrNull;
        if (invoiceFailure != null) {
          return _propagate<SessionData, Invoice?>(invoiceFailure);
        }
        invoice = invoiceResult.valueOrNull;
      }

      return RepositorySuccess<SessionData>(
        SessionData(
          consumer: consumer,
          reservation: reservation,
          station: entry.station,
          port: port,
          session: session,
          invoice: invoice,
        ),
      );
    });

/// Every server session for the signed-in consumer, newest first.
final FutureProvider<RepositoryResult<List<ChargingSession>>>
consumerSessionsProvider =
    FutureProvider<RepositoryResult<List<ChargingSession>>>((Ref ref) async {
      final RepositoryResult<AppUser> profile = await ref.watch(
        currentProfileProvider.future,
      );
      final RepositoryFailure<AppUser>? profileFailure = profile.failureOrNull;
      if (profileFailure != null) {
        return _propagate<List<ChargingSession>, AppUser>(profileFailure);
      }

      final SessionRepository? repository = ref.watch(
        sessionRepositoryProvider,
      );
      if (repository == null) {
        return RepositoryFailure<List<ChargingSession>>(
          kind: UserMessageKind.sessionExpired,
          message: UserMessages.messageFor(UserMessageKind.sessionExpired),
        );
      }

      return repository.forConsumer(profile.valueOrNull!.id);
    });
