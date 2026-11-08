// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'core_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppUser {

 String get id; String? get authUserId; String? get name; String? get email; String? get phone; String? get role; String? get organizationName; String? get verificationStatus; bool get isBlocked; String? get serverUpdatedAt;
/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUserCopyWith<AppUser> get copyWith => _$AppUserCopyWithImpl<AppUser>(this as AppUser, _$identity);

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AppUser;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUser&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.authUserId, _this.authUserId) || other.authUserId == _this.authUserId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.organizationName, _this.organizationName) || other.organizationName == _this.organizationName)&&(identical(other.verificationStatus, _this.verificationStatus) || other.verificationStatus == _this.verificationStatus)&&(identical(other.isBlocked, _this.isBlocked) || other.isBlocked == _this.isBlocked)&&(identical(other.serverUpdatedAt, _this.serverUpdatedAt) || other.serverUpdatedAt == _this.serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AppUser;
  return Object.hash(runtimeType,_this.id,_this.authUserId,_this.name,_this.email,_this.phone,_this.role,_this.organizationName,_this.verificationStatus,_this.isBlocked,_this.serverUpdatedAt);
}

@override
String toString() {
  final _this = this as AppUser;
  return 'AppUser(id: ${_this.id}, authUserId: ${_this.authUserId}, name: ${_this.name}, email: ${_this.email}, phone: ${_this.phone}, role: ${_this.role}, organizationName: ${_this.organizationName}, verificationStatus: ${_this.verificationStatus}, isBlocked: ${_this.isBlocked}, serverUpdatedAt: ${_this.serverUpdatedAt})';
}


}

/// @nodoc
abstract mixin class $AppUserCopyWith<$Res>  {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) _then) = _$AppUserCopyWithImpl;
@useResult
$Res call({
 String id, String? authUserId, String? name, String? email, String? phone, String? role, String? organizationName, String? verificationStatus, bool isBlocked, String? serverUpdatedAt
});




}
/// @nodoc
class _$AppUserCopyWithImpl<$Res>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._self, this._then);

  final AppUser _self;
  final $Res Function(AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? authUserId = freezed,Object? name = freezed,Object? email = freezed,Object? phone = freezed,Object? role = freezed,Object? organizationName = freezed,Object? verificationStatus = freezed,Object? isBlocked = null,Object? serverUpdatedAt = freezed,}) {
  return _then(AppUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,authUserId: freezed == authUserId ? _self.authUserId : authUserId // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,organizationName: freezed == organizationName ? _self.organizationName : organizationName // ignore: cast_nullable_to_non_nullable
as String?,verificationStatus: freezed == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String?,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppUser].
extension AppUserPatterns on AppUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUser value)  $default,){
final _that = this;
switch (_that) {
case _AppUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUser value)?  $default,){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? authUserId,  String? name,  String? email,  String? phone,  String? role,  String? organizationName,  String? verificationStatus,  bool isBlocked,  String? serverUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.id,_that.authUserId,_that.name,_that.email,_that.phone,_that.role,_that.organizationName,_that.verificationStatus,_that.isBlocked,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? authUserId,  String? name,  String? email,  String? phone,  String? role,  String? organizationName,  String? verificationStatus,  bool isBlocked,  String? serverUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _AppUser():
return $default(_that.id,_that.authUserId,_that.name,_that.email,_that.phone,_that.role,_that.organizationName,_that.verificationStatus,_that.isBlocked,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? authUserId,  String? name,  String? email,  String? phone,  String? role,  String? organizationName,  String? verificationStatus,  bool isBlocked,  String? serverUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.id,_that.authUserId,_that.name,_that.email,_that.phone,_that.role,_that.organizationName,_that.verificationStatus,_that.isBlocked,_that.serverUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppUser implements AppUser {
  const _AppUser({required this.id, this.authUserId, this.name, this.email, this.phone, this.role, this.organizationName, this.verificationStatus, this.isBlocked = false, this.serverUpdatedAt});
  factory _AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

@override final  String id;
@override final  String? authUserId;
@override final  String? name;
@override final  String? email;
@override final  String? phone;
@override final  String? role;
@override final  String? organizationName;
@override final  String? verificationStatus;
@override@JsonKey() final  bool isBlocked;
@override final  String? serverUpdatedAt;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUserCopyWith<_AppUser> get copyWith => __$AppUserCopyWithImpl<_AppUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppUserToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUser&&(identical(other.id, id) || other.id == id)&&(identical(other.authUserId, authUserId) || other.authUserId == authUserId)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.role, role) || other.role == role)&&(identical(other.organizationName, organizationName) || other.organizationName == organizationName)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.isBlocked, isBlocked) || other.isBlocked == isBlocked)&&(identical(other.serverUpdatedAt, serverUpdatedAt) || other.serverUpdatedAt == serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,authUserId,name,email,phone,role,organizationName,verificationStatus,isBlocked,serverUpdatedAt);
}

@override
String toString() {
    return 'AppUser(id: $id, authUserId: $authUserId, name: $name, email: $email, phone: $phone, role: $role, organizationName: $organizationName, verificationStatus: $verificationStatus, isBlocked: $isBlocked, serverUpdatedAt: $serverUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$AppUserCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$AppUserCopyWith(_AppUser value, $Res Function(_AppUser) _then) = __$AppUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String? authUserId, String? name, String? email, String? phone, String? role, String? organizationName, String? verificationStatus, bool isBlocked, String? serverUpdatedAt
});




}
/// @nodoc
class __$AppUserCopyWithImpl<$Res>
    implements _$AppUserCopyWith<$Res> {
  __$AppUserCopyWithImpl(this._self, this._then);

  final _AppUser _self;
  final $Res Function(_AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? authUserId = freezed,Object? name = freezed,Object? email = freezed,Object? phone = freezed,Object? role = freezed,Object? organizationName = freezed,Object? verificationStatus = freezed,Object? isBlocked = null,Object? serverUpdatedAt = freezed,}) {
  return _then(_AppUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,authUserId: freezed == authUserId ? _self.authUserId : authUserId // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,organizationName: freezed == organizationName ? _self.organizationName : organizationName // ignore: cast_nullable_to_non_nullable
as String?,verificationStatus: freezed == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String?,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Vehicle {

 String get id; String? get userId; String? get make; String? get model; String? get variant; int get purchaseYear; double get batteryCapacityKwh; String? get connectorType; double get maxAcKw; double get maxDcKw; double get typicalEfficiencyKmPerKwh; double get batteryHealthPercent; double get efficiencyCorrectionPercent; int get minArrivalSocPercent; int get maxChargeSocPercent; String? get licensePlate; bool get isActive; String? get serverUpdatedAt;
/// Create a copy of Vehicle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VehicleCopyWith<Vehicle> get copyWith => _$VehicleCopyWithImpl<Vehicle>(this as Vehicle, _$identity);

  /// Serializes this Vehicle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Vehicle;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Vehicle&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.make, _this.make) || other.make == _this.make)&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.variant, _this.variant) || other.variant == _this.variant)&&(identical(other.purchaseYear, _this.purchaseYear) || other.purchaseYear == _this.purchaseYear)&&(identical(other.batteryCapacityKwh, _this.batteryCapacityKwh) || other.batteryCapacityKwh == _this.batteryCapacityKwh)&&(identical(other.connectorType, _this.connectorType) || other.connectorType == _this.connectorType)&&(identical(other.maxAcKw, _this.maxAcKw) || other.maxAcKw == _this.maxAcKw)&&(identical(other.maxDcKw, _this.maxDcKw) || other.maxDcKw == _this.maxDcKw)&&(identical(other.typicalEfficiencyKmPerKwh, _this.typicalEfficiencyKmPerKwh) || other.typicalEfficiencyKmPerKwh == _this.typicalEfficiencyKmPerKwh)&&(identical(other.batteryHealthPercent, _this.batteryHealthPercent) || other.batteryHealthPercent == _this.batteryHealthPercent)&&(identical(other.efficiencyCorrectionPercent, _this.efficiencyCorrectionPercent) || other.efficiencyCorrectionPercent == _this.efficiencyCorrectionPercent)&&(identical(other.minArrivalSocPercent, _this.minArrivalSocPercent) || other.minArrivalSocPercent == _this.minArrivalSocPercent)&&(identical(other.maxChargeSocPercent, _this.maxChargeSocPercent) || other.maxChargeSocPercent == _this.maxChargeSocPercent)&&(identical(other.licensePlate, _this.licensePlate) || other.licensePlate == _this.licensePlate)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.serverUpdatedAt, _this.serverUpdatedAt) || other.serverUpdatedAt == _this.serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Vehicle;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.make,_this.model,_this.variant,_this.purchaseYear,_this.batteryCapacityKwh,_this.connectorType,_this.maxAcKw,_this.maxDcKw,_this.typicalEfficiencyKmPerKwh,_this.batteryHealthPercent,_this.efficiencyCorrectionPercent,_this.minArrivalSocPercent,_this.maxChargeSocPercent,_this.licensePlate,_this.isActive,_this.serverUpdatedAt);
}

@override
String toString() {
  final _this = this as Vehicle;
  return 'Vehicle(id: ${_this.id}, userId: ${_this.userId}, make: ${_this.make}, model: ${_this.model}, variant: ${_this.variant}, purchaseYear: ${_this.purchaseYear}, batteryCapacityKwh: ${_this.batteryCapacityKwh}, connectorType: ${_this.connectorType}, maxAcKw: ${_this.maxAcKw}, maxDcKw: ${_this.maxDcKw}, typicalEfficiencyKmPerKwh: ${_this.typicalEfficiencyKmPerKwh}, batteryHealthPercent: ${_this.batteryHealthPercent}, efficiencyCorrectionPercent: ${_this.efficiencyCorrectionPercent}, minArrivalSocPercent: ${_this.minArrivalSocPercent}, maxChargeSocPercent: ${_this.maxChargeSocPercent}, licensePlate: ${_this.licensePlate}, isActive: ${_this.isActive}, serverUpdatedAt: ${_this.serverUpdatedAt})';
}


}

/// @nodoc
abstract mixin class $VehicleCopyWith<$Res>  {
  factory $VehicleCopyWith(Vehicle value, $Res Function(Vehicle) _then) = _$VehicleCopyWithImpl;
@useResult
$Res call({
 String id, String? userId, String? make, String? model, String? variant, int purchaseYear, double batteryCapacityKwh, String? connectorType, double maxAcKw, double maxDcKw, double typicalEfficiencyKmPerKwh, double batteryHealthPercent, double efficiencyCorrectionPercent, int minArrivalSocPercent, int maxChargeSocPercent, String? licensePlate, bool isActive, String? serverUpdatedAt
});




}
/// @nodoc
class _$VehicleCopyWithImpl<$Res>
    implements $VehicleCopyWith<$Res> {
  _$VehicleCopyWithImpl(this._self, this._then);

  final Vehicle _self;
  final $Res Function(Vehicle) _then;

/// Create a copy of Vehicle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = freezed,Object? make = freezed,Object? model = freezed,Object? variant = freezed,Object? purchaseYear = null,Object? batteryCapacityKwh = null,Object? connectorType = freezed,Object? maxAcKw = null,Object? maxDcKw = null,Object? typicalEfficiencyKmPerKwh = null,Object? batteryHealthPercent = null,Object? efficiencyCorrectionPercent = null,Object? minArrivalSocPercent = null,Object? maxChargeSocPercent = null,Object? licensePlate = freezed,Object? isActive = null,Object? serverUpdatedAt = freezed,}) {
  return _then(Vehicle(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,make: freezed == make ? _self.make : make // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,variant: freezed == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as String?,purchaseYear: null == purchaseYear ? _self.purchaseYear : purchaseYear // ignore: cast_nullable_to_non_nullable
as int,batteryCapacityKwh: null == batteryCapacityKwh ? _self.batteryCapacityKwh : batteryCapacityKwh // ignore: cast_nullable_to_non_nullable
as double,connectorType: freezed == connectorType ? _self.connectorType : connectorType // ignore: cast_nullable_to_non_nullable
as String?,maxAcKw: null == maxAcKw ? _self.maxAcKw : maxAcKw // ignore: cast_nullable_to_non_nullable
as double,maxDcKw: null == maxDcKw ? _self.maxDcKw : maxDcKw // ignore: cast_nullable_to_non_nullable
as double,typicalEfficiencyKmPerKwh: null == typicalEfficiencyKmPerKwh ? _self.typicalEfficiencyKmPerKwh : typicalEfficiencyKmPerKwh // ignore: cast_nullable_to_non_nullable
as double,batteryHealthPercent: null == batteryHealthPercent ? _self.batteryHealthPercent : batteryHealthPercent // ignore: cast_nullable_to_non_nullable
as double,efficiencyCorrectionPercent: null == efficiencyCorrectionPercent ? _self.efficiencyCorrectionPercent : efficiencyCorrectionPercent // ignore: cast_nullable_to_non_nullable
as double,minArrivalSocPercent: null == minArrivalSocPercent ? _self.minArrivalSocPercent : minArrivalSocPercent // ignore: cast_nullable_to_non_nullable
as int,maxChargeSocPercent: null == maxChargeSocPercent ? _self.maxChargeSocPercent : maxChargeSocPercent // ignore: cast_nullable_to_non_nullable
as int,licensePlate: freezed == licensePlate ? _self.licensePlate : licensePlate // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Vehicle].
extension VehiclePatterns on Vehicle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Vehicle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Vehicle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Vehicle value)  $default,){
final _that = this;
switch (_that) {
case _Vehicle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Vehicle value)?  $default,){
final _that = this;
switch (_that) {
case _Vehicle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? userId,  String? make,  String? model,  String? variant,  int purchaseYear,  double batteryCapacityKwh,  String? connectorType,  double maxAcKw,  double maxDcKw,  double typicalEfficiencyKmPerKwh,  double batteryHealthPercent,  double efficiencyCorrectionPercent,  int minArrivalSocPercent,  int maxChargeSocPercent,  String? licensePlate,  bool isActive,  String? serverUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Vehicle() when $default != null:
return $default(_that.id,_that.userId,_that.make,_that.model,_that.variant,_that.purchaseYear,_that.batteryCapacityKwh,_that.connectorType,_that.maxAcKw,_that.maxDcKw,_that.typicalEfficiencyKmPerKwh,_that.batteryHealthPercent,_that.efficiencyCorrectionPercent,_that.minArrivalSocPercent,_that.maxChargeSocPercent,_that.licensePlate,_that.isActive,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? userId,  String? make,  String? model,  String? variant,  int purchaseYear,  double batteryCapacityKwh,  String? connectorType,  double maxAcKw,  double maxDcKw,  double typicalEfficiencyKmPerKwh,  double batteryHealthPercent,  double efficiencyCorrectionPercent,  int minArrivalSocPercent,  int maxChargeSocPercent,  String? licensePlate,  bool isActive,  String? serverUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _Vehicle():
return $default(_that.id,_that.userId,_that.make,_that.model,_that.variant,_that.purchaseYear,_that.batteryCapacityKwh,_that.connectorType,_that.maxAcKw,_that.maxDcKw,_that.typicalEfficiencyKmPerKwh,_that.batteryHealthPercent,_that.efficiencyCorrectionPercent,_that.minArrivalSocPercent,_that.maxChargeSocPercent,_that.licensePlate,_that.isActive,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? userId,  String? make,  String? model,  String? variant,  int purchaseYear,  double batteryCapacityKwh,  String? connectorType,  double maxAcKw,  double maxDcKw,  double typicalEfficiencyKmPerKwh,  double batteryHealthPercent,  double efficiencyCorrectionPercent,  int minArrivalSocPercent,  int maxChargeSocPercent,  String? licensePlate,  bool isActive,  String? serverUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Vehicle() when $default != null:
return $default(_that.id,_that.userId,_that.make,_that.model,_that.variant,_that.purchaseYear,_that.batteryCapacityKwh,_that.connectorType,_that.maxAcKw,_that.maxDcKw,_that.typicalEfficiencyKmPerKwh,_that.batteryHealthPercent,_that.efficiencyCorrectionPercent,_that.minArrivalSocPercent,_that.maxChargeSocPercent,_that.licensePlate,_that.isActive,_that.serverUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Vehicle implements Vehicle {
  const _Vehicle({required this.id, this.userId, this.make, this.model, this.variant, this.purchaseYear = 0, this.batteryCapacityKwh = 0, this.connectorType, this.maxAcKw = 0, this.maxDcKw = 0, this.typicalEfficiencyKmPerKwh = 0, this.batteryHealthPercent = 0, this.efficiencyCorrectionPercent = 0, this.minArrivalSocPercent = 0, this.maxChargeSocPercent = 0, this.licensePlate, this.isActive = true, this.serverUpdatedAt});
  factory _Vehicle.fromJson(Map<String, dynamic> json) => _$VehicleFromJson(json);

@override final  String id;
@override final  String? userId;
@override final  String? make;
@override final  String? model;
@override final  String? variant;
@override@JsonKey() final  int purchaseYear;
@override@JsonKey() final  double batteryCapacityKwh;
@override final  String? connectorType;
@override@JsonKey() final  double maxAcKw;
@override@JsonKey() final  double maxDcKw;
@override@JsonKey() final  double typicalEfficiencyKmPerKwh;
@override@JsonKey() final  double batteryHealthPercent;
@override@JsonKey() final  double efficiencyCorrectionPercent;
@override@JsonKey() final  int minArrivalSocPercent;
@override@JsonKey() final  int maxChargeSocPercent;
@override final  String? licensePlate;
@override@JsonKey() final  bool isActive;
@override final  String? serverUpdatedAt;

/// Create a copy of Vehicle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VehicleCopyWith<_Vehicle> get copyWith => __$VehicleCopyWithImpl<_Vehicle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VehicleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Vehicle&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.make, make) || other.make == make)&&(identical(other.model, model) || other.model == model)&&(identical(other.variant, variant) || other.variant == variant)&&(identical(other.purchaseYear, purchaseYear) || other.purchaseYear == purchaseYear)&&(identical(other.batteryCapacityKwh, batteryCapacityKwh) || other.batteryCapacityKwh == batteryCapacityKwh)&&(identical(other.connectorType, connectorType) || other.connectorType == connectorType)&&(identical(other.maxAcKw, maxAcKw) || other.maxAcKw == maxAcKw)&&(identical(other.maxDcKw, maxDcKw) || other.maxDcKw == maxDcKw)&&(identical(other.typicalEfficiencyKmPerKwh, typicalEfficiencyKmPerKwh) || other.typicalEfficiencyKmPerKwh == typicalEfficiencyKmPerKwh)&&(identical(other.batteryHealthPercent, batteryHealthPercent) || other.batteryHealthPercent == batteryHealthPercent)&&(identical(other.efficiencyCorrectionPercent, efficiencyCorrectionPercent) || other.efficiencyCorrectionPercent == efficiencyCorrectionPercent)&&(identical(other.minArrivalSocPercent, minArrivalSocPercent) || other.minArrivalSocPercent == minArrivalSocPercent)&&(identical(other.maxChargeSocPercent, maxChargeSocPercent) || other.maxChargeSocPercent == maxChargeSocPercent)&&(identical(other.licensePlate, licensePlate) || other.licensePlate == licensePlate)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.serverUpdatedAt, serverUpdatedAt) || other.serverUpdatedAt == serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,make,model,variant,purchaseYear,batteryCapacityKwh,connectorType,maxAcKw,maxDcKw,typicalEfficiencyKmPerKwh,batteryHealthPercent,efficiencyCorrectionPercent,minArrivalSocPercent,maxChargeSocPercent,licensePlate,isActive,serverUpdatedAt);
}

@override
String toString() {
    return 'Vehicle(id: $id, userId: $userId, make: $make, model: $model, variant: $variant, purchaseYear: $purchaseYear, batteryCapacityKwh: $batteryCapacityKwh, connectorType: $connectorType, maxAcKw: $maxAcKw, maxDcKw: $maxDcKw, typicalEfficiencyKmPerKwh: $typicalEfficiencyKmPerKwh, batteryHealthPercent: $batteryHealthPercent, efficiencyCorrectionPercent: $efficiencyCorrectionPercent, minArrivalSocPercent: $minArrivalSocPercent, maxChargeSocPercent: $maxChargeSocPercent, licensePlate: $licensePlate, isActive: $isActive, serverUpdatedAt: $serverUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$VehicleCopyWith<$Res> implements $VehicleCopyWith<$Res> {
  factory _$VehicleCopyWith(_Vehicle value, $Res Function(_Vehicle) _then) = __$VehicleCopyWithImpl;
@override @useResult
$Res call({
 String id, String? userId, String? make, String? model, String? variant, int purchaseYear, double batteryCapacityKwh, String? connectorType, double maxAcKw, double maxDcKw, double typicalEfficiencyKmPerKwh, double batteryHealthPercent, double efficiencyCorrectionPercent, int minArrivalSocPercent, int maxChargeSocPercent, String? licensePlate, bool isActive, String? serverUpdatedAt
});




}
/// @nodoc
class __$VehicleCopyWithImpl<$Res>
    implements _$VehicleCopyWith<$Res> {
  __$VehicleCopyWithImpl(this._self, this._then);

  final _Vehicle _self;
  final $Res Function(_Vehicle) _then;

/// Create a copy of Vehicle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = freezed,Object? make = freezed,Object? model = freezed,Object? variant = freezed,Object? purchaseYear = null,Object? batteryCapacityKwh = null,Object? connectorType = freezed,Object? maxAcKw = null,Object? maxDcKw = null,Object? typicalEfficiencyKmPerKwh = null,Object? batteryHealthPercent = null,Object? efficiencyCorrectionPercent = null,Object? minArrivalSocPercent = null,Object? maxChargeSocPercent = null,Object? licensePlate = freezed,Object? isActive = null,Object? serverUpdatedAt = freezed,}) {
  return _then(_Vehicle(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,make: freezed == make ? _self.make : make // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,variant: freezed == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as String?,purchaseYear: null == purchaseYear ? _self.purchaseYear : purchaseYear // ignore: cast_nullable_to_non_nullable
as int,batteryCapacityKwh: null == batteryCapacityKwh ? _self.batteryCapacityKwh : batteryCapacityKwh // ignore: cast_nullable_to_non_nullable
as double,connectorType: freezed == connectorType ? _self.connectorType : connectorType // ignore: cast_nullable_to_non_nullable
as String?,maxAcKw: null == maxAcKw ? _self.maxAcKw : maxAcKw // ignore: cast_nullable_to_non_nullable
as double,maxDcKw: null == maxDcKw ? _self.maxDcKw : maxDcKw // ignore: cast_nullable_to_non_nullable
as double,typicalEfficiencyKmPerKwh: null == typicalEfficiencyKmPerKwh ? _self.typicalEfficiencyKmPerKwh : typicalEfficiencyKmPerKwh // ignore: cast_nullable_to_non_nullable
as double,batteryHealthPercent: null == batteryHealthPercent ? _self.batteryHealthPercent : batteryHealthPercent // ignore: cast_nullable_to_non_nullable
as double,efficiencyCorrectionPercent: null == efficiencyCorrectionPercent ? _self.efficiencyCorrectionPercent : efficiencyCorrectionPercent // ignore: cast_nullable_to_non_nullable
as double,minArrivalSocPercent: null == minArrivalSocPercent ? _self.minArrivalSocPercent : minArrivalSocPercent // ignore: cast_nullable_to_non_nullable
as int,maxChargeSocPercent: null == maxChargeSocPercent ? _self.maxChargeSocPercent : maxChargeSocPercent // ignore: cast_nullable_to_non_nullable
as int,licensePlate: freezed == licensePlate ? _self.licensePlate : licensePlate // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ChargerStation {

 String get id; String? get hostId; String? get hostName; String? get name; String? get address; double get latitude; double get longitude; String? get locationType; String? get operatingHours; double get pricePerKwh; double get serviceFee; double get gatewayFee; String? get verificationLevel; bool get isVerified; bool get isPaused; String? get approvalStatus; String? get reviewNote; String? get connectorTypes; double get maxPowerKw; bool get isDcCapable; int get portCount; String? get accessRules; double get rating; double get reliabilityScore; int get incidentCount; int get lastUpdatedMs; String? get serverUpdatedAt;
/// Create a copy of ChargerStation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChargerStationCopyWith<ChargerStation> get copyWith => _$ChargerStationCopyWithImpl<ChargerStation>(this as ChargerStation, _$identity);

  /// Serializes this ChargerStation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ChargerStation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChargerStation&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.hostId, _this.hostId) || other.hostId == _this.hostId)&&(identical(other.hostName, _this.hostName) || other.hostName == _this.hostName)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude)&&(identical(other.locationType, _this.locationType) || other.locationType == _this.locationType)&&(identical(other.operatingHours, _this.operatingHours) || other.operatingHours == _this.operatingHours)&&(identical(other.pricePerKwh, _this.pricePerKwh) || other.pricePerKwh == _this.pricePerKwh)&&(identical(other.serviceFee, _this.serviceFee) || other.serviceFee == _this.serviceFee)&&(identical(other.gatewayFee, _this.gatewayFee) || other.gatewayFee == _this.gatewayFee)&&(identical(other.verificationLevel, _this.verificationLevel) || other.verificationLevel == _this.verificationLevel)&&(identical(other.isVerified, _this.isVerified) || other.isVerified == _this.isVerified)&&(identical(other.isPaused, _this.isPaused) || other.isPaused == _this.isPaused)&&(identical(other.approvalStatus, _this.approvalStatus) || other.approvalStatus == _this.approvalStatus)&&(identical(other.reviewNote, _this.reviewNote) || other.reviewNote == _this.reviewNote)&&(identical(other.connectorTypes, _this.connectorTypes) || other.connectorTypes == _this.connectorTypes)&&(identical(other.maxPowerKw, _this.maxPowerKw) || other.maxPowerKw == _this.maxPowerKw)&&(identical(other.isDcCapable, _this.isDcCapable) || other.isDcCapable == _this.isDcCapable)&&(identical(other.portCount, _this.portCount) || other.portCount == _this.portCount)&&(identical(other.accessRules, _this.accessRules) || other.accessRules == _this.accessRules)&&(identical(other.rating, _this.rating) || other.rating == _this.rating)&&(identical(other.reliabilityScore, _this.reliabilityScore) || other.reliabilityScore == _this.reliabilityScore)&&(identical(other.incidentCount, _this.incidentCount) || other.incidentCount == _this.incidentCount)&&(identical(other.lastUpdatedMs, _this.lastUpdatedMs) || other.lastUpdatedMs == _this.lastUpdatedMs)&&(identical(other.serverUpdatedAt, _this.serverUpdatedAt) || other.serverUpdatedAt == _this.serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ChargerStation;
  return Object.hashAll([runtimeType,_this.id,_this.hostId,_this.hostName,_this.name,_this.address,_this.latitude,_this.longitude,_this.locationType,_this.operatingHours,_this.pricePerKwh,_this.serviceFee,_this.gatewayFee,_this.verificationLevel,_this.isVerified,_this.isPaused,_this.approvalStatus,_this.reviewNote,_this.connectorTypes,_this.maxPowerKw,_this.isDcCapable,_this.portCount,_this.accessRules,_this.rating,_this.reliabilityScore,_this.incidentCount,_this.lastUpdatedMs,_this.serverUpdatedAt]);
}

@override
String toString() {
  final _this = this as ChargerStation;
  return 'ChargerStation(id: ${_this.id}, hostId: ${_this.hostId}, hostName: ${_this.hostName}, name: ${_this.name}, address: ${_this.address}, latitude: ${_this.latitude}, longitude: ${_this.longitude}, locationType: ${_this.locationType}, operatingHours: ${_this.operatingHours}, pricePerKwh: ${_this.pricePerKwh}, serviceFee: ${_this.serviceFee}, gatewayFee: ${_this.gatewayFee}, verificationLevel: ${_this.verificationLevel}, isVerified: ${_this.isVerified}, isPaused: ${_this.isPaused}, approvalStatus: ${_this.approvalStatus}, reviewNote: ${_this.reviewNote}, connectorTypes: ${_this.connectorTypes}, maxPowerKw: ${_this.maxPowerKw}, isDcCapable: ${_this.isDcCapable}, portCount: ${_this.portCount}, accessRules: ${_this.accessRules}, rating: ${_this.rating}, reliabilityScore: ${_this.reliabilityScore}, incidentCount: ${_this.incidentCount}, lastUpdatedMs: ${_this.lastUpdatedMs}, serverUpdatedAt: ${_this.serverUpdatedAt})';
}


}

/// @nodoc
abstract mixin class $ChargerStationCopyWith<$Res>  {
  factory $ChargerStationCopyWith(ChargerStation value, $Res Function(ChargerStation) _then) = _$ChargerStationCopyWithImpl;
@useResult
$Res call({
 String id, String? hostId, String? hostName, String? name, String? address, double latitude, double longitude, String? locationType, String? operatingHours, double pricePerKwh, double serviceFee, double gatewayFee, String? verificationLevel, bool isVerified, bool isPaused, String? approvalStatus, String? reviewNote, String? connectorTypes, double maxPowerKw, bool isDcCapable, int portCount, String? accessRules, double rating, double reliabilityScore, int incidentCount, int lastUpdatedMs, String? serverUpdatedAt
});




}
/// @nodoc
class _$ChargerStationCopyWithImpl<$Res>
    implements $ChargerStationCopyWith<$Res> {
  _$ChargerStationCopyWithImpl(this._self, this._then);

  final ChargerStation _self;
  final $Res Function(ChargerStation) _then;

/// Create a copy of ChargerStation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? hostId = freezed,Object? hostName = freezed,Object? name = freezed,Object? address = freezed,Object? latitude = null,Object? longitude = null,Object? locationType = freezed,Object? operatingHours = freezed,Object? pricePerKwh = null,Object? serviceFee = null,Object? gatewayFee = null,Object? verificationLevel = freezed,Object? isVerified = null,Object? isPaused = null,Object? approvalStatus = freezed,Object? reviewNote = freezed,Object? connectorTypes = freezed,Object? maxPowerKw = null,Object? isDcCapable = null,Object? portCount = null,Object? accessRules = freezed,Object? rating = null,Object? reliabilityScore = null,Object? incidentCount = null,Object? lastUpdatedMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(ChargerStation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,hostId: freezed == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String?,hostName: freezed == hostName ? _self.hostName : hostName // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,locationType: freezed == locationType ? _self.locationType : locationType // ignore: cast_nullable_to_non_nullable
as String?,operatingHours: freezed == operatingHours ? _self.operatingHours : operatingHours // ignore: cast_nullable_to_non_nullable
as String?,pricePerKwh: null == pricePerKwh ? _self.pricePerKwh : pricePerKwh // ignore: cast_nullable_to_non_nullable
as double,serviceFee: null == serviceFee ? _self.serviceFee : serviceFee // ignore: cast_nullable_to_non_nullable
as double,gatewayFee: null == gatewayFee ? _self.gatewayFee : gatewayFee // ignore: cast_nullable_to_non_nullable
as double,verificationLevel: freezed == verificationLevel ? _self.verificationLevel : verificationLevel // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,isPaused: null == isPaused ? _self.isPaused : isPaused // ignore: cast_nullable_to_non_nullable
as bool,approvalStatus: freezed == approvalStatus ? _self.approvalStatus : approvalStatus // ignore: cast_nullable_to_non_nullable
as String?,reviewNote: freezed == reviewNote ? _self.reviewNote : reviewNote // ignore: cast_nullable_to_non_nullable
as String?,connectorTypes: freezed == connectorTypes ? _self.connectorTypes : connectorTypes // ignore: cast_nullable_to_non_nullable
as String?,maxPowerKw: null == maxPowerKw ? _self.maxPowerKw : maxPowerKw // ignore: cast_nullable_to_non_nullable
as double,isDcCapable: null == isDcCapable ? _self.isDcCapable : isDcCapable // ignore: cast_nullable_to_non_nullable
as bool,portCount: null == portCount ? _self.portCount : portCount // ignore: cast_nullable_to_non_nullable
as int,accessRules: freezed == accessRules ? _self.accessRules : accessRules // ignore: cast_nullable_to_non_nullable
as String?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reliabilityScore: null == reliabilityScore ? _self.reliabilityScore : reliabilityScore // ignore: cast_nullable_to_non_nullable
as double,incidentCount: null == incidentCount ? _self.incidentCount : incidentCount // ignore: cast_nullable_to_non_nullable
as int,lastUpdatedMs: null == lastUpdatedMs ? _self.lastUpdatedMs : lastUpdatedMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChargerStation].
extension ChargerStationPatterns on ChargerStation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChargerStation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChargerStation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChargerStation value)  $default,){
final _that = this;
switch (_that) {
case _ChargerStation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChargerStation value)?  $default,){
final _that = this;
switch (_that) {
case _ChargerStation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? hostId,  String? hostName,  String? name,  String? address,  double latitude,  double longitude,  String? locationType,  String? operatingHours,  double pricePerKwh,  double serviceFee,  double gatewayFee,  String? verificationLevel,  bool isVerified,  bool isPaused,  String? approvalStatus,  String? reviewNote,  String? connectorTypes,  double maxPowerKw,  bool isDcCapable,  int portCount,  String? accessRules,  double rating,  double reliabilityScore,  int incidentCount,  int lastUpdatedMs,  String? serverUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChargerStation() when $default != null:
return $default(_that.id,_that.hostId,_that.hostName,_that.name,_that.address,_that.latitude,_that.longitude,_that.locationType,_that.operatingHours,_that.pricePerKwh,_that.serviceFee,_that.gatewayFee,_that.verificationLevel,_that.isVerified,_that.isPaused,_that.approvalStatus,_that.reviewNote,_that.connectorTypes,_that.maxPowerKw,_that.isDcCapable,_that.portCount,_that.accessRules,_that.rating,_that.reliabilityScore,_that.incidentCount,_that.lastUpdatedMs,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? hostId,  String? hostName,  String? name,  String? address,  double latitude,  double longitude,  String? locationType,  String? operatingHours,  double pricePerKwh,  double serviceFee,  double gatewayFee,  String? verificationLevel,  bool isVerified,  bool isPaused,  String? approvalStatus,  String? reviewNote,  String? connectorTypes,  double maxPowerKw,  bool isDcCapable,  int portCount,  String? accessRules,  double rating,  double reliabilityScore,  int incidentCount,  int lastUpdatedMs,  String? serverUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _ChargerStation():
return $default(_that.id,_that.hostId,_that.hostName,_that.name,_that.address,_that.latitude,_that.longitude,_that.locationType,_that.operatingHours,_that.pricePerKwh,_that.serviceFee,_that.gatewayFee,_that.verificationLevel,_that.isVerified,_that.isPaused,_that.approvalStatus,_that.reviewNote,_that.connectorTypes,_that.maxPowerKw,_that.isDcCapable,_that.portCount,_that.accessRules,_that.rating,_that.reliabilityScore,_that.incidentCount,_that.lastUpdatedMs,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? hostId,  String? hostName,  String? name,  String? address,  double latitude,  double longitude,  String? locationType,  String? operatingHours,  double pricePerKwh,  double serviceFee,  double gatewayFee,  String? verificationLevel,  bool isVerified,  bool isPaused,  String? approvalStatus,  String? reviewNote,  String? connectorTypes,  double maxPowerKw,  bool isDcCapable,  int portCount,  String? accessRules,  double rating,  double reliabilityScore,  int incidentCount,  int lastUpdatedMs,  String? serverUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ChargerStation() when $default != null:
return $default(_that.id,_that.hostId,_that.hostName,_that.name,_that.address,_that.latitude,_that.longitude,_that.locationType,_that.operatingHours,_that.pricePerKwh,_that.serviceFee,_that.gatewayFee,_that.verificationLevel,_that.isVerified,_that.isPaused,_that.approvalStatus,_that.reviewNote,_that.connectorTypes,_that.maxPowerKw,_that.isDcCapable,_that.portCount,_that.accessRules,_that.rating,_that.reliabilityScore,_that.incidentCount,_that.lastUpdatedMs,_that.serverUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChargerStation implements ChargerStation {
  const _ChargerStation({required this.id, this.hostId, this.hostName, this.name, this.address, this.latitude = 0, this.longitude = 0, this.locationType, this.operatingHours, this.pricePerKwh = 0, this.serviceFee = 0, this.gatewayFee = 0, this.verificationLevel, this.isVerified = false, this.isPaused = false, this.approvalStatus, this.reviewNote, this.connectorTypes, this.maxPowerKw = 0, this.isDcCapable = false, this.portCount = 0, this.accessRules, this.rating = 0, this.reliabilityScore = 0, this.incidentCount = 0, this.lastUpdatedMs = 0, this.serverUpdatedAt});
  factory _ChargerStation.fromJson(Map<String, dynamic> json) => _$ChargerStationFromJson(json);

@override final  String id;
@override final  String? hostId;
@override final  String? hostName;
@override final  String? name;
@override final  String? address;
@override@JsonKey() final  double latitude;
@override@JsonKey() final  double longitude;
@override final  String? locationType;
@override final  String? operatingHours;
@override@JsonKey() final  double pricePerKwh;
@override@JsonKey() final  double serviceFee;
@override@JsonKey() final  double gatewayFee;
@override final  String? verificationLevel;
@override@JsonKey() final  bool isVerified;
@override@JsonKey() final  bool isPaused;
@override final  String? approvalStatus;
@override final  String? reviewNote;
@override final  String? connectorTypes;
@override@JsonKey() final  double maxPowerKw;
@override@JsonKey() final  bool isDcCapable;
@override@JsonKey() final  int portCount;
@override final  String? accessRules;
@override@JsonKey() final  double rating;
@override@JsonKey() final  double reliabilityScore;
@override@JsonKey() final  int incidentCount;
@override@JsonKey() final  int lastUpdatedMs;
@override final  String? serverUpdatedAt;

/// Create a copy of ChargerStation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChargerStationCopyWith<_ChargerStation> get copyWith => __$ChargerStationCopyWithImpl<_ChargerStation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChargerStationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChargerStation&&(identical(other.id, id) || other.id == id)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.hostName, hostName) || other.hostName == hostName)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.locationType, locationType) || other.locationType == locationType)&&(identical(other.operatingHours, operatingHours) || other.operatingHours == operatingHours)&&(identical(other.pricePerKwh, pricePerKwh) || other.pricePerKwh == pricePerKwh)&&(identical(other.serviceFee, serviceFee) || other.serviceFee == serviceFee)&&(identical(other.gatewayFee, gatewayFee) || other.gatewayFee == gatewayFee)&&(identical(other.verificationLevel, verificationLevel) || other.verificationLevel == verificationLevel)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.isPaused, isPaused) || other.isPaused == isPaused)&&(identical(other.approvalStatus, approvalStatus) || other.approvalStatus == approvalStatus)&&(identical(other.reviewNote, reviewNote) || other.reviewNote == reviewNote)&&(identical(other.connectorTypes, connectorTypes) || other.connectorTypes == connectorTypes)&&(identical(other.maxPowerKw, maxPowerKw) || other.maxPowerKw == maxPowerKw)&&(identical(other.isDcCapable, isDcCapable) || other.isDcCapable == isDcCapable)&&(identical(other.portCount, portCount) || other.portCount == portCount)&&(identical(other.accessRules, accessRules) || other.accessRules == accessRules)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reliabilityScore, reliabilityScore) || other.reliabilityScore == reliabilityScore)&&(identical(other.incidentCount, incidentCount) || other.incidentCount == incidentCount)&&(identical(other.lastUpdatedMs, lastUpdatedMs) || other.lastUpdatedMs == lastUpdatedMs)&&(identical(other.serverUpdatedAt, serverUpdatedAt) || other.serverUpdatedAt == serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,hostId,hostName,name,address,latitude,longitude,locationType,operatingHours,pricePerKwh,serviceFee,gatewayFee,verificationLevel,isVerified,isPaused,approvalStatus,reviewNote,connectorTypes,maxPowerKw,isDcCapable,portCount,accessRules,rating,reliabilityScore,incidentCount,lastUpdatedMs,serverUpdatedAt]);
}

@override
String toString() {
    return 'ChargerStation(id: $id, hostId: $hostId, hostName: $hostName, name: $name, address: $address, latitude: $latitude, longitude: $longitude, locationType: $locationType, operatingHours: $operatingHours, pricePerKwh: $pricePerKwh, serviceFee: $serviceFee, gatewayFee: $gatewayFee, verificationLevel: $verificationLevel, isVerified: $isVerified, isPaused: $isPaused, approvalStatus: $approvalStatus, reviewNote: $reviewNote, connectorTypes: $connectorTypes, maxPowerKw: $maxPowerKw, isDcCapable: $isDcCapable, portCount: $portCount, accessRules: $accessRules, rating: $rating, reliabilityScore: $reliabilityScore, incidentCount: $incidentCount, lastUpdatedMs: $lastUpdatedMs, serverUpdatedAt: $serverUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$ChargerStationCopyWith<$Res> implements $ChargerStationCopyWith<$Res> {
  factory _$ChargerStationCopyWith(_ChargerStation value, $Res Function(_ChargerStation) _then) = __$ChargerStationCopyWithImpl;
@override @useResult
$Res call({
 String id, String? hostId, String? hostName, String? name, String? address, double latitude, double longitude, String? locationType, String? operatingHours, double pricePerKwh, double serviceFee, double gatewayFee, String? verificationLevel, bool isVerified, bool isPaused, String? approvalStatus, String? reviewNote, String? connectorTypes, double maxPowerKw, bool isDcCapable, int portCount, String? accessRules, double rating, double reliabilityScore, int incidentCount, int lastUpdatedMs, String? serverUpdatedAt
});




}
/// @nodoc
class __$ChargerStationCopyWithImpl<$Res>
    implements _$ChargerStationCopyWith<$Res> {
  __$ChargerStationCopyWithImpl(this._self, this._then);

  final _ChargerStation _self;
  final $Res Function(_ChargerStation) _then;

/// Create a copy of ChargerStation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? hostId = freezed,Object? hostName = freezed,Object? name = freezed,Object? address = freezed,Object? latitude = null,Object? longitude = null,Object? locationType = freezed,Object? operatingHours = freezed,Object? pricePerKwh = null,Object? serviceFee = null,Object? gatewayFee = null,Object? verificationLevel = freezed,Object? isVerified = null,Object? isPaused = null,Object? approvalStatus = freezed,Object? reviewNote = freezed,Object? connectorTypes = freezed,Object? maxPowerKw = null,Object? isDcCapable = null,Object? portCount = null,Object? accessRules = freezed,Object? rating = null,Object? reliabilityScore = null,Object? incidentCount = null,Object? lastUpdatedMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(_ChargerStation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,hostId: freezed == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String?,hostName: freezed == hostName ? _self.hostName : hostName // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,locationType: freezed == locationType ? _self.locationType : locationType // ignore: cast_nullable_to_non_nullable
as String?,operatingHours: freezed == operatingHours ? _self.operatingHours : operatingHours // ignore: cast_nullable_to_non_nullable
as String?,pricePerKwh: null == pricePerKwh ? _self.pricePerKwh : pricePerKwh // ignore: cast_nullable_to_non_nullable
as double,serviceFee: null == serviceFee ? _self.serviceFee : serviceFee // ignore: cast_nullable_to_non_nullable
as double,gatewayFee: null == gatewayFee ? _self.gatewayFee : gatewayFee // ignore: cast_nullable_to_non_nullable
as double,verificationLevel: freezed == verificationLevel ? _self.verificationLevel : verificationLevel // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,isPaused: null == isPaused ? _self.isPaused : isPaused // ignore: cast_nullable_to_non_nullable
as bool,approvalStatus: freezed == approvalStatus ? _self.approvalStatus : approvalStatus // ignore: cast_nullable_to_non_nullable
as String?,reviewNote: freezed == reviewNote ? _self.reviewNote : reviewNote // ignore: cast_nullable_to_non_nullable
as String?,connectorTypes: freezed == connectorTypes ? _self.connectorTypes : connectorTypes // ignore: cast_nullable_to_non_nullable
as String?,maxPowerKw: null == maxPowerKw ? _self.maxPowerKw : maxPowerKw // ignore: cast_nullable_to_non_nullable
as double,isDcCapable: null == isDcCapable ? _self.isDcCapable : isDcCapable // ignore: cast_nullable_to_non_nullable
as bool,portCount: null == portCount ? _self.portCount : portCount // ignore: cast_nullable_to_non_nullable
as int,accessRules: freezed == accessRules ? _self.accessRules : accessRules // ignore: cast_nullable_to_non_nullable
as String?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reliabilityScore: null == reliabilityScore ? _self.reliabilityScore : reliabilityScore // ignore: cast_nullable_to_non_nullable
as double,incidentCount: null == incidentCount ? _self.incidentCount : incidentCount // ignore: cast_nullable_to_non_nullable
as int,lastUpdatedMs: null == lastUpdatedMs ? _self.lastUpdatedMs : lastUpdatedMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ChargerPort {

 String get id; String? get stationId; String? get portNumber; String? get connectorType; double get powerKw; bool get isDc; String? get status; String? get serverUpdatedAt;
/// Create a copy of ChargerPort
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChargerPortCopyWith<ChargerPort> get copyWith => _$ChargerPortCopyWithImpl<ChargerPort>(this as ChargerPort, _$identity);

  /// Serializes this ChargerPort to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ChargerPort;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChargerPort&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.stationId, _this.stationId) || other.stationId == _this.stationId)&&(identical(other.portNumber, _this.portNumber) || other.portNumber == _this.portNumber)&&(identical(other.connectorType, _this.connectorType) || other.connectorType == _this.connectorType)&&(identical(other.powerKw, _this.powerKw) || other.powerKw == _this.powerKw)&&(identical(other.isDc, _this.isDc) || other.isDc == _this.isDc)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.serverUpdatedAt, _this.serverUpdatedAt) || other.serverUpdatedAt == _this.serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ChargerPort;
  return Object.hash(runtimeType,_this.id,_this.stationId,_this.portNumber,_this.connectorType,_this.powerKw,_this.isDc,_this.status,_this.serverUpdatedAt);
}

@override
String toString() {
  final _this = this as ChargerPort;
  return 'ChargerPort(id: ${_this.id}, stationId: ${_this.stationId}, portNumber: ${_this.portNumber}, connectorType: ${_this.connectorType}, powerKw: ${_this.powerKw}, isDc: ${_this.isDc}, status: ${_this.status}, serverUpdatedAt: ${_this.serverUpdatedAt})';
}


}

/// @nodoc
abstract mixin class $ChargerPortCopyWith<$Res>  {
  factory $ChargerPortCopyWith(ChargerPort value, $Res Function(ChargerPort) _then) = _$ChargerPortCopyWithImpl;
@useResult
$Res call({
 String id, String? stationId, String? portNumber, String? connectorType, double powerKw, bool isDc, String? status, String? serverUpdatedAt
});




}
/// @nodoc
class _$ChargerPortCopyWithImpl<$Res>
    implements $ChargerPortCopyWith<$Res> {
  _$ChargerPortCopyWithImpl(this._self, this._then);

  final ChargerPort _self;
  final $Res Function(ChargerPort) _then;

/// Create a copy of ChargerPort
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? stationId = freezed,Object? portNumber = freezed,Object? connectorType = freezed,Object? powerKw = null,Object? isDc = null,Object? status = freezed,Object? serverUpdatedAt = freezed,}) {
  return _then(ChargerPort(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,stationId: freezed == stationId ? _self.stationId : stationId // ignore: cast_nullable_to_non_nullable
as String?,portNumber: freezed == portNumber ? _self.portNumber : portNumber // ignore: cast_nullable_to_non_nullable
as String?,connectorType: freezed == connectorType ? _self.connectorType : connectorType // ignore: cast_nullable_to_non_nullable
as String?,powerKw: null == powerKw ? _self.powerKw : powerKw // ignore: cast_nullable_to_non_nullable
as double,isDc: null == isDc ? _self.isDc : isDc // ignore: cast_nullable_to_non_nullable
as bool,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChargerPort].
extension ChargerPortPatterns on ChargerPort {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChargerPort value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChargerPort() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChargerPort value)  $default,){
final _that = this;
switch (_that) {
case _ChargerPort():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChargerPort value)?  $default,){
final _that = this;
switch (_that) {
case _ChargerPort() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? stationId,  String? portNumber,  String? connectorType,  double powerKw,  bool isDc,  String? status,  String? serverUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChargerPort() when $default != null:
return $default(_that.id,_that.stationId,_that.portNumber,_that.connectorType,_that.powerKw,_that.isDc,_that.status,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? stationId,  String? portNumber,  String? connectorType,  double powerKw,  bool isDc,  String? status,  String? serverUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _ChargerPort():
return $default(_that.id,_that.stationId,_that.portNumber,_that.connectorType,_that.powerKw,_that.isDc,_that.status,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? stationId,  String? portNumber,  String? connectorType,  double powerKw,  bool isDc,  String? status,  String? serverUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ChargerPort() when $default != null:
return $default(_that.id,_that.stationId,_that.portNumber,_that.connectorType,_that.powerKw,_that.isDc,_that.status,_that.serverUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChargerPort implements ChargerPort {
  const _ChargerPort({required this.id, this.stationId, this.portNumber, this.connectorType, this.powerKw = 0, this.isDc = false, this.status, this.serverUpdatedAt});
  factory _ChargerPort.fromJson(Map<String, dynamic> json) => _$ChargerPortFromJson(json);

@override final  String id;
@override final  String? stationId;
@override final  String? portNumber;
@override final  String? connectorType;
@override@JsonKey() final  double powerKw;
@override@JsonKey() final  bool isDc;
@override final  String? status;
@override final  String? serverUpdatedAt;

/// Create a copy of ChargerPort
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChargerPortCopyWith<_ChargerPort> get copyWith => __$ChargerPortCopyWithImpl<_ChargerPort>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChargerPortToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChargerPort&&(identical(other.id, id) || other.id == id)&&(identical(other.stationId, stationId) || other.stationId == stationId)&&(identical(other.portNumber, portNumber) || other.portNumber == portNumber)&&(identical(other.connectorType, connectorType) || other.connectorType == connectorType)&&(identical(other.powerKw, powerKw) || other.powerKw == powerKw)&&(identical(other.isDc, isDc) || other.isDc == isDc)&&(identical(other.status, status) || other.status == status)&&(identical(other.serverUpdatedAt, serverUpdatedAt) || other.serverUpdatedAt == serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,stationId,portNumber,connectorType,powerKw,isDc,status,serverUpdatedAt);
}

@override
String toString() {
    return 'ChargerPort(id: $id, stationId: $stationId, portNumber: $portNumber, connectorType: $connectorType, powerKw: $powerKw, isDc: $isDc, status: $status, serverUpdatedAt: $serverUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$ChargerPortCopyWith<$Res> implements $ChargerPortCopyWith<$Res> {
  factory _$ChargerPortCopyWith(_ChargerPort value, $Res Function(_ChargerPort) _then) = __$ChargerPortCopyWithImpl;
@override @useResult
$Res call({
 String id, String? stationId, String? portNumber, String? connectorType, double powerKw, bool isDc, String? status, String? serverUpdatedAt
});




}
/// @nodoc
class __$ChargerPortCopyWithImpl<$Res>
    implements _$ChargerPortCopyWith<$Res> {
  __$ChargerPortCopyWithImpl(this._self, this._then);

  final _ChargerPort _self;
  final $Res Function(_ChargerPort) _then;

/// Create a copy of ChargerPort
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? stationId = freezed,Object? portNumber = freezed,Object? connectorType = freezed,Object? powerKw = null,Object? isDc = null,Object? status = freezed,Object? serverUpdatedAt = freezed,}) {
  return _then(_ChargerPort(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,stationId: freezed == stationId ? _self.stationId : stationId // ignore: cast_nullable_to_non_nullable
as String?,portNumber: freezed == portNumber ? _self.portNumber : portNumber // ignore: cast_nullable_to_non_nullable
as String?,connectorType: freezed == connectorType ? _self.connectorType : connectorType // ignore: cast_nullable_to_non_nullable
as String?,powerKw: null == powerKw ? _self.powerKw : powerKw // ignore: cast_nullable_to_non_nullable
as double,isDc: null == isDc ? _self.isDc : isDc // ignore: cast_nullable_to_non_nullable
as bool,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AvailabilitySchedule {

 String get id; String? get stationId; String? get portId; int get dayOfWeek; int get openMinutes; int get closeMinutes; bool get isBlocked; String? get blockReason; int get updatedAtMs; String? get serverUpdatedAt;
/// Create a copy of AvailabilitySchedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AvailabilityScheduleCopyWith<AvailabilitySchedule> get copyWith => _$AvailabilityScheduleCopyWithImpl<AvailabilitySchedule>(this as AvailabilitySchedule, _$identity);

  /// Serializes this AvailabilitySchedule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AvailabilitySchedule;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AvailabilitySchedule&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.stationId, _this.stationId) || other.stationId == _this.stationId)&&(identical(other.portId, _this.portId) || other.portId == _this.portId)&&(identical(other.dayOfWeek, _this.dayOfWeek) || other.dayOfWeek == _this.dayOfWeek)&&(identical(other.openMinutes, _this.openMinutes) || other.openMinutes == _this.openMinutes)&&(identical(other.closeMinutes, _this.closeMinutes) || other.closeMinutes == _this.closeMinutes)&&(identical(other.isBlocked, _this.isBlocked) || other.isBlocked == _this.isBlocked)&&(identical(other.blockReason, _this.blockReason) || other.blockReason == _this.blockReason)&&(identical(other.updatedAtMs, _this.updatedAtMs) || other.updatedAtMs == _this.updatedAtMs)&&(identical(other.serverUpdatedAt, _this.serverUpdatedAt) || other.serverUpdatedAt == _this.serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AvailabilitySchedule;
  return Object.hash(runtimeType,_this.id,_this.stationId,_this.portId,_this.dayOfWeek,_this.openMinutes,_this.closeMinutes,_this.isBlocked,_this.blockReason,_this.updatedAtMs,_this.serverUpdatedAt);
}

@override
String toString() {
  final _this = this as AvailabilitySchedule;
  return 'AvailabilitySchedule(id: ${_this.id}, stationId: ${_this.stationId}, portId: ${_this.portId}, dayOfWeek: ${_this.dayOfWeek}, openMinutes: ${_this.openMinutes}, closeMinutes: ${_this.closeMinutes}, isBlocked: ${_this.isBlocked}, blockReason: ${_this.blockReason}, updatedAtMs: ${_this.updatedAtMs}, serverUpdatedAt: ${_this.serverUpdatedAt})';
}


}

/// @nodoc
abstract mixin class $AvailabilityScheduleCopyWith<$Res>  {
  factory $AvailabilityScheduleCopyWith(AvailabilitySchedule value, $Res Function(AvailabilitySchedule) _then) = _$AvailabilityScheduleCopyWithImpl;
@useResult
$Res call({
 String id, String? stationId, String? portId, int dayOfWeek, int openMinutes, int closeMinutes, bool isBlocked, String? blockReason, int updatedAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class _$AvailabilityScheduleCopyWithImpl<$Res>
    implements $AvailabilityScheduleCopyWith<$Res> {
  _$AvailabilityScheduleCopyWithImpl(this._self, this._then);

  final AvailabilitySchedule _self;
  final $Res Function(AvailabilitySchedule) _then;

/// Create a copy of AvailabilitySchedule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? stationId = freezed,Object? portId = freezed,Object? dayOfWeek = null,Object? openMinutes = null,Object? closeMinutes = null,Object? isBlocked = null,Object? blockReason = freezed,Object? updatedAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(AvailabilitySchedule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,stationId: freezed == stationId ? _self.stationId : stationId // ignore: cast_nullable_to_non_nullable
as String?,portId: freezed == portId ? _self.portId : portId // ignore: cast_nullable_to_non_nullable
as String?,dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,openMinutes: null == openMinutes ? _self.openMinutes : openMinutes // ignore: cast_nullable_to_non_nullable
as int,closeMinutes: null == closeMinutes ? _self.closeMinutes : closeMinutes // ignore: cast_nullable_to_non_nullable
as int,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,blockReason: freezed == blockReason ? _self.blockReason : blockReason // ignore: cast_nullable_to_non_nullable
as String?,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AvailabilitySchedule].
extension AvailabilitySchedulePatterns on AvailabilitySchedule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AvailabilitySchedule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AvailabilitySchedule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AvailabilitySchedule value)  $default,){
final _that = this;
switch (_that) {
case _AvailabilitySchedule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AvailabilitySchedule value)?  $default,){
final _that = this;
switch (_that) {
case _AvailabilitySchedule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? stationId,  String? portId,  int dayOfWeek,  int openMinutes,  int closeMinutes,  bool isBlocked,  String? blockReason,  int updatedAtMs,  String? serverUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AvailabilitySchedule() when $default != null:
return $default(_that.id,_that.stationId,_that.portId,_that.dayOfWeek,_that.openMinutes,_that.closeMinutes,_that.isBlocked,_that.blockReason,_that.updatedAtMs,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? stationId,  String? portId,  int dayOfWeek,  int openMinutes,  int closeMinutes,  bool isBlocked,  String? blockReason,  int updatedAtMs,  String? serverUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _AvailabilitySchedule():
return $default(_that.id,_that.stationId,_that.portId,_that.dayOfWeek,_that.openMinutes,_that.closeMinutes,_that.isBlocked,_that.blockReason,_that.updatedAtMs,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? stationId,  String? portId,  int dayOfWeek,  int openMinutes,  int closeMinutes,  bool isBlocked,  String? blockReason,  int updatedAtMs,  String? serverUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AvailabilitySchedule() when $default != null:
return $default(_that.id,_that.stationId,_that.portId,_that.dayOfWeek,_that.openMinutes,_that.closeMinutes,_that.isBlocked,_that.blockReason,_that.updatedAtMs,_that.serverUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AvailabilitySchedule implements AvailabilitySchedule {
  const _AvailabilitySchedule({required this.id, this.stationId, this.portId, this.dayOfWeek = 0, this.openMinutes = 0, this.closeMinutes = 0, this.isBlocked = false, this.blockReason, this.updatedAtMs = 0, this.serverUpdatedAt});
  factory _AvailabilitySchedule.fromJson(Map<String, dynamic> json) => _$AvailabilityScheduleFromJson(json);

@override final  String id;
@override final  String? stationId;
@override final  String? portId;
@override@JsonKey() final  int dayOfWeek;
@override@JsonKey() final  int openMinutes;
@override@JsonKey() final  int closeMinutes;
@override@JsonKey() final  bool isBlocked;
@override final  String? blockReason;
@override@JsonKey() final  int updatedAtMs;
@override final  String? serverUpdatedAt;

/// Create a copy of AvailabilitySchedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AvailabilityScheduleCopyWith<_AvailabilitySchedule> get copyWith => __$AvailabilityScheduleCopyWithImpl<_AvailabilitySchedule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AvailabilityScheduleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AvailabilitySchedule&&(identical(other.id, id) || other.id == id)&&(identical(other.stationId, stationId) || other.stationId == stationId)&&(identical(other.portId, portId) || other.portId == portId)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.openMinutes, openMinutes) || other.openMinutes == openMinutes)&&(identical(other.closeMinutes, closeMinutes) || other.closeMinutes == closeMinutes)&&(identical(other.isBlocked, isBlocked) || other.isBlocked == isBlocked)&&(identical(other.blockReason, blockReason) || other.blockReason == blockReason)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs)&&(identical(other.serverUpdatedAt, serverUpdatedAt) || other.serverUpdatedAt == serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,stationId,portId,dayOfWeek,openMinutes,closeMinutes,isBlocked,blockReason,updatedAtMs,serverUpdatedAt);
}

@override
String toString() {
    return 'AvailabilitySchedule(id: $id, stationId: $stationId, portId: $portId, dayOfWeek: $dayOfWeek, openMinutes: $openMinutes, closeMinutes: $closeMinutes, isBlocked: $isBlocked, blockReason: $blockReason, updatedAtMs: $updatedAtMs, serverUpdatedAt: $serverUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$AvailabilityScheduleCopyWith<$Res> implements $AvailabilityScheduleCopyWith<$Res> {
  factory _$AvailabilityScheduleCopyWith(_AvailabilitySchedule value, $Res Function(_AvailabilitySchedule) _then) = __$AvailabilityScheduleCopyWithImpl;
@override @useResult
$Res call({
 String id, String? stationId, String? portId, int dayOfWeek, int openMinutes, int closeMinutes, bool isBlocked, String? blockReason, int updatedAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class __$AvailabilityScheduleCopyWithImpl<$Res>
    implements _$AvailabilityScheduleCopyWith<$Res> {
  __$AvailabilityScheduleCopyWithImpl(this._self, this._then);

  final _AvailabilitySchedule _self;
  final $Res Function(_AvailabilitySchedule) _then;

/// Create a copy of AvailabilitySchedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? stationId = freezed,Object? portId = freezed,Object? dayOfWeek = null,Object? openMinutes = null,Object? closeMinutes = null,Object? isBlocked = null,Object? blockReason = freezed,Object? updatedAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(_AvailabilitySchedule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,stationId: freezed == stationId ? _self.stationId : stationId // ignore: cast_nullable_to_non_nullable
as String?,portId: freezed == portId ? _self.portId : portId // ignore: cast_nullable_to_non_nullable
as String?,dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,openMinutes: null == openMinutes ? _self.openMinutes : openMinutes // ignore: cast_nullable_to_non_nullable
as int,closeMinutes: null == closeMinutes ? _self.closeMinutes : closeMinutes // ignore: cast_nullable_to_non_nullable
as int,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,blockReason: freezed == blockReason ? _self.blockReason : blockReason // ignore: cast_nullable_to_non_nullable
as String?,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AppNotification {

 String get id; String? get userId; String? get title; String? get message; bool get isRead; int get createdAtMs; String? get serverUpdatedAt;
/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppNotificationCopyWith<AppNotification> get copyWith => _$AppNotificationCopyWithImpl<AppNotification>(this as AppNotification, _$identity);

  /// Serializes this AppNotification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AppNotification;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppNotification&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.isRead, _this.isRead) || other.isRead == _this.isRead)&&(identical(other.createdAtMs, _this.createdAtMs) || other.createdAtMs == _this.createdAtMs)&&(identical(other.serverUpdatedAt, _this.serverUpdatedAt) || other.serverUpdatedAt == _this.serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AppNotification;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.title,_this.message,_this.isRead,_this.createdAtMs,_this.serverUpdatedAt);
}

@override
String toString() {
  final _this = this as AppNotification;
  return 'AppNotification(id: ${_this.id}, userId: ${_this.userId}, title: ${_this.title}, message: ${_this.message}, isRead: ${_this.isRead}, createdAtMs: ${_this.createdAtMs}, serverUpdatedAt: ${_this.serverUpdatedAt})';
}


}

/// @nodoc
abstract mixin class $AppNotificationCopyWith<$Res>  {
  factory $AppNotificationCopyWith(AppNotification value, $Res Function(AppNotification) _then) = _$AppNotificationCopyWithImpl;
@useResult
$Res call({
 String id, String? userId, String? title, String? message, bool isRead, int createdAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class _$AppNotificationCopyWithImpl<$Res>
    implements $AppNotificationCopyWith<$Res> {
  _$AppNotificationCopyWithImpl(this._self, this._then);

  final AppNotification _self;
  final $Res Function(AppNotification) _then;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = freezed,Object? title = freezed,Object? message = freezed,Object? isRead = null,Object? createdAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(AppNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppNotification].
extension AppNotificationPatterns on AppNotification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppNotification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppNotification value)  $default,){
final _that = this;
switch (_that) {
case _AppNotification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppNotification value)?  $default,){
final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? userId,  String? title,  String? message,  bool isRead,  int createdAtMs,  String? serverUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.message,_that.isRead,_that.createdAtMs,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? userId,  String? title,  String? message,  bool isRead,  int createdAtMs,  String? serverUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _AppNotification():
return $default(_that.id,_that.userId,_that.title,_that.message,_that.isRead,_that.createdAtMs,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? userId,  String? title,  String? message,  bool isRead,  int createdAtMs,  String? serverUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.message,_that.isRead,_that.createdAtMs,_that.serverUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppNotification implements AppNotification {
  const _AppNotification({required this.id, this.userId, this.title, this.message, this.isRead = false, this.createdAtMs = 0, this.serverUpdatedAt});
  factory _AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);

@override final  String id;
@override final  String? userId;
@override final  String? title;
@override final  String? message;
@override@JsonKey() final  bool isRead;
@override@JsonKey() final  int createdAtMs;
@override final  String? serverUpdatedAt;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppNotificationCopyWith<_AppNotification> get copyWith => __$AppNotificationCopyWithImpl<_AppNotification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppNotificationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.serverUpdatedAt, serverUpdatedAt) || other.serverUpdatedAt == serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,title,message,isRead,createdAtMs,serverUpdatedAt);
}

@override
String toString() {
    return 'AppNotification(id: $id, userId: $userId, title: $title, message: $message, isRead: $isRead, createdAtMs: $createdAtMs, serverUpdatedAt: $serverUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$AppNotificationCopyWith<$Res> implements $AppNotificationCopyWith<$Res> {
  factory _$AppNotificationCopyWith(_AppNotification value, $Res Function(_AppNotification) _then) = __$AppNotificationCopyWithImpl;
@override @useResult
$Res call({
 String id, String? userId, String? title, String? message, bool isRead, int createdAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class __$AppNotificationCopyWithImpl<$Res>
    implements _$AppNotificationCopyWith<$Res> {
  __$AppNotificationCopyWithImpl(this._self, this._then);

  final _AppNotification _self;
  final $Res Function(_AppNotification) _then;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = freezed,Object? title = freezed,Object? message = freezed,Object? isRead = null,Object? createdAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(_AppNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AndroidAutoSession {

 String get id; String? get userId; String? get vehicleId; String? get planId; String? get lastTemplateShown; int get lastSocUpdatePercent; int get connectedAtMs; int get lastSocUpdateAtMs; int get disconnectedAtMs; String? get serverUpdatedAt;
/// Create a copy of AndroidAutoSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AndroidAutoSessionCopyWith<AndroidAutoSession> get copyWith => _$AndroidAutoSessionCopyWithImpl<AndroidAutoSession>(this as AndroidAutoSession, _$identity);

  /// Serializes this AndroidAutoSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AndroidAutoSession;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AndroidAutoSession&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.vehicleId, _this.vehicleId) || other.vehicleId == _this.vehicleId)&&(identical(other.planId, _this.planId) || other.planId == _this.planId)&&(identical(other.lastTemplateShown, _this.lastTemplateShown) || other.lastTemplateShown == _this.lastTemplateShown)&&(identical(other.lastSocUpdatePercent, _this.lastSocUpdatePercent) || other.lastSocUpdatePercent == _this.lastSocUpdatePercent)&&(identical(other.connectedAtMs, _this.connectedAtMs) || other.connectedAtMs == _this.connectedAtMs)&&(identical(other.lastSocUpdateAtMs, _this.lastSocUpdateAtMs) || other.lastSocUpdateAtMs == _this.lastSocUpdateAtMs)&&(identical(other.disconnectedAtMs, _this.disconnectedAtMs) || other.disconnectedAtMs == _this.disconnectedAtMs)&&(identical(other.serverUpdatedAt, _this.serverUpdatedAt) || other.serverUpdatedAt == _this.serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AndroidAutoSession;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.vehicleId,_this.planId,_this.lastTemplateShown,_this.lastSocUpdatePercent,_this.connectedAtMs,_this.lastSocUpdateAtMs,_this.disconnectedAtMs,_this.serverUpdatedAt);
}

@override
String toString() {
  final _this = this as AndroidAutoSession;
  return 'AndroidAutoSession(id: ${_this.id}, userId: ${_this.userId}, vehicleId: ${_this.vehicleId}, planId: ${_this.planId}, lastTemplateShown: ${_this.lastTemplateShown}, lastSocUpdatePercent: ${_this.lastSocUpdatePercent}, connectedAtMs: ${_this.connectedAtMs}, lastSocUpdateAtMs: ${_this.lastSocUpdateAtMs}, disconnectedAtMs: ${_this.disconnectedAtMs}, serverUpdatedAt: ${_this.serverUpdatedAt})';
}


}

/// @nodoc
abstract mixin class $AndroidAutoSessionCopyWith<$Res>  {
  factory $AndroidAutoSessionCopyWith(AndroidAutoSession value, $Res Function(AndroidAutoSession) _then) = _$AndroidAutoSessionCopyWithImpl;
@useResult
$Res call({
 String id, String? userId, String? vehicleId, String? planId, String? lastTemplateShown, int lastSocUpdatePercent, int connectedAtMs, int lastSocUpdateAtMs, int disconnectedAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class _$AndroidAutoSessionCopyWithImpl<$Res>
    implements $AndroidAutoSessionCopyWith<$Res> {
  _$AndroidAutoSessionCopyWithImpl(this._self, this._then);

  final AndroidAutoSession _self;
  final $Res Function(AndroidAutoSession) _then;

/// Create a copy of AndroidAutoSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = freezed,Object? vehicleId = freezed,Object? planId = freezed,Object? lastTemplateShown = freezed,Object? lastSocUpdatePercent = null,Object? connectedAtMs = null,Object? lastSocUpdateAtMs = null,Object? disconnectedAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(AndroidAutoSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as String?,planId: freezed == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String?,lastTemplateShown: freezed == lastTemplateShown ? _self.lastTemplateShown : lastTemplateShown // ignore: cast_nullable_to_non_nullable
as String?,lastSocUpdatePercent: null == lastSocUpdatePercent ? _self.lastSocUpdatePercent : lastSocUpdatePercent // ignore: cast_nullable_to_non_nullable
as int,connectedAtMs: null == connectedAtMs ? _self.connectedAtMs : connectedAtMs // ignore: cast_nullable_to_non_nullable
as int,lastSocUpdateAtMs: null == lastSocUpdateAtMs ? _self.lastSocUpdateAtMs : lastSocUpdateAtMs // ignore: cast_nullable_to_non_nullable
as int,disconnectedAtMs: null == disconnectedAtMs ? _self.disconnectedAtMs : disconnectedAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AndroidAutoSession].
extension AndroidAutoSessionPatterns on AndroidAutoSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AndroidAutoSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AndroidAutoSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AndroidAutoSession value)  $default,){
final _that = this;
switch (_that) {
case _AndroidAutoSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AndroidAutoSession value)?  $default,){
final _that = this;
switch (_that) {
case _AndroidAutoSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? userId,  String? vehicleId,  String? planId,  String? lastTemplateShown,  int lastSocUpdatePercent,  int connectedAtMs,  int lastSocUpdateAtMs,  int disconnectedAtMs,  String? serverUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AndroidAutoSession() when $default != null:
return $default(_that.id,_that.userId,_that.vehicleId,_that.planId,_that.lastTemplateShown,_that.lastSocUpdatePercent,_that.connectedAtMs,_that.lastSocUpdateAtMs,_that.disconnectedAtMs,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? userId,  String? vehicleId,  String? planId,  String? lastTemplateShown,  int lastSocUpdatePercent,  int connectedAtMs,  int lastSocUpdateAtMs,  int disconnectedAtMs,  String? serverUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _AndroidAutoSession():
return $default(_that.id,_that.userId,_that.vehicleId,_that.planId,_that.lastTemplateShown,_that.lastSocUpdatePercent,_that.connectedAtMs,_that.lastSocUpdateAtMs,_that.disconnectedAtMs,_that.serverUpdatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? userId,  String? vehicleId,  String? planId,  String? lastTemplateShown,  int lastSocUpdatePercent,  int connectedAtMs,  int lastSocUpdateAtMs,  int disconnectedAtMs,  String? serverUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AndroidAutoSession() when $default != null:
return $default(_that.id,_that.userId,_that.vehicleId,_that.planId,_that.lastTemplateShown,_that.lastSocUpdatePercent,_that.connectedAtMs,_that.lastSocUpdateAtMs,_that.disconnectedAtMs,_that.serverUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AndroidAutoSession implements AndroidAutoSession {
  const _AndroidAutoSession({required this.id, this.userId, this.vehicleId, this.planId, this.lastTemplateShown, this.lastSocUpdatePercent = 0, this.connectedAtMs = 0, this.lastSocUpdateAtMs = 0, this.disconnectedAtMs = 0, this.serverUpdatedAt});
  factory _AndroidAutoSession.fromJson(Map<String, dynamic> json) => _$AndroidAutoSessionFromJson(json);

@override final  String id;
@override final  String? userId;
@override final  String? vehicleId;
@override final  String? planId;
@override final  String? lastTemplateShown;
@override@JsonKey() final  int lastSocUpdatePercent;
@override@JsonKey() final  int connectedAtMs;
@override@JsonKey() final  int lastSocUpdateAtMs;
@override@JsonKey() final  int disconnectedAtMs;
@override final  String? serverUpdatedAt;

/// Create a copy of AndroidAutoSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AndroidAutoSessionCopyWith<_AndroidAutoSession> get copyWith => __$AndroidAutoSessionCopyWithImpl<_AndroidAutoSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AndroidAutoSessionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AndroidAutoSession&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.lastTemplateShown, lastTemplateShown) || other.lastTemplateShown == lastTemplateShown)&&(identical(other.lastSocUpdatePercent, lastSocUpdatePercent) || other.lastSocUpdatePercent == lastSocUpdatePercent)&&(identical(other.connectedAtMs, connectedAtMs) || other.connectedAtMs == connectedAtMs)&&(identical(other.lastSocUpdateAtMs, lastSocUpdateAtMs) || other.lastSocUpdateAtMs == lastSocUpdateAtMs)&&(identical(other.disconnectedAtMs, disconnectedAtMs) || other.disconnectedAtMs == disconnectedAtMs)&&(identical(other.serverUpdatedAt, serverUpdatedAt) || other.serverUpdatedAt == serverUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,vehicleId,planId,lastTemplateShown,lastSocUpdatePercent,connectedAtMs,lastSocUpdateAtMs,disconnectedAtMs,serverUpdatedAt);
}

@override
String toString() {
    return 'AndroidAutoSession(id: $id, userId: $userId, vehicleId: $vehicleId, planId: $planId, lastTemplateShown: $lastTemplateShown, lastSocUpdatePercent: $lastSocUpdatePercent, connectedAtMs: $connectedAtMs, lastSocUpdateAtMs: $lastSocUpdateAtMs, disconnectedAtMs: $disconnectedAtMs, serverUpdatedAt: $serverUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$AndroidAutoSessionCopyWith<$Res> implements $AndroidAutoSessionCopyWith<$Res> {
  factory _$AndroidAutoSessionCopyWith(_AndroidAutoSession value, $Res Function(_AndroidAutoSession) _then) = __$AndroidAutoSessionCopyWithImpl;
@override @useResult
$Res call({
 String id, String? userId, String? vehicleId, String? planId, String? lastTemplateShown, int lastSocUpdatePercent, int connectedAtMs, int lastSocUpdateAtMs, int disconnectedAtMs, String? serverUpdatedAt
});




}
/// @nodoc
class __$AndroidAutoSessionCopyWithImpl<$Res>
    implements _$AndroidAutoSessionCopyWith<$Res> {
  __$AndroidAutoSessionCopyWithImpl(this._self, this._then);

  final _AndroidAutoSession _self;
  final $Res Function(_AndroidAutoSession) _then;

/// Create a copy of AndroidAutoSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = freezed,Object? vehicleId = freezed,Object? planId = freezed,Object? lastTemplateShown = freezed,Object? lastSocUpdatePercent = null,Object? connectedAtMs = null,Object? lastSocUpdateAtMs = null,Object? disconnectedAtMs = null,Object? serverUpdatedAt = freezed,}) {
  return _then(_AndroidAutoSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as String?,planId: freezed == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String?,lastTemplateShown: freezed == lastTemplateShown ? _self.lastTemplateShown : lastTemplateShown // ignore: cast_nullable_to_non_nullable
as String?,lastSocUpdatePercent: null == lastSocUpdatePercent ? _self.lastSocUpdatePercent : lastSocUpdatePercent // ignore: cast_nullable_to_non_nullable
as int,connectedAtMs: null == connectedAtMs ? _self.connectedAtMs : connectedAtMs // ignore: cast_nullable_to_non_nullable
as int,lastSocUpdateAtMs: null == lastSocUpdateAtMs ? _self.lastSocUpdateAtMs : lastSocUpdateAtMs // ignore: cast_nullable_to_non_nullable
as int,disconnectedAtMs: null == disconnectedAtMs ? _self.disconnectedAtMs : disconnectedAtMs // ignore: cast_nullable_to_non_nullable
as int,serverUpdatedAt: freezed == serverUpdatedAt ? _self.serverUpdatedAt : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
