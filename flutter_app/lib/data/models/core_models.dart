import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/policy.dart';

part 'core_models.freezed.dart';
part 'core_models.g.dart';

@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    String? authUserId,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? organizationName,
    String? verificationStatus,
    @Default(false) bool isBlocked,
    String? serverUpdatedAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}

extension AppUserRules on AppUser {
  bool get isPlatformAdmin => (role ?? '').toUpperCase() == AmpPolicy.roleAdmin;

  bool get canActAsConsumer => !isBlocked;

  bool get canActAsHost => !isBlocked;

  bool get canActAsAdmin => !isBlocked && isPlatformAdmin;
}

@freezed
abstract class Vehicle with _$Vehicle {
  const factory Vehicle({
    required String id,
    String? userId,
    String? make,
    String? model,
    String? variant,
    @Default(0) int purchaseYear,
    @Default(0) double batteryCapacityKwh,
    String? connectorType,
    @Default(0) double maxAcKw,
    @Default(0) double maxDcKw,
    @Default(0) double typicalEfficiencyKmPerKwh,
    @Default(0) double batteryHealthPercent,
    @Default(0) double efficiencyCorrectionPercent,
    @Default(0) int minArrivalSocPercent,
    @Default(0) int maxChargeSocPercent,
    String? licensePlate,
    @Default(true) bool isActive,
    String? serverUpdatedAt,
  }) = _Vehicle;

  factory Vehicle.fromJson(Map<String, dynamic> json) =>
      _$VehicleFromJson(json);
}

extension VehiclePlanning on Vehicle {
  String get displayName {
    final String value = '${make ?? ''} ${model ?? ''}'.trim();
    if (value.isNotEmpty) {
      return value;
    }
    final String plate = (licensePlate ?? '').trim();
    return plate.isEmpty ? 'Vehicle' : plate;
  }

  double get effectiveCapacityKwh {
    final double health = batteryHealthPercent > 0
        ? batteryHealthPercent.clamp(0, 100)
        : 100;
    return (batteryCapacityKwh * (health / 100)).clamp(1, double.infinity);
  }

  double get effectiveEfficiencyKmPerKwh {
    final double base = typicalEfficiencyKmPerKwh > 0
        ? typicalEfficiencyKmPerKwh
        : 6.5;
    final double corrected = base * (1 + (efficiencyCorrectionPercent / 100));
    return corrected.clamp(1, double.infinity);
  }

  static double defaultHealthForYear(int purchaseYear, {int? currentYear}) {
    final int year = currentYear ?? DateTime.now().year;
    final int age = (year - purchaseYear).clamp(0, 100);
    return (100 - age * 2).clamp(70, 100).toDouble();
  }
}

@freezed
abstract class ChargerStation with _$ChargerStation {
  const factory ChargerStation({
    required String id,
    String? hostId,
    String? hostName,
    String? name,
    String? address,
    @Default(0) double latitude,
    @Default(0) double longitude,
    String? locationType,
    String? operatingHours,
    @Default(0) double pricePerKwh,
    @Default(0) double serviceFee,
    @Default(0) double gatewayFee,
    String? verificationLevel,
    @Default(false) bool isVerified,
    @Default(false) bool isPaused,
    String? approvalStatus,
    String? reviewNote,
    String? connectorTypes,
    @Default(0) double maxPowerKw,
    @Default(false) bool isDcCapable,
    @Default(0) int portCount,
    String? accessRules,
    @Default(0) double rating,
    @Default(0) double reliabilityScore,
    @Default(0) int incidentCount,
    @Default(0) int lastUpdatedMs,
    String? serverUpdatedAt,
  }) = _ChargerStation;

  factory ChargerStation.fromJson(Map<String, dynamic> json) =>
      _$ChargerStationFromJson(json);
}

extension ChargerStationRules on ChargerStation {
  List<String> get connectorTypeList {
    final String value = connectorTypes?.trim() ?? '';
    if (value.isEmpty) {
      return const <String>[];
    }
    return value
        .split(RegExp(r'\s*,\s*'))
        .where((String part) => part.isNotEmpty)
        .toList(growable: false);
  }

  bool get supportsPaidEnergyBilling {
    final String level = (verificationLevel ?? '').toUpperCase();
    return level.startsWith('LEVEL_1') || level.startsWith('LEVEL_2');
  }

  bool get isLiveOnMarketplace =>
      (approvalStatus ?? '').toUpperCase() == AmpPolicy.approvalApproved &&
      !isPaused;
}

@freezed
abstract class ChargerPort with _$ChargerPort {
  const factory ChargerPort({
    required String id,
    String? stationId,
    String? portNumber,
    String? connectorType,
    @Default(0) double powerKw,
    @Default(false) bool isDc,
    String? status,
    String? serverUpdatedAt,
  }) = _ChargerPort;

  factory ChargerPort.fromJson(Map<String, dynamic> json) =>
      _$ChargerPortFromJson(json);
}

@freezed
abstract class AvailabilitySchedule with _$AvailabilitySchedule {
  const factory AvailabilitySchedule({
    required String id,
    String? stationId,
    String? portId,
    @Default(0) int dayOfWeek,
    @Default(0) int openMinutes,
    @Default(0) int closeMinutes,
    @Default(false) bool isBlocked,
    String? blockReason,
    @Default(0) int updatedAtMs,
    String? serverUpdatedAt,
  }) = _AvailabilitySchedule;

  factory AvailabilitySchedule.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityScheduleFromJson(json);
}

@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    String? userId,
    String? title,
    String? message,
    @Default(false) bool isRead,
    @Default(0) int createdAtMs,
    String? serverUpdatedAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}

@freezed
abstract class AndroidAutoSession with _$AndroidAutoSession {
  const factory AndroidAutoSession({
    required String id,
    String? userId,
    String? vehicleId,
    String? planId,
    String? lastTemplateShown,
    @Default(0) int lastSocUpdatePercent,
    @Default(0) int connectedAtMs,
    @Default(0) int lastSocUpdateAtMs,
    @Default(0) int disconnectedAtMs,
    String? serverUpdatedAt,
  }) = _AndroidAutoSession;

  factory AndroidAutoSession.fromJson(Map<String, dynamic> json) =>
      _$AndroidAutoSessionFromJson(json);
}
