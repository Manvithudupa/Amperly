import 'package:freezed_annotation/freezed_annotation.dart';

part 'journey_models.freezed.dart';
part 'journey_models.g.dart';

@freezed
abstract class RoutePlan with _$RoutePlan {
  const factory RoutePlan({
    required String id,
    String? consumerId,
    String? vehicleId,
    String? origin,
    String? destination,
    @Default(0) double originLat,
    @Default(0) double originLng,
    @Default(0) double destinationLat,
    @Default(0) double destinationLng,
    @Default(0) double corridorKm,
    String? preference,
    @Default(0) double totalDistanceKm,
    @Default(0) int driveMinutes,
    @Default(0) int detourMinutes,
    @Default(0) int chargingMinutes,
    @Default(0) int totalJourneyMinutes,
    @Default(0) int plannedStartSoc,
    @Default(0) int arrivalSocTarget,
    @Default(false) bool isSocAuthoritative,
    String? assumptions,
    String? confidence,
    String? status,
    String? routeProvider,
    String? googlePlaceId,
    @Default(0) int createdAtMs,
    @Default(0) int updatedAtMs,
    String? serverUpdatedAt,
  }) = _RoutePlan;

  factory RoutePlan.fromJson(Map<String, dynamic> json) =>
      _$RoutePlanFromJson(json);
}

@freezed
abstract class RouteStop with _$RouteStop {
  const factory RouteStop({
    required String id,
    String? planId,
    @Default(0) int sequence,
    String? stationId,
    String? stationName,
    @Default(false) bool isBackup,
    @Default(false) bool isReachable,
    @Default(0) double distanceAlongRouteKm,
    @Default(0) double detourKm,
    @Default(0) int detourMinutes,
    @Default(0) int arrivalSoc,
    @Default(0) int departureSoc,
    @Default(0) double energyAddedKwh,
    @Default(0) int chargingMinutes,
    @Default(0) double estimatedCost,
    String? recommendationReason,
    String? reservationId,
    String? serverUpdatedAt,
  }) = _RouteStop;

  factory RouteStop.fromJson(Map<String, dynamic> json) =>
      _$RouteStopFromJson(json);
}

@freezed
abstract class TripEstimate with _$TripEstimate {
  const factory TripEstimate({
    required String id,
    String? planId,
    String? vehicleId,
    @Default(0) double segmentDistanceKm,
    @Default(0) double estimatedDrainKwh,
    @Default(0) double actualDrainKwh,
    @Default(0) int estimatedArrivalSoc,
    @Default(0) int actualArrivalSoc,
    String? confidence,
    String? notes,
    @Default(0) int createdAtMs,
    String? serverUpdatedAt,
  }) = _TripEstimate;

  factory TripEstimate.fromJson(Map<String, dynamic> json) =>
      _$TripEstimateFromJson(json);
}

@freezed
abstract class BatteryUpdate with _$BatteryUpdate {
  const factory BatteryUpdate({
    required String id,
    String? vehicleId,
    String? tripPlanId,
    @Default(0) int estimatedSoc,
    @Default(0) int actualDashboardSoc,
    @Default(0) double latitude,
    @Default(0) double longitude,
    @Default(0) int timestampMs,
    String? serverUpdatedAt,
  }) = _BatteryUpdate;

  factory BatteryUpdate.fromJson(Map<String, dynamic> json) =>
      _$BatteryUpdateFromJson(json);
}

@freezed
abstract class CommunicationThread with _$CommunicationThread {
  const factory CommunicationThread({
    required String id,
    String? reservationId,
    String? consumerId,
    String? consumerName,
    String? hostId,
    String? hostName,
    String? maskedConsumerNumber,
    String? maskedHostNumber,
    @Default(false) bool isReported,
    @Default(false) bool isBlocked,
    @Default(true) bool isChatEnabled,
    @Default(0) int createdAtMs,
    @Default(0) int expiresAtMs,
    String? serverUpdatedAt,
  }) = _CommunicationThread;

  factory CommunicationThread.fromJson(Map<String, dynamic> json) =>
      _$CommunicationThreadFromJson(json);
}

extension CommunicationThreadRules on CommunicationThread {
  bool isExpired(int nowMs) => expiresAtMs > 0 && nowMs > expiresAtMs;
}

@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    String? threadId,
    String? reservationId,
    String? senderId,
    String? receiverId,
    String? messageText,
    @Default(0) int createdAtMs,
    @Default(false) bool isRead,
    @Default(false) bool isReported,
    @Default(0) int expiresAtMs,
    String? serverUpdatedAt,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

@freezed
abstract class SafetyEvent with _$SafetyEvent {
  const factory SafetyEvent({
    required String id,
    String? consumerId,
    String? stationId,
    String? emergencyType,
    @Default(false) bool isLiveLocationSharingActive,
    String? trustedContactPhone,
    @Default(0) int expiresAtMs,
    @Default(0) int createdAtMs,
    String? serverUpdatedAt,
  }) = _SafetyEvent;

  factory SafetyEvent.fromJson(Map<String, dynamic> json) =>
      _$SafetyEventFromJson(json);
}

@freezed
abstract class TrustedContact with _$TrustedContact {
  const factory TrustedContact({
    required String id,
    String? userId,
    String? name,
    String? phone,
    String? serverUpdatedAt,
  }) = _TrustedContact;

  factory TrustedContact.fromJson(Map<String, dynamic> json) =>
      _$TrustedContactFromJson(json);
}
