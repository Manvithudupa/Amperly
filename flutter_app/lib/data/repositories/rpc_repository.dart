import 'package:supabase_flutter/supabase_flutter.dart';

import 'repository_result.dart';

abstract final class RpcPayloads {
  static Map<String, Object?> createReservation({
    required String id,
    required String stationId,
    required String portId,
    required int startMs,
    required int endMs,
    required String bookingCode,
  }) {
    return <String, Object?>{
      'p_id': id,
      'p_station_id': stationId,
      'p_port_id': portId,
      'p_start_ms': startMs,
      'p_end_ms': endMs,
      'p_booking_code': bookingCode,
    };
  }

  static Map<String, Object?> cancelReservation(String reservationId) =>
      <String, Object?>{'p_reservation_id': reservationId};

  static Map<String, Object?> finalizeChargingSession({
    required String sessionId,
    required String reservationId,
    required double startMeterKwh,
    required double endMeterKwh,
    required bool isSimulated,
    required String meterReadingId,
    required String invoiceId,
  }) {
    return <String, Object?>{
      'p_session_id': sessionId,
      'p_reservation_id': reservationId,
      'p_start_meter_kwh': startMeterKwh,
      'p_end_meter_kwh': endMeterKwh,
      'p_is_simulated': isSimulated,
      'p_meter_reading_id': meterReadingId,
      'p_invoice_id': invoiceId,
    };
  }

  static Map<String, Object?> authorizePayment({
    required String id,
    required String reservationId,
    required String stationId,
    required double amount,
    required String idempotencyKey,
  }) {
    return <String, Object?>{
      'p_id': id,
      'p_reservation_id': reservationId,
      'p_station_id': stationId,
      'p_amount': amount,
      'p_idempotency_key': idempotencyKey,
    };
  }

  static Map<String, Object?> decideStationApproval({
    required String stationId,
    required bool approve,
  }) {
    return <String, Object?>{'p_station_id': stationId, 'p_approve': approve};
  }

  static Map<String, Object?> resolveDisputeRefund(String disputeId) =>
      <String, Object?>{'p_dispute_id': disputeId};

  static Map<String, Object?> freezeDisputePayout(String disputeId) =>
      <String, Object?>{'p_dispute_id': disputeId};

  static Map<String, Object?> applyHostEnforcement({
    required String disputeId,
    required String action,
    required double fineAmount,
    required String note,
  }) {
    return <String, Object?>{
      'p_dispute_id': disputeId,
      'p_action': action,
      'p_fine_amount': fineAmount,
      'p_note': note,
    };
  }
}

final class RpcRepository {
  RpcRepository(this._client);

  final SupabaseClient _client;

  Future<RepositoryResult<String>> createReservation({
    required String id,
    required String stationId,
    required String portId,
    required int startMs,
    required int endMs,
    required String bookingCode,
  }) {
    return _stringRpc(
      'create_reservation',
      RpcPayloads.createReservation(
        id: id,
        stationId: stationId,
        portId: portId,
        startMs: startMs,
        endMs: endMs,
        bookingCode: bookingCode,
      ),
    );
  }

  Future<RepositoryResult<String>> cancelReservation(String reservationId) =>
      _stringRpc(
        'cancel_reservation',
        RpcPayloads.cancelReservation(reservationId),
      );

  Future<RepositoryResult<String>> finalizeChargingSession({
    required String sessionId,
    required String reservationId,
    required double startMeterKwh,
    required double endMeterKwh,
    required bool isSimulated,
    required String meterReadingId,
    required String invoiceId,
  }) {
    return _stringRpc(
      'finalize_charging_session',
      RpcPayloads.finalizeChargingSession(
        sessionId: sessionId,
        reservationId: reservationId,
        startMeterKwh: startMeterKwh,
        endMeterKwh: endMeterKwh,
        isSimulated: isSimulated,
        meterReadingId: meterReadingId,
        invoiceId: invoiceId,
      ),
    );
  }

  Future<RepositoryResult<String>> authorizePayment({
    required String id,
    required String reservationId,
    required String stationId,
    required double amount,
    required String idempotencyKey,
  }) {
    return _stringRpc(
      'authorize_payment',
      RpcPayloads.authorizePayment(
        id: id,
        reservationId: reservationId,
        stationId: stationId,
        amount: amount,
        idempotencyKey: idempotencyKey,
      ),
    );
  }

  Future<RepositoryResult<String>> decideStationApproval({
    required String stationId,
    required bool approve,
  }) {
    return _stringRpc(
      'decide_station_approval',
      RpcPayloads.decideStationApproval(stationId: stationId, approve: approve),
    );
  }

  Future<RepositoryResult<String>> resolveDisputeRefund(String disputeId) =>
      _stringRpc(
        'resolve_dispute_refund',
        RpcPayloads.resolveDisputeRefund(disputeId),
      );

  Future<RepositoryResult<String>> freezeDisputePayout(String disputeId) =>
      _stringRpc(
        'freeze_dispute_payout',
        RpcPayloads.freezeDisputePayout(disputeId),
      );

  Future<RepositoryResult<String>> applyHostEnforcement({
    required String disputeId,
    required String action,
    required double fineAmount,
    required String note,
  }) {
    return _stringRpc(
      'apply_host_enforcement',
      RpcPayloads.applyHostEnforcement(
        disputeId: disputeId,
        action: action,
        fineAmount: fineAmount,
        note: note,
      ),
    );
  }

  Future<RepositoryResult<String>> _stringRpc(
    String name,
    Map<String, Object?> payload,
  ) async {
    try {
      final dynamic result = await _client.rpc<dynamic>(name, params: payload);
      return RepositorySuccess<String>(result?.toString() ?? '');
    } on Object catch (error) {
      return RepositoryFailure<String>.from(error);
    }
  }
}
