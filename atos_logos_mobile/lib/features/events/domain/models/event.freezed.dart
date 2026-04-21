// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventBranch {

 String get id; String get name;
/// Create a copy of EventBranch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventBranchCopyWith<EventBranch> get copyWith => _$EventBranchCopyWithImpl<EventBranch>(this as EventBranch, _$identity);

  /// Serializes this EventBranch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventBranch&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'EventBranch(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $EventBranchCopyWith<$Res>  {
  factory $EventBranchCopyWith(EventBranch value, $Res Function(EventBranch) _then) = _$EventBranchCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$EventBranchCopyWithImpl<$Res>
    implements $EventBranchCopyWith<$Res> {
  _$EventBranchCopyWithImpl(this._self, this._then);

  final EventBranch _self;
  final $Res Function(EventBranch) _then;

/// Create a copy of EventBranch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [EventBranch].
extension EventBranchPatterns on EventBranch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventBranch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventBranch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventBranch value)  $default,){
final _that = this;
switch (_that) {
case _EventBranch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventBranch value)?  $default,){
final _that = this;
switch (_that) {
case _EventBranch() when $default != null:
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
case _EventBranch() when $default != null:
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
case _EventBranch():
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
case _EventBranch() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventBranch implements EventBranch {
  const _EventBranch({required this.id, required this.name});
  factory _EventBranch.fromJson(Map<String, dynamic> json) => _$EventBranchFromJson(json);

@override final  String id;
@override final  String name;

/// Create a copy of EventBranch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventBranchCopyWith<_EventBranch> get copyWith => __$EventBranchCopyWithImpl<_EventBranch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventBranchToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventBranch&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'EventBranch(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$EventBranchCopyWith<$Res> implements $EventBranchCopyWith<$Res> {
  factory _$EventBranchCopyWith(_EventBranch value, $Res Function(_EventBranch) _then) = __$EventBranchCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$EventBranchCopyWithImpl<$Res>
    implements _$EventBranchCopyWith<$Res> {
  __$EventBranchCopyWithImpl(this._self, this._then);

  final _EventBranch _self;
  final $Res Function(_EventBranch) _then;

/// Create a copy of EventBranch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_EventBranch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ScheduleUser {

 String get id; String get name;
/// Create a copy of ScheduleUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleUserCopyWith<ScheduleUser> get copyWith => _$ScheduleUserCopyWithImpl<ScheduleUser>(this as ScheduleUser, _$identity);

  /// Serializes this ScheduleUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'ScheduleUser(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $ScheduleUserCopyWith<$Res>  {
  factory $ScheduleUserCopyWith(ScheduleUser value, $Res Function(ScheduleUser) _then) = _$ScheduleUserCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$ScheduleUserCopyWithImpl<$Res>
    implements $ScheduleUserCopyWith<$Res> {
  _$ScheduleUserCopyWithImpl(this._self, this._then);

  final ScheduleUser _self;
  final $Res Function(ScheduleUser) _then;

/// Create a copy of ScheduleUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduleUser].
extension ScheduleUserPatterns on ScheduleUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduleUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduleUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduleUser value)  $default,){
final _that = this;
switch (_that) {
case _ScheduleUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduleUser value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduleUser() when $default != null:
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
case _ScheduleUser() when $default != null:
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
case _ScheduleUser():
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
case _ScheduleUser() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScheduleUser implements ScheduleUser {
  const _ScheduleUser({required this.id, required this.name});
  factory _ScheduleUser.fromJson(Map<String, dynamic> json) => _$ScheduleUserFromJson(json);

@override final  String id;
@override final  String name;

/// Create a copy of ScheduleUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduleUserCopyWith<_ScheduleUser> get copyWith => __$ScheduleUserCopyWithImpl<_ScheduleUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduleUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduleUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'ScheduleUser(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$ScheduleUserCopyWith<$Res> implements $ScheduleUserCopyWith<$Res> {
  factory _$ScheduleUserCopyWith(_ScheduleUser value, $Res Function(_ScheduleUser) _then) = __$ScheduleUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$ScheduleUserCopyWithImpl<$Res>
    implements _$ScheduleUserCopyWith<$Res> {
  __$ScheduleUserCopyWithImpl(this._self, this._then);

  final _ScheduleUser _self;
  final $Res Function(_ScheduleUser) _then;

/// Create a copy of ScheduleUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_ScheduleUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$EventSchedule {

 String get id; String get eventId; String get userId; String get functionName; ScheduleUser get user;
/// Create a copy of EventSchedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventScheduleCopyWith<EventSchedule> get copyWith => _$EventScheduleCopyWithImpl<EventSchedule>(this as EventSchedule, _$identity);

  /// Serializes this EventSchedule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventSchedule&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.functionName, functionName) || other.functionName == functionName)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,userId,functionName,user);

@override
String toString() {
  return 'EventSchedule(id: $id, eventId: $eventId, userId: $userId, functionName: $functionName, user: $user)';
}


}

/// @nodoc
abstract mixin class $EventScheduleCopyWith<$Res>  {
  factory $EventScheduleCopyWith(EventSchedule value, $Res Function(EventSchedule) _then) = _$EventScheduleCopyWithImpl;
@useResult
$Res call({
 String id, String eventId, String userId, String functionName, ScheduleUser user
});


$ScheduleUserCopyWith<$Res> get user;

}
/// @nodoc
class _$EventScheduleCopyWithImpl<$Res>
    implements $EventScheduleCopyWith<$Res> {
  _$EventScheduleCopyWithImpl(this._self, this._then);

  final EventSchedule _self;
  final $Res Function(EventSchedule) _then;

/// Create a copy of EventSchedule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? eventId = null,Object? userId = null,Object? functionName = null,Object? user = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,functionName: null == functionName ? _self.functionName : functionName // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as ScheduleUser,
  ));
}
/// Create a copy of EventSchedule
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScheduleUserCopyWith<$Res> get user {
  
  return $ScheduleUserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [EventSchedule].
extension EventSchedulePatterns on EventSchedule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventSchedule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventSchedule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventSchedule value)  $default,){
final _that = this;
switch (_that) {
case _EventSchedule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventSchedule value)?  $default,){
final _that = this;
switch (_that) {
case _EventSchedule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String eventId,  String userId,  String functionName,  ScheduleUser user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventSchedule() when $default != null:
return $default(_that.id,_that.eventId,_that.userId,_that.functionName,_that.user);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String eventId,  String userId,  String functionName,  ScheduleUser user)  $default,) {final _that = this;
switch (_that) {
case _EventSchedule():
return $default(_that.id,_that.eventId,_that.userId,_that.functionName,_that.user);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String eventId,  String userId,  String functionName,  ScheduleUser user)?  $default,) {final _that = this;
switch (_that) {
case _EventSchedule() when $default != null:
return $default(_that.id,_that.eventId,_that.userId,_that.functionName,_that.user);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventSchedule implements EventSchedule {
  const _EventSchedule({required this.id, required this.eventId, required this.userId, required this.functionName, required this.user});
  factory _EventSchedule.fromJson(Map<String, dynamic> json) => _$EventScheduleFromJson(json);

@override final  String id;
@override final  String eventId;
@override final  String userId;
@override final  String functionName;
@override final  ScheduleUser user;

/// Create a copy of EventSchedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventScheduleCopyWith<_EventSchedule> get copyWith => __$EventScheduleCopyWithImpl<_EventSchedule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventScheduleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventSchedule&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.functionName, functionName) || other.functionName == functionName)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,userId,functionName,user);

@override
String toString() {
  return 'EventSchedule(id: $id, eventId: $eventId, userId: $userId, functionName: $functionName, user: $user)';
}


}

/// @nodoc
abstract mixin class _$EventScheduleCopyWith<$Res> implements $EventScheduleCopyWith<$Res> {
  factory _$EventScheduleCopyWith(_EventSchedule value, $Res Function(_EventSchedule) _then) = __$EventScheduleCopyWithImpl;
@override @useResult
$Res call({
 String id, String eventId, String userId, String functionName, ScheduleUser user
});


@override $ScheduleUserCopyWith<$Res> get user;

}
/// @nodoc
class __$EventScheduleCopyWithImpl<$Res>
    implements _$EventScheduleCopyWith<$Res> {
  __$EventScheduleCopyWithImpl(this._self, this._then);

  final _EventSchedule _self;
  final $Res Function(_EventSchedule) _then;

/// Create a copy of EventSchedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? eventId = null,Object? userId = null,Object? functionName = null,Object? user = null,}) {
  return _then(_EventSchedule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,functionName: null == functionName ? _self.functionName : functionName // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as ScheduleUser,
  ));
}

/// Create a copy of EventSchedule
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScheduleUserCopyWith<$Res> get user {
  
  return $ScheduleUserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// @nodoc
mixin _$Event {

 String get id; String get churchId; String? get branchId; String get title; String get startsAt; String get type; EventBranch? get branch; List<EventSchedule> get schedules;
/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventCopyWith<Event> get copyWith => _$EventCopyWithImpl<Event>(this as Event, _$identity);

  /// Serializes this Event to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Event&&(identical(other.id, id) || other.id == id)&&(identical(other.churchId, churchId) || other.churchId == churchId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.title, title) || other.title == title)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.type, type) || other.type == type)&&(identical(other.branch, branch) || other.branch == branch)&&const DeepCollectionEquality().equals(other.schedules, schedules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,churchId,branchId,title,startsAt,type,branch,const DeepCollectionEquality().hash(schedules));

@override
String toString() {
  return 'Event(id: $id, churchId: $churchId, branchId: $branchId, title: $title, startsAt: $startsAt, type: $type, branch: $branch, schedules: $schedules)';
}


}

/// @nodoc
abstract mixin class $EventCopyWith<$Res>  {
  factory $EventCopyWith(Event value, $Res Function(Event) _then) = _$EventCopyWithImpl;
@useResult
$Res call({
 String id, String churchId, String? branchId, String title, String startsAt, String type, EventBranch? branch, List<EventSchedule> schedules
});


$EventBranchCopyWith<$Res>? get branch;

}
/// @nodoc
class _$EventCopyWithImpl<$Res>
    implements $EventCopyWith<$Res> {
  _$EventCopyWithImpl(this._self, this._then);

  final Event _self;
  final $Res Function(Event) _then;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? churchId = null,Object? branchId = freezed,Object? title = null,Object? startsAt = null,Object? type = null,Object? branch = freezed,Object? schedules = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,churchId: null == churchId ? _self.churchId : churchId // ignore: cast_nullable_to_non_nullable
as String,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as EventBranch?,schedules: null == schedules ? _self.schedules : schedules // ignore: cast_nullable_to_non_nullable
as List<EventSchedule>,
  ));
}
/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventBranchCopyWith<$Res>? get branch {
    if (_self.branch == null) {
    return null;
  }

  return $EventBranchCopyWith<$Res>(_self.branch!, (value) {
    return _then(_self.copyWith(branch: value));
  });
}
}


/// Adds pattern-matching-related methods to [Event].
extension EventPatterns on Event {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Event value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Event() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Event value)  $default,){
final _that = this;
switch (_that) {
case _Event():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Event value)?  $default,){
final _that = this;
switch (_that) {
case _Event() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String churchId,  String? branchId,  String title,  String startsAt,  String type,  EventBranch? branch,  List<EventSchedule> schedules)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Event() when $default != null:
return $default(_that.id,_that.churchId,_that.branchId,_that.title,_that.startsAt,_that.type,_that.branch,_that.schedules);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String churchId,  String? branchId,  String title,  String startsAt,  String type,  EventBranch? branch,  List<EventSchedule> schedules)  $default,) {final _that = this;
switch (_that) {
case _Event():
return $default(_that.id,_that.churchId,_that.branchId,_that.title,_that.startsAt,_that.type,_that.branch,_that.schedules);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String churchId,  String? branchId,  String title,  String startsAt,  String type,  EventBranch? branch,  List<EventSchedule> schedules)?  $default,) {final _that = this;
switch (_that) {
case _Event() when $default != null:
return $default(_that.id,_that.churchId,_that.branchId,_that.title,_that.startsAt,_that.type,_that.branch,_that.schedules);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Event implements Event {
  const _Event({required this.id, required this.churchId, this.branchId, required this.title, required this.startsAt, required this.type, this.branch, final  List<EventSchedule> schedules = const []}): _schedules = schedules;
  factory _Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

@override final  String id;
@override final  String churchId;
@override final  String? branchId;
@override final  String title;
@override final  String startsAt;
@override final  String type;
@override final  EventBranch? branch;
 final  List<EventSchedule> _schedules;
@override@JsonKey() List<EventSchedule> get schedules {
  if (_schedules is EqualUnmodifiableListView) return _schedules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_schedules);
}


/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventCopyWith<_Event> get copyWith => __$EventCopyWithImpl<_Event>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Event&&(identical(other.id, id) || other.id == id)&&(identical(other.churchId, churchId) || other.churchId == churchId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.title, title) || other.title == title)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.type, type) || other.type == type)&&(identical(other.branch, branch) || other.branch == branch)&&const DeepCollectionEquality().equals(other._schedules, _schedules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,churchId,branchId,title,startsAt,type,branch,const DeepCollectionEquality().hash(_schedules));

@override
String toString() {
  return 'Event(id: $id, churchId: $churchId, branchId: $branchId, title: $title, startsAt: $startsAt, type: $type, branch: $branch, schedules: $schedules)';
}


}

/// @nodoc
abstract mixin class _$EventCopyWith<$Res> implements $EventCopyWith<$Res> {
  factory _$EventCopyWith(_Event value, $Res Function(_Event) _then) = __$EventCopyWithImpl;
@override @useResult
$Res call({
 String id, String churchId, String? branchId, String title, String startsAt, String type, EventBranch? branch, List<EventSchedule> schedules
});


@override $EventBranchCopyWith<$Res>? get branch;

}
/// @nodoc
class __$EventCopyWithImpl<$Res>
    implements _$EventCopyWith<$Res> {
  __$EventCopyWithImpl(this._self, this._then);

  final _Event _self;
  final $Res Function(_Event) _then;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? churchId = null,Object? branchId = freezed,Object? title = null,Object? startsAt = null,Object? type = null,Object? branch = freezed,Object? schedules = null,}) {
  return _then(_Event(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,churchId: null == churchId ? _self.churchId : churchId // ignore: cast_nullable_to_non_nullable
as String,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as EventBranch?,schedules: null == schedules ? _self._schedules : schedules // ignore: cast_nullable_to_non_nullable
as List<EventSchedule>,
  ));
}

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventBranchCopyWith<$Res>? get branch {
    if (_self.branch == null) {
    return null;
  }

  return $EventBranchCopyWith<$Res>(_self.branch!, (value) {
    return _then(_self.copyWith(branch: value));
  });
}
}


/// @nodoc
mixin _$EventPage {

 List<Event> get data; int get total; int get page; int get limit;
/// Create a copy of EventPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventPageCopyWith<EventPage> get copyWith => _$EventPageCopyWithImpl<EventPage>(this as EventPage, _$identity);

  /// Serializes this EventPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventPage&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data),total,page,limit);

@override
String toString() {
  return 'EventPage(data: $data, total: $total, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $EventPageCopyWith<$Res>  {
  factory $EventPageCopyWith(EventPage value, $Res Function(EventPage) _then) = _$EventPageCopyWithImpl;
@useResult
$Res call({
 List<Event> data, int total, int page, int limit
});




}
/// @nodoc
class _$EventPageCopyWithImpl<$Res>
    implements $EventPageCopyWith<$Res> {
  _$EventPageCopyWithImpl(this._self, this._then);

  final EventPage _self;
  final $Res Function(EventPage) _then;

/// Create a copy of EventPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? total = null,Object? page = null,Object? limit = null,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as List<Event>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [EventPage].
extension EventPagePatterns on EventPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventPage value)  $default,){
final _that = this;
switch (_that) {
case _EventPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventPage value)?  $default,){
final _that = this;
switch (_that) {
case _EventPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Event> data,  int total,  int page,  int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventPage() when $default != null:
return $default(_that.data,_that.total,_that.page,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Event> data,  int total,  int page,  int limit)  $default,) {final _that = this;
switch (_that) {
case _EventPage():
return $default(_that.data,_that.total,_that.page,_that.limit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Event> data,  int total,  int page,  int limit)?  $default,) {final _that = this;
switch (_that) {
case _EventPage() when $default != null:
return $default(_that.data,_that.total,_that.page,_that.limit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventPage implements EventPage {
  const _EventPage({required final  List<Event> data, required this.total, required this.page, required this.limit}): _data = data;
  factory _EventPage.fromJson(Map<String, dynamic> json) => _$EventPageFromJson(json);

 final  List<Event> _data;
@override List<Event> get data {
  if (_data is EqualUnmodifiableListView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_data);
}

@override final  int total;
@override final  int page;
@override final  int limit;

/// Create a copy of EventPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventPageCopyWith<_EventPage> get copyWith => __$EventPageCopyWithImpl<_EventPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventPageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventPage&&const DeepCollectionEquality().equals(other._data, _data)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_data),total,page,limit);

@override
String toString() {
  return 'EventPage(data: $data, total: $total, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$EventPageCopyWith<$Res> implements $EventPageCopyWith<$Res> {
  factory _$EventPageCopyWith(_EventPage value, $Res Function(_EventPage) _then) = __$EventPageCopyWithImpl;
@override @useResult
$Res call({
 List<Event> data, int total, int page, int limit
});




}
/// @nodoc
class __$EventPageCopyWithImpl<$Res>
    implements _$EventPageCopyWith<$Res> {
  __$EventPageCopyWithImpl(this._self, this._then);

  final _EventPage _self;
  final $Res Function(_EventPage) _then;

/// Create a copy of EventPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? total = null,Object? page = null,Object? limit = null,}) {
  return _then(_EventPage(
data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as List<Event>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
