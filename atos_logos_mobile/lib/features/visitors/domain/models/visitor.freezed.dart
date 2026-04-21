// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'visitor.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Visitor {

 String get id; String get churchId; String get name; String? get phone; String? get observations; String get createdAt;
/// Create a copy of Visitor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VisitorCopyWith<Visitor> get copyWith => _$VisitorCopyWithImpl<Visitor>(this as Visitor, _$identity);

  /// Serializes this Visitor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Visitor&&(identical(other.id, id) || other.id == id)&&(identical(other.churchId, churchId) || other.churchId == churchId)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.observations, observations) || other.observations == observations)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,churchId,name,phone,observations,createdAt);

@override
String toString() {
  return 'Visitor(id: $id, churchId: $churchId, name: $name, phone: $phone, observations: $observations, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $VisitorCopyWith<$Res>  {
  factory $VisitorCopyWith(Visitor value, $Res Function(Visitor) _then) = _$VisitorCopyWithImpl;
@useResult
$Res call({
 String id, String churchId, String name, String? phone, String? observations, String createdAt
});




}
/// @nodoc
class _$VisitorCopyWithImpl<$Res>
    implements $VisitorCopyWith<$Res> {
  _$VisitorCopyWithImpl(this._self, this._then);

  final Visitor _self;
  final $Res Function(Visitor) _then;

/// Create a copy of Visitor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? churchId = null,Object? name = null,Object? phone = freezed,Object? observations = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,churchId: null == churchId ? _self.churchId : churchId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,observations: freezed == observations ? _self.observations : observations // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Visitor].
extension VisitorPatterns on Visitor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Visitor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Visitor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Visitor value)  $default,){
final _that = this;
switch (_that) {
case _Visitor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Visitor value)?  $default,){
final _that = this;
switch (_that) {
case _Visitor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String churchId,  String name,  String? phone,  String? observations,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Visitor() when $default != null:
return $default(_that.id,_that.churchId,_that.name,_that.phone,_that.observations,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String churchId,  String name,  String? phone,  String? observations,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _Visitor():
return $default(_that.id,_that.churchId,_that.name,_that.phone,_that.observations,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String churchId,  String name,  String? phone,  String? observations,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Visitor() when $default != null:
return $default(_that.id,_that.churchId,_that.name,_that.phone,_that.observations,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Visitor implements Visitor {
  const _Visitor({required this.id, required this.churchId, required this.name, this.phone, this.observations, required this.createdAt});
  factory _Visitor.fromJson(Map<String, dynamic> json) => _$VisitorFromJson(json);

@override final  String id;
@override final  String churchId;
@override final  String name;
@override final  String? phone;
@override final  String? observations;
@override final  String createdAt;

/// Create a copy of Visitor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VisitorCopyWith<_Visitor> get copyWith => __$VisitorCopyWithImpl<_Visitor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VisitorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Visitor&&(identical(other.id, id) || other.id == id)&&(identical(other.churchId, churchId) || other.churchId == churchId)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.observations, observations) || other.observations == observations)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,churchId,name,phone,observations,createdAt);

@override
String toString() {
  return 'Visitor(id: $id, churchId: $churchId, name: $name, phone: $phone, observations: $observations, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$VisitorCopyWith<$Res> implements $VisitorCopyWith<$Res> {
  factory _$VisitorCopyWith(_Visitor value, $Res Function(_Visitor) _then) = __$VisitorCopyWithImpl;
@override @useResult
$Res call({
 String id, String churchId, String name, String? phone, String? observations, String createdAt
});




}
/// @nodoc
class __$VisitorCopyWithImpl<$Res>
    implements _$VisitorCopyWith<$Res> {
  __$VisitorCopyWithImpl(this._self, this._then);

  final _Visitor _self;
  final $Res Function(_Visitor) _then;

/// Create a copy of Visitor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? churchId = null,Object? name = null,Object? phone = freezed,Object? observations = freezed,Object? createdAt = null,}) {
  return _then(_Visitor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,churchId: null == churchId ? _self.churchId : churchId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,observations: freezed == observations ? _self.observations : observations // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$VisitorPage {

 List<Visitor> get data; int get total; int get page; int get limit;
/// Create a copy of VisitorPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VisitorPageCopyWith<VisitorPage> get copyWith => _$VisitorPageCopyWithImpl<VisitorPage>(this as VisitorPage, _$identity);

  /// Serializes this VisitorPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VisitorPage&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data),total,page,limit);

@override
String toString() {
  return 'VisitorPage(data: $data, total: $total, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $VisitorPageCopyWith<$Res>  {
  factory $VisitorPageCopyWith(VisitorPage value, $Res Function(VisitorPage) _then) = _$VisitorPageCopyWithImpl;
@useResult
$Res call({
 List<Visitor> data, int total, int page, int limit
});




}
/// @nodoc
class _$VisitorPageCopyWithImpl<$Res>
    implements $VisitorPageCopyWith<$Res> {
  _$VisitorPageCopyWithImpl(this._self, this._then);

  final VisitorPage _self;
  final $Res Function(VisitorPage) _then;

/// Create a copy of VisitorPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? total = null,Object? page = null,Object? limit = null,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as List<Visitor>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [VisitorPage].
extension VisitorPagePatterns on VisitorPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VisitorPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VisitorPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VisitorPage value)  $default,){
final _that = this;
switch (_that) {
case _VisitorPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VisitorPage value)?  $default,){
final _that = this;
switch (_that) {
case _VisitorPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Visitor> data,  int total,  int page,  int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VisitorPage() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Visitor> data,  int total,  int page,  int limit)  $default,) {final _that = this;
switch (_that) {
case _VisitorPage():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Visitor> data,  int total,  int page,  int limit)?  $default,) {final _that = this;
switch (_that) {
case _VisitorPage() when $default != null:
return $default(_that.data,_that.total,_that.page,_that.limit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VisitorPage implements VisitorPage {
  const _VisitorPage({required final  List<Visitor> data, required this.total, required this.page, required this.limit}): _data = data;
  factory _VisitorPage.fromJson(Map<String, dynamic> json) => _$VisitorPageFromJson(json);

 final  List<Visitor> _data;
@override List<Visitor> get data {
  if (_data is EqualUnmodifiableListView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_data);
}

@override final  int total;
@override final  int page;
@override final  int limit;

/// Create a copy of VisitorPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VisitorPageCopyWith<_VisitorPage> get copyWith => __$VisitorPageCopyWithImpl<_VisitorPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VisitorPageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VisitorPage&&const DeepCollectionEquality().equals(other._data, _data)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_data),total,page,limit);

@override
String toString() {
  return 'VisitorPage(data: $data, total: $total, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$VisitorPageCopyWith<$Res> implements $VisitorPageCopyWith<$Res> {
  factory _$VisitorPageCopyWith(_VisitorPage value, $Res Function(_VisitorPage) _then) = __$VisitorPageCopyWithImpl;
@override @useResult
$Res call({
 List<Visitor> data, int total, int page, int limit
});




}
/// @nodoc
class __$VisitorPageCopyWithImpl<$Res>
    implements _$VisitorPageCopyWith<$Res> {
  __$VisitorPageCopyWithImpl(this._self, this._then);

  final _VisitorPage _self;
  final $Res Function(_VisitorPage) _then;

/// Create a copy of VisitorPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? total = null,Object? page = null,Object? limit = null,}) {
  return _then(_VisitorPage(
data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as List<Visitor>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
