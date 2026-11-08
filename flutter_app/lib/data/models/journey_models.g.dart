// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journey_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RoutePlan _$RoutePlanFromJson(Map<String, dynamic> json) => _RoutePlan(
  id: json['id'] as String,
  consumerId: json['consumerId'] as String?,
  vehicleId: json['vehicleId'] as String?,
  origin: json['origin'] as String?,
  destination: json['destination'] as String?,
  originLat: (json['originLat'] as num?)?.toDouble() ?? 0,
  originLng: (json['originLng'] as num?)?.toDouble() ?? 0,
  destinationLat: (json['destinationLat'] as num?)?.toDouble() ?? 0,
  destinationLng: (json['destinationLng'] as num?)?.toDouble() ?? 0,
  corridorKm: (json['corridorKm'] as num?)?.toDouble() ?? 0,
  preference: json['preference'] as String?,
  totalDistanceKm: (json['totalDistanceKm'] as num?)?.toDouble() ?? 0,
  driveMinutes: (json['driveMinutes'] as num?)?.toInt() ?? 0,
  detourMinutes: (json['detourMinutes'] as num?)?.toInt() ?? 0,
  chargingMinutes: (json['chargingMinutes'] as num?)?.toInt() ?? 0,
  totalJourneyMinutes: (json['totalJourneyMinutes'] as num?)?.toInt() ?? 0,
  plannedStartSoc: (json['plannedStartSoc'] as num?)?.toInt() ?? 0,
  arrivalSocTarget: (json['arrivalSocTarget'] as num?)?.toInt() ?? 0,
  isSocAuthoritative: json['isSocAuthoritative'] as bool? ?? false,
  assumptions: json['assumptions'] as String?,
  confidence: json['confidence'] as String?,
  status: json['status'] as String?,
  routeProvider: json['routeProvider'] as String?,
  googlePlaceId: json['googlePlaceId'] as String?,
  createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
  updatedAtMs: (json['updatedAtMs'] as num?)?.toInt() ?? 0,
  serverUpdatedAt: json['serverUpdatedAt'] as String?,
);

Map<String, dynamic> _$RoutePlanToJson(_RoutePlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'consumerId': instance.consumerId,
      'vehicleId': instance.vehicleId,
      'origin': instance.origin,
      'destination': instance.destination,
      'originLat': instance.originLat,
      'originLng': instance.originLng,
      'destinationLat': instance.destinationLat,
      'destinationLng': instance.destinationLng,
      'corridorKm': instance.corridorKm,
      'preference': instance.preference,
      'totalDistanceKm': instance.totalDistanceKm,
      'driveMinutes': instance.driveMinutes,
      'detourMinutes': instance.detourMinutes,
      'chargingMinutes': instance.chargingMinutes,
      'totalJourneyMinutes': instance.totalJourneyMinutes,
      'plannedStartSoc': instance.plannedStartSoc,
      'arrivalSocTarget': instance.arrivalSocTarget,
      'isSocAuthoritative': instance.isSocAuthoritative,
      'assumptions': instance.assumptions,
      'confidence': instance.confidence,
      'status': instance.status,
      'routeProvider': instance.routeProvider,
      'googlePlaceId': instance.googlePlaceId,
      'createdAtMs': instance.createdAtMs,
      'updatedAtMs': instance.updatedAtMs,
      'serverUpdatedAt': instance.serverUpdatedAt,
    };

_RouteStop _$RouteStopFromJson(Map<String, dynamic> json) => _RouteStop(
  id: json['id'] as String,
  planId: json['planId'] as String?,
  sequence: (json['sequence'] as num?)?.toInt() ?? 0,
  stationId: json['stationId'] as String?,
  stationName: json['stationName'] as String?,
  isBackup: json['isBackup'] as bool? ?? false,
  isReachable: json['isReachable'] as bool? ?? false,
  distanceAlongRouteKm: (json['distanceAlongRouteKm'] as num?)?.toDouble() ?? 0,
  detourKm: (json['detourKm'] as num?)?.toDouble() ?? 0,
  detourMinutes: (json['detourMinutes'] as num?)?.toInt() ?? 0,
  arrivalSoc: (json['arrivalSoc'] as num?)?.toInt() ?? 0,
  departureSoc: (json['departureSoc'] as num?)?.toInt() ?? 0,
  energyAddedKwh: (json['energyAddedKwh'] as num?)?.toDouble() ?? 0,
  chargingMinutes: (json['chargingMinutes'] as num?)?.toInt() ?? 0,
  estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 0,
  recommendationReason: json['recommendationReason'] as String?,
  reservationId: json['reservationId'] as String?,
  serverUpdatedAt: json['serverUpdatedAt'] as String?,
);

Map<String, dynamic> _$RouteStopToJson(_RouteStop instance) =>
    <String, dynamic>{
      'id': instance.id,
      'planId': instance.planId,
      'sequence': instance.sequence,
      'stationId': instance.stationId,
      'stationName': instance.stationName,
      'isBackup': instance.isBackup,
      'isReachable': instance.isReachable,
      'distanceAlongRouteKm': instance.distanceAlongRouteKm,
      'detourKm': instance.detourKm,
      'detourMinutes': instance.detourMinutes,
      'arrivalSoc': instance.arrivalSoc,
      'departureSoc': instance.departureSoc,
      'energyAddedKwh': instance.energyAddedKwh,
      'chargingMinutes': instance.chargingMinutes,
      'estimatedCost': instance.estimatedCost,
      'recommendationReason': instance.recommendationReason,
      'reservationId': instance.reservationId,
      'serverUpdatedAt': instance.serverUpdatedAt,
    };

_TripEstimate _$TripEstimateFromJson(Map<String, dynamic> json) =>
    _TripEstimate(
      id: json['id'] as String,
      planId: json['planId'] as String?,
      vehicleId: json['vehicleId'] as String?,
      segmentDistanceKm: (json['segmentDistanceKm'] as num?)?.toDouble() ?? 0,
      estimatedDrainKwh: (json['estimatedDrainKwh'] as num?)?.toDouble() ?? 0,
      actualDrainKwh: (json['actualDrainKwh'] as num?)?.toDouble() ?? 0,
      estimatedArrivalSoc: (json['estimatedArrivalSoc'] as num?)?.toInt() ?? 0,
      actualArrivalSoc: (json['actualArrivalSoc'] as num?)?.toInt() ?? 0,
      confidence: json['confidence'] as String?,
      notes: json['notes'] as String?,
      createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
      serverUpdatedAt: json['serverUpdatedAt'] as String?,
    );

Map<String, dynamic> _$TripEstimateToJson(_TripEstimate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'planId': instance.planId,
      'vehicleId': instance.vehicleId,
      'segmentDistanceKm': instance.segmentDistanceKm,
      'estimatedDrainKwh': instance.estimatedDrainKwh,
      'actualDrainKwh': instance.actualDrainKwh,
      'estimatedArrivalSoc': instance.estimatedArrivalSoc,
      'actualArrivalSoc': instance.actualArrivalSoc,
      'confidence': instance.confidence,
      'notes': instance.notes,
      'createdAtMs': instance.createdAtMs,
      'serverUpdatedAt': instance.serverUpdatedAt,
    };

_BatteryUpdate _$BatteryUpdateFromJson(Map<String, dynamic> json) =>
    _BatteryUpdate(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String?,
      tripPlanId: json['tripPlanId'] as String?,
      estimatedSoc: (json['estimatedSoc'] as num?)?.toInt() ?? 0,
      actualDashboardSoc: (json['actualDashboardSoc'] as num?)?.toInt() ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      timestampMs: (json['timestampMs'] as num?)?.toInt() ?? 0,
      serverUpdatedAt: json['serverUpdatedAt'] as String?,
    );

Map<String, dynamic> _$BatteryUpdateToJson(_BatteryUpdate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vehicleId': instance.vehicleId,
      'tripPlanId': instance.tripPlanId,
      'estimatedSoc': instance.estimatedSoc,
      'actualDashboardSoc': instance.actualDashboardSoc,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'timestampMs': instance.timestampMs,
      'serverUpdatedAt': instance.serverUpdatedAt,
    };

_CommunicationThread _$CommunicationThreadFromJson(Map<String, dynamic> json) =>
    _CommunicationThread(
      id: json['id'] as String,
      reservationId: json['reservationId'] as String?,
      consumerId: json['consumerId'] as String?,
      consumerName: json['consumerName'] as String?,
      hostId: json['hostId'] as String?,
      hostName: json['hostName'] as String?,
      maskedConsumerNumber: json['maskedConsumerNumber'] as String?,
      maskedHostNumber: json['maskedHostNumber'] as String?,
      isReported: json['isReported'] as bool? ?? false,
      isBlocked: json['isBlocked'] as bool? ?? false,
      isChatEnabled: json['isChatEnabled'] as bool? ?? true,
      createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
      expiresAtMs: (json['expiresAtMs'] as num?)?.toInt() ?? 0,
      serverUpdatedAt: json['serverUpdatedAt'] as String?,
    );

Map<String, dynamic> _$CommunicationThreadToJson(
  _CommunicationThread instance,
) => <String, dynamic>{
  'id': instance.id,
  'reservationId': instance.reservationId,
  'consumerId': instance.consumerId,
  'consumerName': instance.consumerName,
  'hostId': instance.hostId,
  'hostName': instance.hostName,
  'maskedConsumerNumber': instance.maskedConsumerNumber,
  'maskedHostNumber': instance.maskedHostNumber,
  'isReported': instance.isReported,
  'isBlocked': instance.isBlocked,
  'isChatEnabled': instance.isChatEnabled,
  'createdAtMs': instance.createdAtMs,
  'expiresAtMs': instance.expiresAtMs,
  'serverUpdatedAt': instance.serverUpdatedAt,
};

_ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => _ChatMessage(
  id: json['id'] as String,
  threadId: json['threadId'] as String?,
  reservationId: json['reservationId'] as String?,
  senderId: json['senderId'] as String?,
  receiverId: json['receiverId'] as String?,
  messageText: json['messageText'] as String?,
  createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
  isRead: json['isRead'] as bool? ?? false,
  isReported: json['isReported'] as bool? ?? false,
  expiresAtMs: (json['expiresAtMs'] as num?)?.toInt() ?? 0,
  serverUpdatedAt: json['serverUpdatedAt'] as String?,
);

Map<String, dynamic> _$ChatMessageToJson(_ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'threadId': instance.threadId,
      'reservationId': instance.reservationId,
      'senderId': instance.senderId,
      'receiverId': instance.receiverId,
      'messageText': instance.messageText,
      'createdAtMs': instance.createdAtMs,
      'isRead': instance.isRead,
      'isReported': instance.isReported,
      'expiresAtMs': instance.expiresAtMs,
      'serverUpdatedAt': instance.serverUpdatedAt,
    };

_SafetyEvent _$SafetyEventFromJson(Map<String, dynamic> json) => _SafetyEvent(
  id: json['id'] as String,
  consumerId: json['consumerId'] as String?,
  stationId: json['stationId'] as String?,
  emergencyType: json['emergencyType'] as String?,
  isLiveLocationSharingActive:
      json['isLiveLocationSharingActive'] as bool? ?? false,
  trustedContactPhone: json['trustedContactPhone'] as String?,
  expiresAtMs: (json['expiresAtMs'] as num?)?.toInt() ?? 0,
  createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
  serverUpdatedAt: json['serverUpdatedAt'] as String?,
);

Map<String, dynamic> _$SafetyEventToJson(_SafetyEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'consumerId': instance.consumerId,
      'stationId': instance.stationId,
      'emergencyType': instance.emergencyType,
      'isLiveLocationSharingActive': instance.isLiveLocationSharingActive,
      'trustedContactPhone': instance.trustedContactPhone,
      'expiresAtMs': instance.expiresAtMs,
      'createdAtMs': instance.createdAtMs,
      'serverUpdatedAt': instance.serverUpdatedAt,
    };

_TrustedContact _$TrustedContactFromJson(Map<String, dynamic> json) =>
    _TrustedContact(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      serverUpdatedAt: json['serverUpdatedAt'] as String?,
    );

Map<String, dynamic> _$TrustedContactToJson(_TrustedContact instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'phone': instance.phone,
      'serverUpdatedAt': instance.serverUpdatedAt,
    };
