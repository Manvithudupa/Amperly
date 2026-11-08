// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Reservation {

 String get id; String? get consumerId; String? get stationId; String? get stationName; String? get portId; String? get portLabel; String? get bookingCode; int get startTimeMs; int get endTimeMs; String? get status; double get pricePerKwh; double get serviceFee; double get gatewayFee; double get cancellationFee; bool get isPaid; String? get paymentId; int get checkedInAtMs; int get cancelledAtMs; int get createdAtMs; String? get serverUpdatedAt;
/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReservationCopyWith<Reservation> get copyWith => _$ReservationCopyWithImpl<Reservation>(this as Reservation, _$identity);

  /// Serializes this Reservation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Reservation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Reservation&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.consumerId, _this.consumerId) || other.consumerId == _this.consumerId)&&(identical(other.stationId, _this.stationId) || other.stationId == _this.stationId)&&(identical(other.stationName, _this.stationName) || other.stationName == _this.stationName)&&(identical(other.portId, _this.portId) || other.portId == _this.portId)&&(identical(other.portLabel, _this.portLabel) || other.portLabel == _this.portLabel)&&(identical(other.bookingCode, _this.bookingCode) || other.bookingCode == _this.bookingCode)&&(identical(other.startTimeMs, _this.startTimeMs) || other.startTimeMs == _this.startTimeMs)&&(identical(other.endTimeMs, _this.endTimeMs) || other.endTimeMs == _this.endTimeMs)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.pricePerKwh, _this.pricePerKwh) || other.pricePerKwh == _this.pricePerKwh)&&(identical(other.serviceFee, _this.serviceFee) || other.serviceFee == _this.serviceFee)&&(identical(other.gatewayFee, _this.gatewayFee) || other.gatewayFee == _this.gatewayFee)&&(identical(other.cancellationFee, _this.cancellationFee) || other.cancellationFee == _this.cancellationFee)&&(identical(other.isPaid, _this.isPaid) || other.isPaid == _this.isPaid)&&(identical(other.paymentId, _this.paymentId) || other.paymentId == _this.paymentId)&&(identical(other.checkedInAtMs, _this.checkedInAtMs) || other.checkedInAtMs == _this.checkedInAtMs)&&(identical(other.cancelledAtMs, _this.cancelledAtMs) || other.cancelledAtMs == _this.cancelledAtMs)&&(identical(other.createdAtMs, _this.createdAtMs) || other.createdAtMs == _this.createdAtMs)&&(identical(other.serverUpdatedAt, _this.serverUpdatedAt) || other.serverUpdatedAt == _this.serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Reservation;
  return Object.hashAll([runtimeType,_this.id,_this.consumerId,_this.stationId,_this.stationName,_this.portId,_this.portLabel,_this.bookingCode,_this.startTimeMs,_this.endTimeMs,_this.status,_this.pricePerKwh,_this.serviceFee,_this.gatewayFee,_this.cancellationFee,_this.isPaid,_this.paymentId,_this.checkedInAtMs,_this.cancelledAtMs,_this.createdAtMs,_this.serverUpdatedAt]);
}

@override
String toString() {
  final _this = this as Reservation;
  return 'Reservation(id: ${_this.id}, consumerId: ${_this.consumerId}, stationId: ${_this.stationId}, stationName: ${_this.stationName}, portId: ${_this.portId}, portLabel: ${_this.portLabel}, bookingCode: ${_this.bookingCode}, startTimeMs: ${_this.startTimeMs}, endTimeMs: ${_this.endTimeMs}, status: ${_this.status}, pricePerKwh: ${_this.pricePerKwh}, serviceFee: ${_this.serviceFee}, gatewayFee: ${_this.gatewayFee}, cancellationFee: ${_this.cancellationFee}, isPaid: ${_this.isPaid}, paymentId: ${_this.paymentId}, checkedInAtMs: ${_this.checkedInAtMs}, cancelledAtMs: ${_this.cancelledAtMs}, createdAtMs: ${_this.createdAtMs}, serverUpdatedAt: ${_this.serverUpdatedAt})';
}


}

/// @nodoc
abstract mixin class $ReservationCopyWith<$Res>  {
  factory $ReservationCopyWith(Reservation value, $Res Function(Reservation) _then) = _$ReservationCopyWithImpl;
@useResult
$Res call({
 String id, String? consumerId, String? stationId, String? stationName, String? portId, String? portLabel, String? bookingCode, int startTimeMs, int endTimeMs, String? status, double pricePerKwh, double serviceFee, double gatewayFee, double cancellationFee, bool isPaid, String? paymentId, int checkedInAtMs, int cancelledAtMs, int createdAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class _$ReservationCopyWithImpl<$Res>
    implements $ReservationCopyWith<$Res> {
  _$ReservationCopyWithImpl(this._self, this._then);

  final Reservation _self;
  final $Res Function(Reservation) _then;

/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? consumerId = freezed,Object? stationId = freezed,Object? stationName = freezed,Object? portId = freezed,Object? portLabel = freezed,Object? bookingCode = freezed,Object? startTimeMs = null,Object? endTimeMs = null,Object? status = freezed,Object? pricePerKwh = null,Object? serviceFee = null,Object? gatewayFee = null,Object? cancellationFee = null,Object? isPaid = null,Object? paymentId = freezed,Object? checkedInAtMs = null,Object? cancelledAtMs = null,Object? createdAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(Reservation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,consumerId: freezed == consumerId ? _self.consumerId : consumerId // ignore: cast_nullable_to_non_nullable
as String?,stationId: freezed == stationId ? _self.stationId : stationId // ignore: cast_nullable_to_non_nullable
as String?,stationName: freezed == stationName ? _self.stationName : stationName // ignore: cast_nullable_to_non_nullable
as String?,portId: freezed == portId ? _self.portId : portId // ignore: cast_nullable_to_non_nullable
as String?,portLabel: freezed == portLabel ? _self.portLabel : portLabel // ignore: cast_nullable_to_non_nullable
as String?,bookingCode: freezed == bookingCode ? _self.bookingCode : bookingCode // ignore: cast_nullable_to_non_nullable
as String?,startTimeMs: null == startTimeMs ? _self.startTimeMs : startTimeMs // ignore: cast_nullable_to_non_nullable
as int,endTimeMs: null == endTimeMs ? _self.endTimeMs : endTimeMs // ignore: cast_nullable_to_non_nullable
as int,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,pricePerKwh: null == pricePerKwh ? _self.pricePerKwh : pricePerKwh // ignore: cast_nullable_to_non_nullable
as double,serviceFee: null == serviceFee ? _self.serviceFee : serviceFee // ignore: cast_nullable_to_non_nullable
as double,gatewayFee: null == gatewayFee ? _self.gatewayFee : gatewayFee // ignore: cast_nullable_to_non_nullable
as double,cancellationFee: null == cancellationFee ? _self.cancellationFee : cancellationFee // ignore: cast_nullable_to_non_nullable
as double,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,paymentId: freezed == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String?,checkedInAtMs: null == checkedInAtMs ? _self.checkedInAtMs : checkedInAtMs // ignore: cast_nullable_to_non_nullable
as int,cancelledAtMs: null == cancelledAtMs ? _self.cancelledAtMs : cancelledAtMs // ignore: cast_nullable_to_non_nullable
as int,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Reservation].
extension ReservationPatterns on Reservation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Reservation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Reservation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Reservation value)  $default,){
final _that = this;
switch (_that) {
case _Reservation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Reservation value)?  $default,){
final _that = this;
switch (_that) {
case _Reservation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? consumerId,  String? stationId,  String? stationName,  String? portId,  String? portLabel,  String? bookingCode,  int startTimeMs,  int endTimeMs,  String? status,  double pricePerKwh,  double serviceFee,  double gatewayFee,  double cancellationFee,  bool isPaid,  String? paymentId,  int checkedInAtMs,  int cancelledAtMs,  int createdAtMs,  String? serverUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Reservation() when $default != null:
return $default(_that.id,_that.consumerId,_that.stationId,_that.stationName,_that.portId,_that.portLabel,_that.bookingCode,_that.startTimeMs,_that.endTimeMs,_that.status,_that.pricePerKwh,_that.serviceFee,_that.gatewayFee,_that.cancellationFee,_that.isPaid,_that.paymentId,_that.checkedInAtMs,_that.cancelledAtMs,_that.createdAtMs,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? consumerId,  String? stationId,  String? stationName,  String? portId,  String? portLabel,  String? bookingCode,  int startTimeMs,  int endTimeMs,  String? status,  double pricePerKwh,  double serviceFee,  double gatewayFee,  double cancellationFee,  bool isPaid,  String? paymentId,  int checkedInAtMs,  int cancelledAtMs,  int createdAtMs,  String? serverUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _Reservation():
return $default(_that.id,_that.consumerId,_that.stationId,_that.stationName,_that.portId,_that.portLabel,_that.bookingCode,_that.startTimeMs,_that.endTimeMs,_that.status,_that.pricePerKwh,_that.serviceFee,_that.gatewayFee,_that.cancellationFee,_that.isPaid,_that.paymentId,_that.checkedInAtMs,_that.cancelledAtMs,_that.createdAtMs,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? consumerId,  String? stationId,  String? stationName,  String? portId,  String? portLabel,  String? bookingCode,  int startTimeMs,  int endTimeMs,  String? status,  double pricePerKwh,  double serviceFee,  double gatewayFee,  double cancellationFee,  bool isPaid,  String? paymentId,  int checkedInAtMs,  int cancelledAtMs,  int createdAtMs,  String? serverUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Reservation() when $default != null:
return $default(_that.id,_that.consumerId,_that.stationId,_that.stationName,_that.portId,_that.portLabel,_that.bookingCode,_that.startTimeMs,_that.endTimeMs,_that.status,_that.pricePerKwh,_that.serviceFee,_that.gatewayFee,_that.cancellationFee,_that.isPaid,_that.paymentId,_that.checkedInAtMs,_that.cancelledAtMs,_that.createdAtMs,_that.serverUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Reservation implements Reservation {
  const _Reservation({required this.id, this.consumerId, this.stationId, this.stationName, this.portId, this.portLabel, this.bookingCode, this.startTimeMs = 0, this.endTimeMs = 0, this.status, this.pricePerKwh = 0, this.serviceFee = 0, this.gatewayFee = 0, this.cancellationFee = 0, this.isPaid = false, this.paymentId, this.checkedInAtMs = 0, this.cancelledAtMs = 0, this.createdAtMs = 0, this.serverUpdatedAt});
  factory _Reservation.fromJson(Map<String, dynamic> json) => _$ReservationFromJson(json);

@override final  String id;
@override final  String? consumerId;
@override final  String? stationId;
@override final  String? stationName;
@override final  String? portId;
@override final  String? portLabel;
@override final  String? bookingCode;
@override@JsonKey() final  int startTimeMs;
@override@JsonKey() final  int endTimeMs;
@override final  String? status;
@override@JsonKey() final  double pricePerKwh;
@override@JsonKey() final  double serviceFee;
@override@JsonKey() final  double gatewayFee;
@override@JsonKey() final  double cancellationFee;
@override@JsonKey() final  bool isPaid;
@override final  String? paymentId;
@override@JsonKey() final  int checkedInAtMs;
@override@JsonKey() final  int cancelledAtMs;
@override@JsonKey() final  int createdAtMs;
@override final  String? serverUpdatedAt;

/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReservationCopyWith<_Reservation> get copyWith => __$ReservationCopyWithImpl<_Reservation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReservationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reservation&&(identical(other.id, id) || other.id == id)&&(identical(other.consumerId, consumerId) || other.consumerId == consumerId)&&(identical(other.stationId, stationId) || other.stationId == stationId)&&(identical(other.stationName, stationName) || other.stationName == stationName)&&(identical(other.portId, portId) || other.portId == portId)&&(identical(other.portLabel, portLabel) || other.portLabel == portLabel)&&(identical(other.bookingCode, bookingCode) || other.bookingCode == bookingCode)&&(identical(other.startTimeMs, startTimeMs) || other.startTimeMs == startTimeMs)&&(identical(other.endTimeMs, endTimeMs) || other.endTimeMs == endTimeMs)&&(identical(other.status, status) || other.status == status)&&(identical(other.pricePerKwh, pricePerKwh) || other.pricePerKwh == pricePerKwh)&&(identical(other.serviceFee, serviceFee) || other.serviceFee == serviceFee)&&(identical(other.gatewayFee, gatewayFee) || other.gatewayFee == gatewayFee)&&(identical(other.cancellationFee, cancellationFee) || other.cancellationFee == cancellationFee)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.checkedInAtMs, checkedInAtMs) || other.checkedInAtMs == checkedInAtMs)&&(identical(other.cancelledAtMs, cancelledAtMs) || other.cancelledAtMs == cancelledAtMs)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.serverUpdatedAt, serverUpdatedAt) || other.serverUpdatedAt == serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,consumerId,stationId,stationName,portId,portLabel,bookingCode,startTimeMs,endTimeMs,status,pricePerKwh,serviceFee,gatewayFee,cancellationFee,isPaid,paymentId,checkedInAtMs,cancelledAtMs,createdAtMs,serverUpdatedAt]);
}

@override
String toString() {
    return 'Reservation(id: $id, consumerId: $consumerId, stationId: $stationId, stationName: $stationName, portId: $portId, portLabel: $portLabel, bookingCode: $bookingCode, startTimeMs: $startTimeMs, endTimeMs: $endTimeMs, status: $status, pricePerKwh: $pricePerKwh, serviceFee: $serviceFee, gatewayFee: $gatewayFee, cancellationFee: $cancellationFee, isPaid: $isPaid, paymentId: $paymentId, checkedInAtMs: $checkedInAtMs, cancelledAtMs: $cancelledAtMs, createdAtMs: $createdAtMs, serverUpdatedAt: $serverUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$ReservationCopyWith<$Res> implements $ReservationCopyWith<$Res> {
  factory _$ReservationCopyWith(_Reservation value, $Res Function(_Reservation) _then) = __$ReservationCopyWithImpl;
@override @useResult
$Res call({
 String id, String? consumerId, String? stationId, String? stationName, String? portId, String? portLabel, String? bookingCode, int startTimeMs, int endTimeMs, String? status, double pricePerKwh, double serviceFee, double gatewayFee, double cancellationFee, bool isPaid, String? paymentId, int checkedInAtMs, int cancelledAtMs, int createdAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class __$ReservationCopyWithImpl<$Res>
    implements _$ReservationCopyWith<$Res> {
  __$ReservationCopyWithImpl(this._self, this._then);

  final _Reservation _self;
  final $Res Function(_Reservation) _then;

/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? consumerId = freezed,Object? stationId = freezed,Object? stationName = freezed,Object? portId = freezed,Object? portLabel = freezed,Object? bookingCode = freezed,Object? startTimeMs = null,Object? endTimeMs = null,Object? status = freezed,Object? pricePerKwh = null,Object? serviceFee = null,Object? gatewayFee = null,Object? cancellationFee = null,Object? isPaid = null,Object? paymentId = freezed,Object? checkedInAtMs = null,Object? cancelledAtMs = null,Object? createdAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(_Reservation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,consumerId: freezed == consumerId ? _self.consumerId : consumerId // ignore: cast_nullable_to_non_nullable
as String?,stationId: freezed == stationId ? _self.stationId : stationId // ignore: cast_nullable_to_non_nullable
as String?,stationName: freezed == stationName ? _self.stationName : stationName // ignore: cast_nullable_to_non_nullable
as String?,portId: freezed == portId ? _self.portId : portId // ignore: cast_nullable_to_non_nullable
as String?,portLabel: freezed == portLabel ? _self.portLabel : portLabel // ignore: cast_nullable_to_non_nullable
as String?,bookingCode: freezed == bookingCode ? _self.bookingCode : bookingCode // ignore: cast_nullable_to_non_nullable
as String?,startTimeMs: null == startTimeMs ? _self.startTimeMs : startTimeMs // ignore: cast_nullable_to_non_nullable
as int,endTimeMs: null == endTimeMs ? _self.endTimeMs : endTimeMs // ignore: cast_nullable_to_non_nullable
as int,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,pricePerKwh: null == pricePerKwh ? _self.pricePerKwh : pricePerKwh // ignore: cast_nullable_to_non_nullable
as double,serviceFee: null == serviceFee ? _self.serviceFee : serviceFee // ignore: cast_nullable_to_non_nullable
as double,gatewayFee: null == gatewayFee ? _self.gatewayFee : gatewayFee // ignore: cast_nullable_to_non_nullable
as double,cancellationFee: null == cancellationFee ? _self.cancellationFee : cancellationFee // ignore: cast_nullable_to_non_nullable
as double,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,paymentId: freezed == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String?,checkedInAtMs: null == checkedInAtMs ? _self.checkedInAtMs : checkedInAtMs // ignore: cast_nullable_to_non_nullable
as int,cancelledAtMs: null == cancelledAtMs ? _self.cancelledAtMs : cancelledAtMs // ignore: cast_nullable_to_non_nullable
as int,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ChargingSession {

 String get id; String? get reservationId; String? get consumerId; String? get hostId; String? get stationId; String? get stationName; String? get portId; int get startTimeMs; int get endTimeMs; double get startingMeterKwh; double get endingMeterKwh; double get verifiedKwhConsumed; double get energyCharge; double get serviceFee; double get gatewayFee; double get totalPaid; String? get status; String? get meterReadingId; String? get invoiceId; bool get isMeterSimulated; String? get verificationLevel; String? get serverUpdatedAt;
/// Create a copy of ChargingSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChargingSessionCopyWith<ChargingSession> get copyWith => _$ChargingSessionCopyWithImpl<ChargingSession>(this as ChargingSession, _$identity);

  /// Serializes this ChargingSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ChargingSession;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChargingSession&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.reservationId, _this.reservationId) || other.reservationId == _this.reservationId)&&(identical(other.consumerId, _this.consumerId) || other.consumerId == _this.consumerId)&&(identical(other.hostId, _this.hostId) || other.hostId == _this.hostId)&&(identical(other.stationId, _this.stationId) || other.stationId == _this.stationId)&&(identical(other.stationName, _this.stationName) || other.stationName == _this.stationName)&&(identical(other.portId, _this.portId) || other.portId == _this.portId)&&(identical(other.startTimeMs, _this.startTimeMs) || other.startTimeMs == _this.startTimeMs)&&(identical(other.endTimeMs, _this.endTimeMs) || other.endTimeMs == _this.endTimeMs)&&(identical(other.startingMeterKwh, _this.startingMeterKwh) || other.startingMeterKwh == _this.startingMeterKwh)&&(identical(other.endingMeterKwh, _this.endingMeterKwh) || other.endingMeterKwh == _this.endingMeterKwh)&&(identical(other.verifiedKwhConsumed, _this.verifiedKwhConsumed) || other.verifiedKwhConsumed == _this.verifiedKwhConsumed)&&(identical(other.energyCharge, _this.energyCharge) || other.energyCharge == _this.energyCharge)&&(identical(other.serviceFee, _this.serviceFee) || other.serviceFee == _this.serviceFee)&&(identical(other.gatewayFee, _this.gatewayFee) || other.gatewayFee == _this.gatewayFee)&&(identical(other.totalPaid, _this.totalPaid) || other.totalPaid == _this.totalPaid)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.meterReadingId, _this.meterReadingId) || other.meterReadingId == _this.meterReadingId)&&(identical(other.invoiceId, _this.invoiceId) || other.invoiceId == _this.invoiceId)&&(identical(other.isMeterSimulated, _this.isMeterSimulated) || other.isMeterSimulated == _this.isMeterSimulated)&&(identical(other.verificationLevel, _this.verificationLevel) || other.verificationLevel == _this.verificationLevel)&&(identical(other.serverUpdatedAt, _this.serverUpdatedAt) || other.serverUpdatedAt == _this.serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ChargingSession;
  return Object.hashAll([runtimeType,_this.id,_this.reservationId,_this.consumerId,_this.hostId,_this.stationId,_this.stationName,_this.portId,_this.startTimeMs,_this.endTimeMs,_this.startingMeterKwh,_this.endingMeterKwh,_this.verifiedKwhConsumed,_this.energyCharge,_this.serviceFee,_this.gatewayFee,_this.totalPaid,_this.status,_this.meterReadingId,_this.invoiceId,_this.isMeterSimulated,_this.verificationLevel,_this.serverUpdatedAt]);
}

@override
String toString() {
  final _this = this as ChargingSession;
  return 'ChargingSession(id: ${_this.id}, reservationId: ${_this.reservationId}, consumerId: ${_this.consumerId}, hostId: ${_this.hostId}, stationId: ${_this.stationId}, stationName: ${_this.stationName}, portId: ${_this.portId}, startTimeMs: ${_this.startTimeMs}, endTimeMs: ${_this.endTimeMs}, startingMeterKwh: ${_this.startingMeterKwh}, endingMeterKwh: ${_this.endingMeterKwh}, verifiedKwhConsumed: ${_this.verifiedKwhConsumed}, energyCharge: ${_this.energyCharge}, serviceFee: ${_this.serviceFee}, gatewayFee: ${_this.gatewayFee}, totalPaid: ${_this.totalPaid}, status: ${_this.status}, meterReadingId: ${_this.meterReadingId}, invoiceId: ${_this.invoiceId}, isMeterSimulated: ${_this.isMeterSimulated}, verificationLevel: ${_this.verificationLevel}, serverUpdatedAt: ${_this.serverUpdatedAt})';
}


}

/// @nodoc
abstract mixin class $ChargingSessionCopyWith<$Res>  {
  factory $ChargingSessionCopyWith(ChargingSession value, $Res Function(ChargingSession) _then) = _$ChargingSessionCopyWithImpl;
@useResult
$Res call({
 String id, String? reservationId, String? consumerId, String? hostId, String? stationId, String? stationName, String? portId, int startTimeMs, int endTimeMs, double startingMeterKwh, double endingMeterKwh, double verifiedKwhConsumed, double energyCharge, double serviceFee, double gatewayFee, double totalPaid, String? status, String? meterReadingId, String? invoiceId, bool isMeterSimulated, String? verificationLevel, String? serverUpdatedAt
});




}
/// @nodoc
class _$ChargingSessionCopyWithImpl<$Res>
    implements $ChargingSessionCopyWith<$Res> {
  _$ChargingSessionCopyWithImpl(this._self, this._then);

  final ChargingSession _self;
  final $Res Function(ChargingSession) _then;

/// Create a copy of ChargingSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reservationId = freezed,Object? consumerId = freezed,Object? hostId = freezed,Object? stationId = freezed,Object? stationName = freezed,Object? portId = freezed,Object? startTimeMs = null,Object? endTimeMs = null,Object? startingMeterKwh = null,Object? endingMeterKwh = null,Object? verifiedKwhConsumed = null,Object? energyCharge = null,Object? serviceFee = null,Object? gatewayFee = null,Object? totalPaid = null,Object? status = freezed,Object? meterReadingId = freezed,Object? invoiceId = freezed,Object? isMeterSimulated = null,Object? verificationLevel = freezed,Object? serverUpdatedAt = freezed,}) {
  return _then(ChargingSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reservationId: freezed == reservationId ? _self.reservationId : reservationId // ignore: cast_nullable_to_non_nullable
as String?,consumerId: freezed == consumerId ? _self.consumerId : consumerId // ignore: cast_nullable_to_non_nullable
as String?,hostId: freezed == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String?,stationId: freezed == stationId ? _self.stationId : stationId // ignore: cast_nullable_to_non_nullable
as String?,stationName: freezed == stationName ? _self.stationName : stationName // ignore: cast_nullable_to_non_nullable
as String?,portId: freezed == portId ? _self.portId : portId // ignore: cast_nullable_to_non_nullable
as String?,startTimeMs: null == startTimeMs ? _self.startTimeMs : startTimeMs // ignore: cast_nullable_to_non_nullable
as int,endTimeMs: null == endTimeMs ? _self.endTimeMs : endTimeMs // ignore: cast_nullable_to_non_nullable
as int,startingMeterKwh: null == startingMeterKwh ? _self.startingMeterKwh : startingMeterKwh // ignore: cast_nullable_to_non_nullable
as double,endingMeterKwh: null == endingMeterKwh ? _self.endingMeterKwh : endingMeterKwh // ignore: cast_nullable_to_non_nullable
as double,verifiedKwhConsumed: null == verifiedKwhConsumed ? _self.verifiedKwhConsumed : verifiedKwhConsumed // ignore: cast_nullable_to_non_nullable
as double,energyCharge: null == energyCharge ? _self.energyCharge : energyCharge // ignore: cast_nullable_to_non_nullable
as double,serviceFee: null == serviceFee ? _self.serviceFee : serviceFee // ignore: cast_nullable_to_non_nullable
as double,gatewayFee: null == gatewayFee ? _self.gatewayFee : gatewayFee // ignore: cast_nullable_to_non_nullable
as double,totalPaid: null == totalPaid ? _self.totalPaid : totalPaid // ignore: cast_nullable_to_non_nullable
as double,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,meterReadingId: freezed == meterReadingId ? _self.meterReadingId : meterReadingId // ignore: cast_nullable_to_non_nullable
as String?,invoiceId: freezed == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String?,isMeterSimulated: null == isMeterSimulated ? _self.isMeterSimulated : isMeterSimulated // ignore: cast_nullable_to_non_nullable
as bool,verificationLevel: freezed == verificationLevel ? _self.verificationLevel : verificationLevel // ignore: cast_nullable_to_non_nullable
as String?,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChargingSession].
extension ChargingSessionPatterns on ChargingSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChargingSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChargingSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChargingSession value)  $default,){
final _that = this;
switch (_that) {
case _ChargingSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChargingSession value)?  $default,){
final _that = this;
switch (_that) {
case _ChargingSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? reservationId,  String? consumerId,  String? hostId,  String? stationId,  String? stationName,  String? portId,  int startTimeMs,  int endTimeMs,  double startingMeterKwh,  double endingMeterKwh,  double verifiedKwhConsumed,  double energyCharge,  double serviceFee,  double gatewayFee,  double totalPaid,  String? status,  String? meterReadingId,  String? invoiceId,  bool isMeterSimulated,  String? verificationLevel,  String? serverUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChargingSession() when $default != null:
return $default(_that.id,_that.reservationId,_that.consumerId,_that.hostId,_that.stationId,_that.stationName,_that.portId,_that.startTimeMs,_that.endTimeMs,_that.startingMeterKwh,_that.endingMeterKwh,_that.verifiedKwhConsumed,_that.energyCharge,_that.serviceFee,_that.gatewayFee,_that.totalPaid,_that.status,_that.meterReadingId,_that.invoiceId,_that.isMeterSimulated,_that.verificationLevel,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? reservationId,  String? consumerId,  String? hostId,  String? stationId,  String? stationName,  String? portId,  int startTimeMs,  int endTimeMs,  double startingMeterKwh,  double endingMeterKwh,  double verifiedKwhConsumed,  double energyCharge,  double serviceFee,  double gatewayFee,  double totalPaid,  String? status,  String? meterReadingId,  String? invoiceId,  bool isMeterSimulated,  String? verificationLevel,  String? serverUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _ChargingSession():
return $default(_that.id,_that.reservationId,_that.consumerId,_that.hostId,_that.stationId,_that.stationName,_that.portId,_that.startTimeMs,_that.endTimeMs,_that.startingMeterKwh,_that.endingMeterKwh,_that.verifiedKwhConsumed,_that.energyCharge,_that.serviceFee,_that.gatewayFee,_that.totalPaid,_that.status,_that.meterReadingId,_that.invoiceId,_that.isMeterSimulated,_that.verificationLevel,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? reservationId,  String? consumerId,  String? hostId,  String? stationId,  String? stationName,  String? portId,  int startTimeMs,  int endTimeMs,  double startingMeterKwh,  double endingMeterKwh,  double verifiedKwhConsumed,  double energyCharge,  double serviceFee,  double gatewayFee,  double totalPaid,  String? status,  String? meterReadingId,  String? invoiceId,  bool isMeterSimulated,  String? verificationLevel,  String? serverUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ChargingSession() when $default != null:
return $default(_that.id,_that.reservationId,_that.consumerId,_that.hostId,_that.stationId,_that.stationName,_that.portId,_that.startTimeMs,_that.endTimeMs,_that.startingMeterKwh,_that.endingMeterKwh,_that.verifiedKwhConsumed,_that.energyCharge,_that.serviceFee,_that.gatewayFee,_that.totalPaid,_that.status,_that.meterReadingId,_that.invoiceId,_that.isMeterSimulated,_that.verificationLevel,_that.serverUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChargingSession implements ChargingSession {
  const _ChargingSession({required this.id, this.reservationId, this.consumerId, this.hostId, this.stationId, this.stationName, this.portId, this.startTimeMs = 0, this.endTimeMs = 0, this.startingMeterKwh = 0, this.endingMeterKwh = 0, this.verifiedKwhConsumed = 0, this.energyCharge = 0, this.serviceFee = 0, this.gatewayFee = 0, this.totalPaid = 0, this.status, this.meterReadingId, this.invoiceId, this.isMeterSimulated = false, this.verificationLevel, this.serverUpdatedAt});
  factory _ChargingSession.fromJson(Map<String, dynamic> json) => _$ChargingSessionFromJson(json);

@override final  String id;
@override final  String? reservationId;
@override final  String? consumerId;
@override final  String? hostId;
@override final  String? stationId;
@override final  String? stationName;
@override final  String? portId;
@override@JsonKey() final  int startTimeMs;
@override@JsonKey() final  int endTimeMs;
@override@JsonKey() final  double startingMeterKwh;
@override@JsonKey() final  double endingMeterKwh;
@override@JsonKey() final  double verifiedKwhConsumed;
@override@JsonKey() final  double energyCharge;
@override@JsonKey() final  double serviceFee;
@override@JsonKey() final  double gatewayFee;
@override@JsonKey() final  double totalPaid;
@override final  String? status;
@override final  String? meterReadingId;
@override final  String? invoiceId;
@override@JsonKey() final  bool isMeterSimulated;
@override final  String? verificationLevel;
@override final  String? serverUpdatedAt;

/// Create a copy of ChargingSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChargingSessionCopyWith<_ChargingSession> get copyWith => __$ChargingSessionCopyWithImpl<_ChargingSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChargingSessionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChargingSession&&(identical(other.id, id) || other.id == id)&&(identical(other.reservationId, reservationId) || other.reservationId == reservationId)&&(identical(other.consumerId, consumerId) || other.consumerId == consumerId)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.stationId, stationId) || other.stationId == stationId)&&(identical(other.stationName, stationName) || other.stationName == stationName)&&(identical(other.portId, portId) || other.portId == portId)&&(identical(other.startTimeMs, startTimeMs) || other.startTimeMs == startTimeMs)&&(identical(other.endTimeMs, endTimeMs) || other.endTimeMs == endTimeMs)&&(identical(other.startingMeterKwh, startingMeterKwh) || other.startingMeterKwh == startingMeterKwh)&&(identical(other.endingMeterKwh, endingMeterKwh) || other.endingMeterKwh == endingMeterKwh)&&(identical(other.verifiedKwhConsumed, verifiedKwhConsumed) || other.verifiedKwhConsumed == verifiedKwhConsumed)&&(identical(other.energyCharge, energyCharge) || other.energyCharge == energyCharge)&&(identical(other.serviceFee, serviceFee) || other.serviceFee == serviceFee)&&(identical(other.gatewayFee, gatewayFee) || other.gatewayFee == gatewayFee)&&(identical(other.totalPaid, totalPaid) || other.totalPaid == totalPaid)&&(identical(other.status, status) || other.status == status)&&(identical(other.meterReadingId, meterReadingId) || other.meterReadingId == meterReadingId)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.isMeterSimulated, isMeterSimulated) || other.isMeterSimulated == isMeterSimulated)&&(identical(other.verificationLevel, verificationLevel) || other.verificationLevel == verificationLevel)&&(identical(other.serverUpdatedAt, serverUpdatedAt) || other.serverUpdatedAt == serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,reservationId,consumerId,hostId,stationId,stationName,portId,startTimeMs,endTimeMs,startingMeterKwh,endingMeterKwh,verifiedKwhConsumed,energyCharge,serviceFee,gatewayFee,totalPaid,status,meterReadingId,invoiceId,isMeterSimulated,verificationLevel,serverUpdatedAt]);
}

@override
String toString() {
    return 'ChargingSession(id: $id, reservationId: $reservationId, consumerId: $consumerId, hostId: $hostId, stationId: $stationId, stationName: $stationName, portId: $portId, startTimeMs: $startTimeMs, endTimeMs: $endTimeMs, startingMeterKwh: $startingMeterKwh, endingMeterKwh: $endingMeterKwh, verifiedKwhConsumed: $verifiedKwhConsumed, energyCharge: $energyCharge, serviceFee: $serviceFee, gatewayFee: $gatewayFee, totalPaid: $totalPaid, status: $status, meterReadingId: $meterReadingId, invoiceId: $invoiceId, isMeterSimulated: $isMeterSimulated, verificationLevel: $verificationLevel, serverUpdatedAt: $serverUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$ChargingSessionCopyWith<$Res> implements $ChargingSessionCopyWith<$Res> {
  factory _$ChargingSessionCopyWith(_ChargingSession value, $Res Function(_ChargingSession) _then) = __$ChargingSessionCopyWithImpl;
@override @useResult
$Res call({
 String id, String? reservationId, String? consumerId, String? hostId, String? stationId, String? stationName, String? portId, int startTimeMs, int endTimeMs, double startingMeterKwh, double endingMeterKwh, double verifiedKwhConsumed, double energyCharge, double serviceFee, double gatewayFee, double totalPaid, String? status, String? meterReadingId, String? invoiceId, bool isMeterSimulated, String? verificationLevel, String? serverUpdatedAt
});




}
/// @nodoc
class __$ChargingSessionCopyWithImpl<$Res>
    implements _$ChargingSessionCopyWith<$Res> {
  __$ChargingSessionCopyWithImpl(this._self, this._then);

  final _ChargingSession _self;
  final $Res Function(_ChargingSession) _then;

/// Create a copy of ChargingSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reservationId = freezed,Object? consumerId = freezed,Object? hostId = freezed,Object? stationId = freezed,Object? stationName = freezed,Object? portId = freezed,Object? startTimeMs = null,Object? endTimeMs = null,Object? startingMeterKwh = null,Object? endingMeterKwh = null,Object? verifiedKwhConsumed = null,Object? energyCharge = null,Object? serviceFee = null,Object? gatewayFee = null,Object? totalPaid = null,Object? status = freezed,Object? meterReadingId = freezed,Object? invoiceId = freezed,Object? isMeterSimulated = null,Object? verificationLevel = freezed,Object? serverUpdatedAt = freezed,}) {
  return _then(_ChargingSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reservationId: freezed == reservationId ? _self.reservationId : reservationId // ignore: cast_nullable_to_non_nullable
as String?,consumerId: freezed == consumerId ? _self.consumerId : consumerId // ignore: cast_nullable_to_non_nullable
as String?,hostId: freezed == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String?,stationId: freezed == stationId ? _self.stationId : stationId // ignore: cast_nullable_to_non_nullable
as String?,stationName: freezed == stationName ? _self.stationName : stationName // ignore: cast_nullable_to_non_nullable
as String?,portId: freezed == portId ? _self.portId : portId // ignore: cast_nullable_to_non_nullable
as String?,startTimeMs: null == startTimeMs ? _self.startTimeMs : startTimeMs // ignore: cast_nullable_to_non_nullable
as int,endTimeMs: null == endTimeMs ? _self.endTimeMs : endTimeMs // ignore: cast_nullable_to_non_nullable
as int,startingMeterKwh: null == startingMeterKwh ? _self.startingMeterKwh : startingMeterKwh // ignore: cast_nullable_to_non_nullable
as double,endingMeterKwh: null == endingMeterKwh ? _self.endingMeterKwh : endingMeterKwh // ignore: cast_nullable_to_non_nullable
as double,verifiedKwhConsumed: null == verifiedKwhConsumed ? _self.verifiedKwhConsumed : verifiedKwhConsumed // ignore: cast_nullable_to_non_nullable
as double,energyCharge: null == energyCharge ? _self.energyCharge : energyCharge // ignore: cast_nullable_to_non_nullable
as double,serviceFee: null == serviceFee ? _self.serviceFee : serviceFee // ignore: cast_nullable_to_non_nullable
as double,gatewayFee: null == gatewayFee ? _self.gatewayFee : gatewayFee // ignore: cast_nullable_to_non_nullable
as double,totalPaid: null == totalPaid ? _self.totalPaid : totalPaid // ignore: cast_nullable_to_non_nullable
as double,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,meterReadingId: freezed == meterReadingId ? _self.meterReadingId : meterReadingId // ignore: cast_nullable_to_non_nullable
as String?,invoiceId: freezed == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String?,isMeterSimulated: null == isMeterSimulated ? _self.isMeterSimulated : isMeterSimulated // ignore: cast_nullable_to_non_nullable
as bool,verificationLevel: freezed == verificationLevel ? _self.verificationLevel : verificationLevel // ignore: cast_nullable_to_non_nullable
as String?,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MeterReading {

 String get id; String? get sessionId; String? get stationId; double get startMeterKwh; double get endMeterKwh; String? get photoEvidenceUri; String? get verificationLevel; int get timestampMs; bool get isSimulated; String? get serverUpdatedAt;
/// Create a copy of MeterReading
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeterReadingCopyWith<MeterReading> get copyWith => _$MeterReadingCopyWithImpl<MeterReading>(this as MeterReading, _$identity);

  /// Serializes this MeterReading to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MeterReading;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeterReading&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId)&&(identical(other.stationId, _this.stationId) || other.stationId == _this.stationId)&&(identical(other.startMeterKwh, _this.startMeterKwh) || other.startMeterKwh == _this.startMeterKwh)&&(identical(other.endMeterKwh, _this.endMeterKwh) || other.endMeterKwh == _this.endMeterKwh)&&(identical(other.photoEvidenceUri, _this.photoEvidenceUri) || other.photoEvidenceUri == _this.photoEvidenceUri)&&(identical(other.verificationLevel, _this.verificationLevel) || other.verificationLevel == _this.verificationLevel)&&(identical(other.timestampMs, _this.timestampMs) || other.timestampMs == _this.timestampMs)&&(identical(other.isSimulated, _this.isSimulated) || other.isSimulated == _this.isSimulated)&&(identical(other.serverUpdatedAt, _this.serverUpdatedAt) || other.serverUpdatedAt == _this.serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MeterReading;
  return Object.hash(runtimeType,_this.id,_this.sessionId,_this.stationId,_this.startMeterKwh,_this.endMeterKwh,_this.photoEvidenceUri,_this.verificationLevel,_this.timestampMs,_this.isSimulated,_this.serverUpdatedAt);
}

@override
String toString() {
  final _this = this as MeterReading;
  return 'MeterReading(id: ${_this.id}, sessionId: ${_this.sessionId}, stationId: ${_this.stationId}, startMeterKwh: ${_this.startMeterKwh}, endMeterKwh: ${_this.endMeterKwh}, photoEvidenceUri: ${_this.photoEvidenceUri}, verificationLevel: ${_this.verificationLevel}, timestampMs: ${_this.timestampMs}, isSimulated: ${_this.isSimulated}, serverUpdatedAt: ${_this.serverUpdatedAt})';
}


}

/// @nodoc
abstract mixin class $MeterReadingCopyWith<$Res>  {
  factory $MeterReadingCopyWith(MeterReading value, $Res Function(MeterReading) _then) = _$MeterReadingCopyWithImpl;
@useResult
$Res call({
 String id, String? sessionId, String? stationId, double startMeterKwh, double endMeterKwh, String? photoEvidenceUri, String? verificationLevel, int timestampMs, bool isSimulated, String? serverUpdatedAt
});




}
/// @nodoc
class _$MeterReadingCopyWithImpl<$Res>
    implements $MeterReadingCopyWith<$Res> {
  _$MeterReadingCopyWithImpl(this._self, this._then);

  final MeterReading _self;
  final $Res Function(MeterReading) _then;

/// Create a copy of MeterReading
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sessionId = freezed,Object? stationId = freezed,Object? startMeterKwh = null,Object? endMeterKwh = null,Object? photoEvidenceUri = freezed,Object? verificationLevel = freezed,Object? timestampMs = null,Object? isSimulated = null,Object? serverUpdatedAt = freezed,}) {
  return _then(MeterReading(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,stationId: freezed == stationId ? _self.stationId : stationId // ignore: cast_nullable_to_non_nullable
as String?,startMeterKwh: null == startMeterKwh ? _self.startMeterKwh : startMeterKwh // ignore: cast_nullable_to_non_nullable
as double,endMeterKwh: null == endMeterKwh ? _self.endMeterKwh : endMeterKwh // ignore: cast_nullable_to_non_nullable
as double,photoEvidenceUri: freezed == photoEvidenceUri ? _self.photoEvidenceUri : photoEvidenceUri // ignore: cast_nullable_to_non_nullable
as String?,verificationLevel: freezed == verificationLevel ? _self.verificationLevel : verificationLevel // ignore: cast_nullable_to_non_nullable
as String?,timestampMs: null == timestampMs ? _self.timestampMs : timestampMs // ignore: cast_nullable_to_non_nullable
as int,isSimulated: null == isSimulated ? _self.isSimulated : isSimulated // ignore: cast_nullable_to_non_nullable
as bool,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MeterReading].
extension MeterReadingPatterns on MeterReading {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeterReading value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeterReading() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeterReading value)  $default,){
final _that = this;
switch (_that) {
case _MeterReading():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeterReading value)?  $default,){
final _that = this;
switch (_that) {
case _MeterReading() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? sessionId,  String? stationId,  double startMeterKwh,  double endMeterKwh,  String? photoEvidenceUri,  String? verificationLevel,  int timestampMs,  bool isSimulated,  String? serverUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeterReading() when $default != null:
return $default(_that.id,_that.sessionId,_that.stationId,_that.startMeterKwh,_that.endMeterKwh,_that.photoEvidenceUri,_that.verificationLevel,_that.timestampMs,_that.isSimulated,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? sessionId,  String? stationId,  double startMeterKwh,  double endMeterKwh,  String? photoEvidenceUri,  String? verificationLevel,  int timestampMs,  bool isSimulated,  String? serverUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _MeterReading():
return $default(_that.id,_that.sessionId,_that.stationId,_that.startMeterKwh,_that.endMeterKwh,_that.photoEvidenceUri,_that.verificationLevel,_that.timestampMs,_that.isSimulated,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? sessionId,  String? stationId,  double startMeterKwh,  double endMeterKwh,  String? photoEvidenceUri,  String? verificationLevel,  int timestampMs,  bool isSimulated,  String? serverUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MeterReading() when $default != null:
return $default(_that.id,_that.sessionId,_that.stationId,_that.startMeterKwh,_that.endMeterKwh,_that.photoEvidenceUri,_that.verificationLevel,_that.timestampMs,_that.isSimulated,_that.serverUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MeterReading implements MeterReading {
  const _MeterReading({required this.id, this.sessionId, this.stationId, this.startMeterKwh = 0, this.endMeterKwh = 0, this.photoEvidenceUri, this.verificationLevel, this.timestampMs = 0, this.isSimulated = false, this.serverUpdatedAt});
  factory _MeterReading.fromJson(Map<String, dynamic> json) => _$MeterReadingFromJson(json);

@override final  String id;
@override final  String? sessionId;
@override final  String? stationId;
@override@JsonKey() final  double startMeterKwh;
@override@JsonKey() final  double endMeterKwh;
@override final  String? photoEvidenceUri;
@override final  String? verificationLevel;
@override@JsonKey() final  int timestampMs;
@override@JsonKey() final  bool isSimulated;
@override final  String? serverUpdatedAt;

/// Create a copy of MeterReading
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeterReadingCopyWith<_MeterReading> get copyWith => __$MeterReadingCopyWithImpl<_MeterReading>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeterReadingToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeterReading&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.stationId, stationId) || other.stationId == stationId)&&(identical(other.startMeterKwh, startMeterKwh) || other.startMeterKwh == startMeterKwh)&&(identical(other.endMeterKwh, endMeterKwh) || other.endMeterKwh == endMeterKwh)&&(identical(other.photoEvidenceUri, photoEvidenceUri) || other.photoEvidenceUri == photoEvidenceUri)&&(identical(other.verificationLevel, verificationLevel) || other.verificationLevel == verificationLevel)&&(identical(other.timestampMs, timestampMs) || other.timestampMs == timestampMs)&&(identical(other.isSimulated, isSimulated) || other.isSimulated == isSimulated)&&(identical(other.serverUpdatedAt, serverUpdatedAt) || other.serverUpdatedAt == serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,sessionId,stationId,startMeterKwh,endMeterKwh,photoEvidenceUri,verificationLevel,timestampMs,isSimulated,serverUpdatedAt);
}

@override
String toString() {
    return 'MeterReading(id: $id, sessionId: $sessionId, stationId: $stationId, startMeterKwh: $startMeterKwh, endMeterKwh: $endMeterKwh, photoEvidenceUri: $photoEvidenceUri, verificationLevel: $verificationLevel, timestampMs: $timestampMs, isSimulated: $isSimulated, serverUpdatedAt: $serverUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$MeterReadingCopyWith<$Res> implements $MeterReadingCopyWith<$Res> {
  factory _$MeterReadingCopyWith(_MeterReading value, $Res Function(_MeterReading) _then) = __$MeterReadingCopyWithImpl;
@override @useResult
$Res call({
 String id, String? sessionId, String? stationId, double startMeterKwh, double endMeterKwh, String? photoEvidenceUri, String? verificationLevel, int timestampMs, bool isSimulated, String? serverUpdatedAt
});




}
/// @nodoc
class __$MeterReadingCopyWithImpl<$Res>
    implements _$MeterReadingCopyWith<$Res> {
  __$MeterReadingCopyWithImpl(this._self, this._then);

  final _MeterReading _self;
  final $Res Function(_MeterReading) _then;

/// Create a copy of MeterReading
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sessionId = freezed,Object? stationId = freezed,Object? startMeterKwh = null,Object? endMeterKwh = null,Object? photoEvidenceUri = freezed,Object? verificationLevel = freezed,Object? timestampMs = null,Object? isSimulated = null,Object? serverUpdatedAt = freezed,}) {
  return _then(_MeterReading(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,stationId: freezed == stationId ? _self.stationId : stationId // ignore: cast_nullable_to_non_nullable
as String?,startMeterKwh: null == startMeterKwh ? _self.startMeterKwh : startMeterKwh // ignore: cast_nullable_to_non_nullable
as double,endMeterKwh: null == endMeterKwh ? _self.endMeterKwh : endMeterKwh // ignore: cast_nullable_to_non_nullable
as double,photoEvidenceUri: freezed == photoEvidenceUri ? _self.photoEvidenceUri : photoEvidenceUri // ignore: cast_nullable_to_non_nullable
as String?,verificationLevel: freezed == verificationLevel ? _self.verificationLevel : verificationLevel // ignore: cast_nullable_to_non_nullable
as String?,timestampMs: null == timestampMs ? _self.timestampMs : timestampMs // ignore: cast_nullable_to_non_nullable
as int,isSimulated: null == isSimulated ? _self.isSimulated : isSimulated // ignore: cast_nullable_to_non_nullable
as bool,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Invoice {

 String get id; String? get sessionId; String? get consumerId; String? get hostId; String? get stationName; double get verifiedKwh; double get energyCharge; double get serviceFee; double get gatewayFee; double get adjustment; String? get adjustmentNote; double get finalTotal; String? get paymentId; String? get status; int get issuedAtMs; String? get serverUpdatedAt;
/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceCopyWith<Invoice> get copyWith => _$InvoiceCopyWithImpl<Invoice>(this as Invoice, _$identity);

  /// Serializes this Invoice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Invoice;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Invoice&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId)&&(identical(other.consumerId, _this.consumerId) || other.consumerId == _this.consumerId)&&(identical(other.hostId, _this.hostId) || other.hostId == _this.hostId)&&(identical(other.stationName, _this.stationName) || other.stationName == _this.stationName)&&(identical(other.verifiedKwh, _this.verifiedKwh) || other.verifiedKwh == _this.verifiedKwh)&&(identical(other.energyCharge, _this.energyCharge) || other.energyCharge == _this.energyCharge)&&(identical(other.serviceFee, _this.serviceFee) || other.serviceFee == _this.serviceFee)&&(identical(other.gatewayFee, _this.gatewayFee) || other.gatewayFee == _this.gatewayFee)&&(identical(other.adjustment, _this.adjustment) || other.adjustment == _this.adjustment)&&(identical(other.adjustmentNote, _this.adjustmentNote) || other.adjustmentNote == _this.adjustmentNote)&&(identical(other.finalTotal, _this.finalTotal) || other.finalTotal == _this.finalTotal)&&(identical(other.paymentId, _this.paymentId) || other.paymentId == _this.paymentId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.issuedAtMs, _this.issuedAtMs) || other.issuedAtMs == _this.issuedAtMs)&&(identical(other.serverUpdatedAt, _this.serverUpdatedAt) || other.serverUpdatedAt == _this.serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Invoice;
  return Object.hash(runtimeType,_this.id,_this.sessionId,_this.consumerId,_this.hostId,_this.stationName,_this.verifiedKwh,_this.energyCharge,_this.serviceFee,_this.gatewayFee,_this.adjustment,_this.adjustmentNote,_this.finalTotal,_this.paymentId,_this.status,_this.issuedAtMs,_this.serverUpdatedAt);
}

@override
String toString() {
  final _this = this as Invoice;
  return 'Invoice(id: ${_this.id}, sessionId: ${_this.sessionId}, consumerId: ${_this.consumerId}, hostId: ${_this.hostId}, stationName: ${_this.stationName}, verifiedKwh: ${_this.verifiedKwh}, energyCharge: ${_this.energyCharge}, serviceFee: ${_this.serviceFee}, gatewayFee: ${_this.gatewayFee}, adjustment: ${_this.adjustment}, adjustmentNote: ${_this.adjustmentNote}, finalTotal: ${_this.finalTotal}, paymentId: ${_this.paymentId}, status: ${_this.status}, issuedAtMs: ${_this.issuedAtMs}, serverUpdatedAt: ${_this.serverUpdatedAt})';
}


}

/// @nodoc
abstract mixin class $InvoiceCopyWith<$Res>  {
  factory $InvoiceCopyWith(Invoice value, $Res Function(Invoice) _then) = _$InvoiceCopyWithImpl;
@useResult
$Res call({
 String id, String? sessionId, String? consumerId, String? hostId, String? stationName, double verifiedKwh, double energyCharge, double serviceFee, double gatewayFee, double adjustment, String? adjustmentNote, double finalTotal, String? paymentId, String? status, int issuedAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class _$InvoiceCopyWithImpl<$Res>
    implements $InvoiceCopyWith<$Res> {
  _$InvoiceCopyWithImpl(this._self, this._then);

  final Invoice _self;
  final $Res Function(Invoice) _then;

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sessionId = freezed,Object? consumerId = freezed,Object? hostId = freezed,Object? stationName = freezed,Object? verifiedKwh = null,Object? energyCharge = null,Object? serviceFee = null,Object? gatewayFee = null,Object? adjustment = null,Object? adjustmentNote = freezed,Object? finalTotal = null,Object? paymentId = freezed,Object? status = freezed,Object? issuedAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(Invoice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,consumerId: freezed == consumerId ? _self.consumerId : consumerId // ignore: cast_nullable_to_non_nullable
as String?,hostId: freezed == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String?,stationName: freezed == stationName ? _self.stationName : stationName // ignore: cast_nullable_to_non_nullable
as String?,verifiedKwh: null == verifiedKwh ? _self.verifiedKwh : verifiedKwh // ignore: cast_nullable_to_non_nullable
as double,energyCharge: null == energyCharge ? _self.energyCharge : energyCharge // ignore: cast_nullable_to_non_nullable
as double,serviceFee: null == serviceFee ? _self.serviceFee : serviceFee // ignore: cast_nullable_to_non_nullable
as double,gatewayFee: null == gatewayFee ? _self.gatewayFee : gatewayFee // ignore: cast_nullable_to_non_nullable
as double,adjustment: null == adjustment ? _self.adjustment : adjustment // ignore: cast_nullable_to_non_nullable
as double,adjustmentNote: freezed == adjustmentNote ? _self.adjustmentNote : adjustmentNote // ignore: cast_nullable_to_non_nullable
as String?,finalTotal: null == finalTotal ? _self.finalTotal : finalTotal // ignore: cast_nullable_to_non_nullable
as double,paymentId: freezed == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,issuedAtMs: null == issuedAtMs ? _self.issuedAtMs : issuedAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Invoice].
extension InvoicePatterns on Invoice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Invoice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Invoice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Invoice value)  $default,){
final _that = this;
switch (_that) {
case _Invoice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Invoice value)?  $default,){
final _that = this;
switch (_that) {
case _Invoice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? sessionId,  String? consumerId,  String? hostId,  String? stationName,  double verifiedKwh,  double energyCharge,  double serviceFee,  double gatewayFee,  double adjustment,  String? adjustmentNote,  double finalTotal,  String? paymentId,  String? status,  int issuedAtMs,  String? serverUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Invoice() when $default != null:
return $default(_that.id,_that.sessionId,_that.consumerId,_that.hostId,_that.stationName,_that.verifiedKwh,_that.energyCharge,_that.serviceFee,_that.gatewayFee,_that.adjustment,_that.adjustmentNote,_that.finalTotal,_that.paymentId,_that.status,_that.issuedAtMs,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? sessionId,  String? consumerId,  String? hostId,  String? stationName,  double verifiedKwh,  double energyCharge,  double serviceFee,  double gatewayFee,  double adjustment,  String? adjustmentNote,  double finalTotal,  String? paymentId,  String? status,  int issuedAtMs,  String? serverUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _Invoice():
return $default(_that.id,_that.sessionId,_that.consumerId,_that.hostId,_that.stationName,_that.verifiedKwh,_that.energyCharge,_that.serviceFee,_that.gatewayFee,_that.adjustment,_that.adjustmentNote,_that.finalTotal,_that.paymentId,_that.status,_that.issuedAtMs,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? sessionId,  String? consumerId,  String? hostId,  String? stationName,  double verifiedKwh,  double energyCharge,  double serviceFee,  double gatewayFee,  double adjustment,  String? adjustmentNote,  double finalTotal,  String? paymentId,  String? status,  int issuedAtMs,  String? serverUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Invoice() when $default != null:
return $default(_that.id,_that.sessionId,_that.consumerId,_that.hostId,_that.stationName,_that.verifiedKwh,_that.energyCharge,_that.serviceFee,_that.gatewayFee,_that.adjustment,_that.adjustmentNote,_that.finalTotal,_that.paymentId,_that.status,_that.issuedAtMs,_that.serverUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Invoice implements Invoice {
  const _Invoice({required this.id, this.sessionId, this.consumerId, this.hostId, this.stationName, this.verifiedKwh = 0, this.energyCharge = 0, this.serviceFee = 0, this.gatewayFee = 0, this.adjustment = 0, this.adjustmentNote, this.finalTotal = 0, this.paymentId, this.status, this.issuedAtMs = 0, this.serverUpdatedAt});
  factory _Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);

@override final  String id;
@override final  String? sessionId;
@override final  String? consumerId;
@override final  String? hostId;
@override final  String? stationName;
@override@JsonKey() final  double verifiedKwh;
@override@JsonKey() final  double energyCharge;
@override@JsonKey() final  double serviceFee;
@override@JsonKey() final  double gatewayFee;
@override@JsonKey() final  double adjustment;
@override final  String? adjustmentNote;
@override@JsonKey() final  double finalTotal;
@override final  String? paymentId;
@override final  String? status;
@override@JsonKey() final  int issuedAtMs;
@override final  String? serverUpdatedAt;

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceCopyWith<_Invoice> get copyWith => __$InvoiceCopyWithImpl<_Invoice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvoiceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Invoice&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.consumerId, consumerId) || other.consumerId == consumerId)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.stationName, stationName) || other.stationName == stationName)&&(identical(other.verifiedKwh, verifiedKwh) || other.verifiedKwh == verifiedKwh)&&(identical(other.energyCharge, energyCharge) || other.energyCharge == energyCharge)&&(identical(other.serviceFee, serviceFee) || other.serviceFee == serviceFee)&&(identical(other.gatewayFee, gatewayFee) || other.gatewayFee == gatewayFee)&&(identical(other.adjustment, adjustment) || other.adjustment == adjustment)&&(identical(other.adjustmentNote, adjustmentNote) || other.adjustmentNote == adjustmentNote)&&(identical(other.finalTotal, finalTotal) || other.finalTotal == finalTotal)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.status, status) || other.status == status)&&(identical(other.issuedAtMs, issuedAtMs) || other.issuedAtMs == issuedAtMs)&&(identical(other.serverUpdatedAt, serverUpdatedAt) || other.serverUpdatedAt == serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,sessionId,consumerId,hostId,stationName,verifiedKwh,energyCharge,serviceFee,gatewayFee,adjustment,adjustmentNote,finalTotal,paymentId,status,issuedAtMs,serverUpdatedAt);
}

@override
String toString() {
    return 'Invoice(id: $id, sessionId: $sessionId, consumerId: $consumerId, hostId: $hostId, stationName: $stationName, verifiedKwh: $verifiedKwh, energyCharge: $energyCharge, serviceFee: $serviceFee, gatewayFee: $gatewayFee, adjustment: $adjustment, adjustmentNote: $adjustmentNote, finalTotal: $finalTotal, paymentId: $paymentId, status: $status, issuedAtMs: $issuedAtMs, serverUpdatedAt: $serverUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$InvoiceCopyWith<$Res> implements $InvoiceCopyWith<$Res> {
  factory _$InvoiceCopyWith(_Invoice value, $Res Function(_Invoice) _then) = __$InvoiceCopyWithImpl;
@override @useResult
$Res call({
 String id, String? sessionId, String? consumerId, String? hostId, String? stationName, double verifiedKwh, double energyCharge, double serviceFee, double gatewayFee, double adjustment, String? adjustmentNote, double finalTotal, String? paymentId, String? status, int issuedAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class __$InvoiceCopyWithImpl<$Res>
    implements _$InvoiceCopyWith<$Res> {
  __$InvoiceCopyWithImpl(this._self, this._then);

  final _Invoice _self;
  final $Res Function(_Invoice) _then;

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sessionId = freezed,Object? consumerId = freezed,Object? hostId = freezed,Object? stationName = freezed,Object? verifiedKwh = null,Object? energyCharge = null,Object? serviceFee = null,Object? gatewayFee = null,Object? adjustment = null,Object? adjustmentNote = freezed,Object? finalTotal = null,Object? paymentId = freezed,Object? status = freezed,Object? issuedAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(_Invoice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,consumerId: freezed == consumerId ? _self.consumerId : consumerId // ignore: cast_nullable_to_non_nullable
as String?,hostId: freezed == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String?,stationName: freezed == stationName ? _self.stationName : stationName // ignore: cast_nullable_to_non_nullable
as String?,verifiedKwh: null == verifiedKwh ? _self.verifiedKwh : verifiedKwh // ignore: cast_nullable_to_non_nullable
as double,energyCharge: null == energyCharge ? _self.energyCharge : energyCharge // ignore: cast_nullable_to_non_nullable
as double,serviceFee: null == serviceFee ? _self.serviceFee : serviceFee // ignore: cast_nullable_to_non_nullable
as double,gatewayFee: null == gatewayFee ? _self.gatewayFee : gatewayFee // ignore: cast_nullable_to_non_nullable
as double,adjustment: null == adjustment ? _self.adjustment : adjustment // ignore: cast_nullable_to_non_nullable
as double,adjustmentNote: freezed == adjustmentNote ? _self.adjustmentNote : adjustmentNote // ignore: cast_nullable_to_non_nullable
as String?,finalTotal: null == finalTotal ? _self.finalTotal : finalTotal // ignore: cast_nullable_to_non_nullable
as double,paymentId: freezed == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,issuedAtMs: null == issuedAtMs ? _self.issuedAtMs : issuedAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Payment {

 String get id; String? get reservationId; String? get sessionId; String? get consumerId; String? get hostId; String? get idempotencyKey; String? get gateway; String? get gatewayReference; double get authorizedAmount; double get capturedAmount; double get refundedAmount; double get lateCancellationFee; String? get status; String? get failureReason; int get createdAtMs; int get updatedAtMs; String? get serverUpdatedAt;
/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentCopyWith<Payment> get copyWith => _$PaymentCopyWithImpl<Payment>(this as Payment, _$identity);

  /// Serializes this Payment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Payment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Payment&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.reservationId, _this.reservationId) || other.reservationId == _this.reservationId)&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId)&&(identical(other.consumerId, _this.consumerId) || other.consumerId == _this.consumerId)&&(identical(other.hostId, _this.hostId) || other.hostId == _this.hostId)&&(identical(other.idempotencyKey, _this.idempotencyKey) || other.idempotencyKey == _this.idempotencyKey)&&(identical(other.gateway, _this.gateway) || other.gateway == _this.gateway)&&(identical(other.gatewayReference, _this.gatewayReference) || other.gatewayReference == _this.gatewayReference)&&(identical(other.authorizedAmount, _this.authorizedAmount) || other.authorizedAmount == _this.authorizedAmount)&&(identical(other.capturedAmount, _this.capturedAmount) || other.capturedAmount == _this.capturedAmount)&&(identical(other.refundedAmount, _this.refundedAmount) || other.refundedAmount == _this.refundedAmount)&&(identical(other.lateCancellationFee, _this.lateCancellationFee) || other.lateCancellationFee == _this.lateCancellationFee)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.failureReason, _this.failureReason) || other.failureReason == _this.failureReason)&&(identical(other.createdAtMs, _this.createdAtMs) || other.createdAtMs == _this.createdAtMs)&&(identical(other.updatedAtMs, _this.updatedAtMs) || other.updatedAtMs == _this.updatedAtMs)&&(identical(other.serverUpdatedAt, _this.serverUpdatedAt) || other.serverUpdatedAt == _this.serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Payment;
  return Object.hash(runtimeType,_this.id,_this.reservationId,_this.sessionId,_this.consumerId,_this.hostId,_this.idempotencyKey,_this.gateway,_this.gatewayReference,_this.authorizedAmount,_this.capturedAmount,_this.refundedAmount,_this.lateCancellationFee,_this.status,_this.failureReason,_this.createdAtMs,_this.updatedAtMs,_this.serverUpdatedAt);
}

@override
String toString() {
  final _this = this as Payment;
  return 'Payment(id: ${_this.id}, reservationId: ${_this.reservationId}, sessionId: ${_this.sessionId}, consumerId: ${_this.consumerId}, hostId: ${_this.hostId}, idempotencyKey: ${_this.idempotencyKey}, gateway: ${_this.gateway}, gatewayReference: ${_this.gatewayReference}, authorizedAmount: ${_this.authorizedAmount}, capturedAmount: ${_this.capturedAmount}, refundedAmount: ${_this.refundedAmount}, lateCancellationFee: ${_this.lateCancellationFee}, status: ${_this.status}, failureReason: ${_this.failureReason}, createdAtMs: ${_this.createdAtMs}, updatedAtMs: ${_this.updatedAtMs}, serverUpdatedAt: ${_this.serverUpdatedAt})';
}


}

/// @nodoc
abstract mixin class $PaymentCopyWith<$Res>  {
  factory $PaymentCopyWith(Payment value, $Res Function(Payment) _then) = _$PaymentCopyWithImpl;
@useResult
$Res call({
 String id, String? reservationId, String? sessionId, String? consumerId, String? hostId, String? idempotencyKey, String? gateway, String? gatewayReference, double authorizedAmount, double capturedAmount, double refundedAmount, double lateCancellationFee, String? status, String? failureReason, int createdAtMs, int updatedAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class _$PaymentCopyWithImpl<$Res>
    implements $PaymentCopyWith<$Res> {
  _$PaymentCopyWithImpl(this._self, this._then);

  final Payment _self;
  final $Res Function(Payment) _then;

/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reservationId = freezed,Object? sessionId = freezed,Object? consumerId = freezed,Object? hostId = freezed,Object? idempotencyKey = freezed,Object? gateway = freezed,Object? gatewayReference = freezed,Object? authorizedAmount = null,Object? capturedAmount = null,Object? refundedAmount = null,Object? lateCancellationFee = null,Object? status = freezed,Object? failureReason = freezed,Object? createdAtMs = null,Object? updatedAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(Payment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reservationId: freezed == reservationId ? _self.reservationId : reservationId // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,consumerId: freezed == consumerId ? _self.consumerId : consumerId // ignore: cast_nullable_to_non_nullable
as String?,hostId: freezed == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String?,idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,gateway: freezed == gateway ? _self.gateway : gateway // ignore: cast_nullable_to_non_nullable
as String?,gatewayReference: freezed == gatewayReference ? _self.gatewayReference : gatewayReference // ignore: cast_nullable_to_non_nullable
as String?,authorizedAmount: null == authorizedAmount ? _self.authorizedAmount : authorizedAmount // ignore: cast_nullable_to_non_nullable
as double,capturedAmount: null == capturedAmount ? _self.capturedAmount : capturedAmount // ignore: cast_nullable_to_non_nullable
as double,refundedAmount: null == refundedAmount ? _self.refundedAmount : refundedAmount // ignore: cast_nullable_to_non_nullable
as double,lateCancellationFee: null == lateCancellationFee ? _self.lateCancellationFee : lateCancellationFee // ignore: cast_nullable_to_non_nullable
as double,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Payment].
extension PaymentPatterns on Payment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Payment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Payment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Payment value)  $default,){
final _that = this;
switch (_that) {
case _Payment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Payment value)?  $default,){
final _that = this;
switch (_that) {
case _Payment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? reservationId,  String? sessionId,  String? consumerId,  String? hostId,  String? idempotencyKey,  String? gateway,  String? gatewayReference,  double authorizedAmount,  double capturedAmount,  double refundedAmount,  double lateCancellationFee,  String? status,  String? failureReason,  int createdAtMs,  int updatedAtMs,  String? serverUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Payment() when $default != null:
return $default(_that.id,_that.reservationId,_that.sessionId,_that.consumerId,_that.hostId,_that.idempotencyKey,_that.gateway,_that.gatewayReference,_that.authorizedAmount,_that.capturedAmount,_that.refundedAmount,_that.lateCancellationFee,_that.status,_that.failureReason,_that.createdAtMs,_that.updatedAtMs,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? reservationId,  String? sessionId,  String? consumerId,  String? hostId,  String? idempotencyKey,  String? gateway,  String? gatewayReference,  double authorizedAmount,  double capturedAmount,  double refundedAmount,  double lateCancellationFee,  String? status,  String? failureReason,  int createdAtMs,  int updatedAtMs,  String? serverUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _Payment():
return $default(_that.id,_that.reservationId,_that.sessionId,_that.consumerId,_that.hostId,_that.idempotencyKey,_that.gateway,_that.gatewayReference,_that.authorizedAmount,_that.capturedAmount,_that.refundedAmount,_that.lateCancellationFee,_that.status,_that.failureReason,_that.createdAtMs,_that.updatedAtMs,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? reservationId,  String? sessionId,  String? consumerId,  String? hostId,  String? idempotencyKey,  String? gateway,  String? gatewayReference,  double authorizedAmount,  double capturedAmount,  double refundedAmount,  double lateCancellationFee,  String? status,  String? failureReason,  int createdAtMs,  int updatedAtMs,  String? serverUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Payment() when $default != null:
return $default(_that.id,_that.reservationId,_that.sessionId,_that.consumerId,_that.hostId,_that.idempotencyKey,_that.gateway,_that.gatewayReference,_that.authorizedAmount,_that.capturedAmount,_that.refundedAmount,_that.lateCancellationFee,_that.status,_that.failureReason,_that.createdAtMs,_that.updatedAtMs,_that.serverUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Payment implements Payment {
  const _Payment({required this.id, this.reservationId, this.sessionId, this.consumerId, this.hostId, this.idempotencyKey, this.gateway, this.gatewayReference, this.authorizedAmount = 0, this.capturedAmount = 0, this.refundedAmount = 0, this.lateCancellationFee = 0, this.status, this.failureReason, this.createdAtMs = 0, this.updatedAtMs = 0, this.serverUpdatedAt});
  factory _Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);

@override final  String id;
@override final  String? reservationId;
@override final  String? sessionId;
@override final  String? consumerId;
@override final  String? hostId;
@override final  String? idempotencyKey;
@override final  String? gateway;
@override final  String? gatewayReference;
@override@JsonKey() final  double authorizedAmount;
@override@JsonKey() final  double capturedAmount;
@override@JsonKey() final  double refundedAmount;
@override@JsonKey() final  double lateCancellationFee;
@override final  String? status;
@override final  String? failureReason;
@override@JsonKey() final  int createdAtMs;
@override@JsonKey() final  int updatedAtMs;
@override final  String? serverUpdatedAt;

/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentCopyWith<_Payment> get copyWith => __$PaymentCopyWithImpl<_Payment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Payment&&(identical(other.id, id) || other.id == id)&&(identical(other.reservationId, reservationId) || other.reservationId == reservationId)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.consumerId, consumerId) || other.consumerId == consumerId)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey)&&(identical(other.gateway, gateway) || other.gateway == gateway)&&(identical(other.gatewayReference, gatewayReference) || other.gatewayReference == gatewayReference)&&(identical(other.authorizedAmount, authorizedAmount) || other.authorizedAmount == authorizedAmount)&&(identical(other.capturedAmount, capturedAmount) || other.capturedAmount == capturedAmount)&&(identical(other.refundedAmount, refundedAmount) || other.refundedAmount == refundedAmount)&&(identical(other.lateCancellationFee, lateCancellationFee) || other.lateCancellationFee == lateCancellationFee)&&(identical(other.status, status) || other.status == status)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs)&&(identical(other.serverUpdatedAt, serverUpdatedAt) || other.serverUpdatedAt == serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,reservationId,sessionId,consumerId,hostId,idempotencyKey,gateway,gatewayReference,authorizedAmount,capturedAmount,refundedAmount,lateCancellationFee,status,failureReason,createdAtMs,updatedAtMs,serverUpdatedAt);
}

@override
String toString() {
    return 'Payment(id: $id, reservationId: $reservationId, sessionId: $sessionId, consumerId: $consumerId, hostId: $hostId, idempotencyKey: $idempotencyKey, gateway: $gateway, gatewayReference: $gatewayReference, authorizedAmount: $authorizedAmount, capturedAmount: $capturedAmount, refundedAmount: $refundedAmount, lateCancellationFee: $lateCancellationFee, status: $status, failureReason: $failureReason, createdAtMs: $createdAtMs, updatedAtMs: $updatedAtMs, serverUpdatedAt: $serverUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$PaymentCopyWith<$Res> implements $PaymentCopyWith<$Res> {
  factory _$PaymentCopyWith(_Payment value, $Res Function(_Payment) _then) = __$PaymentCopyWithImpl;
@override @useResult
$Res call({
 String id, String? reservationId, String? sessionId, String? consumerId, String? hostId, String? idempotencyKey, String? gateway, String? gatewayReference, double authorizedAmount, double capturedAmount, double refundedAmount, double lateCancellationFee, String? status, String? failureReason, int createdAtMs, int updatedAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class __$PaymentCopyWithImpl<$Res>
    implements _$PaymentCopyWith<$Res> {
  __$PaymentCopyWithImpl(this._self, this._then);

  final _Payment _self;
  final $Res Function(_Payment) _then;

/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reservationId = freezed,Object? sessionId = freezed,Object? consumerId = freezed,Object? hostId = freezed,Object? idempotencyKey = freezed,Object? gateway = freezed,Object? gatewayReference = freezed,Object? authorizedAmount = null,Object? capturedAmount = null,Object? refundedAmount = null,Object? lateCancellationFee = null,Object? status = freezed,Object? failureReason = freezed,Object? createdAtMs = null,Object? updatedAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(_Payment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reservationId: freezed == reservationId ? _self.reservationId : reservationId // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,consumerId: freezed == consumerId ? _self.consumerId : consumerId // ignore: cast_nullable_to_non_nullable
as String?,hostId: freezed == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String?,idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,gateway: freezed == gateway ? _self.gateway : gateway // ignore: cast_nullable_to_non_nullable
as String?,gatewayReference: freezed == gatewayReference ? _self.gatewayReference : gatewayReference // ignore: cast_nullable_to_non_nullable
as String?,authorizedAmount: null == authorizedAmount ? _self.authorizedAmount : authorizedAmount // ignore: cast_nullable_to_non_nullable
as double,capturedAmount: null == capturedAmount ? _self.capturedAmount : capturedAmount // ignore: cast_nullable_to_non_nullable
as double,refundedAmount: null == refundedAmount ? _self.refundedAmount : refundedAmount // ignore: cast_nullable_to_non_nullable
as double,lateCancellationFee: null == lateCancellationFee ? _self.lateCancellationFee : lateCancellationFee // ignore: cast_nullable_to_non_nullable
as double,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Report {

 String get id; String? get reporterId; String? get reporterName; String? get targetStationId; String? get targetHostId; String? get sessionId; String? get reportType; String? get description; String? get status; int get createdAtMs; String? get serverUpdatedAt;
/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportCopyWith<Report> get copyWith => _$ReportCopyWithImpl<Report>(this as Report, _$identity);

  /// Serializes this Report to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Report;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Report&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.reporterId, _this.reporterId) || other.reporterId == _this.reporterId)&&(identical(other.reporterName, _this.reporterName) || other.reporterName == _this.reporterName)&&(identical(other.targetStationId, _this.targetStationId) || other.targetStationId == _this.targetStationId)&&(identical(other.targetHostId, _this.targetHostId) || other.targetHostId == _this.targetHostId)&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId)&&(identical(other.reportType, _this.reportType) || other.reportType == _this.reportType)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.createdAtMs, _this.createdAtMs) || other.createdAtMs == _this.createdAtMs)&&(identical(other.serverUpdatedAt, _this.serverUpdatedAt) || other.serverUpdatedAt == _this.serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Report;
  return Object.hash(runtimeType,_this.id,_this.reporterId,_this.reporterName,_this.targetStationId,_this.targetHostId,_this.sessionId,_this.reportType,_this.description,_this.status,_this.createdAtMs,_this.serverUpdatedAt);
}

@override
String toString() {
  final _this = this as Report;
  return 'Report(id: ${_this.id}, reporterId: ${_this.reporterId}, reporterName: ${_this.reporterName}, targetStationId: ${_this.targetStationId}, targetHostId: ${_this.targetHostId}, sessionId: ${_this.sessionId}, reportType: ${_this.reportType}, description: ${_this.description}, status: ${_this.status}, createdAtMs: ${_this.createdAtMs}, serverUpdatedAt: ${_this.serverUpdatedAt})';
}


}

/// @nodoc
abstract mixin class $ReportCopyWith<$Res>  {
  factory $ReportCopyWith(Report value, $Res Function(Report) _then) = _$ReportCopyWithImpl;
@useResult
$Res call({
 String id, String? reporterId, String? reporterName, String? targetStationId, String? targetHostId, String? sessionId, String? reportType, String? description, String? status, int createdAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class _$ReportCopyWithImpl<$Res>
    implements $ReportCopyWith<$Res> {
  _$ReportCopyWithImpl(this._self, this._then);

  final Report _self;
  final $Res Function(Report) _then;

/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reporterId = freezed,Object? reporterName = freezed,Object? targetStationId = freezed,Object? targetHostId = freezed,Object? sessionId = freezed,Object? reportType = freezed,Object? description = freezed,Object? status = freezed,Object? createdAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(Report(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reporterId: freezed == reporterId ? _self.reporterId : reporterId // ignore: cast_nullable_to_non_nullable
as String?,reporterName: freezed == reporterName ? _self.reporterName : reporterName // ignore: cast_nullable_to_non_nullable
as String?,targetStationId: freezed == targetStationId ? _self.targetStationId : targetStationId // ignore: cast_nullable_to_non_nullable
as String?,targetHostId: freezed == targetHostId ? _self.targetHostId : targetHostId // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,reportType: freezed == reportType ? _self.reportType : reportType // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Report].
extension ReportPatterns on Report {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Report value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Report() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Report value)  $default,){
final _that = this;
switch (_that) {
case _Report():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Report value)?  $default,){
final _that = this;
switch (_that) {
case _Report() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? reporterId,  String? reporterName,  String? targetStationId,  String? targetHostId,  String? sessionId,  String? reportType,  String? description,  String? status,  int createdAtMs,  String? serverUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Report() when $default != null:
return $default(_that.id,_that.reporterId,_that.reporterName,_that.targetStationId,_that.targetHostId,_that.sessionId,_that.reportType,_that.description,_that.status,_that.createdAtMs,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? reporterId,  String? reporterName,  String? targetStationId,  String? targetHostId,  String? sessionId,  String? reportType,  String? description,  String? status,  int createdAtMs,  String? serverUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _Report():
return $default(_that.id,_that.reporterId,_that.reporterName,_that.targetStationId,_that.targetHostId,_that.sessionId,_that.reportType,_that.description,_that.status,_that.createdAtMs,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? reporterId,  String? reporterName,  String? targetStationId,  String? targetHostId,  String? sessionId,  String? reportType,  String? description,  String? status,  int createdAtMs,  String? serverUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Report() when $default != null:
return $default(_that.id,_that.reporterId,_that.reporterName,_that.targetStationId,_that.targetHostId,_that.sessionId,_that.reportType,_that.description,_that.status,_that.createdAtMs,_that.serverUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Report implements Report {
  const _Report({required this.id, this.reporterId, this.reporterName, this.targetStationId, this.targetHostId, this.sessionId, this.reportType, this.description, this.status, this.createdAtMs = 0, this.serverUpdatedAt});
  factory _Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);

@override final  String id;
@override final  String? reporterId;
@override final  String? reporterName;
@override final  String? targetStationId;
@override final  String? targetHostId;
@override final  String? sessionId;
@override final  String? reportType;
@override final  String? description;
@override final  String? status;
@override@JsonKey() final  int createdAtMs;
@override final  String? serverUpdatedAt;

/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportCopyWith<_Report> get copyWith => __$ReportCopyWithImpl<_Report>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Report&&(identical(other.id, id) || other.id == id)&&(identical(other.reporterId, reporterId) || other.reporterId == reporterId)&&(identical(other.reporterName, reporterName) || other.reporterName == reporterName)&&(identical(other.targetStationId, targetStationId) || other.targetStationId == targetStationId)&&(identical(other.targetHostId, targetHostId) || other.targetHostId == targetHostId)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.reportType, reportType) || other.reportType == reportType)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.serverUpdatedAt, serverUpdatedAt) || other.serverUpdatedAt == serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,reporterId,reporterName,targetStationId,targetHostId,sessionId,reportType,description,status,createdAtMs,serverUpdatedAt);
}

@override
String toString() {
    return 'Report(id: $id, reporterId: $reporterId, reporterName: $reporterName, targetStationId: $targetStationId, targetHostId: $targetHostId, sessionId: $sessionId, reportType: $reportType, description: $description, status: $status, createdAtMs: $createdAtMs, serverUpdatedAt: $serverUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$ReportCopyWith<$Res> implements $ReportCopyWith<$Res> {
  factory _$ReportCopyWith(_Report value, $Res Function(_Report) _then) = __$ReportCopyWithImpl;
@override @useResult
$Res call({
 String id, String? reporterId, String? reporterName, String? targetStationId, String? targetHostId, String? sessionId, String? reportType, String? description, String? status, int createdAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class __$ReportCopyWithImpl<$Res>
    implements _$ReportCopyWith<$Res> {
  __$ReportCopyWithImpl(this._self, this._then);

  final _Report _self;
  final $Res Function(_Report) _then;

/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reporterId = freezed,Object? reporterName = freezed,Object? targetStationId = freezed,Object? targetHostId = freezed,Object? sessionId = freezed,Object? reportType = freezed,Object? description = freezed,Object? status = freezed,Object? createdAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(_Report(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reporterId: freezed == reporterId ? _self.reporterId : reporterId // ignore: cast_nullable_to_non_nullable
as String?,reporterName: freezed == reporterName ? _self.reporterName : reporterName // ignore: cast_nullable_to_non_nullable
as String?,targetStationId: freezed == targetStationId ? _self.targetStationId : targetStationId // ignore: cast_nullable_to_non_nullable
as String?,targetHostId: freezed == targetHostId ? _self.targetHostId : targetHostId // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,reportType: freezed == reportType ? _self.reportType : reportType // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Dispute {

 String get id; String? get sessionId; String? get consumerId; String? get consumerName; String? get hostId; String? get stationId; String? get stationName; String? get reason; String? get consumerNotes; String? get hostNotes; String? get evidence; String? get status; String? get enforcementAction; double get refundAmount; String? get resolutionNote; bool get isPayoutFrozen; int get createdAtMs; int get resolvedAtMs; String? get serverUpdatedAt;
/// Create a copy of Dispute
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DisputeCopyWith<Dispute> get copyWith => _$DisputeCopyWithImpl<Dispute>(this as Dispute, _$identity);

  /// Serializes this Dispute to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Dispute;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Dispute&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId)&&(identical(other.consumerId, _this.consumerId) || other.consumerId == _this.consumerId)&&(identical(other.consumerName, _this.consumerName) || other.consumerName == _this.consumerName)&&(identical(other.hostId, _this.hostId) || other.hostId == _this.hostId)&&(identical(other.stationId, _this.stationId) || other.stationId == _this.stationId)&&(identical(other.stationName, _this.stationName) || other.stationName == _this.stationName)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.consumerNotes, _this.consumerNotes) || other.consumerNotes == _this.consumerNotes)&&(identical(other.hostNotes, _this.hostNotes) || other.hostNotes == _this.hostNotes)&&(identical(other.evidence, _this.evidence) || other.evidence == _this.evidence)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.enforcementAction, _this.enforcementAction) || other.enforcementAction == _this.enforcementAction)&&(identical(other.refundAmount, _this.refundAmount) || other.refundAmount == _this.refundAmount)&&(identical(other.resolutionNote, _this.resolutionNote) || other.resolutionNote == _this.resolutionNote)&&(identical(other.isPayoutFrozen, _this.isPayoutFrozen) || other.isPayoutFrozen == _this.isPayoutFrozen)&&(identical(other.createdAtMs, _this.createdAtMs) || other.createdAtMs == _this.createdAtMs)&&(identical(other.resolvedAtMs, _this.resolvedAtMs) || other.resolvedAtMs == _this.resolvedAtMs)&&(identical(other.serverUpdatedAt, _this.serverUpdatedAt) || other.serverUpdatedAt == _this.serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Dispute;
  return Object.hashAll([runtimeType,_this.id,_this.sessionId,_this.consumerId,_this.consumerName,_this.hostId,_this.stationId,_this.stationName,_this.reason,_this.consumerNotes,_this.hostNotes,_this.evidence,_this.status,_this.enforcementAction,_this.refundAmount,_this.resolutionNote,_this.isPayoutFrozen,_this.createdAtMs,_this.resolvedAtMs,_this.serverUpdatedAt]);
}

@override
String toString() {
  final _this = this as Dispute;
  return 'Dispute(id: ${_this.id}, sessionId: ${_this.sessionId}, consumerId: ${_this.consumerId}, consumerName: ${_this.consumerName}, hostId: ${_this.hostId}, stationId: ${_this.stationId}, stationName: ${_this.stationName}, reason: ${_this.reason}, consumerNotes: ${_this.consumerNotes}, hostNotes: ${_this.hostNotes}, evidence: ${_this.evidence}, status: ${_this.status}, enforcementAction: ${_this.enforcementAction}, refundAmount: ${_this.refundAmount}, resolutionNote: ${_this.resolutionNote}, isPayoutFrozen: ${_this.isPayoutFrozen}, createdAtMs: ${_this.createdAtMs}, resolvedAtMs: ${_this.resolvedAtMs}, serverUpdatedAt: ${_this.serverUpdatedAt})';
}


}

/// @nodoc
abstract mixin class $DisputeCopyWith<$Res>  {
  factory $DisputeCopyWith(Dispute value, $Res Function(Dispute) _then) = _$DisputeCopyWithImpl;
@useResult
$Res call({
 String id, String? sessionId, String? consumerId, String? consumerName, String? hostId, String? stationId, String? stationName, String? reason, String? consumerNotes, String? hostNotes, String? evidence, String? status, String? enforcementAction, double refundAmount, String? resolutionNote, bool isPayoutFrozen, int createdAtMs, int resolvedAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class _$DisputeCopyWithImpl<$Res>
    implements $DisputeCopyWith<$Res> {
  _$DisputeCopyWithImpl(this._self, this._then);

  final Dispute _self;
  final $Res Function(Dispute) _then;

/// Create a copy of Dispute
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sessionId = freezed,Object? consumerId = freezed,Object? consumerName = freezed,Object? hostId = freezed,Object? stationId = freezed,Object? stationName = freezed,Object? reason = freezed,Object? consumerNotes = freezed,Object? hostNotes = freezed,Object? evidence = freezed,Object? status = freezed,Object? enforcementAction = freezed,Object? refundAmount = null,Object? resolutionNote = freezed,Object? isPayoutFrozen = null,Object? createdAtMs = null,Object? resolvedAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(Dispute(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,consumerId: freezed == consumerId ? _self.consumerId : consumerId // ignore: cast_nullable_to_non_nullable
as String?,consumerName: freezed == consumerName ? _self.consumerName : consumerName // ignore: cast_nullable_to_non_nullable
as String?,hostId: freezed == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String?,stationId: freezed == stationId ? _self.stationId : stationId // ignore: cast_nullable_to_non_nullable
as String?,stationName: freezed == stationName ? _self.stationName : stationName // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,consumerNotes: freezed == consumerNotes ? _self.consumerNotes : consumerNotes // ignore: cast_nullable_to_non_nullable
as String?,hostNotes: freezed == hostNotes ? _self.hostNotes : hostNotes // ignore: cast_nullable_to_non_nullable
as String?,evidence: freezed == evidence ? _self.evidence : evidence // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,enforcementAction: freezed == enforcementAction ? _self.enforcementAction : enforcementAction // ignore: cast_nullable_to_non_nullable
as String?,refundAmount: null == refundAmount ? _self.refundAmount : refundAmount // ignore: cast_nullable_to_non_nullable
as double,resolutionNote: freezed == resolutionNote ? _self.resolutionNote : resolutionNote // ignore: cast_nullable_to_non_nullable
as String?,isPayoutFrozen: null == isPayoutFrozen ? _self.isPayoutFrozen : isPayoutFrozen // ignore: cast_nullable_to_non_nullable
as bool,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,resolvedAtMs: null == resolvedAtMs ? _self.resolvedAtMs : resolvedAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Dispute].
extension DisputePatterns on Dispute {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Dispute value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Dispute() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Dispute value)  $default,){
final _that = this;
switch (_that) {
case _Dispute():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Dispute value)?  $default,){
final _that = this;
switch (_that) {
case _Dispute() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? sessionId,  String? consumerId,  String? consumerName,  String? hostId,  String? stationId,  String? stationName,  String? reason,  String? consumerNotes,  String? hostNotes,  String? evidence,  String? status,  String? enforcementAction,  double refundAmount,  String? resolutionNote,  bool isPayoutFrozen,  int createdAtMs,  int resolvedAtMs,  String? serverUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Dispute() when $default != null:
return $default(_that.id,_that.sessionId,_that.consumerId,_that.consumerName,_that.hostId,_that.stationId,_that.stationName,_that.reason,_that.consumerNotes,_that.hostNotes,_that.evidence,_that.status,_that.enforcementAction,_that.refundAmount,_that.resolutionNote,_that.isPayoutFrozen,_that.createdAtMs,_that.resolvedAtMs,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? sessionId,  String? consumerId,  String? consumerName,  String? hostId,  String? stationId,  String? stationName,  String? reason,  String? consumerNotes,  String? hostNotes,  String? evidence,  String? status,  String? enforcementAction,  double refundAmount,  String? resolutionNote,  bool isPayoutFrozen,  int createdAtMs,  int resolvedAtMs,  String? serverUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _Dispute():
return $default(_that.id,_that.sessionId,_that.consumerId,_that.consumerName,_that.hostId,_that.stationId,_that.stationName,_that.reason,_that.consumerNotes,_that.hostNotes,_that.evidence,_that.status,_that.enforcementAction,_that.refundAmount,_that.resolutionNote,_that.isPayoutFrozen,_that.createdAtMs,_that.resolvedAtMs,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? sessionId,  String? consumerId,  String? consumerName,  String? hostId,  String? stationId,  String? stationName,  String? reason,  String? consumerNotes,  String? hostNotes,  String? evidence,  String? status,  String? enforcementAction,  double refundAmount,  String? resolutionNote,  bool isPayoutFrozen,  int createdAtMs,  int resolvedAtMs,  String? serverUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Dispute() when $default != null:
return $default(_that.id,_that.sessionId,_that.consumerId,_that.consumerName,_that.hostId,_that.stationId,_that.stationName,_that.reason,_that.consumerNotes,_that.hostNotes,_that.evidence,_that.status,_that.enforcementAction,_that.refundAmount,_that.resolutionNote,_that.isPayoutFrozen,_that.createdAtMs,_that.resolvedAtMs,_that.serverUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Dispute implements Dispute {
  const _Dispute({required this.id, this.sessionId, this.consumerId, this.consumerName, this.hostId, this.stationId, this.stationName, this.reason, this.consumerNotes, this.hostNotes, this.evidence, this.status, this.enforcementAction, this.refundAmount = 0, this.resolutionNote, this.isPayoutFrozen = false, this.createdAtMs = 0, this.resolvedAtMs = 0, this.serverUpdatedAt});
  factory _Dispute.fromJson(Map<String, dynamic> json) => _$DisputeFromJson(json);

@override final  String id;
@override final  String? sessionId;
@override final  String? consumerId;
@override final  String? consumerName;
@override final  String? hostId;
@override final  String? stationId;
@override final  String? stationName;
@override final  String? reason;
@override final  String? consumerNotes;
@override final  String? hostNotes;
@override final  String? evidence;
@override final  String? status;
@override final  String? enforcementAction;
@override@JsonKey() final  double refundAmount;
@override final  String? resolutionNote;
@override@JsonKey() final  bool isPayoutFrozen;
@override@JsonKey() final  int createdAtMs;
@override@JsonKey() final  int resolvedAtMs;
@override final  String? serverUpdatedAt;

/// Create a copy of Dispute
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DisputeCopyWith<_Dispute> get copyWith => __$DisputeCopyWithImpl<_Dispute>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DisputeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Dispute&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.consumerId, consumerId) || other.consumerId == consumerId)&&(identical(other.consumerName, consumerName) || other.consumerName == consumerName)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.stationId, stationId) || other.stationId == stationId)&&(identical(other.stationName, stationName) || other.stationName == stationName)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.consumerNotes, consumerNotes) || other.consumerNotes == consumerNotes)&&(identical(other.hostNotes, hostNotes) || other.hostNotes == hostNotes)&&(identical(other.evidence, evidence) || other.evidence == evidence)&&(identical(other.status, status) || other.status == status)&&(identical(other.enforcementAction, enforcementAction) || other.enforcementAction == enforcementAction)&&(identical(other.refundAmount, refundAmount) || other.refundAmount == refundAmount)&&(identical(other.resolutionNote, resolutionNote) || other.resolutionNote == resolutionNote)&&(identical(other.isPayoutFrozen, isPayoutFrozen) || other.isPayoutFrozen == isPayoutFrozen)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.resolvedAtMs, resolvedAtMs) || other.resolvedAtMs == resolvedAtMs)&&(identical(other.serverUpdatedAt, serverUpdatedAt) || other.serverUpdatedAt == serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,sessionId,consumerId,consumerName,hostId,stationId,stationName,reason,consumerNotes,hostNotes,evidence,status,enforcementAction,refundAmount,resolutionNote,isPayoutFrozen,createdAtMs,resolvedAtMs,serverUpdatedAt]);
}

@override
String toString() {
    return 'Dispute(id: $id, sessionId: $sessionId, consumerId: $consumerId, consumerName: $consumerName, hostId: $hostId, stationId: $stationId, stationName: $stationName, reason: $reason, consumerNotes: $consumerNotes, hostNotes: $hostNotes, evidence: $evidence, status: $status, enforcementAction: $enforcementAction, refundAmount: $refundAmount, resolutionNote: $resolutionNote, isPayoutFrozen: $isPayoutFrozen, createdAtMs: $createdAtMs, resolvedAtMs: $resolvedAtMs, serverUpdatedAt: $serverUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$DisputeCopyWith<$Res> implements $DisputeCopyWith<$Res> {
  factory _$DisputeCopyWith(_Dispute value, $Res Function(_Dispute) _then) = __$DisputeCopyWithImpl;
@override @useResult
$Res call({
 String id, String? sessionId, String? consumerId, String? consumerName, String? hostId, String? stationId, String? stationName, String? reason, String? consumerNotes, String? hostNotes, String? evidence, String? status, String? enforcementAction, double refundAmount, String? resolutionNote, bool isPayoutFrozen, int createdAtMs, int resolvedAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class __$DisputeCopyWithImpl<$Res>
    implements _$DisputeCopyWith<$Res> {
  __$DisputeCopyWithImpl(this._self, this._then);

  final _Dispute _self;
  final $Res Function(_Dispute) _then;

/// Create a copy of Dispute
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sessionId = freezed,Object? consumerId = freezed,Object? consumerName = freezed,Object? hostId = freezed,Object? stationId = freezed,Object? stationName = freezed,Object? reason = freezed,Object? consumerNotes = freezed,Object? hostNotes = freezed,Object? evidence = freezed,Object? status = freezed,Object? enforcementAction = freezed,Object? refundAmount = null,Object? resolutionNote = freezed,Object? isPayoutFrozen = null,Object? createdAtMs = null,Object? resolvedAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(_Dispute(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,consumerId: freezed == consumerId ? _self.consumerId : consumerId // ignore: cast_nullable_to_non_nullable
as String?,consumerName: freezed == consumerName ? _self.consumerName : consumerName // ignore: cast_nullable_to_non_nullable
as String?,hostId: freezed == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String?,stationId: freezed == stationId ? _self.stationId : stationId // ignore: cast_nullable_to_non_nullable
as String?,stationName: freezed == stationName ? _self.stationName : stationName // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,consumerNotes: freezed == consumerNotes ? _self.consumerNotes : consumerNotes // ignore: cast_nullable_to_non_nullable
as String?,hostNotes: freezed == hostNotes ? _self.hostNotes : hostNotes // ignore: cast_nullable_to_non_nullable
as String?,evidence: freezed == evidence ? _self.evidence : evidence // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,enforcementAction: freezed == enforcementAction ? _self.enforcementAction : enforcementAction // ignore: cast_nullable_to_non_nullable
as String?,refundAmount: null == refundAmount ? _self.refundAmount : refundAmount // ignore: cast_nullable_to_non_nullable
as double,resolutionNote: freezed == resolutionNote ? _self.resolutionNote : resolutionNote // ignore: cast_nullable_to_non_nullable
as String?,isPayoutFrozen: null == isPayoutFrozen ? _self.isPayoutFrozen : isPayoutFrozen // ignore: cast_nullable_to_non_nullable
as bool,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,resolvedAtMs: null == resolvedAtMs ? _self.resolvedAtMs : resolvedAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$HostEnforcement {

 String get id; String? get hostId; String? get stationId; String? get actionType; String? get reason; double get fineAmount; int get createdAtMs; int get expiresAtMs; String? get serverUpdatedAt;
/// Create a copy of HostEnforcement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HostEnforcementCopyWith<HostEnforcement> get copyWith => _$HostEnforcementCopyWithImpl<HostEnforcement>(this as HostEnforcement, _$identity);

  /// Serializes this HostEnforcement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HostEnforcement;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HostEnforcement&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.hostId, _this.hostId) || other.hostId == _this.hostId)&&(identical(other.stationId, _this.stationId) || other.stationId == _this.stationId)&&(identical(other.actionType, _this.actionType) || other.actionType == _this.actionType)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.fineAmount, _this.fineAmount) || other.fineAmount == _this.fineAmount)&&(identical(other.createdAtMs, _this.createdAtMs) || other.createdAtMs == _this.createdAtMs)&&(identical(other.expiresAtMs, _this.expiresAtMs) || other.expiresAtMs == _this.expiresAtMs)&&(identical(other.serverUpdatedAt, _this.serverUpdatedAt) || other.serverUpdatedAt == _this.serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HostEnforcement;
  return Object.hash(runtimeType,_this.id,_this.hostId,_this.stationId,_this.actionType,_this.reason,_this.fineAmount,_this.createdAtMs,_this.expiresAtMs,_this.serverUpdatedAt);
}

@override
String toString() {
  final _this = this as HostEnforcement;
  return 'HostEnforcement(id: ${_this.id}, hostId: ${_this.hostId}, stationId: ${_this.stationId}, actionType: ${_this.actionType}, reason: ${_this.reason}, fineAmount: ${_this.fineAmount}, createdAtMs: ${_this.createdAtMs}, expiresAtMs: ${_this.expiresAtMs}, serverUpdatedAt: ${_this.serverUpdatedAt})';
}


}

/// @nodoc
abstract mixin class $HostEnforcementCopyWith<$Res>  {
  factory $HostEnforcementCopyWith(HostEnforcement value, $Res Function(HostEnforcement) _then) = _$HostEnforcementCopyWithImpl;
@useResult
$Res call({
 String id, String? hostId, String? stationId, String? actionType, String? reason, double fineAmount, int createdAtMs, int expiresAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class _$HostEnforcementCopyWithImpl<$Res>
    implements $HostEnforcementCopyWith<$Res> {
  _$HostEnforcementCopyWithImpl(this._self, this._then);

  final HostEnforcement _self;
  final $Res Function(HostEnforcement) _then;

/// Create a copy of HostEnforcement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? hostId = freezed,Object? stationId = freezed,Object? actionType = freezed,Object? reason = freezed,Object? fineAmount = null,Object? createdAtMs = null,Object? expiresAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(HostEnforcement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,hostId: freezed == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String?,stationId: freezed == stationId ? _self.stationId : stationId // ignore: cast_nullable_to_non_nullable
as String?,actionType: freezed == actionType ? _self.actionType : actionType // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,fineAmount: null == fineAmount ? _self.fineAmount : fineAmount // ignore: cast_nullable_to_non_nullable
as double,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,expiresAtMs: null == expiresAtMs ? _self.expiresAtMs : expiresAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HostEnforcement].
extension HostEnforcementPatterns on HostEnforcement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HostEnforcement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HostEnforcement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HostEnforcement value)  $default,){
final _that = this;
switch (_that) {
case _HostEnforcement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HostEnforcement value)?  $default,){
final _that = this;
switch (_that) {
case _HostEnforcement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? hostId,  String? stationId,  String? actionType,  String? reason,  double fineAmount,  int createdAtMs,  int expiresAtMs,  String? serverUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HostEnforcement() when $default != null:
return $default(_that.id,_that.hostId,_that.stationId,_that.actionType,_that.reason,_that.fineAmount,_that.createdAtMs,_that.expiresAtMs,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? hostId,  String? stationId,  String? actionType,  String? reason,  double fineAmount,  int createdAtMs,  int expiresAtMs,  String? serverUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _HostEnforcement():
return $default(_that.id,_that.hostId,_that.stationId,_that.actionType,_that.reason,_that.fineAmount,_that.createdAtMs,_that.expiresAtMs,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? hostId,  String? stationId,  String? actionType,  String? reason,  double fineAmount,  int createdAtMs,  int expiresAtMs,  String? serverUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _HostEnforcement() when $default != null:
return $default(_that.id,_that.hostId,_that.stationId,_that.actionType,_that.reason,_that.fineAmount,_that.createdAtMs,_that.expiresAtMs,_that.serverUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HostEnforcement implements HostEnforcement {
  const _HostEnforcement({required this.id, this.hostId, this.stationId, this.actionType, this.reason, this.fineAmount = 0, this.createdAtMs = 0, this.expiresAtMs = 0, this.serverUpdatedAt});
  factory _HostEnforcement.fromJson(Map<String, dynamic> json) => _$HostEnforcementFromJson(json);

@override final  String id;
@override final  String? hostId;
@override final  String? stationId;
@override final  String? actionType;
@override final  String? reason;
@override@JsonKey() final  double fineAmount;
@override@JsonKey() final  int createdAtMs;
@override@JsonKey() final  int expiresAtMs;
@override final  String? serverUpdatedAt;

/// Create a copy of HostEnforcement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HostEnforcementCopyWith<_HostEnforcement> get copyWith => __$HostEnforcementCopyWithImpl<_HostEnforcement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HostEnforcementToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HostEnforcement&&(identical(other.id, id) || other.id == id)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.stationId, stationId) || other.stationId == stationId)&&(identical(other.actionType, actionType) || other.actionType == actionType)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.fineAmount, fineAmount) || other.fineAmount == fineAmount)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.expiresAtMs, expiresAtMs) || other.expiresAtMs == expiresAtMs)&&(identical(other.serverUpdatedAt, serverUpdatedAt) || other.serverUpdatedAt == serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,hostId,stationId,actionType,reason,fineAmount,createdAtMs,expiresAtMs,serverUpdatedAt);
}

@override
String toString() {
    return 'HostEnforcement(id: $id, hostId: $hostId, stationId: $stationId, actionType: $actionType, reason: $reason, fineAmount: $fineAmount, createdAtMs: $createdAtMs, expiresAtMs: $expiresAtMs, serverUpdatedAt: $serverUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$HostEnforcementCopyWith<$Res> implements $HostEnforcementCopyWith<$Res> {
  factory _$HostEnforcementCopyWith(_HostEnforcement value, $Res Function(_HostEnforcement) _then) = __$HostEnforcementCopyWithImpl;
@override @useResult
$Res call({
 String id, String? hostId, String? stationId, String? actionType, String? reason, double fineAmount, int createdAtMs, int expiresAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class __$HostEnforcementCopyWithImpl<$Res>
    implements _$HostEnforcementCopyWith<$Res> {
  __$HostEnforcementCopyWithImpl(this._self, this._then);

  final _HostEnforcement _self;
  final $Res Function(_HostEnforcement) _then;

/// Create a copy of HostEnforcement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? hostId = freezed,Object? stationId = freezed,Object? actionType = freezed,Object? reason = freezed,Object? fineAmount = null,Object? createdAtMs = null,Object? expiresAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(_HostEnforcement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,hostId: freezed == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String?,stationId: freezed == stationId ? _self.stationId : stationId // ignore: cast_nullable_to_non_nullable
as String?,actionType: freezed == actionType ? _self.actionType : actionType // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,fineAmount: null == fineAmount ? _self.fineAmount : fineAmount // ignore: cast_nullable_to_non_nullable
as double,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,expiresAtMs: null == expiresAtMs ? _self.expiresAtMs : expiresAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
