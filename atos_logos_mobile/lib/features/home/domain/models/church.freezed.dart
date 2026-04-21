// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'church.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Church {

 String get id; String get name; String? get documentNumber; String get activePlan;
/// Create a copy of Church
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChurchCopyWith<Church> get copyWith => _$ChurchCopyWithImpl<Church>(this as Church, _$identity);

  /// Serializes this Church to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Church&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.documentNumber, documentNumber) || other.documentNumber == documentNumber)&&(identical(other.activePlan, activePlan) || other.activePlan == activePlan));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,documentNumber,activePlan);

@override
String toString() {
  return 'Church(id: $id, name: $name, documentNumber: $documentNumber, activePlan: $activePlan)';
}


}

/// @nodoc
abstract mixin class $ChurchCopyWith<$Res>  {
  factory $ChurchCopyWith(Church value, $Res Function(Church) _then) = _$ChurchCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? documentNumber, String activePlan
});




}
/// @nodoc
class _$ChurchCopyWithImpl<$Res>
    implements $ChurchCopyWith<$Res> {
  _$ChurchCopyWithImpl(this._self, this._then);

  final Church _self;
  final $Res Function(Church) _then;

/// Create a copy of Church
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? documentNumber = freezed,Object? activePlan = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,documentNumber: freezed == documentNumber ? _self.documentNumber : documentNumber // ignore: cast_nullable_to_non_nullable
as String?,activePlan: null == activePlan ? _self.activePlan : activePlan // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Church].
extension ChurchPatterns on Church {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Church value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Church() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Church value)  $default,){
final _that = this;
switch (_that) {
case _Church():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Church value)?  $default,){
final _that = this;
switch (_that) {
case _Church() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? documentNumber,  String activePlan)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Church() when $default != null:
return $default(_that.id,_that.name,_that.documentNumber,_that.activePlan);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? documentNumber,  String activePlan)  $default,) {final _that = this;
switch (_that) {
case _Church():
return $default(_that.id,_that.name,_that.documentNumber,_that.activePlan);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? documentNumber,  String activePlan)?  $default,) {final _that = this;
switch (_that) {
case _Church() when $default != null:
return $default(_that.id,_that.name,_that.documentNumber,_that.activePlan);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Church implements Church {
  const _Church({required this.id, required this.name, this.documentNumber, required this.activePlan});
  factory _Church.fromJson(Map<String, dynamic> json) => _$ChurchFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? documentNumber;
@override final  String activePlan;

/// Create a copy of Church
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChurchCopyWith<_Church> get copyWith => __$ChurchCopyWithImpl<_Church>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChurchToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Church&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.documentNumber, documentNumber) || other.documentNumber == documentNumber)&&(identical(other.activePlan, activePlan) || other.activePlan == activePlan));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,documentNumber,activePlan);

@override
String toString() {
  return 'Church(id: $id, name: $name, documentNumber: $documentNumber, activePlan: $activePlan)';
}


}

/// @nodoc
abstract mixin class _$ChurchCopyWith<$Res> implements $ChurchCopyWith<$Res> {
  factory _$ChurchCopyWith(_Church value, $Res Function(_Church) _then) = __$ChurchCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? documentNumber, String activePlan
});




}
/// @nodoc
class __$ChurchCopyWithImpl<$Res>
    implements _$ChurchCopyWith<$Res> {
  __$ChurchCopyWithImpl(this._self, this._then);

  final _Church _self;
  final $Res Function(_Church) _then;

/// Create a copy of Church
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? documentNumber = freezed,Object? activePlan = null,}) {
  return _then(_Church(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,documentNumber: freezed == documentNumber ? _self.documentNumber : documentNumber // ignore: cast_nullable_to_non_nullable
as String?,activePlan: null == activePlan ? _self.activePlan : activePlan // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
