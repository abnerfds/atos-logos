// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MemberProfileUser {

 String get id; String get name; String? get email; String? get phone; String? get cpf; String? get rg; String? get sex; String? get civilStatus; String? get fatherName; String? get motherName; String? get country; String? get state; String? get city; String? get neighborhood; String? get street; String? get number; String? get complement;
/// Create a copy of MemberProfileUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberProfileUserCopyWith<MemberProfileUser> get copyWith => _$MemberProfileUserCopyWithImpl<MemberProfileUser>(this as MemberProfileUser, _$identity);

  /// Serializes this MemberProfileUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberProfileUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.cpf, cpf) || other.cpf == cpf)&&(identical(other.rg, rg) || other.rg == rg)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.civilStatus, civilStatus) || other.civilStatus == civilStatus)&&(identical(other.fatherName, fatherName) || other.fatherName == fatherName)&&(identical(other.motherName, motherName) || other.motherName == motherName)&&(identical(other.country, country) || other.country == country)&&(identical(other.state, state) || other.state == state)&&(identical(other.city, city) || other.city == city)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.street, street) || other.street == street)&&(identical(other.number, number) || other.number == number)&&(identical(other.complement, complement) || other.complement == complement));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,phone,cpf,rg,sex,civilStatus,fatherName,motherName,country,state,city,neighborhood,street,number,complement);

@override
String toString() {
  return 'MemberProfileUser(id: $id, name: $name, email: $email, phone: $phone, cpf: $cpf, rg: $rg, sex: $sex, civilStatus: $civilStatus, fatherName: $fatherName, motherName: $motherName, country: $country, state: $state, city: $city, neighborhood: $neighborhood, street: $street, number: $number, complement: $complement)';
}


}

/// @nodoc
abstract mixin class $MemberProfileUserCopyWith<$Res>  {
  factory $MemberProfileUserCopyWith(MemberProfileUser value, $Res Function(MemberProfileUser) _then) = _$MemberProfileUserCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? email, String? phone, String? cpf, String? rg, String? sex, String? civilStatus, String? fatherName, String? motherName, String? country, String? state, String? city, String? neighborhood, String? street, String? number, String? complement
});




}
/// @nodoc
class _$MemberProfileUserCopyWithImpl<$Res>
    implements $MemberProfileUserCopyWith<$Res> {
  _$MemberProfileUserCopyWithImpl(this._self, this._then);

  final MemberProfileUser _self;
  final $Res Function(MemberProfileUser) _then;

/// Create a copy of MemberProfileUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = freezed,Object? phone = freezed,Object? cpf = freezed,Object? rg = freezed,Object? sex = freezed,Object? civilStatus = freezed,Object? fatherName = freezed,Object? motherName = freezed,Object? country = freezed,Object? state = freezed,Object? city = freezed,Object? neighborhood = freezed,Object? street = freezed,Object? number = freezed,Object? complement = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,cpf: freezed == cpf ? _self.cpf : cpf // ignore: cast_nullable_to_non_nullable
as String?,rg: freezed == rg ? _self.rg : rg // ignore: cast_nullable_to_non_nullable
as String?,sex: freezed == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as String?,civilStatus: freezed == civilStatus ? _self.civilStatus : civilStatus // ignore: cast_nullable_to_non_nullable
as String?,fatherName: freezed == fatherName ? _self.fatherName : fatherName // ignore: cast_nullable_to_non_nullable
as String?,motherName: freezed == motherName ? _self.motherName : motherName // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,neighborhood: freezed == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String?,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String?,complement: freezed == complement ? _self.complement : complement // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MemberProfileUser].
extension MemberProfileUserPatterns on MemberProfileUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberProfileUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberProfileUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberProfileUser value)  $default,){
final _that = this;
switch (_that) {
case _MemberProfileUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberProfileUser value)?  $default,){
final _that = this;
switch (_that) {
case _MemberProfileUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? email,  String? phone,  String? cpf,  String? rg,  String? sex,  String? civilStatus,  String? fatherName,  String? motherName,  String? country,  String? state,  String? city,  String? neighborhood,  String? street,  String? number,  String? complement)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberProfileUser() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.cpf,_that.rg,_that.sex,_that.civilStatus,_that.fatherName,_that.motherName,_that.country,_that.state,_that.city,_that.neighborhood,_that.street,_that.number,_that.complement);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? email,  String? phone,  String? cpf,  String? rg,  String? sex,  String? civilStatus,  String? fatherName,  String? motherName,  String? country,  String? state,  String? city,  String? neighborhood,  String? street,  String? number,  String? complement)  $default,) {final _that = this;
switch (_that) {
case _MemberProfileUser():
return $default(_that.id,_that.name,_that.email,_that.phone,_that.cpf,_that.rg,_that.sex,_that.civilStatus,_that.fatherName,_that.motherName,_that.country,_that.state,_that.city,_that.neighborhood,_that.street,_that.number,_that.complement);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? email,  String? phone,  String? cpf,  String? rg,  String? sex,  String? civilStatus,  String? fatherName,  String? motherName,  String? country,  String? state,  String? city,  String? neighborhood,  String? street,  String? number,  String? complement)?  $default,) {final _that = this;
switch (_that) {
case _MemberProfileUser() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.cpf,_that.rg,_that.sex,_that.civilStatus,_that.fatherName,_that.motherName,_that.country,_that.state,_that.city,_that.neighborhood,_that.street,_that.number,_that.complement);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemberProfileUser implements MemberProfileUser {
  const _MemberProfileUser({required this.id, required this.name, this.email, this.phone, this.cpf, this.rg, this.sex, this.civilStatus, this.fatherName, this.motherName, this.country, this.state, this.city, this.neighborhood, this.street, this.number, this.complement});
  factory _MemberProfileUser.fromJson(Map<String, dynamic> json) => _$MemberProfileUserFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? email;
@override final  String? phone;
@override final  String? cpf;
@override final  String? rg;
@override final  String? sex;
@override final  String? civilStatus;
@override final  String? fatherName;
@override final  String? motherName;
@override final  String? country;
@override final  String? state;
@override final  String? city;
@override final  String? neighborhood;
@override final  String? street;
@override final  String? number;
@override final  String? complement;

/// Create a copy of MemberProfileUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberProfileUserCopyWith<_MemberProfileUser> get copyWith => __$MemberProfileUserCopyWithImpl<_MemberProfileUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberProfileUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberProfileUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.cpf, cpf) || other.cpf == cpf)&&(identical(other.rg, rg) || other.rg == rg)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.civilStatus, civilStatus) || other.civilStatus == civilStatus)&&(identical(other.fatherName, fatherName) || other.fatherName == fatherName)&&(identical(other.motherName, motherName) || other.motherName == motherName)&&(identical(other.country, country) || other.country == country)&&(identical(other.state, state) || other.state == state)&&(identical(other.city, city) || other.city == city)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.street, street) || other.street == street)&&(identical(other.number, number) || other.number == number)&&(identical(other.complement, complement) || other.complement == complement));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,phone,cpf,rg,sex,civilStatus,fatherName,motherName,country,state,city,neighborhood,street,number,complement);

@override
String toString() {
  return 'MemberProfileUser(id: $id, name: $name, email: $email, phone: $phone, cpf: $cpf, rg: $rg, sex: $sex, civilStatus: $civilStatus, fatherName: $fatherName, motherName: $motherName, country: $country, state: $state, city: $city, neighborhood: $neighborhood, street: $street, number: $number, complement: $complement)';
}


}

/// @nodoc
abstract mixin class _$MemberProfileUserCopyWith<$Res> implements $MemberProfileUserCopyWith<$Res> {
  factory _$MemberProfileUserCopyWith(_MemberProfileUser value, $Res Function(_MemberProfileUser) _then) = __$MemberProfileUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? email, String? phone, String? cpf, String? rg, String? sex, String? civilStatus, String? fatherName, String? motherName, String? country, String? state, String? city, String? neighborhood, String? street, String? number, String? complement
});




}
/// @nodoc
class __$MemberProfileUserCopyWithImpl<$Res>
    implements _$MemberProfileUserCopyWith<$Res> {
  __$MemberProfileUserCopyWithImpl(this._self, this._then);

  final _MemberProfileUser _self;
  final $Res Function(_MemberProfileUser) _then;

/// Create a copy of MemberProfileUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = freezed,Object? phone = freezed,Object? cpf = freezed,Object? rg = freezed,Object? sex = freezed,Object? civilStatus = freezed,Object? fatherName = freezed,Object? motherName = freezed,Object? country = freezed,Object? state = freezed,Object? city = freezed,Object? neighborhood = freezed,Object? street = freezed,Object? number = freezed,Object? complement = freezed,}) {
  return _then(_MemberProfileUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,cpf: freezed == cpf ? _self.cpf : cpf // ignore: cast_nullable_to_non_nullable
as String?,rg: freezed == rg ? _self.rg : rg // ignore: cast_nullable_to_non_nullable
as String?,sex: freezed == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as String?,civilStatus: freezed == civilStatus ? _self.civilStatus : civilStatus // ignore: cast_nullable_to_non_nullable
as String?,fatherName: freezed == fatherName ? _self.fatherName : fatherName // ignore: cast_nullable_to_non_nullable
as String?,motherName: freezed == motherName ? _self.motherName : motherName // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,neighborhood: freezed == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String?,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String?,complement: freezed == complement ? _self.complement : complement // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MemberProfile {

 String? get id; String get userId; String get churchId; String? get registrationNumber; String? get birthDate; String? get baptismDate; String? get admissionDate; String? get consecrationDate; String? get photoUrl; MemberProfileUser? get user;
/// Create a copy of MemberProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberProfileCopyWith<MemberProfile> get copyWith => _$MemberProfileCopyWithImpl<MemberProfile>(this as MemberProfile, _$identity);

  /// Serializes this MemberProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.churchId, churchId) || other.churchId == churchId)&&(identical(other.registrationNumber, registrationNumber) || other.registrationNumber == registrationNumber)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.baptismDate, baptismDate) || other.baptismDate == baptismDate)&&(identical(other.admissionDate, admissionDate) || other.admissionDate == admissionDate)&&(identical(other.consecrationDate, consecrationDate) || other.consecrationDate == consecrationDate)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,churchId,registrationNumber,birthDate,baptismDate,admissionDate,consecrationDate,photoUrl,user);

@override
String toString() {
  return 'MemberProfile(id: $id, userId: $userId, churchId: $churchId, registrationNumber: $registrationNumber, birthDate: $birthDate, baptismDate: $baptismDate, admissionDate: $admissionDate, consecrationDate: $consecrationDate, photoUrl: $photoUrl, user: $user)';
}


}

/// @nodoc
abstract mixin class $MemberProfileCopyWith<$Res>  {
  factory $MemberProfileCopyWith(MemberProfile value, $Res Function(MemberProfile) _then) = _$MemberProfileCopyWithImpl;
@useResult
$Res call({
 String? id, String userId, String churchId, String? registrationNumber, String? birthDate, String? baptismDate, String? admissionDate, String? consecrationDate, String? photoUrl, MemberProfileUser? user
});


$MemberProfileUserCopyWith<$Res>? get user;

}
/// @nodoc
class _$MemberProfileCopyWithImpl<$Res>
    implements $MemberProfileCopyWith<$Res> {
  _$MemberProfileCopyWithImpl(this._self, this._then);

  final MemberProfile _self;
  final $Res Function(MemberProfile) _then;

/// Create a copy of MemberProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? userId = null,Object? churchId = null,Object? registrationNumber = freezed,Object? birthDate = freezed,Object? baptismDate = freezed,Object? admissionDate = freezed,Object? consecrationDate = freezed,Object? photoUrl = freezed,Object? user = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,churchId: null == churchId ? _self.churchId : churchId // ignore: cast_nullable_to_non_nullable
as String,registrationNumber: freezed == registrationNumber ? _self.registrationNumber : registrationNumber // ignore: cast_nullable_to_non_nullable
as String?,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String?,baptismDate: freezed == baptismDate ? _self.baptismDate : baptismDate // ignore: cast_nullable_to_non_nullable
as String?,admissionDate: freezed == admissionDate ? _self.admissionDate : admissionDate // ignore: cast_nullable_to_non_nullable
as String?,consecrationDate: freezed == consecrationDate ? _self.consecrationDate : consecrationDate // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as MemberProfileUser?,
  ));
}
/// Create a copy of MemberProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MemberProfileUserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $MemberProfileUserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [MemberProfile].
extension MemberProfilePatterns on MemberProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberProfile value)  $default,){
final _that = this;
switch (_that) {
case _MemberProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberProfile value)?  $default,){
final _that = this;
switch (_that) {
case _MemberProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String userId,  String churchId,  String? registrationNumber,  String? birthDate,  String? baptismDate,  String? admissionDate,  String? consecrationDate,  String? photoUrl,  MemberProfileUser? user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberProfile() when $default != null:
return $default(_that.id,_that.userId,_that.churchId,_that.registrationNumber,_that.birthDate,_that.baptismDate,_that.admissionDate,_that.consecrationDate,_that.photoUrl,_that.user);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String userId,  String churchId,  String? registrationNumber,  String? birthDate,  String? baptismDate,  String? admissionDate,  String? consecrationDate,  String? photoUrl,  MemberProfileUser? user)  $default,) {final _that = this;
switch (_that) {
case _MemberProfile():
return $default(_that.id,_that.userId,_that.churchId,_that.registrationNumber,_that.birthDate,_that.baptismDate,_that.admissionDate,_that.consecrationDate,_that.photoUrl,_that.user);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String userId,  String churchId,  String? registrationNumber,  String? birthDate,  String? baptismDate,  String? admissionDate,  String? consecrationDate,  String? photoUrl,  MemberProfileUser? user)?  $default,) {final _that = this;
switch (_that) {
case _MemberProfile() when $default != null:
return $default(_that.id,_that.userId,_that.churchId,_that.registrationNumber,_that.birthDate,_that.baptismDate,_that.admissionDate,_that.consecrationDate,_that.photoUrl,_that.user);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemberProfile implements MemberProfile {
  const _MemberProfile({this.id, required this.userId, required this.churchId, this.registrationNumber, this.birthDate, this.baptismDate, this.admissionDate, this.consecrationDate, this.photoUrl, this.user});
  factory _MemberProfile.fromJson(Map<String, dynamic> json) => _$MemberProfileFromJson(json);

@override final  String? id;
@override final  String userId;
@override final  String churchId;
@override final  String? registrationNumber;
@override final  String? birthDate;
@override final  String? baptismDate;
@override final  String? admissionDate;
@override final  String? consecrationDate;
@override final  String? photoUrl;
@override final  MemberProfileUser? user;

/// Create a copy of MemberProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberProfileCopyWith<_MemberProfile> get copyWith => __$MemberProfileCopyWithImpl<_MemberProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.churchId, churchId) || other.churchId == churchId)&&(identical(other.registrationNumber, registrationNumber) || other.registrationNumber == registrationNumber)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.baptismDate, baptismDate) || other.baptismDate == baptismDate)&&(identical(other.admissionDate, admissionDate) || other.admissionDate == admissionDate)&&(identical(other.consecrationDate, consecrationDate) || other.consecrationDate == consecrationDate)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,churchId,registrationNumber,birthDate,baptismDate,admissionDate,consecrationDate,photoUrl,user);

@override
String toString() {
  return 'MemberProfile(id: $id, userId: $userId, churchId: $churchId, registrationNumber: $registrationNumber, birthDate: $birthDate, baptismDate: $baptismDate, admissionDate: $admissionDate, consecrationDate: $consecrationDate, photoUrl: $photoUrl, user: $user)';
}


}

/// @nodoc
abstract mixin class _$MemberProfileCopyWith<$Res> implements $MemberProfileCopyWith<$Res> {
  factory _$MemberProfileCopyWith(_MemberProfile value, $Res Function(_MemberProfile) _then) = __$MemberProfileCopyWithImpl;
@override @useResult
$Res call({
 String? id, String userId, String churchId, String? registrationNumber, String? birthDate, String? baptismDate, String? admissionDate, String? consecrationDate, String? photoUrl, MemberProfileUser? user
});


@override $MemberProfileUserCopyWith<$Res>? get user;

}
/// @nodoc
class __$MemberProfileCopyWithImpl<$Res>
    implements _$MemberProfileCopyWith<$Res> {
  __$MemberProfileCopyWithImpl(this._self, this._then);

  final _MemberProfile _self;
  final $Res Function(_MemberProfile) _then;

/// Create a copy of MemberProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? userId = null,Object? churchId = null,Object? registrationNumber = freezed,Object? birthDate = freezed,Object? baptismDate = freezed,Object? admissionDate = freezed,Object? consecrationDate = freezed,Object? photoUrl = freezed,Object? user = freezed,}) {
  return _then(_MemberProfile(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,churchId: null == churchId ? _self.churchId : churchId // ignore: cast_nullable_to_non_nullable
as String,registrationNumber: freezed == registrationNumber ? _self.registrationNumber : registrationNumber // ignore: cast_nullable_to_non_nullable
as String?,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String?,baptismDate: freezed == baptismDate ? _self.baptismDate : baptismDate // ignore: cast_nullable_to_non_nullable
as String?,admissionDate: freezed == admissionDate ? _self.admissionDate : admissionDate // ignore: cast_nullable_to_non_nullable
as String?,consecrationDate: freezed == consecrationDate ? _self.consecrationDate : consecrationDate // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as MemberProfileUser?,
  ));
}

/// Create a copy of MemberProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MemberProfileUserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $MemberProfileUserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
