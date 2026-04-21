// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ebd_class.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EbdClassBranch {

 String get id; String get name;
/// Create a copy of EbdClassBranch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EbdClassBranchCopyWith<EbdClassBranch> get copyWith => _$EbdClassBranchCopyWithImpl<EbdClassBranch>(this as EbdClassBranch, _$identity);

  /// Serializes this EbdClassBranch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EbdClassBranch&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'EbdClassBranch(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $EbdClassBranchCopyWith<$Res>  {
  factory $EbdClassBranchCopyWith(EbdClassBranch value, $Res Function(EbdClassBranch) _then) = _$EbdClassBranchCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$EbdClassBranchCopyWithImpl<$Res>
    implements $EbdClassBranchCopyWith<$Res> {
  _$EbdClassBranchCopyWithImpl(this._self, this._then);

  final EbdClassBranch _self;
  final $Res Function(EbdClassBranch) _then;

/// Create a copy of EbdClassBranch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [EbdClassBranch].
extension EbdClassBranchPatterns on EbdClassBranch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EbdClassBranch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EbdClassBranch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EbdClassBranch value)  $default,){
final _that = this;
switch (_that) {
case _EbdClassBranch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EbdClassBranch value)?  $default,){
final _that = this;
switch (_that) {
case _EbdClassBranch() when $default != null:
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
case _EbdClassBranch() when $default != null:
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
case _EbdClassBranch():
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
case _EbdClassBranch() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EbdClassBranch implements EbdClassBranch {
  const _EbdClassBranch({required this.id, required this.name});
  factory _EbdClassBranch.fromJson(Map<String, dynamic> json) => _$EbdClassBranchFromJson(json);

@override final  String id;
@override final  String name;

/// Create a copy of EbdClassBranch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EbdClassBranchCopyWith<_EbdClassBranch> get copyWith => __$EbdClassBranchCopyWithImpl<_EbdClassBranch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EbdClassBranchToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EbdClassBranch&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'EbdClassBranch(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$EbdClassBranchCopyWith<$Res> implements $EbdClassBranchCopyWith<$Res> {
  factory _$EbdClassBranchCopyWith(_EbdClassBranch value, $Res Function(_EbdClassBranch) _then) = __$EbdClassBranchCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$EbdClassBranchCopyWithImpl<$Res>
    implements _$EbdClassBranchCopyWith<$Res> {
  __$EbdClassBranchCopyWithImpl(this._self, this._then);

  final _EbdClassBranch _self;
  final $Res Function(_EbdClassBranch) _then;

/// Create a copy of EbdClassBranch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_EbdClassBranch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$EbdClass {

 String get id; String get churchId; String get branchId; String get name; EbdClassBranch? get branch;
/// Create a copy of EbdClass
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EbdClassCopyWith<EbdClass> get copyWith => _$EbdClassCopyWithImpl<EbdClass>(this as EbdClass, _$identity);

  /// Serializes this EbdClass to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EbdClass&&(identical(other.id, id) || other.id == id)&&(identical(other.churchId, churchId) || other.churchId == churchId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.name, name) || other.name == name)&&(identical(other.branch, branch) || other.branch == branch));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,churchId,branchId,name,branch);

@override
String toString() {
  return 'EbdClass(id: $id, churchId: $churchId, branchId: $branchId, name: $name, branch: $branch)';
}


}

/// @nodoc
abstract mixin class $EbdClassCopyWith<$Res>  {
  factory $EbdClassCopyWith(EbdClass value, $Res Function(EbdClass) _then) = _$EbdClassCopyWithImpl;
@useResult
$Res call({
 String id, String churchId, String branchId, String name, EbdClassBranch? branch
});


$EbdClassBranchCopyWith<$Res>? get branch;

}
/// @nodoc
class _$EbdClassCopyWithImpl<$Res>
    implements $EbdClassCopyWith<$Res> {
  _$EbdClassCopyWithImpl(this._self, this._then);

  final EbdClass _self;
  final $Res Function(EbdClass) _then;

/// Create a copy of EbdClass
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? churchId = null,Object? branchId = null,Object? name = null,Object? branch = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,churchId: null == churchId ? _self.churchId : churchId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as EbdClassBranch?,
  ));
}
/// Create a copy of EbdClass
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EbdClassBranchCopyWith<$Res>? get branch {
    if (_self.branch == null) {
    return null;
  }

  return $EbdClassBranchCopyWith<$Res>(_self.branch!, (value) {
    return _then(_self.copyWith(branch: value));
  });
}
}


/// Adds pattern-matching-related methods to [EbdClass].
extension EbdClassPatterns on EbdClass {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EbdClass value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EbdClass() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EbdClass value)  $default,){
final _that = this;
switch (_that) {
case _EbdClass():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EbdClass value)?  $default,){
final _that = this;
switch (_that) {
case _EbdClass() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String churchId,  String branchId,  String name,  EbdClassBranch? branch)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EbdClass() when $default != null:
return $default(_that.id,_that.churchId,_that.branchId,_that.name,_that.branch);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String churchId,  String branchId,  String name,  EbdClassBranch? branch)  $default,) {final _that = this;
switch (_that) {
case _EbdClass():
return $default(_that.id,_that.churchId,_that.branchId,_that.name,_that.branch);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String churchId,  String branchId,  String name,  EbdClassBranch? branch)?  $default,) {final _that = this;
switch (_that) {
case _EbdClass() when $default != null:
return $default(_that.id,_that.churchId,_that.branchId,_that.name,_that.branch);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EbdClass implements EbdClass {
  const _EbdClass({required this.id, required this.churchId, required this.branchId, required this.name, this.branch});
  factory _EbdClass.fromJson(Map<String, dynamic> json) => _$EbdClassFromJson(json);

@override final  String id;
@override final  String churchId;
@override final  String branchId;
@override final  String name;
@override final  EbdClassBranch? branch;

/// Create a copy of EbdClass
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EbdClassCopyWith<_EbdClass> get copyWith => __$EbdClassCopyWithImpl<_EbdClass>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EbdClassToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EbdClass&&(identical(other.id, id) || other.id == id)&&(identical(other.churchId, churchId) || other.churchId == churchId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.name, name) || other.name == name)&&(identical(other.branch, branch) || other.branch == branch));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,churchId,branchId,name,branch);

@override
String toString() {
  return 'EbdClass(id: $id, churchId: $churchId, branchId: $branchId, name: $name, branch: $branch)';
}


}

/// @nodoc
abstract mixin class _$EbdClassCopyWith<$Res> implements $EbdClassCopyWith<$Res> {
  factory _$EbdClassCopyWith(_EbdClass value, $Res Function(_EbdClass) _then) = __$EbdClassCopyWithImpl;
@override @useResult
$Res call({
 String id, String churchId, String branchId, String name, EbdClassBranch? branch
});


@override $EbdClassBranchCopyWith<$Res>? get branch;

}
/// @nodoc
class __$EbdClassCopyWithImpl<$Res>
    implements _$EbdClassCopyWith<$Res> {
  __$EbdClassCopyWithImpl(this._self, this._then);

  final _EbdClass _self;
  final $Res Function(_EbdClass) _then;

/// Create a copy of EbdClass
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? churchId = null,Object? branchId = null,Object? name = null,Object? branch = freezed,}) {
  return _then(_EbdClass(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,churchId: null == churchId ? _self.churchId : churchId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as EbdClassBranch?,
  ));
}

/// Create a copy of EbdClass
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EbdClassBranchCopyWith<$Res>? get branch {
    if (_self.branch == null) {
    return null;
  }

  return $EbdClassBranchCopyWith<$Res>(_self.branch!, (value) {
    return _then(_self.copyWith(branch: value));
  });
}
}


/// @nodoc
mixin _$EbdFrequency {

 String get userId; String get classId; int get totalSessions; int get presentCount; double get frequency; bool get certificateEligible;
/// Create a copy of EbdFrequency
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EbdFrequencyCopyWith<EbdFrequency> get copyWith => _$EbdFrequencyCopyWithImpl<EbdFrequency>(this as EbdFrequency, _$identity);

  /// Serializes this EbdFrequency to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EbdFrequency&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.classId, classId) || other.classId == classId)&&(identical(other.totalSessions, totalSessions) || other.totalSessions == totalSessions)&&(identical(other.presentCount, presentCount) || other.presentCount == presentCount)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.certificateEligible, certificateEligible) || other.certificateEligible == certificateEligible));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,classId,totalSessions,presentCount,frequency,certificateEligible);

@override
String toString() {
  return 'EbdFrequency(userId: $userId, classId: $classId, totalSessions: $totalSessions, presentCount: $presentCount, frequency: $frequency, certificateEligible: $certificateEligible)';
}


}

/// @nodoc
abstract mixin class $EbdFrequencyCopyWith<$Res>  {
  factory $EbdFrequencyCopyWith(EbdFrequency value, $Res Function(EbdFrequency) _then) = _$EbdFrequencyCopyWithImpl;
@useResult
$Res call({
 String userId, String classId, int totalSessions, int presentCount, double frequency, bool certificateEligible
});




}
/// @nodoc
class _$EbdFrequencyCopyWithImpl<$Res>
    implements $EbdFrequencyCopyWith<$Res> {
  _$EbdFrequencyCopyWithImpl(this._self, this._then);

  final EbdFrequency _self;
  final $Res Function(EbdFrequency) _then;

/// Create a copy of EbdFrequency
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? classId = null,Object? totalSessions = null,Object? presentCount = null,Object? frequency = null,Object? certificateEligible = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,classId: null == classId ? _self.classId : classId // ignore: cast_nullable_to_non_nullable
as String,totalSessions: null == totalSessions ? _self.totalSessions : totalSessions // ignore: cast_nullable_to_non_nullable
as int,presentCount: null == presentCount ? _self.presentCount : presentCount // ignore: cast_nullable_to_non_nullable
as int,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as double,certificateEligible: null == certificateEligible ? _self.certificateEligible : certificateEligible // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [EbdFrequency].
extension EbdFrequencyPatterns on EbdFrequency {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EbdFrequency value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EbdFrequency() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EbdFrequency value)  $default,){
final _that = this;
switch (_that) {
case _EbdFrequency():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EbdFrequency value)?  $default,){
final _that = this;
switch (_that) {
case _EbdFrequency() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String classId,  int totalSessions,  int presentCount,  double frequency,  bool certificateEligible)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EbdFrequency() when $default != null:
return $default(_that.userId,_that.classId,_that.totalSessions,_that.presentCount,_that.frequency,_that.certificateEligible);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String classId,  int totalSessions,  int presentCount,  double frequency,  bool certificateEligible)  $default,) {final _that = this;
switch (_that) {
case _EbdFrequency():
return $default(_that.userId,_that.classId,_that.totalSessions,_that.presentCount,_that.frequency,_that.certificateEligible);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String classId,  int totalSessions,  int presentCount,  double frequency,  bool certificateEligible)?  $default,) {final _that = this;
switch (_that) {
case _EbdFrequency() when $default != null:
return $default(_that.userId,_that.classId,_that.totalSessions,_that.presentCount,_that.frequency,_that.certificateEligible);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EbdFrequency implements EbdFrequency {
  const _EbdFrequency({required this.userId, required this.classId, required this.totalSessions, required this.presentCount, required this.frequency, required this.certificateEligible});
  factory _EbdFrequency.fromJson(Map<String, dynamic> json) => _$EbdFrequencyFromJson(json);

@override final  String userId;
@override final  String classId;
@override final  int totalSessions;
@override final  int presentCount;
@override final  double frequency;
@override final  bool certificateEligible;

/// Create a copy of EbdFrequency
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EbdFrequencyCopyWith<_EbdFrequency> get copyWith => __$EbdFrequencyCopyWithImpl<_EbdFrequency>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EbdFrequencyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EbdFrequency&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.classId, classId) || other.classId == classId)&&(identical(other.totalSessions, totalSessions) || other.totalSessions == totalSessions)&&(identical(other.presentCount, presentCount) || other.presentCount == presentCount)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.certificateEligible, certificateEligible) || other.certificateEligible == certificateEligible));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,classId,totalSessions,presentCount,frequency,certificateEligible);

@override
String toString() {
  return 'EbdFrequency(userId: $userId, classId: $classId, totalSessions: $totalSessions, presentCount: $presentCount, frequency: $frequency, certificateEligible: $certificateEligible)';
}


}

/// @nodoc
abstract mixin class _$EbdFrequencyCopyWith<$Res> implements $EbdFrequencyCopyWith<$Res> {
  factory _$EbdFrequencyCopyWith(_EbdFrequency value, $Res Function(_EbdFrequency) _then) = __$EbdFrequencyCopyWithImpl;
@override @useResult
$Res call({
 String userId, String classId, int totalSessions, int presentCount, double frequency, bool certificateEligible
});




}
/// @nodoc
class __$EbdFrequencyCopyWithImpl<$Res>
    implements _$EbdFrequencyCopyWith<$Res> {
  __$EbdFrequencyCopyWithImpl(this._self, this._then);

  final _EbdFrequency _self;
  final $Res Function(_EbdFrequency) _then;

/// Create a copy of EbdFrequency
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? classId = null,Object? totalSessions = null,Object? presentCount = null,Object? frequency = null,Object? certificateEligible = null,}) {
  return _then(_EbdFrequency(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,classId: null == classId ? _self.classId : classId // ignore: cast_nullable_to_non_nullable
as String,totalSessions: null == totalSessions ? _self.totalSessions : totalSessions // ignore: cast_nullable_to_non_nullable
as int,presentCount: null == presentCount ? _self.presentCount : presentCount // ignore: cast_nullable_to_non_nullable
as int,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as double,certificateEligible: null == certificateEligible ? _self.certificateEligible : certificateEligible // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
