// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfile {

 UserProfileUser get user; UserProfileDetail? get profile; UserProfileMembership get membership; List<UserProfilePosition> get positions; UserProfileChurch get church; UserProfileBranch get branch;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.user, user) || other.user == user)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.membership, membership) || other.membership == membership)&&const DeepCollectionEquality().equals(other.positions, positions)&&(identical(other.church, church) || other.church == church)&&(identical(other.branch, branch) || other.branch == branch));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,user,profile,membership,const DeepCollectionEquality().hash(positions),church,branch);

@override
String toString() {
  return 'UserProfile(user: $user, profile: $profile, membership: $membership, positions: $positions, church: $church, branch: $branch)';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 UserProfileUser user, UserProfileDetail? profile, UserProfileMembership membership, List<UserProfilePosition> positions, UserProfileChurch church, UserProfileBranch branch
});


$UserProfileUserCopyWith<$Res> get user;$UserProfileDetailCopyWith<$Res>? get profile;$UserProfileMembershipCopyWith<$Res> get membership;$UserProfileChurchCopyWith<$Res> get church;$UserProfileBranchCopyWith<$Res> get branch;

}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? profile = freezed,Object? membership = null,Object? positions = null,Object? church = null,Object? branch = null,}) {
  return _then(_self.copyWith(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserProfileUser,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UserProfileDetail?,membership: null == membership ? _self.membership : membership // ignore: cast_nullable_to_non_nullable
as UserProfileMembership,positions: null == positions ? _self.positions : positions // ignore: cast_nullable_to_non_nullable
as List<UserProfilePosition>,church: null == church ? _self.church : church // ignore: cast_nullable_to_non_nullable
as UserProfileChurch,branch: null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as UserProfileBranch,
  ));
}
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileUserCopyWith<$Res> get user {
  
  return $UserProfileUserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileDetailCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $UserProfileDetailCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileMembershipCopyWith<$Res> get membership {
  
  return $UserProfileMembershipCopyWith<$Res>(_self.membership, (value) {
    return _then(_self.copyWith(membership: value));
  });
}/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileChurchCopyWith<$Res> get church {
  
  return $UserProfileChurchCopyWith<$Res>(_self.church, (value) {
    return _then(_self.copyWith(church: value));
  });
}/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileBranchCopyWith<$Res> get branch {
  
  return $UserProfileBranchCopyWith<$Res>(_self.branch, (value) {
    return _then(_self.copyWith(branch: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserProfileUser user,  UserProfileDetail? profile,  UserProfileMembership membership,  List<UserProfilePosition> positions,  UserProfileChurch church,  UserProfileBranch branch)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.user,_that.profile,_that.membership,_that.positions,_that.church,_that.branch);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserProfileUser user,  UserProfileDetail? profile,  UserProfileMembership membership,  List<UserProfilePosition> positions,  UserProfileChurch church,  UserProfileBranch branch)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.user,_that.profile,_that.membership,_that.positions,_that.church,_that.branch);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserProfileUser user,  UserProfileDetail? profile,  UserProfileMembership membership,  List<UserProfilePosition> positions,  UserProfileChurch church,  UserProfileBranch branch)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.user,_that.profile,_that.membership,_that.positions,_that.church,_that.branch);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfile implements UserProfile {
  const _UserProfile({required this.user, this.profile, required this.membership, required final  List<UserProfilePosition> positions, required this.church, required this.branch}): _positions = positions;
  factory _UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

@override final  UserProfileUser user;
@override final  UserProfileDetail? profile;
@override final  UserProfileMembership membership;
 final  List<UserProfilePosition> _positions;
@override List<UserProfilePosition> get positions {
  if (_positions is EqualUnmodifiableListView) return _positions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_positions);
}

@override final  UserProfileChurch church;
@override final  UserProfileBranch branch;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.user, user) || other.user == user)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.membership, membership) || other.membership == membership)&&const DeepCollectionEquality().equals(other._positions, _positions)&&(identical(other.church, church) || other.church == church)&&(identical(other.branch, branch) || other.branch == branch));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,user,profile,membership,const DeepCollectionEquality().hash(_positions),church,branch);

@override
String toString() {
  return 'UserProfile(user: $user, profile: $profile, membership: $membership, positions: $positions, church: $church, branch: $branch)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 UserProfileUser user, UserProfileDetail? profile, UserProfileMembership membership, List<UserProfilePosition> positions, UserProfileChurch church, UserProfileBranch branch
});


@override $UserProfileUserCopyWith<$Res> get user;@override $UserProfileDetailCopyWith<$Res>? get profile;@override $UserProfileMembershipCopyWith<$Res> get membership;@override $UserProfileChurchCopyWith<$Res> get church;@override $UserProfileBranchCopyWith<$Res> get branch;

}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? profile = freezed,Object? membership = null,Object? positions = null,Object? church = null,Object? branch = null,}) {
  return _then(_UserProfile(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserProfileUser,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UserProfileDetail?,membership: null == membership ? _self.membership : membership // ignore: cast_nullable_to_non_nullable
as UserProfileMembership,positions: null == positions ? _self._positions : positions // ignore: cast_nullable_to_non_nullable
as List<UserProfilePosition>,church: null == church ? _self.church : church // ignore: cast_nullable_to_non_nullable
as UserProfileChurch,branch: null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as UserProfileBranch,
  ));
}

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileUserCopyWith<$Res> get user {
  
  return $UserProfileUserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileDetailCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $UserProfileDetailCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileMembershipCopyWith<$Res> get membership {
  
  return $UserProfileMembershipCopyWith<$Res>(_self.membership, (value) {
    return _then(_self.copyWith(membership: value));
  });
}/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileChurchCopyWith<$Res> get church {
  
  return $UserProfileChurchCopyWith<$Res>(_self.church, (value) {
    return _then(_self.copyWith(church: value));
  });
}/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileBranchCopyWith<$Res> get branch {
  
  return $UserProfileBranchCopyWith<$Res>(_self.branch, (value) {
    return _then(_self.copyWith(branch: value));
  });
}
}


/// @nodoc
mixin _$UserProfileUser {

 String get id; String get name; String get email; String? get phone; String? get cpf; String? get rg; String? get sex; String? get civilStatus; String? get fatherName; String? get motherName; String? get country; String? get state; String? get city; String? get neighborhood; String? get street; String? get number; String? get complement;
/// Create a copy of UserProfileUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileUserCopyWith<UserProfileUser> get copyWith => _$UserProfileUserCopyWithImpl<UserProfileUser>(this as UserProfileUser, _$identity);

  /// Serializes this UserProfileUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfileUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.cpf, cpf) || other.cpf == cpf)&&(identical(other.rg, rg) || other.rg == rg)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.civilStatus, civilStatus) || other.civilStatus == civilStatus)&&(identical(other.fatherName, fatherName) || other.fatherName == fatherName)&&(identical(other.motherName, motherName) || other.motherName == motherName)&&(identical(other.country, country) || other.country == country)&&(identical(other.state, state) || other.state == state)&&(identical(other.city, city) || other.city == city)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.street, street) || other.street == street)&&(identical(other.number, number) || other.number == number)&&(identical(other.complement, complement) || other.complement == complement));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,phone,cpf,rg,sex,civilStatus,fatherName,motherName,country,state,city,neighborhood,street,number,complement);

@override
String toString() {
  return 'UserProfileUser(id: $id, name: $name, email: $email, phone: $phone, cpf: $cpf, rg: $rg, sex: $sex, civilStatus: $civilStatus, fatherName: $fatherName, motherName: $motherName, country: $country, state: $state, city: $city, neighborhood: $neighborhood, street: $street, number: $number, complement: $complement)';
}


}

/// @nodoc
abstract mixin class $UserProfileUserCopyWith<$Res>  {
  factory $UserProfileUserCopyWith(UserProfileUser value, $Res Function(UserProfileUser) _then) = _$UserProfileUserCopyWithImpl;
@useResult
$Res call({
 String id, String name, String email, String? phone, String? cpf, String? rg, String? sex, String? civilStatus, String? fatherName, String? motherName, String? country, String? state, String? city, String? neighborhood, String? street, String? number, String? complement
});




}
/// @nodoc
class _$UserProfileUserCopyWithImpl<$Res>
    implements $UserProfileUserCopyWith<$Res> {
  _$UserProfileUserCopyWithImpl(this._self, this._then);

  final UserProfileUser _self;
  final $Res Function(UserProfileUser) _then;

/// Create a copy of UserProfileUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = null,Object? phone = freezed,Object? cpf = freezed,Object? rg = freezed,Object? sex = freezed,Object? civilStatus = freezed,Object? fatherName = freezed,Object? motherName = freezed,Object? country = freezed,Object? state = freezed,Object? city = freezed,Object? neighborhood = freezed,Object? street = freezed,Object? number = freezed,Object? complement = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
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


/// Adds pattern-matching-related methods to [UserProfileUser].
extension UserProfileUserPatterns on UserProfileUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfileUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfileUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfileUser value)  $default,){
final _that = this;
switch (_that) {
case _UserProfileUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfileUser value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfileUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String? phone,  String? cpf,  String? rg,  String? sex,  String? civilStatus,  String? fatherName,  String? motherName,  String? country,  String? state,  String? city,  String? neighborhood,  String? street,  String? number,  String? complement)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfileUser() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String? phone,  String? cpf,  String? rg,  String? sex,  String? civilStatus,  String? fatherName,  String? motherName,  String? country,  String? state,  String? city,  String? neighborhood,  String? street,  String? number,  String? complement)  $default,) {final _that = this;
switch (_that) {
case _UserProfileUser():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String email,  String? phone,  String? cpf,  String? rg,  String? sex,  String? civilStatus,  String? fatherName,  String? motherName,  String? country,  String? state,  String? city,  String? neighborhood,  String? street,  String? number,  String? complement)?  $default,) {final _that = this;
switch (_that) {
case _UserProfileUser() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.cpf,_that.rg,_that.sex,_that.civilStatus,_that.fatherName,_that.motherName,_that.country,_that.state,_that.city,_that.neighborhood,_that.street,_that.number,_that.complement);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfileUser implements UserProfileUser {
  const _UserProfileUser({required this.id, required this.name, required this.email, this.phone, this.cpf, this.rg, this.sex, this.civilStatus, this.fatherName, this.motherName, this.country, this.state, this.city, this.neighborhood, this.street, this.number, this.complement});
  factory _UserProfileUser.fromJson(Map<String, dynamic> json) => _$UserProfileUserFromJson(json);

@override final  String id;
@override final  String name;
@override final  String email;
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

/// Create a copy of UserProfileUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileUserCopyWith<_UserProfileUser> get copyWith => __$UserProfileUserCopyWithImpl<_UserProfileUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfileUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.cpf, cpf) || other.cpf == cpf)&&(identical(other.rg, rg) || other.rg == rg)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.civilStatus, civilStatus) || other.civilStatus == civilStatus)&&(identical(other.fatherName, fatherName) || other.fatherName == fatherName)&&(identical(other.motherName, motherName) || other.motherName == motherName)&&(identical(other.country, country) || other.country == country)&&(identical(other.state, state) || other.state == state)&&(identical(other.city, city) || other.city == city)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.street, street) || other.street == street)&&(identical(other.number, number) || other.number == number)&&(identical(other.complement, complement) || other.complement == complement));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,phone,cpf,rg,sex,civilStatus,fatherName,motherName,country,state,city,neighborhood,street,number,complement);

@override
String toString() {
  return 'UserProfileUser(id: $id, name: $name, email: $email, phone: $phone, cpf: $cpf, rg: $rg, sex: $sex, civilStatus: $civilStatus, fatherName: $fatherName, motherName: $motherName, country: $country, state: $state, city: $city, neighborhood: $neighborhood, street: $street, number: $number, complement: $complement)';
}


}

/// @nodoc
abstract mixin class _$UserProfileUserCopyWith<$Res> implements $UserProfileUserCopyWith<$Res> {
  factory _$UserProfileUserCopyWith(_UserProfileUser value, $Res Function(_UserProfileUser) _then) = __$UserProfileUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String email, String? phone, String? cpf, String? rg, String? sex, String? civilStatus, String? fatherName, String? motherName, String? country, String? state, String? city, String? neighborhood, String? street, String? number, String? complement
});




}
/// @nodoc
class __$UserProfileUserCopyWithImpl<$Res>
    implements _$UserProfileUserCopyWith<$Res> {
  __$UserProfileUserCopyWithImpl(this._self, this._then);

  final _UserProfileUser _self;
  final $Res Function(_UserProfileUser) _then;

/// Create a copy of UserProfileUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,Object? phone = freezed,Object? cpf = freezed,Object? rg = freezed,Object? sex = freezed,Object? civilStatus = freezed,Object? fatherName = freezed,Object? motherName = freezed,Object? country = freezed,Object? state = freezed,Object? city = freezed,Object? neighborhood = freezed,Object? street = freezed,Object? number = freezed,Object? complement = freezed,}) {
  return _then(_UserProfileUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
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
mixin _$UserProfileDetail {

 String? get photoUrl; String? get admissionDate; String? get birthDate; String? get baptismDate; String? get consecrationDate; String? get registrationNumber;
/// Create a copy of UserProfileDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileDetailCopyWith<UserProfileDetail> get copyWith => _$UserProfileDetailCopyWithImpl<UserProfileDetail>(this as UserProfileDetail, _$identity);

  /// Serializes this UserProfileDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfileDetail&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.admissionDate, admissionDate) || other.admissionDate == admissionDate)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.baptismDate, baptismDate) || other.baptismDate == baptismDate)&&(identical(other.consecrationDate, consecrationDate) || other.consecrationDate == consecrationDate)&&(identical(other.registrationNumber, registrationNumber) || other.registrationNumber == registrationNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,photoUrl,admissionDate,birthDate,baptismDate,consecrationDate,registrationNumber);

@override
String toString() {
  return 'UserProfileDetail(photoUrl: $photoUrl, admissionDate: $admissionDate, birthDate: $birthDate, baptismDate: $baptismDate, consecrationDate: $consecrationDate, registrationNumber: $registrationNumber)';
}


}

/// @nodoc
abstract mixin class $UserProfileDetailCopyWith<$Res>  {
  factory $UserProfileDetailCopyWith(UserProfileDetail value, $Res Function(UserProfileDetail) _then) = _$UserProfileDetailCopyWithImpl;
@useResult
$Res call({
 String? photoUrl, String? admissionDate, String? birthDate, String? baptismDate, String? consecrationDate, String? registrationNumber
});




}
/// @nodoc
class _$UserProfileDetailCopyWithImpl<$Res>
    implements $UserProfileDetailCopyWith<$Res> {
  _$UserProfileDetailCopyWithImpl(this._self, this._then);

  final UserProfileDetail _self;
  final $Res Function(UserProfileDetail) _then;

/// Create a copy of UserProfileDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? photoUrl = freezed,Object? admissionDate = freezed,Object? birthDate = freezed,Object? baptismDate = freezed,Object? consecrationDate = freezed,Object? registrationNumber = freezed,}) {
  return _then(_self.copyWith(
photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,admissionDate: freezed == admissionDate ? _self.admissionDate : admissionDate // ignore: cast_nullable_to_non_nullable
as String?,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String?,baptismDate: freezed == baptismDate ? _self.baptismDate : baptismDate // ignore: cast_nullable_to_non_nullable
as String?,consecrationDate: freezed == consecrationDate ? _self.consecrationDate : consecrationDate // ignore: cast_nullable_to_non_nullable
as String?,registrationNumber: freezed == registrationNumber ? _self.registrationNumber : registrationNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfileDetail].
extension UserProfileDetailPatterns on UserProfileDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfileDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfileDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfileDetail value)  $default,){
final _that = this;
switch (_that) {
case _UserProfileDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfileDetail value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfileDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? photoUrl,  String? admissionDate,  String? birthDate,  String? baptismDate,  String? consecrationDate,  String? registrationNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfileDetail() when $default != null:
return $default(_that.photoUrl,_that.admissionDate,_that.birthDate,_that.baptismDate,_that.consecrationDate,_that.registrationNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? photoUrl,  String? admissionDate,  String? birthDate,  String? baptismDate,  String? consecrationDate,  String? registrationNumber)  $default,) {final _that = this;
switch (_that) {
case _UserProfileDetail():
return $default(_that.photoUrl,_that.admissionDate,_that.birthDate,_that.baptismDate,_that.consecrationDate,_that.registrationNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? photoUrl,  String? admissionDate,  String? birthDate,  String? baptismDate,  String? consecrationDate,  String? registrationNumber)?  $default,) {final _that = this;
switch (_that) {
case _UserProfileDetail() when $default != null:
return $default(_that.photoUrl,_that.admissionDate,_that.birthDate,_that.baptismDate,_that.consecrationDate,_that.registrationNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfileDetail implements UserProfileDetail {
  const _UserProfileDetail({this.photoUrl, this.admissionDate, this.birthDate, this.baptismDate, this.consecrationDate, this.registrationNumber});
  factory _UserProfileDetail.fromJson(Map<String, dynamic> json) => _$UserProfileDetailFromJson(json);

@override final  String? photoUrl;
@override final  String? admissionDate;
@override final  String? birthDate;
@override final  String? baptismDate;
@override final  String? consecrationDate;
@override final  String? registrationNumber;

/// Create a copy of UserProfileDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileDetailCopyWith<_UserProfileDetail> get copyWith => __$UserProfileDetailCopyWithImpl<_UserProfileDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfileDetail&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.admissionDate, admissionDate) || other.admissionDate == admissionDate)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.baptismDate, baptismDate) || other.baptismDate == baptismDate)&&(identical(other.consecrationDate, consecrationDate) || other.consecrationDate == consecrationDate)&&(identical(other.registrationNumber, registrationNumber) || other.registrationNumber == registrationNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,photoUrl,admissionDate,birthDate,baptismDate,consecrationDate,registrationNumber);

@override
String toString() {
  return 'UserProfileDetail(photoUrl: $photoUrl, admissionDate: $admissionDate, birthDate: $birthDate, baptismDate: $baptismDate, consecrationDate: $consecrationDate, registrationNumber: $registrationNumber)';
}


}

/// @nodoc
abstract mixin class _$UserProfileDetailCopyWith<$Res> implements $UserProfileDetailCopyWith<$Res> {
  factory _$UserProfileDetailCopyWith(_UserProfileDetail value, $Res Function(_UserProfileDetail) _then) = __$UserProfileDetailCopyWithImpl;
@override @useResult
$Res call({
 String? photoUrl, String? admissionDate, String? birthDate, String? baptismDate, String? consecrationDate, String? registrationNumber
});




}
/// @nodoc
class __$UserProfileDetailCopyWithImpl<$Res>
    implements _$UserProfileDetailCopyWith<$Res> {
  __$UserProfileDetailCopyWithImpl(this._self, this._then);

  final _UserProfileDetail _self;
  final $Res Function(_UserProfileDetail) _then;

/// Create a copy of UserProfileDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? photoUrl = freezed,Object? admissionDate = freezed,Object? birthDate = freezed,Object? baptismDate = freezed,Object? consecrationDate = freezed,Object? registrationNumber = freezed,}) {
  return _then(_UserProfileDetail(
photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,admissionDate: freezed == admissionDate ? _self.admissionDate : admissionDate // ignore: cast_nullable_to_non_nullable
as String?,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String?,baptismDate: freezed == baptismDate ? _self.baptismDate : baptismDate // ignore: cast_nullable_to_non_nullable
as String?,consecrationDate: freezed == consecrationDate ? _self.consecrationDate : consecrationDate // ignore: cast_nullable_to_non_nullable
as String?,registrationNumber: freezed == registrationNumber ? _self.registrationNumber : registrationNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UserProfileMembership {

 String get role; String get status;
/// Create a copy of UserProfileMembership
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileMembershipCopyWith<UserProfileMembership> get copyWith => _$UserProfileMembershipCopyWithImpl<UserProfileMembership>(this as UserProfileMembership, _$identity);

  /// Serializes this UserProfileMembership to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfileMembership&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role,status);

@override
String toString() {
  return 'UserProfileMembership(role: $role, status: $status)';
}


}

/// @nodoc
abstract mixin class $UserProfileMembershipCopyWith<$Res>  {
  factory $UserProfileMembershipCopyWith(UserProfileMembership value, $Res Function(UserProfileMembership) _then) = _$UserProfileMembershipCopyWithImpl;
@useResult
$Res call({
 String role, String status
});




}
/// @nodoc
class _$UserProfileMembershipCopyWithImpl<$Res>
    implements $UserProfileMembershipCopyWith<$Res> {
  _$UserProfileMembershipCopyWithImpl(this._self, this._then);

  final UserProfileMembership _self;
  final $Res Function(UserProfileMembership) _then;

/// Create a copy of UserProfileMembership
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? role = null,Object? status = null,}) {
  return _then(_self.copyWith(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfileMembership].
extension UserProfileMembershipPatterns on UserProfileMembership {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfileMembership value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfileMembership() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfileMembership value)  $default,){
final _that = this;
switch (_that) {
case _UserProfileMembership():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfileMembership value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfileMembership() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String role,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfileMembership() when $default != null:
return $default(_that.role,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String role,  String status)  $default,) {final _that = this;
switch (_that) {
case _UserProfileMembership():
return $default(_that.role,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String role,  String status)?  $default,) {final _that = this;
switch (_that) {
case _UserProfileMembership() when $default != null:
return $default(_that.role,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfileMembership implements UserProfileMembership {
  const _UserProfileMembership({required this.role, required this.status});
  factory _UserProfileMembership.fromJson(Map<String, dynamic> json) => _$UserProfileMembershipFromJson(json);

@override final  String role;
@override final  String status;

/// Create a copy of UserProfileMembership
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileMembershipCopyWith<_UserProfileMembership> get copyWith => __$UserProfileMembershipCopyWithImpl<_UserProfileMembership>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileMembershipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfileMembership&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role,status);

@override
String toString() {
  return 'UserProfileMembership(role: $role, status: $status)';
}


}

/// @nodoc
abstract mixin class _$UserProfileMembershipCopyWith<$Res> implements $UserProfileMembershipCopyWith<$Res> {
  factory _$UserProfileMembershipCopyWith(_UserProfileMembership value, $Res Function(_UserProfileMembership) _then) = __$UserProfileMembershipCopyWithImpl;
@override @useResult
$Res call({
 String role, String status
});




}
/// @nodoc
class __$UserProfileMembershipCopyWithImpl<$Res>
    implements _$UserProfileMembershipCopyWith<$Res> {
  __$UserProfileMembershipCopyWithImpl(this._self, this._then);

  final _UserProfileMembership _self;
  final $Res Function(_UserProfileMembership) _then;

/// Create a copy of UserProfileMembership
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? role = null,Object? status = null,}) {
  return _then(_UserProfileMembership(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UserProfilePosition {

 String get id; String get name;
/// Create a copy of UserProfilePosition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfilePositionCopyWith<UserProfilePosition> get copyWith => _$UserProfilePositionCopyWithImpl<UserProfilePosition>(this as UserProfilePosition, _$identity);

  /// Serializes this UserProfilePosition to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfilePosition&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'UserProfilePosition(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $UserProfilePositionCopyWith<$Res>  {
  factory $UserProfilePositionCopyWith(UserProfilePosition value, $Res Function(UserProfilePosition) _then) = _$UserProfilePositionCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$UserProfilePositionCopyWithImpl<$Res>
    implements $UserProfilePositionCopyWith<$Res> {
  _$UserProfilePositionCopyWithImpl(this._self, this._then);

  final UserProfilePosition _self;
  final $Res Function(UserProfilePosition) _then;

/// Create a copy of UserProfilePosition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfilePosition].
extension UserProfilePositionPatterns on UserProfilePosition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfilePosition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfilePosition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfilePosition value)  $default,){
final _that = this;
switch (_that) {
case _UserProfilePosition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfilePosition value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfilePosition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfilePosition() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name)  $default,) {final _that = this;
switch (_that) {
case _UserProfilePosition():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _UserProfilePosition() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfilePosition implements UserProfilePosition {
  const _UserProfilePosition({required this.id, required this.name});
  factory _UserProfilePosition.fromJson(Map<String, dynamic> json) => _$UserProfilePositionFromJson(json);

@override final  String id;
@override final  String name;

/// Create a copy of UserProfilePosition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfilePositionCopyWith<_UserProfilePosition> get copyWith => __$UserProfilePositionCopyWithImpl<_UserProfilePosition>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfilePositionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfilePosition&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'UserProfilePosition(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$UserProfilePositionCopyWith<$Res> implements $UserProfilePositionCopyWith<$Res> {
  factory _$UserProfilePositionCopyWith(_UserProfilePosition value, $Res Function(_UserProfilePosition) _then) = __$UserProfilePositionCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$UserProfilePositionCopyWithImpl<$Res>
    implements _$UserProfilePositionCopyWith<$Res> {
  __$UserProfilePositionCopyWithImpl(this._self, this._then);

  final _UserProfilePosition _self;
  final $Res Function(_UserProfilePosition) _then;

/// Create a copy of UserProfilePosition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_UserProfilePosition(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UserProfileChurch {

 String get id; String get name;
/// Create a copy of UserProfileChurch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileChurchCopyWith<UserProfileChurch> get copyWith => _$UserProfileChurchCopyWithImpl<UserProfileChurch>(this as UserProfileChurch, _$identity);

  /// Serializes this UserProfileChurch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfileChurch&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'UserProfileChurch(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $UserProfileChurchCopyWith<$Res>  {
  factory $UserProfileChurchCopyWith(UserProfileChurch value, $Res Function(UserProfileChurch) _then) = _$UserProfileChurchCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$UserProfileChurchCopyWithImpl<$Res>
    implements $UserProfileChurchCopyWith<$Res> {
  _$UserProfileChurchCopyWithImpl(this._self, this._then);

  final UserProfileChurch _self;
  final $Res Function(UserProfileChurch) _then;

/// Create a copy of UserProfileChurch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfileChurch].
extension UserProfileChurchPatterns on UserProfileChurch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfileChurch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfileChurch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfileChurch value)  $default,){
final _that = this;
switch (_that) {
case _UserProfileChurch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfileChurch value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfileChurch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfileChurch() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name)  $default,) {final _that = this;
switch (_that) {
case _UserProfileChurch():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _UserProfileChurch() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfileChurch implements UserProfileChurch {
  const _UserProfileChurch({required this.id, required this.name});
  factory _UserProfileChurch.fromJson(Map<String, dynamic> json) => _$UserProfileChurchFromJson(json);

@override final  String id;
@override final  String name;

/// Create a copy of UserProfileChurch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileChurchCopyWith<_UserProfileChurch> get copyWith => __$UserProfileChurchCopyWithImpl<_UserProfileChurch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileChurchToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfileChurch&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'UserProfileChurch(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$UserProfileChurchCopyWith<$Res> implements $UserProfileChurchCopyWith<$Res> {
  factory _$UserProfileChurchCopyWith(_UserProfileChurch value, $Res Function(_UserProfileChurch) _then) = __$UserProfileChurchCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$UserProfileChurchCopyWithImpl<$Res>
    implements _$UserProfileChurchCopyWith<$Res> {
  __$UserProfileChurchCopyWithImpl(this._self, this._then);

  final _UserProfileChurch _self;
  final $Res Function(_UserProfileChurch) _then;

/// Create a copy of UserProfileChurch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_UserProfileChurch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UserProfileBranch {

 String get id; String get name;
/// Create a copy of UserProfileBranch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileBranchCopyWith<UserProfileBranch> get copyWith => _$UserProfileBranchCopyWithImpl<UserProfileBranch>(this as UserProfileBranch, _$identity);

  /// Serializes this UserProfileBranch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfileBranch&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'UserProfileBranch(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $UserProfileBranchCopyWith<$Res>  {
  factory $UserProfileBranchCopyWith(UserProfileBranch value, $Res Function(UserProfileBranch) _then) = _$UserProfileBranchCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$UserProfileBranchCopyWithImpl<$Res>
    implements $UserProfileBranchCopyWith<$Res> {
  _$UserProfileBranchCopyWithImpl(this._self, this._then);

  final UserProfileBranch _self;
  final $Res Function(UserProfileBranch) _then;

/// Create a copy of UserProfileBranch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfileBranch].
extension UserProfileBranchPatterns on UserProfileBranch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfileBranch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfileBranch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfileBranch value)  $default,){
final _that = this;
switch (_that) {
case _UserProfileBranch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfileBranch value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfileBranch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfileBranch() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name)  $default,) {final _that = this;
switch (_that) {
case _UserProfileBranch():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _UserProfileBranch() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfileBranch implements UserProfileBranch {
  const _UserProfileBranch({required this.id, required this.name});
  factory _UserProfileBranch.fromJson(Map<String, dynamic> json) => _$UserProfileBranchFromJson(json);

@override final  String id;
@override final  String name;

/// Create a copy of UserProfileBranch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileBranchCopyWith<_UserProfileBranch> get copyWith => __$UserProfileBranchCopyWithImpl<_UserProfileBranch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileBranchToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfileBranch&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'UserProfileBranch(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$UserProfileBranchCopyWith<$Res> implements $UserProfileBranchCopyWith<$Res> {
  factory _$UserProfileBranchCopyWith(_UserProfileBranch value, $Res Function(_UserProfileBranch) _then) = __$UserProfileBranchCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$UserProfileBranchCopyWithImpl<$Res>
    implements _$UserProfileBranchCopyWith<$Res> {
  __$UserProfileBranchCopyWithImpl(this._self, this._then);

  final _UserProfileBranch _self;
  final $Res Function(_UserProfileBranch) _then;

/// Create a copy of UserProfileBranch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_UserProfileBranch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
