import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/policy.dart';

part 'booking_models.freezed.dart';
part 'booking_models.g.dart';

@freezed
abstract class Reservation with _$Reservation {
  const factory Reservation({
    required String id,
    String? consumerId,
    String? stationId,
    String? stationName,
    String? portId,
    String? portLabel,
    String? bookingCode,
    @Default(0) int startTimeMs,
    @Default(0) int endTimeMs,
    String? status,
    @Default(0) double pricePerKwh,
    @Default(0) double serviceFee,
    @Default(0) double gatewayFee,
    @Default(0) double cancellationFee,
    @Default(false) bool isPaid,
    String? paymentId,
    @Default(0) int checkedInAtMs,
    @Default(0) int cancelledAtMs,
    @Default(0) int createdAtMs,
    String? serverUpdatedAt,
  }) = _Reservation;

  factory Reservation.fromJson(Map<String, dynamic> json) =>
      _$ReservationFromJson(json);
}

extension ReservationRules on Reservation {
  bool get isActive =>
      status == AmpPolicy.statusReserved ||
      status == AmpPolicy.statusCheckedIn ||
      status == AmpPolicy.statusCharging;

  bool isInFreeCancellationWindow(int nowMs) {
    return nowMs <= startTimeMs - AmpPolicy.freeCancellationMinutes * 60000;
  }
}

@freezed
abstract class ChargingSession with _$ChargingSession {
  const factory ChargingSession({
    required String id,
    String? reservationId,
    String? consumerId,
    String? hostId,
    String? stationId,
    String? stationName,
    String? portId,
    @Default(0) int startTimeMs,
    @Default(0) int endTimeMs,
    @Default(0) double startingMeterKwh,
    @Default(0) double endingMeterKwh,
    @Default(0) double verifiedKwhConsumed,
    @Default(0) double energyCharge,
    @Default(0) double serviceFee,
    @Default(0) double gatewayFee,
    @Default(0) double totalPaid,
    String? status,
    String? meterReadingId,
    String? invoiceId,
    @Default(false) bool isMeterSimulated,
    String? verificationLevel,
    String? serverUpdatedAt,
  }) = _ChargingSession;

  factory ChargingSession.fromJson(Map<String, dynamic> json) =>
      _$ChargingSessionFromJson(json);
}

@freezed
abstract class MeterReading with _$MeterReading {
  const factory MeterReading({
    required String id,
    String? sessionId,
    String? stationId,
    @Default(0) double startMeterKwh,
    @Default(0) double endMeterKwh,
    String? photoEvidenceUri,
    String? verificationLevel,
    @Default(0) int timestampMs,
    @Default(false) bool isSimulated,
    String? serverUpdatedAt,
  }) = _MeterReading;

  factory MeterReading.fromJson(Map<String, dynamic> json) =>
      _$MeterReadingFromJson(json);
}

@freezed
abstract class Invoice with _$Invoice {
  const factory Invoice({
    required String id,
    String? sessionId,
    String? consumerId,
    String? hostId,
    String? stationName,
    @Default(0) double verifiedKwh,
    @Default(0) double energyCharge,
    @Default(0) double serviceFee,
    @Default(0) double gatewayFee,
    @Default(0) double adjustment,
    String? adjustmentNote,
    @Default(0) double finalTotal,
    String? paymentId,
    String? status,
    @Default(0) int issuedAtMs,
    String? serverUpdatedAt,
  }) = _Invoice;

  factory Invoice.fromJson(Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);
}

extension InvoiceRules on Invoice {
  double get totalBeforeAdjustment => energyCharge + serviceFee + gatewayFee;
}

@freezed
abstract class Payment with _$Payment {
  const factory Payment({
    required String id,
    String? reservationId,
    String? sessionId,
    String? consumerId,
    String? hostId,
    String? idempotencyKey,
    String? gateway,
    String? gatewayReference,
    @Default(0) double authorizedAmount,
    @Default(0) double capturedAmount,
    @Default(0) double refundedAmount,
    @Default(0) double lateCancellationFee,
    String? status,
    String? failureReason,
    @Default(0) int createdAtMs,
    @Default(0) int updatedAtMs,
    String? serverUpdatedAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
}

extension PaymentRules on Payment {
  bool get isSettled =>
      status == AmpPolicy.paymentCaptured ||
      status == AmpPolicy.paymentRefunded;
}

@freezed
abstract class Report with _$Report {
  const factory Report({
    required String id,
    String? reporterId,
    String? reporterName,
    String? targetStationId,
    String? targetHostId,
    String? sessionId,
    String? reportType,
    String? description,
    String? status,
    @Default(0) int createdAtMs,
    String? serverUpdatedAt,
  }) = _Report;

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
}

@freezed
abstract class Dispute with _$Dispute {
  const factory Dispute({
    required String id,
    String? sessionId,
    String? consumerId,
    String? consumerName,
    String? hostId,
    String? stationId,
    String? stationName,
    String? reason,
    String? consumerNotes,
    String? hostNotes,
    String? evidence,
    String? status,
    String? enforcementAction,
    @Default(0) double refundAmount,
    String? resolutionNote,
    @Default(false) bool isPayoutFrozen,
    @Default(0) int createdAtMs,
    @Default(0) int resolvedAtMs,
    String? serverUpdatedAt,
  }) = _Dispute;

  factory Dispute.fromJson(Map<String, dynamic> json) =>
      _$DisputeFromJson(json);
}

extension DisputeRules on Dispute {
  bool get isOpen => status == 'OPEN' || status == 'REVIEWED';
}

@freezed
abstract class HostEnforcement with _$HostEnforcement {
  const factory HostEnforcement({
    required String id,
    String? hostId,
    String? stationId,
    String? actionType,
    String? reason,
    @Default(0) double fineAmount,
    @Default(0) int createdAtMs,
    @Default(0) int expiresAtMs,
    String? serverUpdatedAt,
  }) = _HostEnforcement;

  factory HostEnforcement.fromJson(Map<String, dynamic> json) =>
      _$HostEnforcementFromJson(json);
}
