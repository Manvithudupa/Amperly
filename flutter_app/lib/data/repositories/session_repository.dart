import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/policy.dart';
import '../models/models.dart';
import 'repository_result.dart';
import 'rpc_repository.dart';

final class SessionRepository {
  SessionRepository(this._client) : _rpc = RpcRepository(_client);

  final SupabaseClient _client;
  final RpcRepository _rpc;

  Future<RepositoryResult<List<ChargingSession>>> forConsumer(
    String consumerId,
  ) async {
    try {
      final List<dynamic> rows = await _client
          .from('charging_sessions')
          .select()
          .eq('consumerId', consumerId)
          .order('startTimeMs', ascending: false);
      return RepositorySuccess<List<ChargingSession>>(
        rows
            .whereType<Map<String, dynamic>>()
            .map(
              (Map<String, dynamic> row) =>
                  ChargingSession.fromJson(Map<String, dynamic>.from(row)),
            )
            .toList(growable: false),
      );
    } on Object catch (error) {
      return RepositoryFailure<List<ChargingSession>>.from(error);
    }
  }

  Future<RepositoryResult<ChargingSession?>> forReservation(
    String reservationId,
  ) async {
    try {
      final List<dynamic> rows = await _client
          .from('charging_sessions')
          .select()
          .eq('reservationId', reservationId)
          .order('startTimeMs', ascending: false)
          .limit(1);
      if (rows.isEmpty) {
        return const RepositorySuccess<ChargingSession?>(null);
      }
      return RepositorySuccess<ChargingSession?>(
        ChargingSession.fromJson(
          Map<String, dynamic>.from(rows.first as Map<dynamic, dynamic>),
        ),
      );
    } on Object catch (error) {
      return RepositoryFailure<ChargingSession?>.from(error);
    }
  }

  Future<RepositoryResult<Invoice?>> invoiceForSession(String sessionId) async {
    try {
      final List<dynamic> rows = await _client
          .from('invoices')
          .select()
          .eq('sessionId', sessionId)
          .order('issuedAtMs', ascending: false)
          .limit(1);
      if (rows.isEmpty) {
        return const RepositorySuccess<Invoice?>(null);
      }
      return RepositorySuccess<Invoice?>(
        Invoice.fromJson(
          Map<String, dynamic>.from(rows.first as Map<dynamic, dynamic>),
        ),
      );
    } on Object catch (error) {
      return RepositoryFailure<Invoice?>.from(error);
    }
  }

  /// Opens a server session at check-in with zero billing.
  ///
  /// The insert trigger pins every money column to zero and the consumer's
  /// session policy permits the row. Settlement is still performed only by
  /// `finalize_charging_session`.
  Future<RepositoryResult<ChargingSession>> open({
    required String id,
    required String reservationId,
    required String consumerId,
    required String? hostId,
    required String? stationId,
    required String? stationName,
    required String? portId,
    required int startTimeMs,
    required double startingMeterKwh,
    required String? verificationLevel,
  }) async {
    try {
      final Map<String, dynamic> row = await _client
          .from('charging_sessions')
          .insert(<String, Object?>{
            'id': id,
            'reservationId': reservationId,
            'consumerId': consumerId,
            'hostId': hostId,
            'stationId': stationId,
            'stationName': stationName,
            'portId': portId,
            'startTimeMs': startTimeMs,
            'endTimeMs': 0,
            'startingMeterKwh': startingMeterKwh,
            'endingMeterKwh': 0,
            'verifiedKwhConsumed': 0,
            'energyCharge': 0,
            'serviceFee': 0,
            'gatewayFee': 0,
            'totalPaid': 0,
            'status': AmpPolicy.statusCheckedIn,
            'meterReadingId': null,
            'invoiceId': null,
            'isMeterSimulated': false,
            'verificationLevel': verificationLevel,
          })
          .select()
          .single();
      return RepositorySuccess<ChargingSession>(
        ChargingSession.fromJson(Map<String, dynamic>.from(row)),
      );
    } on Object catch (error) {
      return RepositoryFailure<ChargingSession>.from(error);
    }
  }

  Future<RepositoryResult<bool>> setStatus({
    required String sessionId,
    required String status,
  }) async {
    try {
      await _client
          .from('charging_sessions')
          .update(<String, Object?>{'status': status})
          .eq('id', sessionId);
      return const RepositorySuccess<bool>(true);
    } on Object catch (error) {
      return RepositoryFailure<bool>.from(error);
    }
  }

  Future<RepositoryResult<String>> finalize({
    required String sessionId,
    required String reservationId,
    required double startMeterKwh,
    required double endMeterKwh,
    required bool isSimulated,
    required String meterReadingId,
    required String invoiceId,
  }) {
    return _rpc.finalizeChargingSession(
      sessionId: sessionId,
      reservationId: reservationId,
      startMeterKwh: startMeterKwh,
      endMeterKwh: endMeterKwh,
      isSimulated: isSimulated,
      meterReadingId: meterReadingId,
      invoiceId: invoiceId,
    );
  }
}
