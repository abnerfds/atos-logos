// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'select_church_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SelectChurchRequest {

 String get selectionToken; String get churchId;
/// Create a copy of SelectChurchRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectChurchRequestCopyWith<SelectChurchRequest> get copyWith => _$SelectChurchRequestCopyWithImpl<SelectChurchRequest>(this as SelectChurchRequest, _$identity);

  /// Serializes this SelectChurchRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectChurchRequest&&(identical(other.selectionToken, selectionToken) || other.selectionToken == selectionToken)&&(identical(other.churchId, churchId) || other.churchId == churchId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,selectionToken,churchId);

@override
String toString() {
  return 'SelectChurchRequest(selectionToken: $selectionToken, churchId: $churchId)';
}


}

/// @nodoc
abstract mixin class $SelectChurchRequestCopyWith<$Res>  {
  factory $SelectChurchRequestCopyWith(SelectChurchRequest value, $Res Function(SelectChurchRequest) _then) = _$SelectChurchRequestCopyWithImpl;
@useResult
$Res call({
 String selectionToken, String churchId
});




}
/// @nodoc
class _$SelectChurchRequestCopyWithImpl<$Res>
    implements $SelectChurchRequestCopyWith<$Res> {
  _$SelectChurchRequestCopyWithImpl(this._self, this._then);

  final SelectChurchRequest _self;
  final $Res Function(SelectChurchRequest) _then;

/// Create a copy of SelectChurchRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectionToken = null,Object? churchId = null,}) {
  return _then(_self.copyWith(
selectionToken: null == selectionToken ? _self.selectionToken : selectionToken // ignore: cast_nullable_to_non_nullable
as String,churchId: null == churchId ? _self.churchId : churchId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SelectChurchRequest].
extension SelectChurchRequestPatterns on SelectChurchRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SelectChurchRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SelectChurchRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SelectChurchRequest value)  $default,){
final _that = this;
switch (_that) {
case _SelectChurchRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SelectChurchRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SelectChurchRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String selectionToken,  String churchId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SelectChurchRequest() when $default != null:
return $default(_that.selectionToken,_that.churchId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String selectionToken,  String churchId)  $default,) {final _that = this;
switch (_that) {
case _SelectChurchRequest():
return $default(_that.selectionToken,_that.churchId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String selectionToken,  String churchId)?  $default,) {final _that = this;
switch (_that) {
case _SelectChurchRequest() when $default != null:
return $default(_that.selectionToken,_that.churchId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SelectChurchRequest implements SelectChurchRequest {
  const _SelectChurchRequest({required this.selectionToken, required this.churchId});
  factory _SelectChurchRequest.fromJson(Map<String, dynamic> json) => _$SelectChurchRequestFromJson(json);

@override final  String selectionToken;
@override final  String churchId;

/// Create a copy of SelectChurchRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SelectChurchRequestCopyWith<_SelectChurchRequest> get copyWith => __$SelectChurchRequestCopyWithImpl<_SelectChurchRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SelectChurchRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SelectChurchRequest&&(identical(other.selectionToken, selectionToken) || other.selectionToken == selectionToken)&&(identical(other.churchId, churchId) || other.churchId == churchId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,selectionToken,churchId);

@override
String toString() {
  return 'SelectChurchRequest(selectionToken: $selectionToken, churchId: $churchId)';
}


}

/// @nodoc
abstract mixin class _$SelectChurchRequestCopyWith<$Res> implements $SelectChurchRequestCopyWith<$Res> {
  factory _$SelectChurchRequestCopyWith(_SelectChurchRequest value, $Res Function(_SelectChurchRequest) _then) = __$SelectChurchRequestCopyWithImpl;
@override @useResult
$Res call({
 String selectionToken, String churchId
});




}
/// @nodoc
class __$SelectChurchRequestCopyWithImpl<$Res>
    implements _$SelectChurchRequestCopyWith<$Res> {
  __$SelectChurchRequestCopyWithImpl(this._self, this._then);

  final _SelectChurchRequest _self;
  final $Res Function(_SelectChurchRequest) _then;

/// Create a copy of SelectChurchRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectionToken = null,Object? churchId = null,}) {
  return _then(_SelectChurchRequest(
selectionToken: null == selectionToken ? _self.selectionToken : selectionToken // ignore: cast_nullable_to_non_nullable
as String,churchId: null == churchId ? _self.churchId : churchId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
