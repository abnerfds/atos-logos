// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'branch.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Branch {

 String get id; String get name; bool get isHeadquarters; String? get country; String? get state; String? get city; String? get neighborhood; String? get street; String? get number;@JsonKey(name: '_count') BranchCount? get count;
/// Create a copy of Branch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BranchCopyWith<Branch> get copyWith => _$BranchCopyWithImpl<Branch>(this as Branch, _$identity);

  /// Serializes this Branch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Branch&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.isHeadquarters, isHeadquarters) || other.isHeadquarters == isHeadquarters)&&(identical(other.country, country) || other.country == country)&&(identical(other.state, state) || other.state == state)&&(identical(other.city, city) || other.city == city)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.street, street) || other.street == street)&&(identical(other.number, number) || other.number == number)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,isHeadquarters,country,state,city,neighborhood,street,number,count);

@override
String toString() {
  return 'Branch(id: $id, name: $name, isHeadquarters: $isHeadquarters, country: $country, state: $state, city: $city, neighborhood: $neighborhood, street: $street, number: $number, count: $count)';
}


}

/// @nodoc
abstract mixin class $BranchCopyWith<$Res>  {
  factory $BranchCopyWith(Branch value, $Res Function(Branch) _then) = _$BranchCopyWithImpl;
@useResult
$Res call({
 String id, String name, bool isHeadquarters, String? country, String? state, String? city, String? neighborhood, String? street, String? number,@JsonKey(name: '_count') BranchCount? count
});


$BranchCountCopyWith<$Res>? get count;

}
/// @nodoc
class _$BranchCopyWithImpl<$Res>
    implements $BranchCopyWith<$Res> {
  _$BranchCopyWithImpl(this._self, this._then);

  final Branch _self;
  final $Res Function(Branch) _then;

/// Create a copy of Branch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? isHeadquarters = null,Object? country = freezed,Object? state = freezed,Object? city = freezed,Object? neighborhood = freezed,Object? street = freezed,Object? number = freezed,Object? count = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isHeadquarters: null == isHeadquarters ? _self.isHeadquarters : isHeadquarters // ignore: cast_nullable_to_non_nullable
as bool,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,neighborhood: freezed == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String?,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String?,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as BranchCount?,
  ));
}
/// Create a copy of Branch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BranchCountCopyWith<$Res>? get count {
    if (_self.count == null) {
    return null;
  }

  return $BranchCountCopyWith<$Res>(_self.count!, (value) {
    return _then(_self.copyWith(count: value));
  });
}
}


/// Adds pattern-matching-related methods to [Branch].
extension BranchPatterns on Branch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Branch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Branch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Branch value)  $default,){
final _that = this;
switch (_that) {
case _Branch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Branch value)?  $default,){
final _that = this;
switch (_that) {
case _Branch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  bool isHeadquarters,  String? country,  String? state,  String? city,  String? neighborhood,  String? street,  String? number, @JsonKey(name: '_count')  BranchCount? count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Branch() when $default != null:
return $default(_that.id,_that.name,_that.isHeadquarters,_that.country,_that.state,_that.city,_that.neighborhood,_that.street,_that.number,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  bool isHeadquarters,  String? country,  String? state,  String? city,  String? neighborhood,  String? street,  String? number, @JsonKey(name: '_count')  BranchCount? count)  $default,) {final _that = this;
switch (_that) {
case _Branch():
return $default(_that.id,_that.name,_that.isHeadquarters,_that.country,_that.state,_that.city,_that.neighborhood,_that.street,_that.number,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  bool isHeadquarters,  String? country,  String? state,  String? city,  String? neighborhood,  String? street,  String? number, @JsonKey(name: '_count')  BranchCount? count)?  $default,) {final _that = this;
switch (_that) {
case _Branch() when $default != null:
return $default(_that.id,_that.name,_that.isHeadquarters,_that.country,_that.state,_that.city,_that.neighborhood,_that.street,_that.number,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Branch implements Branch {
  const _Branch({required this.id, required this.name, required this.isHeadquarters, this.country, this.state, this.city, this.neighborhood, this.street, this.number, @JsonKey(name: '_count') this.count});
  factory _Branch.fromJson(Map<String, dynamic> json) => _$BranchFromJson(json);

@override final  String id;
@override final  String name;
@override final  bool isHeadquarters;
@override final  String? country;
@override final  String? state;
@override final  String? city;
@override final  String? neighborhood;
@override final  String? street;
@override final  String? number;
@override@JsonKey(name: '_count') final  BranchCount? count;

/// Create a copy of Branch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BranchCopyWith<_Branch> get copyWith => __$BranchCopyWithImpl<_Branch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BranchToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Branch&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.isHeadquarters, isHeadquarters) || other.isHeadquarters == isHeadquarters)&&(identical(other.country, country) || other.country == country)&&(identical(other.state, state) || other.state == state)&&(identical(other.city, city) || other.city == city)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.street, street) || other.street == street)&&(identical(other.number, number) || other.number == number)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,isHeadquarters,country,state,city,neighborhood,street,number,count);

@override
String toString() {
  return 'Branch(id: $id, name: $name, isHeadquarters: $isHeadquarters, country: $country, state: $state, city: $city, neighborhood: $neighborhood, street: $street, number: $number, count: $count)';
}


}

/// @nodoc
abstract mixin class _$BranchCopyWith<$Res> implements $BranchCopyWith<$Res> {
  factory _$BranchCopyWith(_Branch value, $Res Function(_Branch) _then) = __$BranchCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, bool isHeadquarters, String? country, String? state, String? city, String? neighborhood, String? street, String? number,@JsonKey(name: '_count') BranchCount? count
});


@override $BranchCountCopyWith<$Res>? get count;

}
/// @nodoc
class __$BranchCopyWithImpl<$Res>
    implements _$BranchCopyWith<$Res> {
  __$BranchCopyWithImpl(this._self, this._then);

  final _Branch _self;
  final $Res Function(_Branch) _then;

/// Create a copy of Branch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? isHeadquarters = null,Object? country = freezed,Object? state = freezed,Object? city = freezed,Object? neighborhood = freezed,Object? street = freezed,Object? number = freezed,Object? count = freezed,}) {
  return _then(_Branch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isHeadquarters: null == isHeadquarters ? _self.isHeadquarters : isHeadquarters // ignore: cast_nullable_to_non_nullable
as bool,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,neighborhood: freezed == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String?,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String?,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as BranchCount?,
  ));
}

/// Create a copy of Branch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BranchCountCopyWith<$Res>? get count {
    if (_self.count == null) {
    return null;
  }

  return $BranchCountCopyWith<$Res>(_self.count!, (value) {
    return _then(_self.copyWith(count: value));
  });
}
}


/// @nodoc
mixin _$BranchCount {

 int get memberships;
/// Create a copy of BranchCount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BranchCountCopyWith<BranchCount> get copyWith => _$BranchCountCopyWithImpl<BranchCount>(this as BranchCount, _$identity);

  /// Serializes this BranchCount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BranchCount&&(identical(other.memberships, memberships) || other.memberships == memberships));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberships);

@override
String toString() {
  return 'BranchCount(memberships: $memberships)';
}


}

/// @nodoc
abstract mixin class $BranchCountCopyWith<$Res>  {
  factory $BranchCountCopyWith(BranchCount value, $Res Function(BranchCount) _then) = _$BranchCountCopyWithImpl;
@useResult
$Res call({
 int memberships
});




}
/// @nodoc
class _$BranchCountCopyWithImpl<$Res>
    implements $BranchCountCopyWith<$Res> {
  _$BranchCountCopyWithImpl(this._self, this._then);

  final BranchCount _self;
  final $Res Function(BranchCount) _then;

/// Create a copy of BranchCount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? memberships = null,}) {
  return _then(_self.copyWith(
memberships: null == memberships ? _self.memberships : memberships // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BranchCount].
extension BranchCountPatterns on BranchCount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BranchCount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BranchCount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BranchCount value)  $default,){
final _that = this;
switch (_that) {
case _BranchCount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BranchCount value)?  $default,){
final _that = this;
switch (_that) {
case _BranchCount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int memberships)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BranchCount() when $default != null:
return $default(_that.memberships);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int memberships)  $default,) {final _that = this;
switch (_that) {
case _BranchCount():
return $default(_that.memberships);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int memberships)?  $default,) {final _that = this;
switch (_that) {
case _BranchCount() when $default != null:
return $default(_that.memberships);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BranchCount implements BranchCount {
  const _BranchCount({this.memberships = 0});
  factory _BranchCount.fromJson(Map<String, dynamic> json) => _$BranchCountFromJson(json);

@override@JsonKey() final  int memberships;

/// Create a copy of BranchCount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BranchCountCopyWith<_BranchCount> get copyWith => __$BranchCountCopyWithImpl<_BranchCount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BranchCountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BranchCount&&(identical(other.memberships, memberships) || other.memberships == memberships));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberships);

@override
String toString() {
  return 'BranchCount(memberships: $memberships)';
}


}

/// @nodoc
abstract mixin class _$BranchCountCopyWith<$Res> implements $BranchCountCopyWith<$Res> {
  factory _$BranchCountCopyWith(_BranchCount value, $Res Function(_BranchCount) _then) = __$BranchCountCopyWithImpl;
@override @useResult
$Res call({
 int memberships
});




}
/// @nodoc
class __$BranchCountCopyWithImpl<$Res>
    implements _$BranchCountCopyWith<$Res> {
  __$BranchCountCopyWithImpl(this._self, this._then);

  final _BranchCount _self;
  final $Res Function(_BranchCount) _then;

/// Create a copy of BranchCount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? memberships = null,}) {
  return _then(_BranchCount(
memberships: null == memberships ? _self.memberships : memberships // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
