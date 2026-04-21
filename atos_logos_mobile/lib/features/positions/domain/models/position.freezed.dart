// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'position.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PositionUserInfo {

 String get id; String get name;
/// Create a copy of PositionUserInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PositionUserInfoCopyWith<PositionUserInfo> get copyWith => _$PositionUserInfoCopyWithImpl<PositionUserInfo>(this as PositionUserInfo, _$identity);

  /// Serializes this PositionUserInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PositionUserInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'PositionUserInfo(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $PositionUserInfoCopyWith<$Res>  {
  factory $PositionUserInfoCopyWith(PositionUserInfo value, $Res Function(PositionUserInfo) _then) = _$PositionUserInfoCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$PositionUserInfoCopyWithImpl<$Res>
    implements $PositionUserInfoCopyWith<$Res> {
  _$PositionUserInfoCopyWithImpl(this._self, this._then);

  final PositionUserInfo _self;
  final $Res Function(PositionUserInfo) _then;

/// Create a copy of PositionUserInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PositionUserInfo].
extension PositionUserInfoPatterns on PositionUserInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PositionUserInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PositionUserInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PositionUserInfo value)  $default,){
final _that = this;
switch (_that) {
case _PositionUserInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PositionUserInfo value)?  $default,){
final _that = this;
switch (_that) {
case _PositionUserInfo() when $default != null:
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
case _PositionUserInfo() when $default != null:
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
case _PositionUserInfo():
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
case _PositionUserInfo() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PositionUserInfo implements PositionUserInfo {
  const _PositionUserInfo({required this.id, required this.name});
  factory _PositionUserInfo.fromJson(Map<String, dynamic> json) => _$PositionUserInfoFromJson(json);

@override final  String id;
@override final  String name;

/// Create a copy of PositionUserInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PositionUserInfoCopyWith<_PositionUserInfo> get copyWith => __$PositionUserInfoCopyWithImpl<_PositionUserInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PositionUserInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PositionUserInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'PositionUserInfo(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$PositionUserInfoCopyWith<$Res> implements $PositionUserInfoCopyWith<$Res> {
  factory _$PositionUserInfoCopyWith(_PositionUserInfo value, $Res Function(_PositionUserInfo) _then) = __$PositionUserInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$PositionUserInfoCopyWithImpl<$Res>
    implements _$PositionUserInfoCopyWith<$Res> {
  __$PositionUserInfoCopyWithImpl(this._self, this._then);

  final _PositionUserInfo _self;
  final $Res Function(_PositionUserInfo) _then;

/// Create a copy of PositionUserInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_PositionUserInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PositionUserPivot {

 String get id; String get userId; String get positionId; PositionUserInfo get user;
/// Create a copy of PositionUserPivot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PositionUserPivotCopyWith<PositionUserPivot> get copyWith => _$PositionUserPivotCopyWithImpl<PositionUserPivot>(this as PositionUserPivot, _$identity);

  /// Serializes this PositionUserPivot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PositionUserPivot&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.positionId, positionId) || other.positionId == positionId)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,positionId,user);

@override
String toString() {
  return 'PositionUserPivot(id: $id, userId: $userId, positionId: $positionId, user: $user)';
}


}

/// @nodoc
abstract mixin class $PositionUserPivotCopyWith<$Res>  {
  factory $PositionUserPivotCopyWith(PositionUserPivot value, $Res Function(PositionUserPivot) _then) = _$PositionUserPivotCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String positionId, PositionUserInfo user
});


$PositionUserInfoCopyWith<$Res> get user;

}
/// @nodoc
class _$PositionUserPivotCopyWithImpl<$Res>
    implements $PositionUserPivotCopyWith<$Res> {
  _$PositionUserPivotCopyWithImpl(this._self, this._then);

  final PositionUserPivot _self;
  final $Res Function(PositionUserPivot) _then;

/// Create a copy of PositionUserPivot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? positionId = null,Object? user = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,positionId: null == positionId ? _self.positionId : positionId // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as PositionUserInfo,
  ));
}
/// Create a copy of PositionUserPivot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PositionUserInfoCopyWith<$Res> get user {
  
  return $PositionUserInfoCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [PositionUserPivot].
extension PositionUserPivotPatterns on PositionUserPivot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PositionUserPivot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PositionUserPivot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PositionUserPivot value)  $default,){
final _that = this;
switch (_that) {
case _PositionUserPivot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PositionUserPivot value)?  $default,){
final _that = this;
switch (_that) {
case _PositionUserPivot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String positionId,  PositionUserInfo user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PositionUserPivot() when $default != null:
return $default(_that.id,_that.userId,_that.positionId,_that.user);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String positionId,  PositionUserInfo user)  $default,) {final _that = this;
switch (_that) {
case _PositionUserPivot():
return $default(_that.id,_that.userId,_that.positionId,_that.user);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String positionId,  PositionUserInfo user)?  $default,) {final _that = this;
switch (_that) {
case _PositionUserPivot() when $default != null:
return $default(_that.id,_that.userId,_that.positionId,_that.user);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PositionUserPivot implements PositionUserPivot {
  const _PositionUserPivot({required this.id, required this.userId, required this.positionId, required this.user});
  factory _PositionUserPivot.fromJson(Map<String, dynamic> json) => _$PositionUserPivotFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String positionId;
@override final  PositionUserInfo user;

/// Create a copy of PositionUserPivot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PositionUserPivotCopyWith<_PositionUserPivot> get copyWith => __$PositionUserPivotCopyWithImpl<_PositionUserPivot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PositionUserPivotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PositionUserPivot&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.positionId, positionId) || other.positionId == positionId)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,positionId,user);

@override
String toString() {
  return 'PositionUserPivot(id: $id, userId: $userId, positionId: $positionId, user: $user)';
}


}

/// @nodoc
abstract mixin class _$PositionUserPivotCopyWith<$Res> implements $PositionUserPivotCopyWith<$Res> {
  factory _$PositionUserPivotCopyWith(_PositionUserPivot value, $Res Function(_PositionUserPivot) _then) = __$PositionUserPivotCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String positionId, PositionUserInfo user
});


@override $PositionUserInfoCopyWith<$Res> get user;

}
/// @nodoc
class __$PositionUserPivotCopyWithImpl<$Res>
    implements _$PositionUserPivotCopyWith<$Res> {
  __$PositionUserPivotCopyWithImpl(this._self, this._then);

  final _PositionUserPivot _self;
  final $Res Function(_PositionUserPivot) _then;

/// Create a copy of PositionUserPivot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? positionId = null,Object? user = null,}) {
  return _then(_PositionUserPivot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,positionId: null == positionId ? _self.positionId : positionId // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as PositionUserInfo,
  ));
}

/// Create a copy of PositionUserPivot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PositionUserInfoCopyWith<$Res> get user {
  
  return $PositionUserInfoCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// @nodoc
mixin _$Position {

 String get id; String get churchId; String get name; List<PositionUserPivot> get users;
/// Create a copy of Position
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PositionCopyWith<Position> get copyWith => _$PositionCopyWithImpl<Position>(this as Position, _$identity);

  /// Serializes this Position to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Position&&(identical(other.id, id) || other.id == id)&&(identical(other.churchId, churchId) || other.churchId == churchId)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.users, users));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,churchId,name,const DeepCollectionEquality().hash(users));

@override
String toString() {
  return 'Position(id: $id, churchId: $churchId, name: $name, users: $users)';
}


}

/// @nodoc
abstract mixin class $PositionCopyWith<$Res>  {
  factory $PositionCopyWith(Position value, $Res Function(Position) _then) = _$PositionCopyWithImpl;
@useResult
$Res call({
 String id, String churchId, String name, List<PositionUserPivot> users
});




}
/// @nodoc
class _$PositionCopyWithImpl<$Res>
    implements $PositionCopyWith<$Res> {
  _$PositionCopyWithImpl(this._self, this._then);

  final Position _self;
  final $Res Function(Position) _then;

/// Create a copy of Position
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? churchId = null,Object? name = null,Object? users = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,churchId: null == churchId ? _self.churchId : churchId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,users: null == users ? _self.users : users // ignore: cast_nullable_to_non_nullable
as List<PositionUserPivot>,
  ));
}

}


/// Adds pattern-matching-related methods to [Position].
extension PositionPatterns on Position {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Position value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Position() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Position value)  $default,){
final _that = this;
switch (_that) {
case _Position():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Position value)?  $default,){
final _that = this;
switch (_that) {
case _Position() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String churchId,  String name,  List<PositionUserPivot> users)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Position() when $default != null:
return $default(_that.id,_that.churchId,_that.name,_that.users);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String churchId,  String name,  List<PositionUserPivot> users)  $default,) {final _that = this;
switch (_that) {
case _Position():
return $default(_that.id,_that.churchId,_that.name,_that.users);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String churchId,  String name,  List<PositionUserPivot> users)?  $default,) {final _that = this;
switch (_that) {
case _Position() when $default != null:
return $default(_that.id,_that.churchId,_that.name,_that.users);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Position implements Position {
  const _Position({required this.id, required this.churchId, required this.name, final  List<PositionUserPivot> users = const []}): _users = users;
  factory _Position.fromJson(Map<String, dynamic> json) => _$PositionFromJson(json);

@override final  String id;
@override final  String churchId;
@override final  String name;
 final  List<PositionUserPivot> _users;
@override@JsonKey() List<PositionUserPivot> get users {
  if (_users is EqualUnmodifiableListView) return _users;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_users);
}


/// Create a copy of Position
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PositionCopyWith<_Position> get copyWith => __$PositionCopyWithImpl<_Position>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PositionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Position&&(identical(other.id, id) || other.id == id)&&(identical(other.churchId, churchId) || other.churchId == churchId)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._users, _users));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,churchId,name,const DeepCollectionEquality().hash(_users));

@override
String toString() {
  return 'Position(id: $id, churchId: $churchId, name: $name, users: $users)';
}


}

/// @nodoc
abstract mixin class _$PositionCopyWith<$Res> implements $PositionCopyWith<$Res> {
  factory _$PositionCopyWith(_Position value, $Res Function(_Position) _then) = __$PositionCopyWithImpl;
@override @useResult
$Res call({
 String id, String churchId, String name, List<PositionUserPivot> users
});




}
/// @nodoc
class __$PositionCopyWithImpl<$Res>
    implements _$PositionCopyWith<$Res> {
  __$PositionCopyWithImpl(this._self, this._then);

  final _Position _self;
  final $Res Function(_Position) _then;

/// Create a copy of Position
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? churchId = null,Object? name = null,Object? users = null,}) {
  return _then(_Position(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,churchId: null == churchId ? _self.churchId : churchId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,users: null == users ? _self._users : users // ignore: cast_nullable_to_non_nullable
as List<PositionUserPivot>,
  ));
}


}

// dart format on
