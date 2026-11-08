// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'journey_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RoutePlan {

 String get id; String? get consumerId; String? get vehicleId; String? get origin; String? get destination; double get originLat; double get originLng; double get destinationLat; double get destinationLng; double get corridorKm; String? get preference; double get totalDistanceKm; int get driveMinutes; int get detourMinutes; int get chargingMinutes; int get totalJourneyMinutes; int get plannedStartSoc; int get arrivalSocTarget; bool get isSocAuthoritative; String? get assumptions; String? get confidence; String? get status; String? get routeProvider; String? get googlePlaceId; int get createdAtMs; int get updatedAtMs; String? get serverUpdatedAt;
/// Create a copy of RoutePlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutePlanCopyWith<RoutePlan> get copyWith => _$RoutePlanCopyWithImpl<RoutePlan>(this as RoutePlan, _$identity);

  /// Serializes this RoutePlan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RoutePlan;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutePlan&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.consumerId, _this.consumerId) || other.consumerId == _this.consumerId)&&(identical(other.vehicleId, _this.vehicleId) || other.vehicleId == _this.vehicleId)&&(identical(other.origin, _this.origin) || other.origin == _this.origin)&&(identical(other.destination, _this.destination) || other.destination == _this.destination)&&(identical(other.originLat, _this.originLat) || other.originLat == _this.originLat)&&(identical(other.originLng, _this.originLng) || other.originLng == _this.originLng)&&(identical(other.destinationLat, _this.destinationLat) || other.destinationLat == _this.destinationLat)&&(identical(other.destinationLng, _this.destinationLng) || other.destinationLng == _this.destinationLng)&&(identical(other.corridorKm, _this.corridorKm) || other.corridorKm == _this.corridorKm)&&(identical(other.preference, _this.preference) || other.preference == _this.preference)&&(identical(other.totalDistanceKm, _this.totalDistanceKm) || other.totalDistanceKm == _this.totalDistanceKm)&&(identical(other.driveMinutes, _this.driveMinutes) || other.driveMinutes == _this.driveMinutes)&&(identical(other.detourMinutes, _this.detourMinutes) || other.detourMinutes == _this.detourMinutes)&&(identical(other.chargingMinutes, _this.chargingMinutes) || other.chargingMinutes == _this.chargingMinutes)&&(identical(other.totalJourneyMinutes, _this.totalJourneyMinutes) || other.totalJourneyMinutes == _this.totalJourneyMinutes)&&(identical(other.plannedStartSoc, _this.plannedStartSoc) || other.plannedStartSoc == _this.plannedStartSoc)&&(identical(other.arrivalSocTarget, _this.arrivalSocTarget) || other.arrivalSocTarget == _this.arrivalSocTarget)&&(identical(other.isSocAuthoritative, _this.isSocAuthoritative) || other.isSocAuthoritative == _this.isSocAuthoritative)&&(identical(other.assumptions, _this.assumptions) || other.assumptions == _this.assumptions)&&(identical(other.confidence, _this.confidence) || other.confidence == _this.confidence)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.routeProvider, _this.routeProvider) || other.routeProvider == _this.routeProvider)&&(identical(other.googlePlaceId, _this.googlePlaceId) || other.googlePlaceId == _this.googlePlaceId)&&(identical(other.createdAtMs, _this.createdAtMs) || other.createdAtMs == _this.createdAtMs)&&(identical(other.updatedAtMs, _this.updatedAtMs) || other.updatedAtMs == _this.updatedAtMs)&&(identical(other.serverUpdatedAt, _this.serverUpdatedAt) || other.serverUpdatedAt == _this.serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RoutePlan;
  return Object.hashAll([runtimeType,_this.id,_this.consumerId,_this.vehicleId,_this.origin,_this.destination,_this.originLat,_this.originLng,_this.destinationLat,_this.destinationLng,_this.corridorKm,_this.preference,_this.totalDistanceKm,_this.driveMinutes,_this.detourMinutes,_this.chargingMinutes,_this.totalJourneyMinutes,_this.plannedStartSoc,_this.arrivalSocTarget,_this.isSocAuthoritative,_this.assumptions,_this.confidence,_this.status,_this.routeProvider,_this.googlePlaceId,_this.createdAtMs,_this.updatedAtMs,_this.serverUpdatedAt]);
}

@override
String toString() {
  final _this = this as RoutePlan;
  return 'RoutePlan(id: ${_this.id}, consumerId: ${_this.consumerId}, vehicleId: ${_this.vehicleId}, origin: ${_this.origin}, destination: ${_this.destination}, originLat: ${_this.originLat}, originLng: ${_this.originLng}, destinationLat: ${_this.destinationLat}, destinationLng: ${_this.destinationLng}, corridorKm: ${_this.corridorKm}, preference: ${_this.preference}, totalDistanceKm: ${_this.totalDistanceKm}, driveMinutes: ${_this.driveMinutes}, detourMinutes: ${_this.detourMinutes}, chargingMinutes: ${_this.chargingMinutes}, totalJourneyMinutes: ${_this.totalJourneyMinutes}, plannedStartSoc: ${_this.plannedStartSoc}, arrivalSocTarget: ${_this.arrivalSocTarget}, isSocAuthoritative: ${_this.isSocAuthoritative}, assumptions: ${_this.assumptions}, confidence: ${_this.confidence}, status: ${_this.status}, routeProvider: ${_this.routeProvider}, googlePlaceId: ${_this.googlePlaceId}, createdAtMs: ${_this.createdAtMs}, updatedAtMs: ${_this.updatedAtMs}, serverUpdatedAt: ${_this.serverUpdatedAt})';
}


}

/// @nodoc
abstract mixin class $RoutePlanCopyWith<$Res>  {
  factory $RoutePlanCopyWith(RoutePlan value, $Res Function(RoutePlan) _then) = _$RoutePlanCopyWithImpl;
@useResult
$Res call({
 String id, String? consumerId, String? vehicleId, String? origin, String? destination, double originLat, double originLng, double destinationLat, double destinationLng, double corridorKm, String? preference, double totalDistanceKm, int driveMinutes, int detourMinutes, int chargingMinutes, int totalJourneyMinutes, int plannedStartSoc, int arrivalSocTarget, bool isSocAuthoritative, String? assumptions, String? confidence, String? status, String? routeProvider, String? googlePlaceId, int createdAtMs, int updatedAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class _$RoutePlanCopyWithImpl<$Res>
    implements $RoutePlanCopyWith<$Res> {
  _$RoutePlanCopyWithImpl(this._self, this._then);

  final RoutePlan _self;
  final $Res Function(RoutePlan) _then;

/// Create a copy of RoutePlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? consumerId = freezed,Object? vehicleId = freezed,Object? origin = freezed,Object? destination = freezed,Object? originLat = null,Object? originLng = null,Object? destinationLat = null,Object? destinationLng = null,Object? corridorKm = null,Object? preference = freezed,Object? totalDistanceKm = null,Object? driveMinutes = null,Object? detourMinutes = null,Object? chargingMinutes = null,Object? totalJourneyMinutes = null,Object? plannedStartSoc = null,Object? arrivalSocTarget = null,Object? isSocAuthoritative = null,Object? assumptions = freezed,Object? confidence = freezed,Object? status = freezed,Object? routeProvider = freezed,Object? googlePlaceId = freezed,Object? createdAtMs = null,Object? updatedAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(RoutePlan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,consumerId: freezed == consumerId ? _self.consumerId : consumerId // ignore: cast_nullable_to_non_nullable
as String?,vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as String?,origin: freezed == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String?,originLat: null == originLat ? _self.originLat : originLat // ignore: cast_nullable_to_non_nullable
as double,originLng: null == originLng ? _self.originLng : originLng // ignore: cast_nullable_to_non_nullable
as double,destinationLat: null == destinationLat ? _self.destinationLat : destinationLat // ignore: cast_nullable_to_non_nullable
as double,destinationLng: null == destinationLng ? _self.destinationLng : destinationLng // ignore: cast_nullable_to_non_nullable
as double,corridorKm: null == corridorKm ? _self.corridorKm : corridorKm // ignore: cast_nullable_to_non_nullable
as double,preference: freezed == preference ? _self.preference : preference // ignore: cast_nullable_to_non_nullable
as String?,totalDistanceKm: null == totalDistanceKm ? _self.totalDistanceKm : totalDistanceKm // ignore: cast_nullable_to_non_nullable
as double,driveMinutes: null == driveMinutes ? _self.driveMinutes : driveMinutes // ignore: cast_nullable_to_non_nullable
as int,detourMinutes: null == detourMinutes ? _self.detourMinutes : detourMinutes // ignore: cast_nullable_to_non_nullable
as int,chargingMinutes: null == chargingMinutes ? _self.chargingMinutes : chargingMinutes // ignore: cast_nullable_to_non_nullable
as int,totalJourneyMinutes: null == totalJourneyMinutes ? _self.totalJourneyMinutes : totalJourneyMinutes // ignore: cast_nullable_to_non_nullable
as int,plannedStartSoc: null == plannedStartSoc ? _self.plannedStartSoc : plannedStartSoc // ignore: cast_nullable_to_non_nullable
as int,arrivalSocTarget: null == arrivalSocTarget ? _self.arrivalSocTarget : arrivalSocTarget // ignore: cast_nullable_to_non_nullable
as int,isSocAuthoritative: null == isSocAuthoritative ? _self.isSocAuthoritative : isSocAuthoritative // ignore: cast_nullable_to_non_nullable
as bool,assumptions: freezed == assumptions ? _self.assumptions : assumptions // ignore: cast_nullable_to_non_nullable
as String?,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,routeProvider: freezed == routeProvider ? _self.routeProvider : routeProvider // ignore: cast_nullable_to_non_nullable
as String?,googlePlaceId: freezed == googlePlaceId ? _self.googlePlaceId : googlePlaceId // ignore: cast_nullable_to_non_nullable
as String?,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutePlan].
extension RoutePlanPatterns on RoutePlan {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutePlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutePlan() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutePlan value)  $default,){
final _that = this;
switch (_that) {
case _RoutePlan():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutePlan value)?  $default,){
final _that = this;
switch (_that) {
case _RoutePlan() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? consumerId,  String? vehicleId,  String? origin,  String? destination,  double originLat,  double originLng,  double destinationLat,  double destinationLng,  double corridorKm,  String? preference,  double totalDistanceKm,  int driveMinutes,  int detourMinutes,  int chargingMinutes,  int totalJourneyMinutes,  int plannedStartSoc,  int arrivalSocTarget,  bool isSocAuthoritative,  String? assumptions,  String? confidence,  String? status,  String? routeProvider,  String? googlePlaceId,  int createdAtMs,  int updatedAtMs,  String? serverUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutePlan() when $default != null:
return $default(_that.id,_that.consumerId,_that.vehicleId,_that.origin,_that.destination,_that.originLat,_that.originLng,_that.destinationLat,_that.destinationLng,_that.corridorKm,_that.preference,_that.totalDistanceKm,_that.driveMinutes,_that.detourMinutes,_that.chargingMinutes,_that.totalJourneyMinutes,_that.plannedStartSoc,_that.arrivalSocTarget,_that.isSocAuthoritative,_that.assumptions,_that.confidence,_that.status,_that.routeProvider,_that.googlePlaceId,_that.createdAtMs,_that.updatedAtMs,_that.serverUpdatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? consumerId,  String? vehicleId,  String? origin,  String? destination,  double originLat,  double originLng,  double destinationLat,  double destinationLng,  double corridorKm,  String? preference,  double totalDistanceKm,  int driveMinutes,  int detourMinutes,  int chargingMinutes,  int totalJourneyMinutes,  int plannedStartSoc,  int arrivalSocTarget,  bool isSocAuthoritative,  String? assumptions,  String? confidence,  String? status,  String? routeProvider,  String? googlePlaceId,  int createdAtMs,  int updatedAtMs,  String? serverUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _RoutePlan():
return $default(_that.id,_that.consumerId,_that.vehicleId,_that.origin,_that.destination,_that.originLat,_that.originLng,_that.destinationLat,_that.destinationLng,_that.corridorKm,_that.preference,_that.totalDistanceKm,_that.driveMinutes,_that.detourMinutes,_that.chargingMinutes,_that.totalJourneyMinutes,_that.plannedStartSoc,_that.arrivalSocTarget,_that.isSocAuthoritative,_that.assumptions,_that.confidence,_that.status,_that.routeProvider,_that.googlePlaceId,_that.createdAtMs,_that.updatedAtMs,_that.serverUpdatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? consumerId,  String? vehicleId,  String? origin,  String? destination,  double originLat,  double originLng,  double destinationLat,  double destinationLng,  double corridorKm,  String? preference,  double totalDistanceKm,  int driveMinutes,  int detourMinutes,  int chargingMinutes,  int totalJourneyMinutes,  int plannedStartSoc,  int arrivalSocTarget,  bool isSocAuthoritative,  String? assumptions,  String? confidence,  String? status,  String? routeProvider,  String? googlePlaceId,  int createdAtMs,  int updatedAtMs,  String? serverUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _RoutePlan() when $default != null:
return $default(_that.id,_that.consumerId,_that.vehicleId,_that.origin,_that.destination,_that.originLat,_that.originLng,_that.destinationLat,_that.destinationLng,_that.corridorKm,_that.preference,_that.totalDistanceKm,_that.driveMinutes,_that.detourMinutes,_that.chargingMinutes,_that.totalJourneyMinutes,_that.plannedStartSoc,_that.arrivalSocTarget,_that.isSocAuthoritative,_that.assumptions,_that.confidence,_that.status,_that.routeProvider,_that.googlePlaceId,_that.createdAtMs,_that.updatedAtMs,_that.serverUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoutePlan implements RoutePlan {
  const _RoutePlan({required this.id, this.consumerId, this.vehicleId, this.origin, this.destination, this.originLat = 0, this.originLng = 0, this.destinationLat = 0, this.destinationLng = 0, this.corridorKm = 0, this.preference, this.totalDistanceKm = 0, this.driveMinutes = 0, this.detourMinutes = 0, this.chargingMinutes = 0, this.totalJourneyMinutes = 0, this.plannedStartSoc = 0, this.arrivalSocTarget = 0, this.isSocAuthoritative = false, this.assumptions, this.confidence, this.status, this.routeProvider, this.googlePlaceId, this.createdAtMs = 0, this.updatedAtMs = 0, this.serverUpdatedAt});
  factory _RoutePlan.fromJson(Map<String, dynamic> json) => _$RoutePlanFromJson(json);

@override final  String id;
@override final  String? consumerId;
@override final  String? vehicleId;
@override final  String? origin;
@override final  String? destination;
@override@JsonKey() final  double originLat;
@override@JsonKey() final  double originLng;
@override@JsonKey() final  double destinationLat;
@override@JsonKey() final  double destinationLng;
@override@JsonKey() final  double corridorKm;
@override final  String? preference;
@override@JsonKey() final  double totalDistanceKm;
@override@JsonKey() final  int driveMinutes;
@override@JsonKey() final  int detourMinutes;
@override@JsonKey() final  int chargingMinutes;
@override@JsonKey() final  int totalJourneyMinutes;
@override@JsonKey() final  int plannedStartSoc;
@override@JsonKey() final  int arrivalSocTarget;
@override@JsonKey() final  bool isSocAuthoritative;
@override final  String? assumptions;
@override final  String? confidence;
@override final  String? status;
@override final  String? routeProvider;
@override final  String? googlePlaceId;
@override@JsonKey() final  int createdAtMs;
@override@JsonKey() final  int updatedAtMs;
@override final  String? serverUpdatedAt;

/// Create a copy of RoutePlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutePlanCopyWith<_RoutePlan> get copyWith => __$RoutePlanCopyWithImpl<_RoutePlan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoutePlanToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutePlan&&(identical(other.id, id) || other.id == id)&&(identical(other.consumerId, consumerId) || other.consumerId == consumerId)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.originLat, originLat) || other.originLat == originLat)&&(identical(other.originLng, originLng) || other.originLng == originLng)&&(identical(other.destinationLat, destinationLat) || other.destinationLat == destinationLat)&&(identical(other.destinationLng, destinationLng) || other.destinationLng == destinationLng)&&(identical(other.corridorKm, corridorKm) || other.corridorKm == corridorKm)&&(identical(other.preference, preference) || other.preference == preference)&&(identical(other.totalDistanceKm, totalDistanceKm) || other.totalDistanceKm == totalDistanceKm)&&(identical(other.driveMinutes, driveMinutes) || other.driveMinutes == driveMinutes)&&(identical(other.detourMinutes, detourMinutes) || other.detourMinutes == detourMinutes)&&(identical(other.chargingMinutes, chargingMinutes) || other.chargingMinutes == chargingMinutes)&&(identical(other.totalJourneyMinutes, totalJourneyMinutes) || other.totalJourneyMinutes == totalJourneyMinutes)&&(identical(other.plannedStartSoc, plannedStartSoc) || other.plannedStartSoc == plannedStartSoc)&&(identical(other.arrivalSocTarget, arrivalSocTarget) || other.arrivalSocTarget == arrivalSocTarget)&&(identical(other.isSocAuthoritative, isSocAuthoritative) || other.isSocAuthoritative == isSocAuthoritative)&&(identical(other.assumptions, assumptions) || other.assumptions == assumptions)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.status, status) || other.status == status)&&(identical(other.routeProvider, routeProvider) || other.routeProvider == routeProvider)&&(identical(other.googlePlaceId, googlePlaceId) || other.googlePlaceId == googlePlaceId)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs)&&(identical(other.serverUpdatedAt, serverUpdatedAt) || other.serverUpdatedAt == serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,consumerId,vehicleId,origin,destination,originLat,originLng,destinationLat,destinationLng,corridorKm,preference,totalDistanceKm,driveMinutes,detourMinutes,chargingMinutes,totalJourneyMinutes,plannedStartSoc,arrivalSocTarget,isSocAuthoritative,assumptions,confidence,status,routeProvider,googlePlaceId,createdAtMs,updatedAtMs,serverUpdatedAt]);
}

@override
String toString() {
    return 'RoutePlan(id: $id, consumerId: $consumerId, vehicleId: $vehicleId, origin: $origin, destination: $destination, originLat: $originLat, originLng: $originLng, destinationLat: $destinationLat, destinationLng: $destinationLng, corridorKm: $corridorKm, preference: $preference, totalDistanceKm: $totalDistanceKm, driveMinutes: $driveMinutes, detourMinutes: $detourMinutes, chargingMinutes: $chargingMinutes, totalJourneyMinutes: $totalJourneyMinutes, plannedStartSoc: $plannedStartSoc, arrivalSocTarget: $arrivalSocTarget, isSocAuthoritative: $isSocAuthoritative, assumptions: $assumptions, confidence: $confidence, status: $status, routeProvider: $routeProvider, googlePlaceId: $googlePlaceId, createdAtMs: $createdAtMs, updatedAtMs: $updatedAtMs, serverUpdatedAt: $serverUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$RoutePlanCopyWith<$Res> implements $RoutePlanCopyWith<$Res> {
  factory _$RoutePlanCopyWith(_RoutePlan value, $Res Function(_RoutePlan) _then) = __$RoutePlanCopyWithImpl;
@override @useResult
$Res call({
 String id, String? consumerId, String? vehicleId, String? origin, String? destination, double originLat, double originLng, double destinationLat, double destinationLng, double corridorKm, String? preference, double totalDistanceKm, int driveMinutes, int detourMinutes, int chargingMinutes, int totalJourneyMinutes, int plannedStartSoc, int arrivalSocTarget, bool isSocAuthoritative, String? assumptions, String? confidence, String? status, String? routeProvider, String? googlePlaceId, int createdAtMs, int updatedAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class __$RoutePlanCopyWithImpl<$Res>
    implements _$RoutePlanCopyWith<$Res> {
  __$RoutePlanCopyWithImpl(this._self, this._then);

  final _RoutePlan _self;
  final $Res Function(_RoutePlan) _then;

/// Create a copy of RoutePlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? consumerId = freezed,Object? vehicleId = freezed,Object? origin = freezed,Object? destination = freezed,Object? originLat = null,Object? originLng = null,Object? destinationLat = null,Object? destinationLng = null,Object? corridorKm = null,Object? preference = freezed,Object? totalDistanceKm = null,Object? driveMinutes = null,Object? detourMinutes = null,Object? chargingMinutes = null,Object? totalJourneyMinutes = null,Object? plannedStartSoc = null,Object? arrivalSocTarget = null,Object? isSocAuthoritative = null,Object? assumptions = freezed,Object? confidence = freezed,Object? status = freezed,Object? routeProvider = freezed,Object? googlePlaceId = freezed,Object? createdAtMs = null,Object? updatedAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(_RoutePlan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,consumerId: freezed == consumerId ? _self.consumerId : consumerId // ignore: cast_nullable_to_non_nullable
as String?,vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as String?,origin: freezed == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String?,originLat: null == originLat ? _self.originLat : originLat // ignore: cast_nullable_to_non_nullable
as double,originLng: null == originLng ? _self.originLng : originLng // ignore: cast_nullable_to_non_nullable
as double,destinationLat: null == destinationLat ? _self.destinationLat : destinationLat // ignore: cast_nullable_to_non_nullable
as double,destinationLng: null == destinationLng ? _self.destinationLng : destinationLng // ignore: cast_nullable_to_non_nullable
as double,corridorKm: null == corridorKm ? _self.corridorKm : corridorKm // ignore: cast_nullable_to_non_nullable
as double,preference: freezed == preference ? _self.preference : preference // ignore: cast_nullable_to_non_nullable
as String?,totalDistanceKm: null == totalDistanceKm ? _self.totalDistanceKm : totalDistanceKm // ignore: cast_nullable_to_non_nullable
as double,driveMinutes: null == driveMinutes ? _self.driveMinutes : driveMinutes // ignore: cast_nullable_to_non_nullable
as int,detourMinutes: null == detourMinutes ? _self.detourMinutes : detourMinutes // ignore: cast_nullable_to_non_nullable
as int,chargingMinutes: null == chargingMinutes ? _self.chargingMinutes : chargingMinutes // ignore: cast_nullable_to_non_nullable
as int,totalJourneyMinutes: null == totalJourneyMinutes ? _self.totalJourneyMinutes : totalJourneyMinutes // ignore: cast_nullable_to_non_nullable
as int,plannedStartSoc: null == plannedStartSoc ? _self.plannedStartSoc : plannedStartSoc // ignore: cast_nullable_to_non_nullable
as int,arrivalSocTarget: null == arrivalSocTarget ? _self.arrivalSocTarget : arrivalSocTarget // ignore: cast_nullable_to_non_nullable
as int,isSocAuthoritative: null == isSocAuthoritative ? _self.isSocAuthoritative : isSocAuthoritative // ignore: cast_nullable_to_non_nullable
as bool,assumptions: freezed == assumptions ? _self.assumptions : assumptions // ignore: cast_nullable_to_non_nullable
as String?,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,routeProvider: freezed == routeProvider ? _self.routeProvider : routeProvider // ignore: cast_nullable_to_non_nullable
as String?,googlePlaceId: freezed == googlePlaceId ? _self.googlePlaceId : googlePlaceId // ignore: cast_nullable_to_non_nullable
as String?,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RouteStop {

 String get id; String? get planId; int get sequence; String? get stationId; String? get stationName; bool get isBackup; bool get isReachable; double get distanceAlongRouteKm; double get detourKm; int get detourMinutes; int get arrivalSoc; int get departureSoc; double get energyAddedKwh; int get chargingMinutes; double get estimatedCost; String? get recommendationReason; String? get reservationId; String? get serverUpdatedAt;
/// Create a copy of RouteStop
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteStopCopyWith<RouteStop> get copyWith => _$RouteStopCopyWithImpl<RouteStop>(this as RouteStop, _$identity);

  /// Serializes this RouteStop to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RouteStop;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteStop&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.planId, _this.planId) || other.planId == _this.planId)&&(identical(other.sequence, _this.sequence) || other.sequence == _this.sequence)&&(identical(other.stationId, _this.stationId) || other.stationId == _this.stationId)&&(identical(other.stationName, _this.stationName) || other.stationName == _this.stationName)&&(identical(other.isBackup, _this.isBackup) || other.isBackup == _this.isBackup)&&(identical(other.isReachable, _this.isReachable) || other.isReachable == _this.isReachable)&&(identical(other.distanceAlongRouteKm, _this.distanceAlongRouteKm) || other.distanceAlongRouteKm == _this.distanceAlongRouteKm)&&(identical(other.detourKm, _this.detourKm) || other.detourKm == _this.detourKm)&&(identical(other.detourMinutes, _this.detourMinutes) || other.detourMinutes == _this.detourMinutes)&&(identical(other.arrivalSoc, _this.arrivalSoc) || other.arrivalSoc == _this.arrivalSoc)&&(identical(other.departureSoc, _this.departureSoc) || other.departureSoc == _this.departureSoc)&&(identical(other.energyAddedKwh, _this.energyAddedKwh) || other.energyAddedKwh == _this.energyAddedKwh)&&(identical(other.chargingMinutes, _this.chargingMinutes) || other.chargingMinutes == _this.chargingMinutes)&&(identical(other.estimatedCost, _this.estimatedCost) || other.estimatedCost == _this.estimatedCost)&&(identical(other.recommendationReason, _this.recommendationReason) || other.recommendationReason == _this.recommendationReason)&&(identical(other.reservationId, _this.reservationId) || other.reservationId == _this.reservationId)&&(identical(other.serverUpdatedAt, _this.serverUpdatedAt) || other.serverUpdatedAt == _this.serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RouteStop;
  return Object.hash(runtimeType,_this.id,_this.planId,_this.sequence,_this.stationId,_this.stationName,_this.isBackup,_this.isReachable,_this.distanceAlongRouteKm,_this.detourKm,_this.detourMinutes,_this.arrivalSoc,_this.departureSoc,_this.energyAddedKwh,_this.chargingMinutes,_this.estimatedCost,_this.recommendationReason,_this.reservationId,_this.serverUpdatedAt);
}

@override
String toString() {
  final _this = this as RouteStop;
  return 'RouteStop(id: ${_this.id}, planId: ${_this.planId}, sequence: ${_this.sequence}, stationId: ${_this.stationId}, stationName: ${_this.stationName}, isBackup: ${_this.isBackup}, isReachable: ${_this.isReachable}, distanceAlongRouteKm: ${_this.distanceAlongRouteKm}, detourKm: ${_this.detourKm}, detourMinutes: ${_this.detourMinutes}, arrivalSoc: ${_this.arrivalSoc}, departureSoc: ${_this.departureSoc}, energyAddedKwh: ${_this.energyAddedKwh}, chargingMinutes: ${_this.chargingMinutes}, estimatedCost: ${_this.estimatedCost}, recommendationReason: ${_this.recommendationReason}, reservationId: ${_this.reservationId}, serverUpdatedAt: ${_this.serverUpdatedAt})';
}


}

/// @nodoc
abstract mixin class $RouteStopCopyWith<$Res>  {
  factory $RouteStopCopyWith(RouteStop value, $Res Function(RouteStop) _then) = _$RouteStopCopyWithImpl;
@useResult
$Res call({
 String id, String? planId, int sequence, String? stationId, String? stationName, bool isBackup, bool isReachable, double distanceAlongRouteKm, double detourKm, int detourMinutes, int arrivalSoc, int departureSoc, double energyAddedKwh, int chargingMinutes, double estimatedCost, String? recommendationReason, String? reservationId, String? serverUpdatedAt
});




}
/// @nodoc
class _$RouteStopCopyWithImpl<$Res>
    implements $RouteStopCopyWith<$Res> {
  _$RouteStopCopyWithImpl(this._self, this._then);

  final RouteStop _self;
  final $Res Function(RouteStop) _then;

/// Create a copy of RouteStop
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? planId = freezed,Object? sequence = null,Object? stationId = freezed,Object? stationName = freezed,Object? isBackup = null,Object? isReachable = null,Object? distanceAlongRouteKm = null,Object? detourKm = null,Object? detourMinutes = null,Object? arrivalSoc = null,Object? departureSoc = null,Object? energyAddedKwh = null,Object? chargingMinutes = null,Object? estimatedCost = null,Object? recommendationReason = freezed,Object? reservationId = freezed,Object? serverUpdatedAt = freezed,}) {
  return _then(RouteStop(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,planId: freezed == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String?,sequence: null == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int,stationId: freezed == stationId ? _self.stationId : stationId // ignore: cast_nullable_to_non_nullable
as String?,stationName: freezed == stationName ? _self.stationName : stationName // ignore: cast_nullable_to_non_nullable
as String?,isBackup: null == isBackup ? _self.isBackup : isBackup // ignore: cast_nullable_to_non_nullable
as bool,isReachable: null == isReachable ? _self.isReachable : isReachable // ignore: cast_nullable_to_non_nullable
as bool,distanceAlongRouteKm: null == distanceAlongRouteKm ? _self.distanceAlongRouteKm : distanceAlongRouteKm // ignore: cast_nullable_to_non_nullable
as double,detourKm: null == detourKm ? _self.detourKm : detourKm // ignore: cast_nullable_to_non_nullable
as double,detourMinutes: null == detourMinutes ? _self.detourMinutes : detourMinutes // ignore: cast_nullable_to_non_nullable
as int,arrivalSoc: null == arrivalSoc ? _self.arrivalSoc : arrivalSoc // ignore: cast_nullable_to_non_nullable
as int,departureSoc: null == departureSoc ? _self.departureSoc : departureSoc // ignore: cast_nullable_to_non_nullable
as int,energyAddedKwh: null == energyAddedKwh ? _self.energyAddedKwh : energyAddedKwh // ignore: cast_nullable_to_non_nullable
as double,chargingMinutes: null == chargingMinutes ? _self.chargingMinutes : chargingMinutes // ignore: cast_nullable_to_non_nullable
as int,estimatedCost: null == estimatedCost ? _self.estimatedCost : estimatedCost // ignore: cast_nullable_to_non_nullable
as double,recommendationReason: freezed == recommendationReason ? _self.recommendationReason : recommendationReason // ignore: cast_nullable_to_non_nullable
as String?,reservationId: freezed == reservationId ? _self.reservationId : reservationId // ignore: cast_nullable_to_non_nullable
as String?,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RouteStop].
extension RouteStopPatterns on RouteStop {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RouteStop value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RouteStop() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RouteStop value)  $default,){
final _that = this;
switch (_that) {
case _RouteStop():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RouteStop value)?  $default,){
final _that = this;
switch (_that) {
case _RouteStop() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? planId,  int sequence,  String? stationId,  String? stationName,  bool isBackup,  bool isReachable,  double distanceAlongRouteKm,  double detourKm,  int detourMinutes,  int arrivalSoc,  int departureSoc,  double energyAddedKwh,  int chargingMinutes,  double estimatedCost,  String? recommendationReason,  String? reservationId,  String? serverUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RouteStop() when $default != null:
return $default(_that.id,_that.planId,_that.sequence,_that.stationId,_that.stationName,_that.isBackup,_that.isReachable,_that.distanceAlongRouteKm,_that.detourKm,_that.detourMinutes,_that.arrivalSoc,_that.departureSoc,_that.energyAddedKwh,_that.chargingMinutes,_that.estimatedCost,_that.recommendationReason,_that.reservationId,_that.serverUpdatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? planId,  int sequence,  String? stationId,  String? stationName,  bool isBackup,  bool isReachable,  double distanceAlongRouteKm,  double detourKm,  int detourMinutes,  int arrivalSoc,  int departureSoc,  double energyAddedKwh,  int chargingMinutes,  double estimatedCost,  String? recommendationReason,  String? reservationId,  String? serverUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _RouteStop():
return $default(_that.id,_that.planId,_that.sequence,_that.stationId,_that.stationName,_that.isBackup,_that.isReachable,_that.distanceAlongRouteKm,_that.detourKm,_that.detourMinutes,_that.arrivalSoc,_that.departureSoc,_that.energyAddedKwh,_that.chargingMinutes,_that.estimatedCost,_that.recommendationReason,_that.reservationId,_that.serverUpdatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? planId,  int sequence,  String? stationId,  String? stationName,  bool isBackup,  bool isReachable,  double distanceAlongRouteKm,  double detourKm,  int detourMinutes,  int arrivalSoc,  int departureSoc,  double energyAddedKwh,  int chargingMinutes,  double estimatedCost,  String? recommendationReason,  String? reservationId,  String? serverUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _RouteStop() when $default != null:
return $default(_that.id,_that.planId,_that.sequence,_that.stationId,_that.stationName,_that.isBackup,_that.isReachable,_that.distanceAlongRouteKm,_that.detourKm,_that.detourMinutes,_that.arrivalSoc,_that.departureSoc,_that.energyAddedKwh,_that.chargingMinutes,_that.estimatedCost,_that.recommendationReason,_that.reservationId,_that.serverUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RouteStop implements RouteStop {
  const _RouteStop({required this.id, this.planId, this.sequence = 0, this.stationId, this.stationName, this.isBackup = false, this.isReachable = false, this.distanceAlongRouteKm = 0, this.detourKm = 0, this.detourMinutes = 0, this.arrivalSoc = 0, this.departureSoc = 0, this.energyAddedKwh = 0, this.chargingMinutes = 0, this.estimatedCost = 0, this.recommendationReason, this.reservationId, this.serverUpdatedAt});
  factory _RouteStop.fromJson(Map<String, dynamic> json) => _$RouteStopFromJson(json);

@override final  String id;
@override final  String? planId;
@override@JsonKey() final  int sequence;
@override final  String? stationId;
@override final  String? stationName;
@override@JsonKey() final  bool isBackup;
@override@JsonKey() final  bool isReachable;
@override@JsonKey() final  double distanceAlongRouteKm;
@override@JsonKey() final  double detourKm;
@override@JsonKey() final  int detourMinutes;
@override@JsonKey() final  int arrivalSoc;
@override@JsonKey() final  int departureSoc;
@override@JsonKey() final  double energyAddedKwh;
@override@JsonKey() final  int chargingMinutes;
@override@JsonKey() final  double estimatedCost;
@override final  String? recommendationReason;
@override final  String? reservationId;
@override final  String? serverUpdatedAt;

/// Create a copy of RouteStop
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RouteStopCopyWith<_RouteStop> get copyWith => __$RouteStopCopyWithImpl<_RouteStop>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RouteStopToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteStop&&(identical(other.id, id) || other.id == id)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.sequence, sequence) || other.sequence == sequence)&&(identical(other.stationId, stationId) || other.stationId == stationId)&&(identical(other.stationName, stationName) || other.stationName == stationName)&&(identical(other.isBackup, isBackup) || other.isBackup == isBackup)&&(identical(other.isReachable, isReachable) || other.isReachable == isReachable)&&(identical(other.distanceAlongRouteKm, distanceAlongRouteKm) || other.distanceAlongRouteKm == distanceAlongRouteKm)&&(identical(other.detourKm, detourKm) || other.detourKm == detourKm)&&(identical(other.detourMinutes, detourMinutes) || other.detourMinutes == detourMinutes)&&(identical(other.arrivalSoc, arrivalSoc) || other.arrivalSoc == arrivalSoc)&&(identical(other.departureSoc, departureSoc) || other.departureSoc == departureSoc)&&(identical(other.energyAddedKwh, energyAddedKwh) || other.energyAddedKwh == energyAddedKwh)&&(identical(other.chargingMinutes, chargingMinutes) || other.chargingMinutes == chargingMinutes)&&(identical(other.estimatedCost, estimatedCost) || other.estimatedCost == estimatedCost)&&(identical(other.recommendationReason, recommendationReason) || other.recommendationReason == recommendationReason)&&(identical(other.reservationId, reservationId) || other.reservationId == reservationId)&&(identical(other.serverUpdatedAt, serverUpdatedAt) || other.serverUpdatedAt == serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,planId,sequence,stationId,stationName,isBackup,isReachable,distanceAlongRouteKm,detourKm,detourMinutes,arrivalSoc,departureSoc,energyAddedKwh,chargingMinutes,estimatedCost,recommendationReason,reservationId,serverUpdatedAt);
}

@override
String toString() {
    return 'RouteStop(id: $id, planId: $planId, sequence: $sequence, stationId: $stationId, stationName: $stationName, isBackup: $isBackup, isReachable: $isReachable, distanceAlongRouteKm: $distanceAlongRouteKm, detourKm: $detourKm, detourMinutes: $detourMinutes, arrivalSoc: $arrivalSoc, departureSoc: $departureSoc, energyAddedKwh: $energyAddedKwh, chargingMinutes: $chargingMinutes, estimatedCost: $estimatedCost, recommendationReason: $recommendationReason, reservationId: $reservationId, serverUpdatedAt: $serverUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$RouteStopCopyWith<$Res> implements $RouteStopCopyWith<$Res> {
  factory _$RouteStopCopyWith(_RouteStop value, $Res Function(_RouteStop) _then) = __$RouteStopCopyWithImpl;
@override @useResult
$Res call({
 String id, String? planId, int sequence, String? stationId, String? stationName, bool isBackup, bool isReachable, double distanceAlongRouteKm, double detourKm, int detourMinutes, int arrivalSoc, int departureSoc, double energyAddedKwh, int chargingMinutes, double estimatedCost, String? recommendationReason, String? reservationId, String? serverUpdatedAt
});




}
/// @nodoc
class __$RouteStopCopyWithImpl<$Res>
    implements _$RouteStopCopyWith<$Res> {
  __$RouteStopCopyWithImpl(this._self, this._then);

  final _RouteStop _self;
  final $Res Function(_RouteStop) _then;

/// Create a copy of RouteStop
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? planId = freezed,Object? sequence = null,Object? stationId = freezed,Object? stationName = freezed,Object? isBackup = null,Object? isReachable = null,Object? distanceAlongRouteKm = null,Object? detourKm = null,Object? detourMinutes = null,Object? arrivalSoc = null,Object? departureSoc = null,Object? energyAddedKwh = null,Object? chargingMinutes = null,Object? estimatedCost = null,Object? recommendationReason = freezed,Object? reservationId = freezed,Object? serverUpdatedAt = freezed,}) {
  return _then(_RouteStop(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,planId: freezed == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String?,sequence: null == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int,stationId: freezed == stationId ? _self.stationId : stationId // ignore: cast_nullable_to_non_nullable
as String?,stationName: freezed == stationName ? _self.stationName : stationName // ignore: cast_nullable_to_non_nullable
as String?,isBackup: null == isBackup ? _self.isBackup : isBackup // ignore: cast_nullable_to_non_nullable
as bool,isReachable: null == isReachable ? _self.isReachable : isReachable // ignore: cast_nullable_to_non_nullable
as bool,distanceAlongRouteKm: null == distanceAlongRouteKm ? _self.distanceAlongRouteKm : distanceAlongRouteKm // ignore: cast_nullable_to_non_nullable
as double,detourKm: null == detourKm ? _self.detourKm : detourKm // ignore: cast_nullable_to_non_nullable
as double,detourMinutes: null == detourMinutes ? _self.detourMinutes : detourMinutes // ignore: cast_nullable_to_non_nullable
as int,arrivalSoc: null == arrivalSoc ? _self.arrivalSoc : arrivalSoc // ignore: cast_nullable_to_non_nullable
as int,departureSoc: null == departureSoc ? _self.departureSoc : departureSoc // ignore: cast_nullable_to_non_nullable
as int,energyAddedKwh: null == energyAddedKwh ? _self.energyAddedKwh : energyAddedKwh // ignore: cast_nullable_to_non_nullable
as double,chargingMinutes: null == chargingMinutes ? _self.chargingMinutes : chargingMinutes // ignore: cast_nullable_to_non_nullable
as int,estimatedCost: null == estimatedCost ? _self.estimatedCost : estimatedCost // ignore: cast_nullable_to_non_nullable
as double,recommendationReason: freezed == recommendationReason ? _self.recommendationReason : recommendationReason // ignore: cast_nullable_to_non_nullable
as String?,reservationId: freezed == reservationId ? _self.reservationId : reservationId // ignore: cast_nullable_to_non_nullable
as String?,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TripEstimate {

 String get id; String? get planId; String? get vehicleId; double get segmentDistanceKm; double get estimatedDrainKwh; double get actualDrainKwh; int get estimatedArrivalSoc; int get actualArrivalSoc; String? get confidence; String? get notes; int get createdAtMs; String? get serverUpdatedAt;
/// Create a copy of TripEstimate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TripEstimateCopyWith<TripEstimate> get copyWith => _$TripEstimateCopyWithImpl<TripEstimate>(this as TripEstimate, _$identity);

  /// Serializes this TripEstimate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TripEstimate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TripEstimate&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.planId, _this.planId) || other.planId == _this.planId)&&(identical(other.vehicleId, _this.vehicleId) || other.vehicleId == _this.vehicleId)&&(identical(other.segmentDistanceKm, _this.segmentDistanceKm) || other.segmentDistanceKm == _this.segmentDistanceKm)&&(identical(other.estimatedDrainKwh, _this.estimatedDrainKwh) || other.estimatedDrainKwh == _this.estimatedDrainKwh)&&(identical(other.actualDrainKwh, _this.actualDrainKwh) || other.actualDrainKwh == _this.actualDrainKwh)&&(identical(other.estimatedArrivalSoc, _this.estimatedArrivalSoc) || other.estimatedArrivalSoc == _this.estimatedArrivalSoc)&&(identical(other.actualArrivalSoc, _this.actualArrivalSoc) || other.actualArrivalSoc == _this.actualArrivalSoc)&&(identical(other.confidence, _this.confidence) || other.confidence == _this.confidence)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.createdAtMs, _this.createdAtMs) || other.createdAtMs == _this.createdAtMs)&&(identical(other.serverUpdatedAt, _this.serverUpdatedAt) || other.serverUpdatedAt == _this.serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TripEstimate;
  return Object.hash(runtimeType,_this.id,_this.planId,_this.vehicleId,_this.segmentDistanceKm,_this.estimatedDrainKwh,_this.actualDrainKwh,_this.estimatedArrivalSoc,_this.actualArrivalSoc,_this.confidence,_this.notes,_this.createdAtMs,_this.serverUpdatedAt);
}

@override
String toString() {
  final _this = this as TripEstimate;
  return 'TripEstimate(id: ${_this.id}, planId: ${_this.planId}, vehicleId: ${_this.vehicleId}, segmentDistanceKm: ${_this.segmentDistanceKm}, estimatedDrainKwh: ${_this.estimatedDrainKwh}, actualDrainKwh: ${_this.actualDrainKwh}, estimatedArrivalSoc: ${_this.estimatedArrivalSoc}, actualArrivalSoc: ${_this.actualArrivalSoc}, confidence: ${_this.confidence}, notes: ${_this.notes}, createdAtMs: ${_this.createdAtMs}, serverUpdatedAt: ${_this.serverUpdatedAt})';
}


}

/// @nodoc
abstract mixin class $TripEstimateCopyWith<$Res>  {
  factory $TripEstimateCopyWith(TripEstimate value, $Res Function(TripEstimate) _then) = _$TripEstimateCopyWithImpl;
@useResult
$Res call({
 String id, String? planId, String? vehicleId, double segmentDistanceKm, double estimatedDrainKwh, double actualDrainKwh, int estimatedArrivalSoc, int actualArrivalSoc, String? confidence, String? notes, int createdAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class _$TripEstimateCopyWithImpl<$Res>
    implements $TripEstimateCopyWith<$Res> {
  _$TripEstimateCopyWithImpl(this._self, this._then);

  final TripEstimate _self;
  final $Res Function(TripEstimate) _then;

/// Create a copy of TripEstimate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? planId = freezed,Object? vehicleId = freezed,Object? segmentDistanceKm = null,Object? estimatedDrainKwh = null,Object? actualDrainKwh = null,Object? estimatedArrivalSoc = null,Object? actualArrivalSoc = null,Object? confidence = freezed,Object? notes = freezed,Object? createdAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(TripEstimate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,planId: freezed == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String?,vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as String?,segmentDistanceKm: null == segmentDistanceKm ? _self.segmentDistanceKm : segmentDistanceKm // ignore: cast_nullable_to_non_nullable
as double,estimatedDrainKwh: null == estimatedDrainKwh ? _self.estimatedDrainKwh : estimatedDrainKwh // ignore: cast_nullable_to_non_nullable
as double,actualDrainKwh: null == actualDrainKwh ? _self.actualDrainKwh : actualDrainKwh // ignore: cast_nullable_to_non_nullable
as double,estimatedArrivalSoc: null == estimatedArrivalSoc ? _self.estimatedArrivalSoc : estimatedArrivalSoc // ignore: cast_nullable_to_non_nullable
as int,actualArrivalSoc: null == actualArrivalSoc ? _self.actualArrivalSoc : actualArrivalSoc // ignore: cast_nullable_to_non_nullable
as int,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TripEstimate].
extension TripEstimatePatterns on TripEstimate {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TripEstimate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TripEstimate() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TripEstimate value)  $default,){
final _that = this;
switch (_that) {
case _TripEstimate():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TripEstimate value)?  $default,){
final _that = this;
switch (_that) {
case _TripEstimate() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? planId,  String? vehicleId,  double segmentDistanceKm,  double estimatedDrainKwh,  double actualDrainKwh,  int estimatedArrivalSoc,  int actualArrivalSoc,  String? confidence,  String? notes,  int createdAtMs,  String? serverUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TripEstimate() when $default != null:
return $default(_that.id,_that.planId,_that.vehicleId,_that.segmentDistanceKm,_that.estimatedDrainKwh,_that.actualDrainKwh,_that.estimatedArrivalSoc,_that.actualArrivalSoc,_that.confidence,_that.notes,_that.createdAtMs,_that.serverUpdatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? planId,  String? vehicleId,  double segmentDistanceKm,  double estimatedDrainKwh,  double actualDrainKwh,  int estimatedArrivalSoc,  int actualArrivalSoc,  String? confidence,  String? notes,  int createdAtMs,  String? serverUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _TripEstimate():
return $default(_that.id,_that.planId,_that.vehicleId,_that.segmentDistanceKm,_that.estimatedDrainKwh,_that.actualDrainKwh,_that.estimatedArrivalSoc,_that.actualArrivalSoc,_that.confidence,_that.notes,_that.createdAtMs,_that.serverUpdatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? planId,  String? vehicleId,  double segmentDistanceKm,  double estimatedDrainKwh,  double actualDrainKwh,  int estimatedArrivalSoc,  int actualArrivalSoc,  String? confidence,  String? notes,  int createdAtMs,  String? serverUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _TripEstimate() when $default != null:
return $default(_that.id,_that.planId,_that.vehicleId,_that.segmentDistanceKm,_that.estimatedDrainKwh,_that.actualDrainKwh,_that.estimatedArrivalSoc,_that.actualArrivalSoc,_that.confidence,_that.notes,_that.createdAtMs,_that.serverUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TripEstimate implements TripEstimate {
  const _TripEstimate({required this.id, this.planId, this.vehicleId, this.segmentDistanceKm = 0, this.estimatedDrainKwh = 0, this.actualDrainKwh = 0, this.estimatedArrivalSoc = 0, this.actualArrivalSoc = 0, this.confidence, this.notes, this.createdAtMs = 0, this.serverUpdatedAt});
  factory _TripEstimate.fromJson(Map<String, dynamic> json) => _$TripEstimateFromJson(json);

@override final  String id;
@override final  String? planId;
@override final  String? vehicleId;
@override@JsonKey() final  double segmentDistanceKm;
@override@JsonKey() final  double estimatedDrainKwh;
@override@JsonKey() final  double actualDrainKwh;
@override@JsonKey() final  int estimatedArrivalSoc;
@override@JsonKey() final  int actualArrivalSoc;
@override final  String? confidence;
@override final  String? notes;
@override@JsonKey() final  int createdAtMs;
@override final  String? serverUpdatedAt;

/// Create a copy of TripEstimate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TripEstimateCopyWith<_TripEstimate> get copyWith => __$TripEstimateCopyWithImpl<_TripEstimate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TripEstimateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TripEstimate&&(identical(other.id, id) || other.id == id)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.segmentDistanceKm, segmentDistanceKm) || other.segmentDistanceKm == segmentDistanceKm)&&(identical(other.estimatedDrainKwh, estimatedDrainKwh) || other.estimatedDrainKwh == estimatedDrainKwh)&&(identical(other.actualDrainKwh, actualDrainKwh) || other.actualDrainKwh == actualDrainKwh)&&(identical(other.estimatedArrivalSoc, estimatedArrivalSoc) || other.estimatedArrivalSoc == estimatedArrivalSoc)&&(identical(other.actualArrivalSoc, actualArrivalSoc) || other.actualArrivalSoc == actualArrivalSoc)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.serverUpdatedAt, serverUpdatedAt) || other.serverUpdatedAt == serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,planId,vehicleId,segmentDistanceKm,estimatedDrainKwh,actualDrainKwh,estimatedArrivalSoc,actualArrivalSoc,confidence,notes,createdAtMs,serverUpdatedAt);
}

@override
String toString() {
    return 'TripEstimate(id: $id, planId: $planId, vehicleId: $vehicleId, segmentDistanceKm: $segmentDistanceKm, estimatedDrainKwh: $estimatedDrainKwh, actualDrainKwh: $actualDrainKwh, estimatedArrivalSoc: $estimatedArrivalSoc, actualArrivalSoc: $actualArrivalSoc, confidence: $confidence, notes: $notes, createdAtMs: $createdAtMs, serverUpdatedAt: $serverUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$TripEstimateCopyWith<$Res> implements $TripEstimateCopyWith<$Res> {
  factory _$TripEstimateCopyWith(_TripEstimate value, $Res Function(_TripEstimate) _then) = __$TripEstimateCopyWithImpl;
@override @useResult
$Res call({
 String id, String? planId, String? vehicleId, double segmentDistanceKm, double estimatedDrainKwh, double actualDrainKwh, int estimatedArrivalSoc, int actualArrivalSoc, String? confidence, String? notes, int createdAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class __$TripEstimateCopyWithImpl<$Res>
    implements _$TripEstimateCopyWith<$Res> {
  __$TripEstimateCopyWithImpl(this._self, this._then);

  final _TripEstimate _self;
  final $Res Function(_TripEstimate) _then;

/// Create a copy of TripEstimate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? planId = freezed,Object? vehicleId = freezed,Object? segmentDistanceKm = null,Object? estimatedDrainKwh = null,Object? actualDrainKwh = null,Object? estimatedArrivalSoc = null,Object? actualArrivalSoc = null,Object? confidence = freezed,Object? notes = freezed,Object? createdAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(_TripEstimate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,planId: freezed == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String?,vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as String?,segmentDistanceKm: null == segmentDistanceKm ? _self.segmentDistanceKm : segmentDistanceKm // ignore: cast_nullable_to_non_nullable
as double,estimatedDrainKwh: null == estimatedDrainKwh ? _self.estimatedDrainKwh : estimatedDrainKwh // ignore: cast_nullable_to_non_nullable
as double,actualDrainKwh: null == actualDrainKwh ? _self.actualDrainKwh : actualDrainKwh // ignore: cast_nullable_to_non_nullable
as double,estimatedArrivalSoc: null == estimatedArrivalSoc ? _self.estimatedArrivalSoc : estimatedArrivalSoc // ignore: cast_nullable_to_non_nullable
as int,actualArrivalSoc: null == actualArrivalSoc ? _self.actualArrivalSoc : actualArrivalSoc // ignore: cast_nullable_to_non_nullable
as int,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$BatteryUpdate {

 String get id; String? get vehicleId; String? get tripPlanId; int get estimatedSoc; int get actualDashboardSoc; double get latitude; double get longitude; int get timestampMs; String? get serverUpdatedAt;
/// Create a copy of BatteryUpdate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BatteryUpdateCopyWith<BatteryUpdate> get copyWith => _$BatteryUpdateCopyWithImpl<BatteryUpdate>(this as BatteryUpdate, _$identity);

  /// Serializes this BatteryUpdate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BatteryUpdate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BatteryUpdate&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.vehicleId, _this.vehicleId) || other.vehicleId == _this.vehicleId)&&(identical(other.tripPlanId, _this.tripPlanId) || other.tripPlanId == _this.tripPlanId)&&(identical(other.estimatedSoc, _this.estimatedSoc) || other.estimatedSoc == _this.estimatedSoc)&&(identical(other.actualDashboardSoc, _this.actualDashboardSoc) || other.actualDashboardSoc == _this.actualDashboardSoc)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude)&&(identical(other.timestampMs, _this.timestampMs) || other.timestampMs == _this.timestampMs)&&(identical(other.serverUpdatedAt, _this.serverUpdatedAt) || other.serverUpdatedAt == _this.serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BatteryUpdate;
  return Object.hash(runtimeType,_this.id,_this.vehicleId,_this.tripPlanId,_this.estimatedSoc,_this.actualDashboardSoc,_this.latitude,_this.longitude,_this.timestampMs,_this.serverUpdatedAt);
}

@override
String toString() {
  final _this = this as BatteryUpdate;
  return 'BatteryUpdate(id: ${_this.id}, vehicleId: ${_this.vehicleId}, tripPlanId: ${_this.tripPlanId}, estimatedSoc: ${_this.estimatedSoc}, actualDashboardSoc: ${_this.actualDashboardSoc}, latitude: ${_this.latitude}, longitude: ${_this.longitude}, timestampMs: ${_this.timestampMs}, serverUpdatedAt: ${_this.serverUpdatedAt})';
}


}

/// @nodoc
abstract mixin class $BatteryUpdateCopyWith<$Res>  {
  factory $BatteryUpdateCopyWith(BatteryUpdate value, $Res Function(BatteryUpdate) _then) = _$BatteryUpdateCopyWithImpl;
@useResult
$Res call({
 String id, String? vehicleId, String? tripPlanId, int estimatedSoc, int actualDashboardSoc, double latitude, double longitude, int timestampMs, String? serverUpdatedAt
});




}
/// @nodoc
class _$BatteryUpdateCopyWithImpl<$Res>
    implements $BatteryUpdateCopyWith<$Res> {
  _$BatteryUpdateCopyWithImpl(this._self, this._then);

  final BatteryUpdate _self;
  final $Res Function(BatteryUpdate) _then;

/// Create a copy of BatteryUpdate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? vehicleId = freezed,Object? tripPlanId = freezed,Object? estimatedSoc = null,Object? actualDashboardSoc = null,Object? latitude = null,Object? longitude = null,Object? timestampMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(BatteryUpdate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as String?,tripPlanId: freezed == tripPlanId ? _self.tripPlanId : tripPlanId // ignore: cast_nullable_to_non_nullable
as String?,estimatedSoc: null == estimatedSoc ? _self.estimatedSoc : estimatedSoc // ignore: cast_nullable_to_non_nullable
as int,actualDashboardSoc: null == actualDashboardSoc ? _self.actualDashboardSoc : actualDashboardSoc // ignore: cast_nullable_to_non_nullable
as int,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,timestampMs: null == timestampMs ? _self.timestampMs : timestampMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BatteryUpdate].
extension BatteryUpdatePatterns on BatteryUpdate {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BatteryUpdate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BatteryUpdate() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BatteryUpdate value)  $default,){
final _that = this;
switch (_that) {
case _BatteryUpdate():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BatteryUpdate value)?  $default,){
final _that = this;
switch (_that) {
case _BatteryUpdate() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? vehicleId,  String? tripPlanId,  int estimatedSoc,  int actualDashboardSoc,  double latitude,  double longitude,  int timestampMs,  String? serverUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BatteryUpdate() when $default != null:
return $default(_that.id,_that.vehicleId,_that.tripPlanId,_that.estimatedSoc,_that.actualDashboardSoc,_that.latitude,_that.longitude,_that.timestampMs,_that.serverUpdatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? vehicleId,  String? tripPlanId,  int estimatedSoc,  int actualDashboardSoc,  double latitude,  double longitude,  int timestampMs,  String? serverUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _BatteryUpdate():
return $default(_that.id,_that.vehicleId,_that.tripPlanId,_that.estimatedSoc,_that.actualDashboardSoc,_that.latitude,_that.longitude,_that.timestampMs,_that.serverUpdatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? vehicleId,  String? tripPlanId,  int estimatedSoc,  int actualDashboardSoc,  double latitude,  double longitude,  int timestampMs,  String? serverUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _BatteryUpdate() when $default != null:
return $default(_that.id,_that.vehicleId,_that.tripPlanId,_that.estimatedSoc,_that.actualDashboardSoc,_that.latitude,_that.longitude,_that.timestampMs,_that.serverUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BatteryUpdate implements BatteryUpdate {
  const _BatteryUpdate({required this.id, this.vehicleId, this.tripPlanId, this.estimatedSoc = 0, this.actualDashboardSoc = 0, this.latitude = 0, this.longitude = 0, this.timestampMs = 0, this.serverUpdatedAt});
  factory _BatteryUpdate.fromJson(Map<String, dynamic> json) => _$BatteryUpdateFromJson(json);

@override final  String id;
@override final  String? vehicleId;
@override final  String? tripPlanId;
@override@JsonKey() final  int estimatedSoc;
@override@JsonKey() final  int actualDashboardSoc;
@override@JsonKey() final  double latitude;
@override@JsonKey() final  double longitude;
@override@JsonKey() final  int timestampMs;
@override final  String? serverUpdatedAt;

/// Create a copy of BatteryUpdate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BatteryUpdateCopyWith<_BatteryUpdate> get copyWith => __$BatteryUpdateCopyWithImpl<_BatteryUpdate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BatteryUpdateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BatteryUpdate&&(identical(other.id, id) || other.id == id)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.tripPlanId, tripPlanId) || other.tripPlanId == tripPlanId)&&(identical(other.estimatedSoc, estimatedSoc) || other.estimatedSoc == estimatedSoc)&&(identical(other.actualDashboardSoc, actualDashboardSoc) || other.actualDashboardSoc == actualDashboardSoc)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.timestampMs, timestampMs) || other.timestampMs == timestampMs)&&(identical(other.serverUpdatedAt, serverUpdatedAt) || other.serverUpdatedAt == serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,vehicleId,tripPlanId,estimatedSoc,actualDashboardSoc,latitude,longitude,timestampMs,serverUpdatedAt);
}

@override
String toString() {
    return 'BatteryUpdate(id: $id, vehicleId: $vehicleId, tripPlanId: $tripPlanId, estimatedSoc: $estimatedSoc, actualDashboardSoc: $actualDashboardSoc, latitude: $latitude, longitude: $longitude, timestampMs: $timestampMs, serverUpdatedAt: $serverUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$BatteryUpdateCopyWith<$Res> implements $BatteryUpdateCopyWith<$Res> {
  factory _$BatteryUpdateCopyWith(_BatteryUpdate value, $Res Function(_BatteryUpdate) _then) = __$BatteryUpdateCopyWithImpl;
@override @useResult
$Res call({
 String id, String? vehicleId, String? tripPlanId, int estimatedSoc, int actualDashboardSoc, double latitude, double longitude, int timestampMs, String? serverUpdatedAt
});




}
/// @nodoc
class __$BatteryUpdateCopyWithImpl<$Res>
    implements _$BatteryUpdateCopyWith<$Res> {
  __$BatteryUpdateCopyWithImpl(this._self, this._then);

  final _BatteryUpdate _self;
  final $Res Function(_BatteryUpdate) _then;

/// Create a copy of BatteryUpdate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? vehicleId = freezed,Object? tripPlanId = freezed,Object? estimatedSoc = null,Object? actualDashboardSoc = null,Object? latitude = null,Object? longitude = null,Object? timestampMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(_BatteryUpdate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as String?,tripPlanId: freezed == tripPlanId ? _self.tripPlanId : tripPlanId // ignore: cast_nullable_to_non_nullable
as String?,estimatedSoc: null == estimatedSoc ? _self.estimatedSoc : estimatedSoc // ignore: cast_nullable_to_non_nullable
as int,actualDashboardSoc: null == actualDashboardSoc ? _self.actualDashboardSoc : actualDashboardSoc // ignore: cast_nullable_to_non_nullable
as int,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,timestampMs: null == timestampMs ? _self.timestampMs : timestampMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CommunicationThread {

 String get id; String? get reservationId; String? get consumerId; String? get consumerName; String? get hostId; String? get hostName; String? get maskedConsumerNumber; String? get maskedHostNumber; bool get isReported; bool get isBlocked; bool get isChatEnabled; int get createdAtMs; int get expiresAtMs; String? get serverUpdatedAt;
/// Create a copy of CommunicationThread
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunicationThreadCopyWith<CommunicationThread> get copyWith => _$CommunicationThreadCopyWithImpl<CommunicationThread>(this as CommunicationThread, _$identity);

  /// Serializes this CommunicationThread to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CommunicationThread;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommunicationThread&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.reservationId, _this.reservationId) || other.reservationId == _this.reservationId)&&(identical(other.consumerId, _this.consumerId) || other.consumerId == _this.consumerId)&&(identical(other.consumerName, _this.consumerName) || other.consumerName == _this.consumerName)&&(identical(other.hostId, _this.hostId) || other.hostId == _this.hostId)&&(identical(other.hostName, _this.hostName) || other.hostName == _this.hostName)&&(identical(other.maskedConsumerNumber, _this.maskedConsumerNumber) || other.maskedConsumerNumber == _this.maskedConsumerNumber)&&(identical(other.maskedHostNumber, _this.maskedHostNumber) || other.maskedHostNumber == _this.maskedHostNumber)&&(identical(other.isReported, _this.isReported) || other.isReported == _this.isReported)&&(identical(other.isBlocked, _this.isBlocked) || other.isBlocked == _this.isBlocked)&&(identical(other.isChatEnabled, _this.isChatEnabled) || other.isChatEnabled == _this.isChatEnabled)&&(identical(other.createdAtMs, _this.createdAtMs) || other.createdAtMs == _this.createdAtMs)&&(identical(other.expiresAtMs, _this.expiresAtMs) || other.expiresAtMs == _this.expiresAtMs)&&(identical(other.serverUpdatedAt, _this.serverUpdatedAt) || other.serverUpdatedAt == _this.serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CommunicationThread;
  return Object.hash(runtimeType,_this.id,_this.reservationId,_this.consumerId,_this.consumerName,_this.hostId,_this.hostName,_this.maskedConsumerNumber,_this.maskedHostNumber,_this.isReported,_this.isBlocked,_this.isChatEnabled,_this.createdAtMs,_this.expiresAtMs,_this.serverUpdatedAt);
}

@override
String toString() {
  final _this = this as CommunicationThread;
  return 'CommunicationThread(id: ${_this.id}, reservationId: ${_this.reservationId}, consumerId: ${_this.consumerId}, consumerName: ${_this.consumerName}, hostId: ${_this.hostId}, hostName: ${_this.hostName}, maskedConsumerNumber: ${_this.maskedConsumerNumber}, maskedHostNumber: ${_this.maskedHostNumber}, isReported: ${_this.isReported}, isBlocked: ${_this.isBlocked}, isChatEnabled: ${_this.isChatEnabled}, createdAtMs: ${_this.createdAtMs}, expiresAtMs: ${_this.expiresAtMs}, serverUpdatedAt: ${_this.serverUpdatedAt})';
}


}

/// @nodoc
abstract mixin class $CommunicationThreadCopyWith<$Res>  {
  factory $CommunicationThreadCopyWith(CommunicationThread value, $Res Function(CommunicationThread) _then) = _$CommunicationThreadCopyWithImpl;
@useResult
$Res call({
 String id, String? reservationId, String? consumerId, String? consumerName, String? hostId, String? hostName, String? maskedConsumerNumber, String? maskedHostNumber, bool isReported, bool isBlocked, bool isChatEnabled, int createdAtMs, int expiresAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class _$CommunicationThreadCopyWithImpl<$Res>
    implements $CommunicationThreadCopyWith<$Res> {
  _$CommunicationThreadCopyWithImpl(this._self, this._then);

  final CommunicationThread _self;
  final $Res Function(CommunicationThread) _then;

/// Create a copy of CommunicationThread
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reservationId = freezed,Object? consumerId = freezed,Object? consumerName = freezed,Object? hostId = freezed,Object? hostName = freezed,Object? maskedConsumerNumber = freezed,Object? maskedHostNumber = freezed,Object? isReported = null,Object? isBlocked = null,Object? isChatEnabled = null,Object? createdAtMs = null,Object? expiresAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(CommunicationThread(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reservationId: freezed == reservationId ? _self.reservationId : reservationId // ignore: cast_nullable_to_non_nullable
as String?,consumerId: freezed == consumerId ? _self.consumerId : consumerId // ignore: cast_nullable_to_non_nullable
as String?,consumerName: freezed == consumerName ? _self.consumerName : consumerName // ignore: cast_nullable_to_non_nullable
as String?,hostId: freezed == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String?,hostName: freezed == hostName ? _self.hostName : hostName // ignore: cast_nullable_to_non_nullable
as String?,maskedConsumerNumber: freezed == maskedConsumerNumber ? _self.maskedConsumerNumber : maskedConsumerNumber // ignore: cast_nullable_to_non_nullable
as String?,maskedHostNumber: freezed == maskedHostNumber ? _self.maskedHostNumber : maskedHostNumber // ignore: cast_nullable_to_non_nullable
as String?,isReported: null == isReported ? _self.isReported : isReported // ignore: cast_nullable_to_non_nullable
as bool,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,isChatEnabled: null == isChatEnabled ? _self.isChatEnabled : isChatEnabled // ignore: cast_nullable_to_non_nullable
as bool,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,expiresAtMs: null == expiresAtMs ? _self.expiresAtMs : expiresAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CommunicationThread].
extension CommunicationThreadPatterns on CommunicationThread {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommunicationThread value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommunicationThread() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommunicationThread value)  $default,){
final _that = this;
switch (_that) {
case _CommunicationThread():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommunicationThread value)?  $default,){
final _that = this;
switch (_that) {
case _CommunicationThread() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? reservationId,  String? consumerId,  String? consumerName,  String? hostId,  String? hostName,  String? maskedConsumerNumber,  String? maskedHostNumber,  bool isReported,  bool isBlocked,  bool isChatEnabled,  int createdAtMs,  int expiresAtMs,  String? serverUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommunicationThread() when $default != null:
return $default(_that.id,_that.reservationId,_that.consumerId,_that.consumerName,_that.hostId,_that.hostName,_that.maskedConsumerNumber,_that.maskedHostNumber,_that.isReported,_that.isBlocked,_that.isChatEnabled,_that.createdAtMs,_that.expiresAtMs,_that.serverUpdatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? reservationId,  String? consumerId,  String? consumerName,  String? hostId,  String? hostName,  String? maskedConsumerNumber,  String? maskedHostNumber,  bool isReported,  bool isBlocked,  bool isChatEnabled,  int createdAtMs,  int expiresAtMs,  String? serverUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _CommunicationThread():
return $default(_that.id,_that.reservationId,_that.consumerId,_that.consumerName,_that.hostId,_that.hostName,_that.maskedConsumerNumber,_that.maskedHostNumber,_that.isReported,_that.isBlocked,_that.isChatEnabled,_that.createdAtMs,_that.expiresAtMs,_that.serverUpdatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? reservationId,  String? consumerId,  String? consumerName,  String? hostId,  String? hostName,  String? maskedConsumerNumber,  String? maskedHostNumber,  bool isReported,  bool isBlocked,  bool isChatEnabled,  int createdAtMs,  int expiresAtMs,  String? serverUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CommunicationThread() when $default != null:
return $default(_that.id,_that.reservationId,_that.consumerId,_that.consumerName,_that.hostId,_that.hostName,_that.maskedConsumerNumber,_that.maskedHostNumber,_that.isReported,_that.isBlocked,_that.isChatEnabled,_that.createdAtMs,_that.expiresAtMs,_that.serverUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommunicationThread implements CommunicationThread {
  const _CommunicationThread({required this.id, this.reservationId, this.consumerId, this.consumerName, this.hostId, this.hostName, this.maskedConsumerNumber, this.maskedHostNumber, this.isReported = false, this.isBlocked = false, this.isChatEnabled = true, this.createdAtMs = 0, this.expiresAtMs = 0, this.serverUpdatedAt});
  factory _CommunicationThread.fromJson(Map<String, dynamic> json) => _$CommunicationThreadFromJson(json);

@override final  String id;
@override final  String? reservationId;
@override final  String? consumerId;
@override final  String? consumerName;
@override final  String? hostId;
@override final  String? hostName;
@override final  String? maskedConsumerNumber;
@override final  String? maskedHostNumber;
@override@JsonKey() final  bool isReported;
@override@JsonKey() final  bool isBlocked;
@override@JsonKey() final  bool isChatEnabled;
@override@JsonKey() final  int createdAtMs;
@override@JsonKey() final  int expiresAtMs;
@override final  String? serverUpdatedAt;

/// Create a copy of CommunicationThread
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunicationThreadCopyWith<_CommunicationThread> get copyWith => __$CommunicationThreadCopyWithImpl<_CommunicationThread>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommunicationThreadToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommunicationThread&&(identical(other.id, id) || other.id == id)&&(identical(other.reservationId, reservationId) || other.reservationId == reservationId)&&(identical(other.consumerId, consumerId) || other.consumerId == consumerId)&&(identical(other.consumerName, consumerName) || other.consumerName == consumerName)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.hostName, hostName) || other.hostName == hostName)&&(identical(other.maskedConsumerNumber, maskedConsumerNumber) || other.maskedConsumerNumber == maskedConsumerNumber)&&(identical(other.maskedHostNumber, maskedHostNumber) || other.maskedHostNumber == maskedHostNumber)&&(identical(other.isReported, isReported) || other.isReported == isReported)&&(identical(other.isBlocked, isBlocked) || other.isBlocked == isBlocked)&&(identical(other.isChatEnabled, isChatEnabled) || other.isChatEnabled == isChatEnabled)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.expiresAtMs, expiresAtMs) || other.expiresAtMs == expiresAtMs)&&(identical(other.serverUpdatedAt, serverUpdatedAt) || other.serverUpdatedAt == serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,reservationId,consumerId,consumerName,hostId,hostName,maskedConsumerNumber,maskedHostNumber,isReported,isBlocked,isChatEnabled,createdAtMs,expiresAtMs,serverUpdatedAt);
}

@override
String toString() {
    return 'CommunicationThread(id: $id, reservationId: $reservationId, consumerId: $consumerId, consumerName: $consumerName, hostId: $hostId, hostName: $hostName, maskedConsumerNumber: $maskedConsumerNumber, maskedHostNumber: $maskedHostNumber, isReported: $isReported, isBlocked: $isBlocked, isChatEnabled: $isChatEnabled, createdAtMs: $createdAtMs, expiresAtMs: $expiresAtMs, serverUpdatedAt: $serverUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$CommunicationThreadCopyWith<$Res> implements $CommunicationThreadCopyWith<$Res> {
  factory _$CommunicationThreadCopyWith(_CommunicationThread value, $Res Function(_CommunicationThread) _then) = __$CommunicationThreadCopyWithImpl;
@override @useResult
$Res call({
 String id, String? reservationId, String? consumerId, String? consumerName, String? hostId, String? hostName, String? maskedConsumerNumber, String? maskedHostNumber, bool isReported, bool isBlocked, bool isChatEnabled, int createdAtMs, int expiresAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class __$CommunicationThreadCopyWithImpl<$Res>
    implements _$CommunicationThreadCopyWith<$Res> {
  __$CommunicationThreadCopyWithImpl(this._self, this._then);

  final _CommunicationThread _self;
  final $Res Function(_CommunicationThread) _then;

/// Create a copy of CommunicationThread
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reservationId = freezed,Object? consumerId = freezed,Object? consumerName = freezed,Object? hostId = freezed,Object? hostName = freezed,Object? maskedConsumerNumber = freezed,Object? maskedHostNumber = freezed,Object? isReported = null,Object? isBlocked = null,Object? isChatEnabled = null,Object? createdAtMs = null,Object? expiresAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(_CommunicationThread(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reservationId: freezed == reservationId ? _self.reservationId : reservationId // ignore: cast_nullable_to_non_nullable
as String?,consumerId: freezed == consumerId ? _self.consumerId : consumerId // ignore: cast_nullable_to_non_nullable
as String?,consumerName: freezed == consumerName ? _self.consumerName : consumerName // ignore: cast_nullable_to_non_nullable
as String?,hostId: freezed == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String?,hostName: freezed == hostName ? _self.hostName : hostName // ignore: cast_nullable_to_non_nullable
as String?,maskedConsumerNumber: freezed == maskedConsumerNumber ? _self.maskedConsumerNumber : maskedConsumerNumber // ignore: cast_nullable_to_non_nullable
as String?,maskedHostNumber: freezed == maskedHostNumber ? _self.maskedHostNumber : maskedHostNumber // ignore: cast_nullable_to_non_nullable
as String?,isReported: null == isReported ? _self.isReported : isReported // ignore: cast_nullable_to_non_nullable
as bool,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,isChatEnabled: null == isChatEnabled ? _self.isChatEnabled : isChatEnabled // ignore: cast_nullable_to_non_nullable
as bool,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,expiresAtMs: null == expiresAtMs ? _self.expiresAtMs : expiresAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ChatMessage {

 String get id; String? get threadId; String? get reservationId; String? get senderId; String? get receiverId; String? get messageText; int get createdAtMs; bool get isRead; bool get isReported; int get expiresAtMs; String? get serverUpdatedAt;
/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageCopyWith<ChatMessage> get copyWith => _$ChatMessageCopyWithImpl<ChatMessage>(this as ChatMessage, _$identity);

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ChatMessage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessage&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.threadId, _this.threadId) || other.threadId == _this.threadId)&&(identical(other.reservationId, _this.reservationId) || other.reservationId == _this.reservationId)&&(identical(other.senderId, _this.senderId) || other.senderId == _this.senderId)&&(identical(other.receiverId, _this.receiverId) || other.receiverId == _this.receiverId)&&(identical(other.messageText, _this.messageText) || other.messageText == _this.messageText)&&(identical(other.createdAtMs, _this.createdAtMs) || other.createdAtMs == _this.createdAtMs)&&(identical(other.isRead, _this.isRead) || other.isRead == _this.isRead)&&(identical(other.isReported, _this.isReported) || other.isReported == _this.isReported)&&(identical(other.expiresAtMs, _this.expiresAtMs) || other.expiresAtMs == _this.expiresAtMs)&&(identical(other.serverUpdatedAt, _this.serverUpdatedAt) || other.serverUpdatedAt == _this.serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ChatMessage;
  return Object.hash(runtimeType,_this.id,_this.threadId,_this.reservationId,_this.senderId,_this.receiverId,_this.messageText,_this.createdAtMs,_this.isRead,_this.isReported,_this.expiresAtMs,_this.serverUpdatedAt);
}

@override
String toString() {
  final _this = this as ChatMessage;
  return 'ChatMessage(id: ${_this.id}, threadId: ${_this.threadId}, reservationId: ${_this.reservationId}, senderId: ${_this.senderId}, receiverId: ${_this.receiverId}, messageText: ${_this.messageText}, createdAtMs: ${_this.createdAtMs}, isRead: ${_this.isRead}, isReported: ${_this.isReported}, expiresAtMs: ${_this.expiresAtMs}, serverUpdatedAt: ${_this.serverUpdatedAt})';
}


}

/// @nodoc
abstract mixin class $ChatMessageCopyWith<$Res>  {
  factory $ChatMessageCopyWith(ChatMessage value, $Res Function(ChatMessage) _then) = _$ChatMessageCopyWithImpl;
@useResult
$Res call({
 String id, String? threadId, String? reservationId, String? senderId, String? receiverId, String? messageText, int createdAtMs, bool isRead, bool isReported, int expiresAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class _$ChatMessageCopyWithImpl<$Res>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._self, this._then);

  final ChatMessage _self;
  final $Res Function(ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? threadId = freezed,Object? reservationId = freezed,Object? senderId = freezed,Object? receiverId = freezed,Object? messageText = freezed,Object? createdAtMs = null,Object? isRead = null,Object? isReported = null,Object? expiresAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(ChatMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,threadId: freezed == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String?,reservationId: freezed == reservationId ? _self.reservationId : reservationId // ignore: cast_nullable_to_non_nullable
as String?,senderId: freezed == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String?,receiverId: freezed == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as String?,messageText: freezed == messageText ? _self.messageText : messageText // ignore: cast_nullable_to_non_nullable
as String?,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,isReported: null == isReported ? _self.isReported : isReported // ignore: cast_nullable_to_non_nullable
as bool,expiresAtMs: null == expiresAtMs ? _self.expiresAtMs : expiresAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessage].
extension ChatMessagePatterns on ChatMessage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessage value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessage():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessage value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? threadId,  String? reservationId,  String? senderId,  String? receiverId,  String? messageText,  int createdAtMs,  bool isRead,  bool isReported,  int expiresAtMs,  String? serverUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.id,_that.threadId,_that.reservationId,_that.senderId,_that.receiverId,_that.messageText,_that.createdAtMs,_that.isRead,_that.isReported,_that.expiresAtMs,_that.serverUpdatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? threadId,  String? reservationId,  String? senderId,  String? receiverId,  String? messageText,  int createdAtMs,  bool isRead,  bool isReported,  int expiresAtMs,  String? serverUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _ChatMessage():
return $default(_that.id,_that.threadId,_that.reservationId,_that.senderId,_that.receiverId,_that.messageText,_that.createdAtMs,_that.isRead,_that.isReported,_that.expiresAtMs,_that.serverUpdatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? threadId,  String? reservationId,  String? senderId,  String? receiverId,  String? messageText,  int createdAtMs,  bool isRead,  bool isReported,  int expiresAtMs,  String? serverUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.id,_that.threadId,_that.reservationId,_that.senderId,_that.receiverId,_that.messageText,_that.createdAtMs,_that.isRead,_that.isReported,_that.expiresAtMs,_that.serverUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatMessage implements ChatMessage {
  const _ChatMessage({required this.id, this.threadId, this.reservationId, this.senderId, this.receiverId, this.messageText, this.createdAtMs = 0, this.isRead = false, this.isReported = false, this.expiresAtMs = 0, this.serverUpdatedAt});
  factory _ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);

@override final  String id;
@override final  String? threadId;
@override final  String? reservationId;
@override final  String? senderId;
@override final  String? receiverId;
@override final  String? messageText;
@override@JsonKey() final  int createdAtMs;
@override@JsonKey() final  bool isRead;
@override@JsonKey() final  bool isReported;
@override@JsonKey() final  int expiresAtMs;
@override final  String? serverUpdatedAt;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageCopyWith<_ChatMessage> get copyWith => __$ChatMessageCopyWithImpl<_ChatMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatMessageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.reservationId, reservationId) || other.reservationId == reservationId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.receiverId, receiverId) || other.receiverId == receiverId)&&(identical(other.messageText, messageText) || other.messageText == messageText)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.isReported, isReported) || other.isReported == isReported)&&(identical(other.expiresAtMs, expiresAtMs) || other.expiresAtMs == expiresAtMs)&&(identical(other.serverUpdatedAt, serverUpdatedAt) || other.serverUpdatedAt == serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,threadId,reservationId,senderId,receiverId,messageText,createdAtMs,isRead,isReported,expiresAtMs,serverUpdatedAt);
}

@override
String toString() {
    return 'ChatMessage(id: $id, threadId: $threadId, reservationId: $reservationId, senderId: $senderId, receiverId: $receiverId, messageText: $messageText, createdAtMs: $createdAtMs, isRead: $isRead, isReported: $isReported, expiresAtMs: $expiresAtMs, serverUpdatedAt: $serverUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageCopyWith<$Res> implements $ChatMessageCopyWith<$Res> {
  factory _$ChatMessageCopyWith(_ChatMessage value, $Res Function(_ChatMessage) _then) = __$ChatMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, String? threadId, String? reservationId, String? senderId, String? receiverId, String? messageText, int createdAtMs, bool isRead, bool isReported, int expiresAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class __$ChatMessageCopyWithImpl<$Res>
    implements _$ChatMessageCopyWith<$Res> {
  __$ChatMessageCopyWithImpl(this._self, this._then);

  final _ChatMessage _self;
  final $Res Function(_ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? threadId = freezed,Object? reservationId = freezed,Object? senderId = freezed,Object? receiverId = freezed,Object? messageText = freezed,Object? createdAtMs = null,Object? isRead = null,Object? isReported = null,Object? expiresAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(_ChatMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,threadId: freezed == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String?,reservationId: freezed == reservationId ? _self.reservationId : reservationId // ignore: cast_nullable_to_non_nullable
as String?,senderId: freezed == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String?,receiverId: freezed == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as String?,messageText: freezed == messageText ? _self.messageText : messageText // ignore: cast_nullable_to_non_nullable
as String?,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,isReported: null == isReported ? _self.isReported : isReported // ignore: cast_nullable_to_non_nullable
as bool,expiresAtMs: null == expiresAtMs ? _self.expiresAtMs : expiresAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SafetyEvent {

 String get id; String? get consumerId; String? get stationId; String? get emergencyType; bool get isLiveLocationSharingActive; String? get trustedContactPhone; int get expiresAtMs; int get createdAtMs; String? get serverUpdatedAt;
/// Create a copy of SafetyEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SafetyEventCopyWith<SafetyEvent> get copyWith => _$SafetyEventCopyWithImpl<SafetyEvent>(this as SafetyEvent, _$identity);

  /// Serializes this SafetyEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SafetyEvent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SafetyEvent&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.consumerId, _this.consumerId) || other.consumerId == _this.consumerId)&&(identical(other.stationId, _this.stationId) || other.stationId == _this.stationId)&&(identical(other.emergencyType, _this.emergencyType) || other.emergencyType == _this.emergencyType)&&(identical(other.isLiveLocationSharingActive, _this.isLiveLocationSharingActive) || other.isLiveLocationSharingActive == _this.isLiveLocationSharingActive)&&(identical(other.trustedContactPhone, _this.trustedContactPhone) || other.trustedContactPhone == _this.trustedContactPhone)&&(identical(other.expiresAtMs, _this.expiresAtMs) || other.expiresAtMs == _this.expiresAtMs)&&(identical(other.createdAtMs, _this.createdAtMs) || other.createdAtMs == _this.createdAtMs)&&(identical(other.serverUpdatedAt, _this.serverUpdatedAt) || other.serverUpdatedAt == _this.serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SafetyEvent;
  return Object.hash(runtimeType,_this.id,_this.consumerId,_this.stationId,_this.emergencyType,_this.isLiveLocationSharingActive,_this.trustedContactPhone,_this.expiresAtMs,_this.createdAtMs,_this.serverUpdatedAt);
}

@override
String toString() {
  final _this = this as SafetyEvent;
  return 'SafetyEvent(id: ${_this.id}, consumerId: ${_this.consumerId}, stationId: ${_this.stationId}, emergencyType: ${_this.emergencyType}, isLiveLocationSharingActive: ${_this.isLiveLocationSharingActive}, trustedContactPhone: ${_this.trustedContactPhone}, expiresAtMs: ${_this.expiresAtMs}, createdAtMs: ${_this.createdAtMs}, serverUpdatedAt: ${_this.serverUpdatedAt})';
}


}

/// @nodoc
abstract mixin class $SafetyEventCopyWith<$Res>  {
  factory $SafetyEventCopyWith(SafetyEvent value, $Res Function(SafetyEvent) _then) = _$SafetyEventCopyWithImpl;
@useResult
$Res call({
 String id, String? consumerId, String? stationId, String? emergencyType, bool isLiveLocationSharingActive, String? trustedContactPhone, int expiresAtMs, int createdAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class _$SafetyEventCopyWithImpl<$Res>
    implements $SafetyEventCopyWith<$Res> {
  _$SafetyEventCopyWithImpl(this._self, this._then);

  final SafetyEvent _self;
  final $Res Function(SafetyEvent) _then;

/// Create a copy of SafetyEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? consumerId = freezed,Object? stationId = freezed,Object? emergencyType = freezed,Object? isLiveLocationSharingActive = null,Object? trustedContactPhone = freezed,Object? expiresAtMs = null,Object? createdAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(SafetyEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,consumerId: freezed == consumerId ? _self.consumerId : consumerId // ignore: cast_nullable_to_non_nullable
as String?,stationId: freezed == stationId ? _self.stationId : stationId // ignore: cast_nullable_to_non_nullable
as String?,emergencyType: freezed == emergencyType ? _self.emergencyType : emergencyType // ignore: cast_nullable_to_non_nullable
as String?,isLiveLocationSharingActive: null == isLiveLocationSharingActive ? _self.isLiveLocationSharingActive : isLiveLocationSharingActive // ignore: cast_nullable_to_non_nullable
as bool,trustedContactPhone: freezed == trustedContactPhone ? _self.trustedContactPhone : trustedContactPhone // ignore: cast_nullable_to_non_nullable
as String?,expiresAtMs: null == expiresAtMs ? _self.expiresAtMs : expiresAtMs // ignore: cast_nullable_to_non_nullable
as int,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SafetyEvent].
extension SafetyEventPatterns on SafetyEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SafetyEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SafetyEvent() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SafetyEvent value)  $default,){
final _that = this;
switch (_that) {
case _SafetyEvent():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SafetyEvent value)?  $default,){
final _that = this;
switch (_that) {
case _SafetyEvent() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? consumerId,  String? stationId,  String? emergencyType,  bool isLiveLocationSharingActive,  String? trustedContactPhone,  int expiresAtMs,  int createdAtMs,  String? serverUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SafetyEvent() when $default != null:
return $default(_that.id,_that.consumerId,_that.stationId,_that.emergencyType,_that.isLiveLocationSharingActive,_that.trustedContactPhone,_that.expiresAtMs,_that.createdAtMs,_that.serverUpdatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? consumerId,  String? stationId,  String? emergencyType,  bool isLiveLocationSharingActive,  String? trustedContactPhone,  int expiresAtMs,  int createdAtMs,  String? serverUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _SafetyEvent():
return $default(_that.id,_that.consumerId,_that.stationId,_that.emergencyType,_that.isLiveLocationSharingActive,_that.trustedContactPhone,_that.expiresAtMs,_that.createdAtMs,_that.serverUpdatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? consumerId,  String? stationId,  String? emergencyType,  bool isLiveLocationSharingActive,  String? trustedContactPhone,  int expiresAtMs,  int createdAtMs,  String? serverUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SafetyEvent() when $default != null:
return $default(_that.id,_that.consumerId,_that.stationId,_that.emergencyType,_that.isLiveLocationSharingActive,_that.trustedContactPhone,_that.expiresAtMs,_that.createdAtMs,_that.serverUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SafetyEvent implements SafetyEvent {
  const _SafetyEvent({required this.id, this.consumerId, this.stationId, this.emergencyType, this.isLiveLocationSharingActive = false, this.trustedContactPhone, this.expiresAtMs = 0, this.createdAtMs = 0, this.serverUpdatedAt});
  factory _SafetyEvent.fromJson(Map<String, dynamic> json) => _$SafetyEventFromJson(json);

@override final  String id;
@override final  String? consumerId;
@override final  String? stationId;
@override final  String? emergencyType;
@override@JsonKey() final  bool isLiveLocationSharingActive;
@override final  String? trustedContactPhone;
@override@JsonKey() final  int expiresAtMs;
@override@JsonKey() final  int createdAtMs;
@override final  String? serverUpdatedAt;

/// Create a copy of SafetyEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SafetyEventCopyWith<_SafetyEvent> get copyWith => __$SafetyEventCopyWithImpl<_SafetyEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SafetyEventToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SafetyEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.consumerId, consumerId) || other.consumerId == consumerId)&&(identical(other.stationId, stationId) || other.stationId == stationId)&&(identical(other.emergencyType, emergencyType) || other.emergencyType == emergencyType)&&(identical(other.isLiveLocationSharingActive, isLiveLocationSharingActive) || other.isLiveLocationSharingActive == isLiveLocationSharingActive)&&(identical(other.trustedContactPhone, trustedContactPhone) || other.trustedContactPhone == trustedContactPhone)&&(identical(other.expiresAtMs, expiresAtMs) || other.expiresAtMs == expiresAtMs)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.serverUpdatedAt, serverUpdatedAt) || other.serverUpdatedAt == serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,consumerId,stationId,emergencyType,isLiveLocationSharingActive,trustedContactPhone,expiresAtMs,createdAtMs,serverUpdatedAt);
}

@override
String toString() {
    return 'SafetyEvent(id: $id, consumerId: $consumerId, stationId: $stationId, emergencyType: $emergencyType, isLiveLocationSharingActive: $isLiveLocationSharingActive, trustedContactPhone: $trustedContactPhone, expiresAtMs: $expiresAtMs, createdAtMs: $createdAtMs, serverUpdatedAt: $serverUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$SafetyEventCopyWith<$Res> implements $SafetyEventCopyWith<$Res> {
  factory _$SafetyEventCopyWith(_SafetyEvent value, $Res Function(_SafetyEvent) _then) = __$SafetyEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String? consumerId, String? stationId, String? emergencyType, bool isLiveLocationSharingActive, String? trustedContactPhone, int expiresAtMs, int createdAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class __$SafetyEventCopyWithImpl<$Res>
    implements _$SafetyEventCopyWith<$Res> {
  __$SafetyEventCopyWithImpl(this._self, this._then);

  final _SafetyEvent _self;
  final $Res Function(_SafetyEvent) _then;

/// Create a copy of SafetyEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? consumerId = freezed,Object? stationId = freezed,Object? emergencyType = freezed,Object? isLiveLocationSharingActive = null,Object? trustedContactPhone = freezed,Object? expiresAtMs = null,Object? createdAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(_SafetyEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,consumerId: freezed == consumerId ? _self.consumerId : consumerId // ignore: cast_nullable_to_non_nullable
as String?,stationId: freezed == stationId ? _self.stationId : stationId // ignore: cast_nullable_to_non_nullable
as String?,emergencyType: freezed == emergencyType ? _self.emergencyType : emergencyType // ignore: cast_nullable_to_non_nullable
as String?,isLiveLocationSharingActive: null == isLiveLocationSharingActive ? _self.isLiveLocationSharingActive : isLiveLocationSharingActive // ignore: cast_nullable_to_non_nullable
as bool,trustedContactPhone: freezed == trustedContactPhone ? _self.trustedContactPhone : trustedContactPhone // ignore: cast_nullable_to_non_nullable
as String?,expiresAtMs: null == expiresAtMs ? _self.expiresAtMs : expiresAtMs // ignore: cast_nullable_to_non_nullable
as int,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TrustedContact {

 String get id; String? get userId; String? get name; String? get phone; String? get serverUpdatedAt;
/// Create a copy of TrustedContact
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrustedContactCopyWith<TrustedContact> get copyWith => _$TrustedContactCopyWithImpl<TrustedContact>(this as TrustedContact, _$identity);

  /// Serializes this TrustedContact to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TrustedContact;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrustedContact&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.serverUpdatedAt, _this.serverUpdatedAt) || other.serverUpdatedAt == _this.serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TrustedContact;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.name,_this.phone,_this.serverUpdatedAt);
}

@override
String toString() {
  final _this = this as TrustedContact;
  return 'TrustedContact(id: ${_this.id}, userId: ${_this.userId}, name: ${_this.name}, phone: ${_this.phone}, serverUpdatedAt: ${_this.serverUpdatedAt})';
}


}

/// @nodoc
abstract mixin class $TrustedContactCopyWith<$Res>  {
  factory $TrustedContactCopyWith(TrustedContact value, $Res Function(TrustedContact) _then) = _$TrustedContactCopyWithImpl;
@useResult
$Res call({
 String id, String? userId, String? name, String? phone, String? serverUpdatedAt
});




}
/// @nodoc
class _$TrustedContactCopyWithImpl<$Res>
    implements $TrustedContactCopyWith<$Res> {
  _$TrustedContactCopyWithImpl(this._self, this._then);

  final TrustedContact _self;
  final $Res Function(TrustedContact) _then;

/// Create a copy of TrustedContact
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = freezed,Object? name = freezed,Object? phone = freezed,Object? serverUpdatedAt = freezed,}) {
  return _then(TrustedContact(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TrustedContact].
extension TrustedContactPatterns on TrustedContact {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrustedContact value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrustedContact() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrustedContact value)  $default,){
final _that = this;
switch (_that) {
case _TrustedContact():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrustedContact value)?  $default,){
final _that = this;
switch (_that) {
case _TrustedContact() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? userId,  String? name,  String? phone,  String? serverUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrustedContact() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.phone,_that.serverUpdatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? userId,  String? name,  String? phone,  String? serverUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _TrustedContact():
return $default(_that.id,_that.userId,_that.name,_that.phone,_that.serverUpdatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? userId,  String? name,  String? phone,  String? serverUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _TrustedContact() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.phone,_that.serverUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrustedContact implements TrustedContact {
  const _TrustedContact({required this.id, this.userId, this.name, this.phone, this.serverUpdatedAt});
  factory _TrustedContact.fromJson(Map<String, dynamic> json) => _$TrustedContactFromJson(json);

@override final  String id;
@override final  String? userId;
@override final  String? name;
@override final  String? phone;
@override final  String? serverUpdatedAt;

/// Create a copy of TrustedContact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrustedContactCopyWith<_TrustedContact> get copyWith => __$TrustedContactCopyWithImpl<_TrustedContact>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrustedContactToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrustedContact&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.serverUpdatedAt, serverUpdatedAt) || other.serverUpdatedAt == serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,name,phone,serverUpdatedAt);
}

@override
String toString() {
    return 'TrustedContact(id: $id, userId: $userId, name: $name, phone: $phone, serverUpdatedAt: $serverUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$TrustedContactCopyWith<$Res> implements $TrustedContactCopyWith<$Res> {
  factory _$TrustedContactCopyWith(_TrustedContact value, $Res Function(_TrustedContact) _then) = __$TrustedContactCopyWithImpl;
@override @useResult
$Res call({
 String id, String? userId, String? name, String? phone, String? serverUpdatedAt
});




}
/// @nodoc
class __$TrustedContactCopyWithImpl<$Res>
    implements _$TrustedContactCopyWith<$Res> {
  __$TrustedContactCopyWithImpl(this._self, this._then);

  final _TrustedContact _self;
  final $Res Function(_TrustedContact) _then;

/// Create a copy of TrustedContact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = freezed,Object? name = freezed,Object? phone = freezed,Object? serverUpdatedAt = freezed,}) {
  return _then(_TrustedContact(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
