import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';
import 'repository_result.dart';
import 'rpc_repository.dart';

final class ReservationRepository {
  ReservationRepository(this._client) : _rpc = RpcRepository(_client);

  final SupabaseClient _client;
  final RpcRepository _rpc;

  Future<RepositoryResult<List<Reservation>>> forConsumer(
    String consumerId,
  ) async {
    try {
      final List<dynamic> rows = await _client
          .from('reservations')
          .select()
          .eq('consumerId', consumerId)
          .order('startTimeMs', ascending: false);
      return RepositorySuccess<List<Reservation>>(
        rows
            .whereType<Map<String, dynamic>>()
            .map(
              (Map<String, dynamic> row) =>
                  Reservation.fromJson(Map<String, dynamic>.from(row)),
            )
            .toList(growable: false),
      );
    } on Object catch (error) {
      return RepositoryFailure<List<Reservation>>.from(error);
    }
  }

  Future<RepositoryResult<String>> create({
    required String id,
    required String stationId,
    required String portId,
    required int startMs,
    required int endMs,
    required String bookingCode,
  }) {
    return _rpc.createReservation(
      id: id,
      stationId: stationId,
      portId: portId,
      startMs: startMs,
      endMs: endMs,
      bookingCode: bookingCode,
    );
  }

  Future<RepositoryResult<String>> cancel(String reservationId) =>
      _rpc.cancelReservation(reservationId);

  /// Advances the booking's operational status during check-in and charging.
  ///
  /// The server's tamper trigger pins the slot, port, price and payment state;
  /// only the status fields written here are allowed to change.
  Future<RepositoryResult<bool>> updateStatus(
    String reservationId, {
    required String status,
    int? checkedInAtMs,
  }) async {
    try {
      final Map<String, Object?> values = <String, Object?>{'status': status};
      if (checkedInAtMs != null && checkedInAtMs > 0) {
        values['checkedInAtMs'] = checkedInAtMs;
      }
      await _client.from('reservations').update(values).eq('id', reservationId);
      return const RepositorySuccess<bool>(true);
    } on Object catch (error) {
      return RepositoryFailure<bool>.from(error);
    }
  }
}
