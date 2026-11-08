// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  id: json['id'] as String,
  authUserId: json['authUserId'] as String?,
  name: json['name'] as String?,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  role: json['role'] as String?,
  organizationName: json['organizationName'] as String?,
  verificationStatus: json['verificationStatus'] as String?,
  isBlocked: json['isBlocked'] as bool? ?? false,
  serverUpdatedAt: json['serverUpdatedAt'] as String?,
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'id': instance.id,
  'authUserId': instance.authUserId,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'role': instance.role,
  'organizationName': instance.organizationName,
  'verificationStatus': instance.verificationStatus,
  'isBlocked': instance.isBlocked,
  'serverUpdatedAt': instance.serverUpdatedAt,
};

_Vehicle _$VehicleFromJson(Map<String, dynamic> json) => _Vehicle(
  id: json['id'] as String,
  userId: json['userId'] as String?,
  make: json['make'] as String?,
  model: json['model'] as String?,
  variant: json['variant'] as String?,
  purchaseYear: (json['purchaseYear'] as num?)?.toInt() ?? 0,
  batteryCapacityKwh: (json['batteryCapacityKwh'] as num?)?.toDouble() ?? 0,
  connectorType: json['connectorType'] as String?,
  maxAcKw: (json['maxAcKw'] as num?)?.toDouble() ?? 0,
  maxDcKw: (json['maxDcKw'] as num?)?.toDouble() ?? 0,
  typicalEfficiencyKmPerKwh:
      (json['typicalEfficiencyKmPerKwh'] as num?)?.toDouble() ?? 0,
  batteryHealthPercent: (json['batteryHealthPercent'] as num?)?.toDouble() ?? 0,
  efficiencyCorrectionPercent:
      (json['efficiencyCorrectionPercent'] as num?)?.toDouble() ?? 0,
  minArrivalSocPercent: (json['minArrivalSocPercent'] as num?)?.toInt() ?? 0,
  maxChargeSocPercent: (json['maxChargeSocPercent'] as num?)?.toInt() ?? 0,
  licensePlate: json['licensePlate'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  serverUpdatedAt: json['serverUpdatedAt'] as String?,
);

Map<String, dynamic> _$VehicleToJson(_Vehicle instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'make': instance.make,
  'model': instance.model,
  'variant': instance.variant,
  'purchaseYear': instance.purchaseYear,
  'batteryCapacityKwh': instance.batteryCapacityKwh,
  'connectorType': instance.connectorType,
  'maxAcKw': instance.maxAcKw,
  'maxDcKw': instance.maxDcKw,
  'typicalEfficiencyKmPerKwh': instance.typicalEfficiencyKmPerKwh,
  'batteryHealthPercent': instance.batteryHealthPercent,
  'efficiencyCorrectionPercent': instance.efficiencyCorrectionPercent,
  'minArrivalSocPercent': instance.minArrivalSocPercent,
  'maxChargeSocPercent': instance.maxChargeSocPercent,
  'licensePlate': instance.licensePlate,
  'isActive': instance.isActive,
  'serverUpdatedAt': instance.serverUpdatedAt,
};

_ChargerStation _$ChargerStationFromJson(Map<String, dynamic> json) =>
    _ChargerStation(
      id: json['id'] as String,
      hostId: json['hostId'] as String?,
      hostName: json['hostName'] as String?,
      name: json['name'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      locationType: json['locationType'] as String?,
      operatingHours: json['operatingHours'] as String?,
      pricePerKwh: (json['pricePerKwh'] as num?)?.toDouble() ?? 0,
      serviceFee: (json['serviceFee'] as num?)?.toDouble() ?? 0,
      gatewayFee: (json['gatewayFee'] as num?)?.toDouble() ?? 0,
      verificationLevel: json['verificationLevel'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      isPaused: json['isPaused'] as bool? ?? false,
      approvalStatus: json['approvalStatus'] as String?,
      reviewNote: json['reviewNote'] as String?,
      connectorTypes: json['connectorTypes'] as String?,
      maxPowerKw: (json['maxPowerKw'] as num?)?.toDouble() ?? 0,
      isDcCapable: json['isDcCapable'] as bool? ?? false,
      portCount: (json['portCount'] as num?)?.toInt() ?? 0,
      accessRules: json['accessRules'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reliabilityScore: (json['reliabilityScore'] as num?)?.toDouble() ?? 0,
      incidentCount: (json['incidentCount'] as num?)?.toInt() ?? 0,
      lastUpdatedMs: (json['lastUpdatedMs'] as num?)?.toInt() ?? 0,
      serverUpdatedAt: json['serverUpdatedAt'] as String?,
    );

Map<String, dynamic> _$ChargerStationToJson(_ChargerStation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hostId': instance.hostId,
      'hostName': instance.hostName,
      'name': instance.name,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'locationType': instance.locationType,
      'operatingHours': instance.operatingHours,
      'pricePerKwh': instance.pricePerKwh,
      'serviceFee': instance.serviceFee,
      'gatewayFee': instance.gatewayFee,
      'verificationLevel': instance.verificationLevel,
      'isVerified': instance.isVerified,
      'isPaused': instance.isPaused,
      'approvalStatus': instance.approvalStatus,
      'reviewNote': instance.reviewNote,
      'connectorTypes': instance.connectorTypes,
      'maxPowerKw': instance.maxPowerKw,
      'isDcCapable': instance.isDcCapable,
      'portCount': instance.portCount,
      'accessRules': instance.accessRules,
      'rating': instance.rating,
      'reliabilityScore': instance.reliabilityScore,
      'incidentCount': instance.incidentCount,
      'lastUpdatedMs': instance.lastUpdatedMs,
      'serverUpdatedAt': instance.serverUpdatedAt,
    };

_ChargerPort _$ChargerPortFromJson(Map<String, dynamic> json) => _ChargerPort(
  id: json['id'] as String,
  stationId: json['stationId'] as String?,
  portNumber: json['portNumber'] as String?,
  connectorType: json['connectorType'] as String?,
  powerKw: (json['powerKw'] as num?)?.toDouble() ?? 0,
  isDc: json['isDc'] as bool? ?? false,
  status: json['status'] as String?,
  serverUpdatedAt: json['serverUpdatedAt'] as String?,
);

Map<String, dynamic> _$ChargerPortToJson(_ChargerPort instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stationId': instance.stationId,
      'portNumber': instance.portNumber,
      'connectorType': instance.connectorType,
      'powerKw': instance.powerKw,
      'isDc': instance.isDc,
      'status': instance.status,
      'serverUpdatedAt': instance.serverUpdatedAt,
    };

_AvailabilitySchedule _$AvailabilityScheduleFromJson(
  Map<String, dynamic> json,
) => _AvailabilitySchedule(
  id: json['id'] as String,
  stationId: json['stationId'] as String?,
  portId: json['portId'] as String?,
  dayOfWeek: (json['dayOfWeek'] as num?)?.toInt() ?? 0,
  openMinutes: (json['openMinutes'] as num?)?.toInt() ?? 0,
  closeMinutes: (json['closeMinutes'] as num?)?.toInt() ?? 0,
  isBlocked: json['isBlocked'] as bool? ?? false,
  blockReason: json['blockReason'] as String?,
  updatedAtMs: (json['updatedAtMs'] as num?)?.toInt() ?? 0,
  serverUpdatedAt: json['serverUpdatedAt'] as String?,
);

Map<String, dynamic> _$AvailabilityScheduleToJson(
  _AvailabilitySchedule instance,
) => <String, dynamic>{
  'id': instance.id,
  'stationId': instance.stationId,
  'portId': instance.portId,
  'dayOfWeek': instance.dayOfWeek,
  'openMinutes': instance.openMinutes,
  'closeMinutes': instance.closeMinutes,
  'isBlocked': instance.isBlocked,
  'blockReason': instance.blockReason,
  'updatedAtMs': instance.updatedAtMs,
  'serverUpdatedAt': instance.serverUpdatedAt,
};

_AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    _AppNotification(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      title: json['title'] as String?,
      message: json['message'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
      serverUpdatedAt: json['serverUpdatedAt'] as String?,
    );

Map<String, dynamic> _$AppNotificationToJson(_AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'message': instance.message,
      'isRead': instance.isRead,
      'createdAtMs': instance.createdAtMs,
      'serverUpdatedAt': instance.serverUpdatedAt,
    };

_AndroidAutoSession _$AndroidAutoSessionFromJson(Map<String, dynamic> json) =>
    _AndroidAutoSession(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      vehicleId: json['vehicleId'] as String?,
      planId: json['planId'] as String?,
      lastTemplateShown: json['lastTemplateShown'] as String?,
      lastSocUpdatePercent:
          (json['lastSocUpdatePercent'] as num?)?.toInt() ?? 0,
      connectedAtMs: (json['connectedAtMs'] as num?)?.toInt() ?? 0,
      lastSocUpdateAtMs: (json['lastSocUpdateAtMs'] as num?)?.toInt() ?? 0,
      disconnectedAtMs: (json['disconnectedAtMs'] as num?)?.toInt() ?? 0,
      serverUpdatedAt: json['serverUpdatedAt'] as String?,
    );

Map<String, dynamic> _$AndroidAutoSessionToJson(_AndroidAutoSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'vehicleId': instance.vehicleId,
      'planId': instance.planId,
      'lastTemplateShown': instance.lastTemplateShown,
      'lastSocUpdatePercent': instance.lastSocUpdatePercent,
      'connectedAtMs': instance.connectedAtMs,
      'lastSocUpdateAtMs': instance.lastSocUpdateAtMs,
      'disconnectedAtMs': instance.disconnectedAtMs,
      'serverUpdatedAt': instance.serverUpdatedAt,
    };
