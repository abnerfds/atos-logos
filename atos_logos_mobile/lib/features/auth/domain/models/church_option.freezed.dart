// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'church_option.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChurchOption {

 String get id; String get name; String get branchName; String get role;
/// Create a copy of ChurchOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChurchOptionCopyWith<ChurchOption> get copyWith => _$ChurchOptionCopyWithImpl<ChurchOption>(this as ChurchOption, _$identity);

  /// Serializes this ChurchOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChurchOption&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.branchName, branchName) || other.branchName == branchName)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,branchName,role);

@override
String toString() {
  return 'ChurchOption(id: $id, name: $name, branchName: $branchName, role: $role)';
}


}

/// @nodoc
abstract mixin class $ChurchOptionCopyWith<$Res>  {
  factory $ChurchOptionCopyWith(ChurchOption value, $Res Function(ChurchOption) _then) = _$ChurchOptionCopyWithImpl;
@useResult
$Res call({
 String id, String name, String branchName, String role
});




}
/// @nodoc
class _$ChurchOptionCopyWithImpl<$Res>
    implements $ChurchOptionCopyWith<$Res> {
  _$ChurchOptionCopyWithImpl(this._self, this._then);

  final ChurchOption _self;
  final $Res Function(ChurchOption) _then;

/// Create a copy of ChurchOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? branchName = null,Object? role = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,branchName: null == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChurchOption].
extension ChurchOptionPatterns on ChurchOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChurchOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChurchOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChurchOption value)  $default,){
final _that = this;
switch (_that) {
case _ChurchOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChurchOption value)?  $default,){
final _that = this;
switch (_that) {
case _ChurchOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String branchName,  String role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChurchOption() when $default != null:
return $default(_that.id,_that.name,_that.branchName,_that.role);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String branchName,  String role)  $default,) {final _that = this;
switch (_that) {
case _ChurchOption():
return $default(_that.id,_that.name,_that.branchName,_that.role);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String branchName,  String role)?  $default,) {final _that = this;
switch (_that) {
case _ChurchOption() when $default != null:
return $default(_that.id,_that.name,_that.branchName,_that.role);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChurchOption implements ChurchOption {
  const _ChurchOption({required this.id, required this.name, required this.branchName, required this.role});
  factory _ChurchOption.fromJson(Map<String, dynamic> json) => _$ChurchOptionFromJson(json);

@override final  String id;
@override final  String name;
@override final  String branchName;
@override final  String role;

/// Create a copy of ChurchOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChurchOptionCopyWith<_ChurchOption> get copyWith => __$ChurchOptionCopyWithImpl<_ChurchOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChurchOptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChurchOption&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.branchName, branchName) || other.branchName == branchName)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,branchName,role);

@override
String toString() {
  return 'ChurchOption(id: $id, name: $name, branchName: $branchName, role: $role)';
}


}

/// @nodoc
abstract mixin class _$ChurchOptionCopyWith<$Res> implements $ChurchOptionCopyWith<$Res> {
  factory _$ChurchOptionCopyWith(_ChurchOption value, $Res Function(_ChurchOption) _then) = __$ChurchOptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String branchName, String role
});




}
/// @nodoc
class __$ChurchOptionCopyWithImpl<$Res>
    implements _$ChurchOptionCopyWith<$Res> {
  __$ChurchOptionCopyWithImpl(this._self, this._then);

  final _ChurchOption _self;
  final $Res Function(_ChurchOption) _then;

/// Create a copy of ChurchOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? branchName = null,Object? role = null,}) {
  return _then(_ChurchOption(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,branchName: null == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
