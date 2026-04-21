// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upcoming_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpcomingEvent {

 String get id; String get title; DateTime get startsAt; String? get branchName; String? get type;
/// Create a copy of UpcomingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpcomingEventCopyWith<UpcomingEvent> get copyWith => _$UpcomingEventCopyWithImpl<UpcomingEvent>(this as UpcomingEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpcomingEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.branchName, branchName) || other.branchName == branchName)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,startsAt,branchName,type);

@override
String toString() {
  return 'UpcomingEvent(id: $id, title: $title, startsAt: $startsAt, branchName: $branchName, type: $type)';
}


}

/// @nodoc
abstract mixin class $UpcomingEventCopyWith<$Res>  {
  factory $UpcomingEventCopyWith(UpcomingEvent value, $Res Function(UpcomingEvent) _then) = _$UpcomingEventCopyWithImpl;
@useResult
$Res call({
 String id, String title, DateTime startsAt, String? branchName, String? type
});




}
/// @nodoc
class _$UpcomingEventCopyWithImpl<$Res>
    implements $UpcomingEventCopyWith<$Res> {
  _$UpcomingEventCopyWithImpl(this._self, this._then);

  final UpcomingEvent _self;
  final $Res Function(UpcomingEvent) _then;

/// Create a copy of UpcomingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? startsAt = null,Object? branchName = freezed,Object? type = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,branchName: freezed == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpcomingEvent].
extension UpcomingEventPatterns on UpcomingEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpcomingEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpcomingEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpcomingEvent value)  $default,){
final _that = this;
switch (_that) {
case _UpcomingEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpcomingEvent value)?  $default,){
final _that = this;
switch (_that) {
case _UpcomingEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  DateTime startsAt,  String? branchName,  String? type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpcomingEvent() when $default != null:
return $default(_that.id,_that.title,_that.startsAt,_that.branchName,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  DateTime startsAt,  String? branchName,  String? type)  $default,) {final _that = this;
switch (_that) {
case _UpcomingEvent():
return $default(_that.id,_that.title,_that.startsAt,_that.branchName,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  DateTime startsAt,  String? branchName,  String? type)?  $default,) {final _that = this;
switch (_that) {
case _UpcomingEvent() when $default != null:
return $default(_that.id,_that.title,_that.startsAt,_that.branchName,_that.type);case _:
  return null;

}
}

}

/// @nodoc


class _UpcomingEvent implements UpcomingEvent {
  const _UpcomingEvent({required this.id, required this.title, required this.startsAt, this.branchName, this.type});
  

@override final  String id;
@override final  String title;
@override final  DateTime startsAt;
@override final  String? branchName;
@override final  String? type;

/// Create a copy of UpcomingEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpcomingEventCopyWith<_UpcomingEvent> get copyWith => __$UpcomingEventCopyWithImpl<_UpcomingEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpcomingEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.branchName, branchName) || other.branchName == branchName)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,startsAt,branchName,type);

@override
String toString() {
  return 'UpcomingEvent(id: $id, title: $title, startsAt: $startsAt, branchName: $branchName, type: $type)';
}


}

/// @nodoc
abstract mixin class _$UpcomingEventCopyWith<$Res> implements $UpcomingEventCopyWith<$Res> {
  factory _$UpcomingEventCopyWith(_UpcomingEvent value, $Res Function(_UpcomingEvent) _then) = __$UpcomingEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, DateTime startsAt, String? branchName, String? type
});




}
/// @nodoc
class __$UpcomingEventCopyWithImpl<$Res>
    implements _$UpcomingEventCopyWith<$Res> {
  __$UpcomingEventCopyWithImpl(this._self, this._then);

  final _UpcomingEvent _self;
  final $Res Function(_UpcomingEvent) _then;

/// Create a copy of UpcomingEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? startsAt = null,Object? branchName = freezed,Object? type = freezed,}) {
  return _then(_UpcomingEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,branchName: freezed == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
