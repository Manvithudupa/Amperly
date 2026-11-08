// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Reservation _$ReservationFromJson(Map<String, dynamic> json) => _Reservation(
  id: json['id'] as String,
  consumerId: json['consumerId'] as String?,
  stationId: json['stationId'] as String?,
  stationName: json['stationName'] as String?,
  portId: json['portId'] as String?,
  portLabel: json['portLabel'] as String?,
  bookingCode: json['bookingCode'] as String?,
  startTimeMs: (json['startTimeMs'] as num?)?.toInt() ?? 0,
  endTimeMs: (json['endTimeMs'] as num?)?.toInt() ?? 0,
  status: json['status'] as String?,
  pricePerKwh: (json['pricePerKwh'] as num?)?.toDouble() ?? 0,
  serviceFee: (json['serviceFee'] as num?)?.toDouble() ?? 0,
  gatewayFee: (json['gatewayFee'] as num?)?.toDouble() ?? 0,
  cancellationFee: (json['cancellationFee'] as num?)?.toDouble() ?? 0,
  isPaid: json['isPaid'] as bool? ?? false,
  paymentId: json['paymentId'] as String?,
  checkedInAtMs: (json['checkedInAtMs'] as num?)?.toInt() ?? 0,
  cancelledAtMs: (json['cancelledAtMs'] as num?)?.toInt() ?? 0,
  createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
  serverUpdatedAt: json['serverUpdatedAt'] as String?,
);

Map<String, dynamic> _$ReservationToJson(_Reservation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'consumerId': instance.consumerId,
      'stationId': instance.stationId,
      'stationName': instance.stationName,
      'portId': instance.portId,
      'portLabel': instance.portLabel,
      'bookingCode': instance.bookingCode,
      'startTimeMs': instance.startTimeMs,
      'endTimeMs': instance.endTimeMs,
      'status': instance.status,
      'pricePerKwh': instance.pricePerKwh,
      'serviceFee': instance.serviceFee,
      'gatewayFee': instance.gatewayFee,
      'cancellationFee': instance.cancellationFee,
      'isPaid': instance.isPaid,
      'paymentId': instance.paymentId,
      'checkedInAtMs': instance.checkedInAtMs,
      'cancelledAtMs': instance.cancelledAtMs,
      'createdAtMs': instance.createdAtMs,
      'serverUpdatedAt': instance.serverUpdatedAt,
    };

_ChargingSession _$ChargingSessionFromJson(Map<String, dynamic> json) =>
    _ChargingSession(
      id: json['id'] as String,
      reservationId: json['reservationId'] as String?,
      consumerId: json['consumerId'] as String?,
      hostId: json['hostId'] as String?,
      stationId: json['stationId'] as String?,
      stationName: json['stationName'] as String?,
      portId: json['portId'] as String?,
      startTimeMs: (json['startTimeMs'] as num?)?.toInt() ?? 0,
      endTimeMs: (json['endTimeMs'] as num?)?.toInt() ?? 0,
      startingMeterKwh: (json['startingMeterKwh'] as num?)?.toDouble() ?? 0,
      endingMeterKwh: (json['endingMeterKwh'] as num?)?.toDouble() ?? 0,
      verifiedKwhConsumed:
          (json['verifiedKwhConsumed'] as num?)?.toDouble() ?? 0,
      energyCharge: (json['energyCharge'] as num?)?.toDouble() ?? 0,
      serviceFee: (json['serviceFee'] as num?)?.toDouble() ?? 0,
      gatewayFee: (json['gatewayFee'] as num?)?.toDouble() ?? 0,
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String?,
      meterReadingId: json['meterReadingId'] as String?,
      invoiceId: json['invoiceId'] as String?,
      isMeterSimulated: json['isMeterSimulated'] as bool? ?? false,
      verificationLevel: json['verificationLevel'] as String?,
      serverUpdatedAt: json['serverUpdatedAt'] as String?,
    );

Map<String, dynamic> _$ChargingSessionToJson(_ChargingSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reservationId': instance.reservationId,
      'consumerId': instance.consumerId,
      'hostId': instance.hostId,
      'stationId': instance.stationId,
      'stationName': instance.stationName,
      'portId': instance.portId,
      'startTimeMs': instance.startTimeMs,
      'endTimeMs': instance.endTimeMs,
      'startingMeterKwh': instance.startingMeterKwh,
      'endingMeterKwh': instance.endingMeterKwh,
      'verifiedKwhConsumed': instance.verifiedKwhConsumed,
      'energyCharge': instance.energyCharge,
      'serviceFee': instance.serviceFee,
      'gatewayFee': instance.gatewayFee,
      'totalPaid': instance.totalPaid,
      'status': instance.status,
      'meterReadingId': instance.meterReadingId,
      'invoiceId': instance.invoiceId,
      'isMeterSimulated': instance.isMeterSimulated,
      'verificationLevel': instance.verificationLevel,
      'serverUpdatedAt': instance.serverUpdatedAt,
    };

_MeterReading _$MeterReadingFromJson(Map<String, dynamic> json) =>
    _MeterReading(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String?,
      stationId: json['stationId'] as String?,
      startMeterKwh: (json['startMeterKwh'] as num?)?.toDouble() ?? 0,
      endMeterKwh: (json['endMeterKwh'] as num?)?.toDouble() ?? 0,
      photoEvidenceUri: json['photoEvidenceUri'] as String?,
      verificationLevel: json['verificationLevel'] as String?,
      timestampMs: (json['timestampMs'] as num?)?.toInt() ?? 0,
      isSimulated: json['isSimulated'] as bool? ?? false,
      serverUpdatedAt: json['serverUpdatedAt'] as String?,
    );

Map<String, dynamic> _$MeterReadingToJson(_MeterReading instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'stationId': instance.stationId,
      'startMeterKwh': instance.startMeterKwh,
      'endMeterKwh': instance.endMeterKwh,
      'photoEvidenceUri': instance.photoEvidenceUri,
      'verificationLevel': instance.verificationLevel,
      'timestampMs': instance.timestampMs,
      'isSimulated': instance.isSimulated,
      'serverUpdatedAt': instance.serverUpdatedAt,
    };

_Invoice _$InvoiceFromJson(Map<String, dynamic> json) => _Invoice(
  id: json['id'] as String,
  sessionId: json['sessionId'] as String?,
  consumerId: json['consumerId'] as String?,
  hostId: json['hostId'] as String?,
  stationName: json['stationName'] as String?,
  verifiedKwh: (json['verifiedKwh'] as num?)?.toDouble() ?? 0,
  energyCharge: (json['energyCharge'] as num?)?.toDouble() ?? 0,
  serviceFee: (json['serviceFee'] as num?)?.toDouble() ?? 0,
  gatewayFee: (json['gatewayFee'] as num?)?.toDouble() ?? 0,
  adjustment: (json['adjustment'] as num?)?.toDouble() ?? 0,
  adjustmentNote: json['adjustmentNote'] as String?,
  finalTotal: (json['finalTotal'] as num?)?.toDouble() ?? 0,
  paymentId: json['paymentId'] as String?,
  status: json['status'] as String?,
  issuedAtMs: (json['issuedAtMs'] as num?)?.toInt() ?? 0,
  serverUpdatedAt: json['serverUpdatedAt'] as String?,
);

Map<String, dynamic> _$InvoiceToJson(_Invoice instance) => <String, dynamic>{
  'id': instance.id,
  'sessionId': instance.sessionId,
  'consumerId': instance.consumerId,
  'hostId': instance.hostId,
  'stationName': instance.stationName,
  'verifiedKwh': instance.verifiedKwh,
  'energyCharge': instance.energyCharge,
  'serviceFee': instance.serviceFee,
  'gatewayFee': instance.gatewayFee,
  'adjustment': instance.adjustment,
  'adjustmentNote': instance.adjustmentNote,
  'finalTotal': instance.finalTotal,
  'paymentId': instance.paymentId,
  'status': instance.status,
  'issuedAtMs': instance.issuedAtMs,
  'serverUpdatedAt': instance.serverUpdatedAt,
};

_Payment _$PaymentFromJson(Map<String, dynamic> json) => _Payment(
  id: json['id'] as String,
  reservationId: json['reservationId'] as String?,
  sessionId: json['sessionId'] as String?,
  consumerId: json['consumerId'] as String?,
  hostId: json['hostId'] as String?,
  idempotencyKey: json['idempotencyKey'] as String?,
  gateway: json['gateway'] as String?,
  gatewayReference: json['gatewayReference'] as String?,
  authorizedAmount: (json['authorizedAmount'] as num?)?.toDouble() ?? 0,
  capturedAmount: (json['capturedAmount'] as num?)?.toDouble() ?? 0,
  refundedAmount: (json['refundedAmount'] as num?)?.toDouble() ?? 0,
  lateCancellationFee: (json['lateCancellationFee'] as num?)?.toDouble() ?? 0,
  status: json['status'] as String?,
  failureReason: json['failureReason'] as String?,
  createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
  updatedAtMs: (json['updatedAtMs'] as num?)?.toInt() ?? 0,
  serverUpdatedAt: json['serverUpdatedAt'] as String?,
);

Map<String, dynamic> _$PaymentToJson(_Payment instance) => <String, dynamic>{
  'id': instance.id,
  'reservationId': instance.reservationId,
  'sessionId': instance.sessionId,
  'consumerId': instance.consumerId,
  'hostId': instance.hostId,
  'idempotencyKey': instance.idempotencyKey,
  'gateway': instance.gateway,
  'gatewayReference': instance.gatewayReference,
  'authorizedAmount': instance.authorizedAmount,
  'capturedAmount': instance.capturedAmount,
  'refundedAmount': instance.refundedAmount,
  'lateCancellationFee': instance.lateCancellationFee,
  'status': instance.status,
  'failureReason': instance.failureReason,
  'createdAtMs': instance.createdAtMs,
  'updatedAtMs': instance.updatedAtMs,
  'serverUpdatedAt': instance.serverUpdatedAt,
};

_Report _$ReportFromJson(Map<String, dynamic> json) => _Report(
  id: json['id'] as String,
  reporterId: json['reporterId'] as String?,
  reporterName: json['reporterName'] as String?,
  targetStationId: json['targetStationId'] as String?,
  targetHostId: json['targetHostId'] as String?,
  sessionId: json['sessionId'] as String?,
  reportType: json['reportType'] as String?,
  description: json['description'] as String?,
  status: json['status'] as String?,
  createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
  serverUpdatedAt: json['serverUpdatedAt'] as String?,
);

Map<String, dynamic> _$ReportToJson(_Report instance) => <String, dynamic>{
  'id': instance.id,
  'reporterId': instance.reporterId,
  'reporterName': instance.reporterName,
  'targetStationId': instance.targetStationId,
  'targetHostId': instance.targetHostId,
  'sessionId': instance.sessionId,
  'reportType': instance.reportType,
  'description': instance.description,
  'status': instance.status,
  'createdAtMs': instance.createdAtMs,
  'serverUpdatedAt': instance.serverUpdatedAt,
};

_Dispute _$DisputeFromJson(Map<String, dynamic> json) => _Dispute(
  id: json['id'] as String,
  sessionId: json['sessionId'] as String?,
  consumerId: json['consumerId'] as String?,
  consumerName: json['consumerName'] as String?,
  hostId: json['hostId'] as String?,
  stationId: json['stationId'] as String?,
  stationName: json['stationName'] as String?,
  reason: json['reason'] as String?,
  consumerNotes: json['consumerNotes'] as String?,
  hostNotes: json['hostNotes'] as String?,
  evidence: json['evidence'] as String?,
  status: json['status'] as String?,
  enforcementAction: json['enforcementAction'] as String?,
  refundAmount: (json['refundAmount'] as num?)?.toDouble() ?? 0,
  resolutionNote: json['resolutionNote'] as String?,
  isPayoutFrozen: json['isPayoutFrozen'] as bool? ?? false,
  createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
  resolvedAtMs: (json['resolvedAtMs'] as num?)?.toInt() ?? 0,
  serverUpdatedAt: json['serverUpdatedAt'] as String?,
);

Map<String, dynamic> _$DisputeToJson(_Dispute instance) => <String, dynamic>{
  'id': instance.id,
  'sessionId': instance.sessionId,
  'consumerId': instance.consumerId,
  'consumerName': instance.consumerName,
  'hostId': instance.hostId,
  'stationId': instance.stationId,
  'stationName': instance.stationName,
  'reason': instance.reason,
  'consumerNotes': instance.consumerNotes,
  'hostNotes': instance.hostNotes,
  'evidence': instance.evidence,
  'status': instance.status,
  'enforcementAction': instance.enforcementAction,
  'refundAmount': instance.refundAmount,
  'resolutionNote': instance.resolutionNote,
  'isPayoutFrozen': instance.isPayoutFrozen,
  'createdAtMs': instance.createdAtMs,
  'resolvedAtMs': instance.resolvedAtMs,
  'serverUpdatedAt': instance.serverUpdatedAt,
};

_HostEnforcement _$HostEnforcementFromJson(Map<String, dynamic> json) =>
    _HostEnforcement(
      id: json['id'] as String,
      hostId: json['hostId'] as String?,
      stationId: json['stationId'] as String?,
      actionType: json['actionType'] as String?,
      reason: json['reason'] as String?,
      fineAmount: (json['fineAmount'] as num?)?.toDouble() ?? 0,
      createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
      expiresAtMs: (json['expiresAtMs'] as num?)?.toInt() ?? 0,
      serverUpdatedAt: json['serverUpdatedAt'] as String?,
    );

Map<String, dynamic> _$HostEnforcementToJson(_HostEnforcement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hostId': instance.hostId,
      'stationId': instance.stationId,
      'actionType': instance.actionType,
      'reason': instance.reason,
      'fineAmount': instance.fineAmount,
      'createdAtMs': instance.createdAtMs,
      'expiresAtMs': instance.expiresAtMs,
      'serverUpdatedAt': instance.serverUpdatedAt,
    };
