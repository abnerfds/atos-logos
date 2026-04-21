// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'birthday_member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BirthdayMember {

 String get id; String get name; String? get photoUrl; String get birthDate;
/// Create a copy of BirthdayMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BirthdayMemberCopyWith<BirthdayMember> get copyWith => _$BirthdayMemberCopyWithImpl<BirthdayMember>(this as BirthdayMember, _$identity);

  /// Serializes this BirthdayMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BirthdayMember&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,photoUrl,birthDate);

@override
String toString() {
  return 'BirthdayMember(id: $id, name: $name, photoUrl: $photoUrl, birthDate: $birthDate)';
}


}

/// @nodoc
abstract mixin class $BirthdayMemberCopyWith<$Res>  {
  factory $BirthdayMemberCopyWith(BirthdayMember value, $Res Function(BirthdayMember) _then) = _$BirthdayMemberCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? photoUrl, String birthDate
});




}
/// @nodoc
class _$BirthdayMemberCopyWithImpl<$Res>
    implements $BirthdayMemberCopyWith<$Res> {
  _$BirthdayMemberCopyWithImpl(this._self, this._then);

  final BirthdayMember _self;
  final $Res Function(BirthdayMember) _then;

/// Create a copy of BirthdayMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? photoUrl = freezed,Object? birthDate = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BirthdayMember].
extension BirthdayMemberPatterns on BirthdayMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BirthdayMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BirthdayMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BirthdayMember value)  $default,){
final _that = this;
switch (_that) {
case _BirthdayMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BirthdayMember value)?  $default,){
final _that = this;
switch (_that) {
case _BirthdayMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? photoUrl,  String birthDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BirthdayMember() when $default != null:
return $default(_that.id,_that.name,_that.photoUrl,_that.birthDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? photoUrl,  String birthDate)  $default,) {final _that = this;
switch (_that) {
case _BirthdayMember():
return $default(_that.id,_that.name,_that.photoUrl,_that.birthDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? photoUrl,  String birthDate)?  $default,) {final _that = this;
switch (_that) {
case _BirthdayMember() when $default != null:
return $default(_that.id,_that.name,_that.photoUrl,_that.birthDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BirthdayMember implements BirthdayMember {
  const _BirthdayMember({required this.id, required this.name, this.photoUrl, required this.birthDate});
  factory _BirthdayMember.fromJson(Map<String, dynamic> json) => _$BirthdayMemberFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? photoUrl;
@override final  String birthDate;

/// Create a copy of BirthdayMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BirthdayMemberCopyWith<_BirthdayMember> get copyWith => __$BirthdayMemberCopyWithImpl<_BirthdayMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BirthdayMemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BirthdayMember&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,photoUrl,birthDate);

@override
String toString() {
  return 'BirthdayMember(id: $id, name: $name, photoUrl: $photoUrl, birthDate: $birthDate)';
}


}

/// @nodoc
abstract mixin class _$BirthdayMemberCopyWith<$Res> implements $BirthdayMemberCopyWith<$Res> {
  factory _$BirthdayMemberCopyWith(_BirthdayMember value, $Res Function(_BirthdayMember) _then) = __$BirthdayMemberCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? photoUrl, String birthDate
});




}
/// @nodoc
class __$BirthdayMemberCopyWithImpl<$Res>
    implements _$BirthdayMemberCopyWith<$Res> {
  __$BirthdayMemberCopyWithImpl(this._self, this._then);

  final _BirthdayMember _self;
  final $Res Function(_BirthdayMember) _then;

/// Create a copy of BirthdayMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? photoUrl = freezed,Object? birthDate = null,}) {
  return _then(_BirthdayMember(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$BirthdaysResponse {

 List<BirthdayMember> get data; int get month;
/// Create a copy of BirthdaysResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BirthdaysResponseCopyWith<BirthdaysResponse> get copyWith => _$BirthdaysResponseCopyWithImpl<BirthdaysResponse>(this as BirthdaysResponse, _$identity);

  /// Serializes this BirthdaysResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BirthdaysResponse&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.month, month) || other.month == month));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data),month);

@override
String toString() {
  return 'BirthdaysResponse(data: $data, month: $month)';
}


}

/// @nodoc
abstract mixin class $BirthdaysResponseCopyWith<$Res>  {
  factory $BirthdaysResponseCopyWith(BirthdaysResponse value, $Res Function(BirthdaysResponse) _then) = _$BirthdaysResponseCopyWithImpl;
@useResult
$Res call({
 List<BirthdayMember> data, int month
});




}
/// @nodoc
class _$BirthdaysResponseCopyWithImpl<$Res>
    implements $BirthdaysResponseCopyWith<$Res> {
  _$BirthdaysResponseCopyWithImpl(this._self, this._then);

  final BirthdaysResponse _self;
  final $Res Function(BirthdaysResponse) _then;

/// Create a copy of BirthdaysResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? month = null,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as List<BirthdayMember>,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BirthdaysResponse].
extension BirthdaysResponsePatterns on BirthdaysResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BirthdaysResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BirthdaysResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BirthdaysResponse value)  $default,){
final _that = this;
switch (_that) {
case _BirthdaysResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BirthdaysResponse value)?  $default,){
final _that = this;
switch (_that) {
case _BirthdaysResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<BirthdayMember> data,  int month)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BirthdaysResponse() when $default != null:
return $default(_that.data,_that.month);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<BirthdayMember> data,  int month)  $default,) {final _that = this;
switch (_that) {
case _BirthdaysResponse():
return $default(_that.data,_that.month);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<BirthdayMember> data,  int month)?  $default,) {final _that = this;
switch (_that) {
case _BirthdaysResponse() when $default != null:
return $default(_that.data,_that.month);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BirthdaysResponse implements BirthdaysResponse {
  const _BirthdaysResponse({required final  List<BirthdayMember> data, required this.month}): _data = data;
  factory _BirthdaysResponse.fromJson(Map<String, dynamic> json) => _$BirthdaysResponseFromJson(json);

 final  List<BirthdayMember> _data;
@override List<BirthdayMember> get data {
  if (_data is EqualUnmodifiableListView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_data);
}

@override final  int month;

/// Create a copy of BirthdaysResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BirthdaysResponseCopyWith<_BirthdaysResponse> get copyWith => __$BirthdaysResponseCopyWithImpl<_BirthdaysResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BirthdaysResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BirthdaysResponse&&const DeepCollectionEquality().equals(other._data, _data)&&(identical(other.month, month) || other.month == month));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_data),month);

@override
String toString() {
  return 'BirthdaysResponse(data: $data, month: $month)';
}


}

/// @nodoc
abstract mixin class _$BirthdaysResponseCopyWith<$Res> implements $BirthdaysResponseCopyWith<$Res> {
  factory _$BirthdaysResponseCopyWith(_BirthdaysResponse value, $Res Function(_BirthdaysResponse) _then) = __$BirthdaysResponseCopyWithImpl;
@override @useResult
$Res call({
 List<BirthdayMember> data, int month
});




}
/// @nodoc
class __$BirthdaysResponseCopyWithImpl<$Res>
    implements _$BirthdaysResponseCopyWith<$Res> {
  __$BirthdaysResponseCopyWithImpl(this._self, this._then);

  final _BirthdaysResponse _self;
  final $Res Function(_BirthdaysResponse) _then;

/// Create a copy of BirthdaysResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? month = null,}) {
  return _then(_BirthdaysResponse(
data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as List<BirthdayMember>,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
