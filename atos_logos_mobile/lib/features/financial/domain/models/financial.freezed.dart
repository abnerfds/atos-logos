// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'financial.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Campaign {

 String get id; String get churchId; String get title; String get goalAmount; String get currentAmount; String get status;
/// Create a copy of Campaign
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CampaignCopyWith<Campaign> get copyWith => _$CampaignCopyWithImpl<Campaign>(this as Campaign, _$identity);

  /// Serializes this Campaign to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Campaign&&(identical(other.id, id) || other.id == id)&&(identical(other.churchId, churchId) || other.churchId == churchId)&&(identical(other.title, title) || other.title == title)&&(identical(other.goalAmount, goalAmount) || other.goalAmount == goalAmount)&&(identical(other.currentAmount, currentAmount) || other.currentAmount == currentAmount)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,churchId,title,goalAmount,currentAmount,status);

@override
String toString() {
  return 'Campaign(id: $id, churchId: $churchId, title: $title, goalAmount: $goalAmount, currentAmount: $currentAmount, status: $status)';
}


}

/// @nodoc
abstract mixin class $CampaignCopyWith<$Res>  {
  factory $CampaignCopyWith(Campaign value, $Res Function(Campaign) _then) = _$CampaignCopyWithImpl;
@useResult
$Res call({
 String id, String churchId, String title, String goalAmount, String currentAmount, String status
});




}
/// @nodoc
class _$CampaignCopyWithImpl<$Res>
    implements $CampaignCopyWith<$Res> {
  _$CampaignCopyWithImpl(this._self, this._then);

  final Campaign _self;
  final $Res Function(Campaign) _then;

/// Create a copy of Campaign
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? churchId = null,Object? title = null,Object? goalAmount = null,Object? currentAmount = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,churchId: null == churchId ? _self.churchId : churchId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,goalAmount: null == goalAmount ? _self.goalAmount : goalAmount // ignore: cast_nullable_to_non_nullable
as String,currentAmount: null == currentAmount ? _self.currentAmount : currentAmount // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Campaign].
extension CampaignPatterns on Campaign {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Campaign value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Campaign() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Campaign value)  $default,){
final _that = this;
switch (_that) {
case _Campaign():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Campaign value)?  $default,){
final _that = this;
switch (_that) {
case _Campaign() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String churchId,  String title,  String goalAmount,  String currentAmount,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Campaign() when $default != null:
return $default(_that.id,_that.churchId,_that.title,_that.goalAmount,_that.currentAmount,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String churchId,  String title,  String goalAmount,  String currentAmount,  String status)  $default,) {final _that = this;
switch (_that) {
case _Campaign():
return $default(_that.id,_that.churchId,_that.title,_that.goalAmount,_that.currentAmount,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String churchId,  String title,  String goalAmount,  String currentAmount,  String status)?  $default,) {final _that = this;
switch (_that) {
case _Campaign() when $default != null:
return $default(_that.id,_that.churchId,_that.title,_that.goalAmount,_that.currentAmount,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Campaign implements Campaign {
  const _Campaign({required this.id, required this.churchId, required this.title, required this.goalAmount, required this.currentAmount, required this.status});
  factory _Campaign.fromJson(Map<String, dynamic> json) => _$CampaignFromJson(json);

@override final  String id;
@override final  String churchId;
@override final  String title;
@override final  String goalAmount;
@override final  String currentAmount;
@override final  String status;

/// Create a copy of Campaign
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CampaignCopyWith<_Campaign> get copyWith => __$CampaignCopyWithImpl<_Campaign>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CampaignToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Campaign&&(identical(other.id, id) || other.id == id)&&(identical(other.churchId, churchId) || other.churchId == churchId)&&(identical(other.title, title) || other.title == title)&&(identical(other.goalAmount, goalAmount) || other.goalAmount == goalAmount)&&(identical(other.currentAmount, currentAmount) || other.currentAmount == currentAmount)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,churchId,title,goalAmount,currentAmount,status);

@override
String toString() {
  return 'Campaign(id: $id, churchId: $churchId, title: $title, goalAmount: $goalAmount, currentAmount: $currentAmount, status: $status)';
}


}

/// @nodoc
abstract mixin class _$CampaignCopyWith<$Res> implements $CampaignCopyWith<$Res> {
  factory _$CampaignCopyWith(_Campaign value, $Res Function(_Campaign) _then) = __$CampaignCopyWithImpl;
@override @useResult
$Res call({
 String id, String churchId, String title, String goalAmount, String currentAmount, String status
});




}
/// @nodoc
class __$CampaignCopyWithImpl<$Res>
    implements _$CampaignCopyWith<$Res> {
  __$CampaignCopyWithImpl(this._self, this._then);

  final _Campaign _self;
  final $Res Function(_Campaign) _then;

/// Create a copy of Campaign
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? churchId = null,Object? title = null,Object? goalAmount = null,Object? currentAmount = null,Object? status = null,}) {
  return _then(_Campaign(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,churchId: null == churchId ? _self.churchId : churchId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,goalAmount: null == goalAmount ? _self.goalAmount : goalAmount // ignore: cast_nullable_to_non_nullable
as String,currentAmount: null == currentAmount ? _self.currentAmount : currentAmount // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TransactionDonor {

 String get id; String get name;
/// Create a copy of TransactionDonor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionDonorCopyWith<TransactionDonor> get copyWith => _$TransactionDonorCopyWithImpl<TransactionDonor>(this as TransactionDonor, _$identity);

  /// Serializes this TransactionDonor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionDonor&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'TransactionDonor(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $TransactionDonorCopyWith<$Res>  {
  factory $TransactionDonorCopyWith(TransactionDonor value, $Res Function(TransactionDonor) _then) = _$TransactionDonorCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$TransactionDonorCopyWithImpl<$Res>
    implements $TransactionDonorCopyWith<$Res> {
  _$TransactionDonorCopyWithImpl(this._self, this._then);

  final TransactionDonor _self;
  final $Res Function(TransactionDonor) _then;

/// Create a copy of TransactionDonor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionDonor].
extension TransactionDonorPatterns on TransactionDonor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionDonor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionDonor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionDonor value)  $default,){
final _that = this;
switch (_that) {
case _TransactionDonor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionDonor value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionDonor() when $default != null:
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
case _TransactionDonor() when $default != null:
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
case _TransactionDonor():
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
case _TransactionDonor() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionDonor implements TransactionDonor {
  const _TransactionDonor({required this.id, required this.name});
  factory _TransactionDonor.fromJson(Map<String, dynamic> json) => _$TransactionDonorFromJson(json);

@override final  String id;
@override final  String name;

/// Create a copy of TransactionDonor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionDonorCopyWith<_TransactionDonor> get copyWith => __$TransactionDonorCopyWithImpl<_TransactionDonor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionDonorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionDonor&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'TransactionDonor(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$TransactionDonorCopyWith<$Res> implements $TransactionDonorCopyWith<$Res> {
  factory _$TransactionDonorCopyWith(_TransactionDonor value, $Res Function(_TransactionDonor) _then) = __$TransactionDonorCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$TransactionDonorCopyWithImpl<$Res>
    implements _$TransactionDonorCopyWith<$Res> {
  __$TransactionDonorCopyWithImpl(this._self, this._then);

  final _TransactionDonor _self;
  final $Res Function(_TransactionDonor) _then;

/// Create a copy of TransactionDonor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_TransactionDonor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$FinancialTransaction {

 String get id; String get churchId; String get type; String get category; String get amount; String get transactionDate; TransactionDonor? get donor;
/// Create a copy of FinancialTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FinancialTransactionCopyWith<FinancialTransaction> get copyWith => _$FinancialTransactionCopyWithImpl<FinancialTransaction>(this as FinancialTransaction, _$identity);

  /// Serializes this FinancialTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FinancialTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.churchId, churchId) || other.churchId == churchId)&&(identical(other.type, type) || other.type == type)&&(identical(other.category, category) || other.category == category)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.transactionDate, transactionDate) || other.transactionDate == transactionDate)&&(identical(other.donor, donor) || other.donor == donor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,churchId,type,category,amount,transactionDate,donor);

@override
String toString() {
  return 'FinancialTransaction(id: $id, churchId: $churchId, type: $type, category: $category, amount: $amount, transactionDate: $transactionDate, donor: $donor)';
}


}

/// @nodoc
abstract mixin class $FinancialTransactionCopyWith<$Res>  {
  factory $FinancialTransactionCopyWith(FinancialTransaction value, $Res Function(FinancialTransaction) _then) = _$FinancialTransactionCopyWithImpl;
@useResult
$Res call({
 String id, String churchId, String type, String category, String amount, String transactionDate, TransactionDonor? donor
});


$TransactionDonorCopyWith<$Res>? get donor;

}
/// @nodoc
class _$FinancialTransactionCopyWithImpl<$Res>
    implements $FinancialTransactionCopyWith<$Res> {
  _$FinancialTransactionCopyWithImpl(this._self, this._then);

  final FinancialTransaction _self;
  final $Res Function(FinancialTransaction) _then;

/// Create a copy of FinancialTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? churchId = null,Object? type = null,Object? category = null,Object? amount = null,Object? transactionDate = null,Object? donor = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,churchId: null == churchId ? _self.churchId : churchId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,transactionDate: null == transactionDate ? _self.transactionDate : transactionDate // ignore: cast_nullable_to_non_nullable
as String,donor: freezed == donor ? _self.donor : donor // ignore: cast_nullable_to_non_nullable
as TransactionDonor?,
  ));
}
/// Create a copy of FinancialTransaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransactionDonorCopyWith<$Res>? get donor {
    if (_self.donor == null) {
    return null;
  }

  return $TransactionDonorCopyWith<$Res>(_self.donor!, (value) {
    return _then(_self.copyWith(donor: value));
  });
}
}


/// Adds pattern-matching-related methods to [FinancialTransaction].
extension FinancialTransactionPatterns on FinancialTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FinancialTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FinancialTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FinancialTransaction value)  $default,){
final _that = this;
switch (_that) {
case _FinancialTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FinancialTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _FinancialTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String churchId,  String type,  String category,  String amount,  String transactionDate,  TransactionDonor? donor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FinancialTransaction() when $default != null:
return $default(_that.id,_that.churchId,_that.type,_that.category,_that.amount,_that.transactionDate,_that.donor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String churchId,  String type,  String category,  String amount,  String transactionDate,  TransactionDonor? donor)  $default,) {final _that = this;
switch (_that) {
case _FinancialTransaction():
return $default(_that.id,_that.churchId,_that.type,_that.category,_that.amount,_that.transactionDate,_that.donor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String churchId,  String type,  String category,  String amount,  String transactionDate,  TransactionDonor? donor)?  $default,) {final _that = this;
switch (_that) {
case _FinancialTransaction() when $default != null:
return $default(_that.id,_that.churchId,_that.type,_that.category,_that.amount,_that.transactionDate,_that.donor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FinancialTransaction implements FinancialTransaction {
  const _FinancialTransaction({required this.id, required this.churchId, required this.type, required this.category, required this.amount, required this.transactionDate, this.donor});
  factory _FinancialTransaction.fromJson(Map<String, dynamic> json) => _$FinancialTransactionFromJson(json);

@override final  String id;
@override final  String churchId;
@override final  String type;
@override final  String category;
@override final  String amount;
@override final  String transactionDate;
@override final  TransactionDonor? donor;

/// Create a copy of FinancialTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FinancialTransactionCopyWith<_FinancialTransaction> get copyWith => __$FinancialTransactionCopyWithImpl<_FinancialTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FinancialTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FinancialTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.churchId, churchId) || other.churchId == churchId)&&(identical(other.type, type) || other.type == type)&&(identical(other.category, category) || other.category == category)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.transactionDate, transactionDate) || other.transactionDate == transactionDate)&&(identical(other.donor, donor) || other.donor == donor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,churchId,type,category,amount,transactionDate,donor);

@override
String toString() {
  return 'FinancialTransaction(id: $id, churchId: $churchId, type: $type, category: $category, amount: $amount, transactionDate: $transactionDate, donor: $donor)';
}


}

/// @nodoc
abstract mixin class _$FinancialTransactionCopyWith<$Res> implements $FinancialTransactionCopyWith<$Res> {
  factory _$FinancialTransactionCopyWith(_FinancialTransaction value, $Res Function(_FinancialTransaction) _then) = __$FinancialTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String churchId, String type, String category, String amount, String transactionDate, TransactionDonor? donor
});


@override $TransactionDonorCopyWith<$Res>? get donor;

}
/// @nodoc
class __$FinancialTransactionCopyWithImpl<$Res>
    implements _$FinancialTransactionCopyWith<$Res> {
  __$FinancialTransactionCopyWithImpl(this._self, this._then);

  final _FinancialTransaction _self;
  final $Res Function(_FinancialTransaction) _then;

/// Create a copy of FinancialTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? churchId = null,Object? type = null,Object? category = null,Object? amount = null,Object? transactionDate = null,Object? donor = freezed,}) {
  return _then(_FinancialTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,churchId: null == churchId ? _self.churchId : churchId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,transactionDate: null == transactionDate ? _self.transactionDate : transactionDate // ignore: cast_nullable_to_non_nullable
as String,donor: freezed == donor ? _self.donor : donor // ignore: cast_nullable_to_non_nullable
as TransactionDonor?,
  ));
}

/// Create a copy of FinancialTransaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransactionDonorCopyWith<$Res>? get donor {
    if (_self.donor == null) {
    return null;
  }

  return $TransactionDonorCopyWith<$Res>(_self.donor!, (value) {
    return _then(_self.copyWith(donor: value));
  });
}
}


/// @nodoc
mixin _$TransactionPage {

 List<FinancialTransaction> get data; int get total; int get page; int get limit;
/// Create a copy of TransactionPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionPageCopyWith<TransactionPage> get copyWith => _$TransactionPageCopyWithImpl<TransactionPage>(this as TransactionPage, _$identity);

  /// Serializes this TransactionPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionPage&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data),total,page,limit);

@override
String toString() {
  return 'TransactionPage(data: $data, total: $total, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $TransactionPageCopyWith<$Res>  {
  factory $TransactionPageCopyWith(TransactionPage value, $Res Function(TransactionPage) _then) = _$TransactionPageCopyWithImpl;
@useResult
$Res call({
 List<FinancialTransaction> data, int total, int page, int limit
});




}
/// @nodoc
class _$TransactionPageCopyWithImpl<$Res>
    implements $TransactionPageCopyWith<$Res> {
  _$TransactionPageCopyWithImpl(this._self, this._then);

  final TransactionPage _self;
  final $Res Function(TransactionPage) _then;

/// Create a copy of TransactionPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? total = null,Object? page = null,Object? limit = null,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as List<FinancialTransaction>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionPage].
extension TransactionPagePatterns on TransactionPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionPage value)  $default,){
final _that = this;
switch (_that) {
case _TransactionPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionPage value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<FinancialTransaction> data,  int total,  int page,  int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionPage() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<FinancialTransaction> data,  int total,  int page,  int limit)  $default,) {final _that = this;
switch (_that) {
case _TransactionPage():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<FinancialTransaction> data,  int total,  int page,  int limit)?  $default,) {final _that = this;
switch (_that) {
case _TransactionPage() when $default != null:
return $default(_that.data,_that.total,_that.page,_that.limit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionPage implements TransactionPage {
  const _TransactionPage({required final  List<FinancialTransaction> data, required this.total, required this.page, required this.limit}): _data = data;
  factory _TransactionPage.fromJson(Map<String, dynamic> json) => _$TransactionPageFromJson(json);

 final  List<FinancialTransaction> _data;
@override List<FinancialTransaction> get data {
  if (_data is EqualUnmodifiableListView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_data);
}

@override final  int total;
@override final  int page;
@override final  int limit;

/// Create a copy of TransactionPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionPageCopyWith<_TransactionPage> get copyWith => __$TransactionPageCopyWithImpl<_TransactionPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionPageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionPage&&const DeepCollectionEquality().equals(other._data, _data)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_data),total,page,limit);

@override
String toString() {
  return 'TransactionPage(data: $data, total: $total, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$TransactionPageCopyWith<$Res> implements $TransactionPageCopyWith<$Res> {
  factory _$TransactionPageCopyWith(_TransactionPage value, $Res Function(_TransactionPage) _then) = __$TransactionPageCopyWithImpl;
@override @useResult
$Res call({
 List<FinancialTransaction> data, int total, int page, int limit
});




}
/// @nodoc
class __$TransactionPageCopyWithImpl<$Res>
    implements _$TransactionPageCopyWith<$Res> {
  __$TransactionPageCopyWithImpl(this._self, this._then);

  final _TransactionPage _self;
  final $Res Function(_TransactionPage) _then;

/// Create a copy of TransactionPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? total = null,Object? page = null,Object? limit = null,}) {
  return _then(_TransactionPage(
data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as List<FinancialTransaction>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$FinancialSummary {

 double get totalIncome; double get totalExpense; double get balance;
/// Create a copy of FinancialSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FinancialSummaryCopyWith<FinancialSummary> get copyWith => _$FinancialSummaryCopyWithImpl<FinancialSummary>(this as FinancialSummary, _$identity);

  /// Serializes this FinancialSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FinancialSummary&&(identical(other.totalIncome, totalIncome) || other.totalIncome == totalIncome)&&(identical(other.totalExpense, totalExpense) || other.totalExpense == totalExpense)&&(identical(other.balance, balance) || other.balance == balance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalIncome,totalExpense,balance);

@override
String toString() {
  return 'FinancialSummary(totalIncome: $totalIncome, totalExpense: $totalExpense, balance: $balance)';
}


}

/// @nodoc
abstract mixin class $FinancialSummaryCopyWith<$Res>  {
  factory $FinancialSummaryCopyWith(FinancialSummary value, $Res Function(FinancialSummary) _then) = _$FinancialSummaryCopyWithImpl;
@useResult
$Res call({
 double totalIncome, double totalExpense, double balance
});




}
/// @nodoc
class _$FinancialSummaryCopyWithImpl<$Res>
    implements $FinancialSummaryCopyWith<$Res> {
  _$FinancialSummaryCopyWithImpl(this._self, this._then);

  final FinancialSummary _self;
  final $Res Function(FinancialSummary) _then;

/// Create a copy of FinancialSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalIncome = null,Object? totalExpense = null,Object? balance = null,}) {
  return _then(_self.copyWith(
totalIncome: null == totalIncome ? _self.totalIncome : totalIncome // ignore: cast_nullable_to_non_nullable
as double,totalExpense: null == totalExpense ? _self.totalExpense : totalExpense // ignore: cast_nullable_to_non_nullable
as double,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [FinancialSummary].
extension FinancialSummaryPatterns on FinancialSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FinancialSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FinancialSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FinancialSummary value)  $default,){
final _that = this;
switch (_that) {
case _FinancialSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FinancialSummary value)?  $default,){
final _that = this;
switch (_that) {
case _FinancialSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double totalIncome,  double totalExpense,  double balance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FinancialSummary() when $default != null:
return $default(_that.totalIncome,_that.totalExpense,_that.balance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double totalIncome,  double totalExpense,  double balance)  $default,) {final _that = this;
switch (_that) {
case _FinancialSummary():
return $default(_that.totalIncome,_that.totalExpense,_that.balance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double totalIncome,  double totalExpense,  double balance)?  $default,) {final _that = this;
switch (_that) {
case _FinancialSummary() when $default != null:
return $default(_that.totalIncome,_that.totalExpense,_that.balance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FinancialSummary implements FinancialSummary {
  const _FinancialSummary({required this.totalIncome, required this.totalExpense, required this.balance});
  factory _FinancialSummary.fromJson(Map<String, dynamic> json) => _$FinancialSummaryFromJson(json);

@override final  double totalIncome;
@override final  double totalExpense;
@override final  double balance;

/// Create a copy of FinancialSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FinancialSummaryCopyWith<_FinancialSummary> get copyWith => __$FinancialSummaryCopyWithImpl<_FinancialSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FinancialSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FinancialSummary&&(identical(other.totalIncome, totalIncome) || other.totalIncome == totalIncome)&&(identical(other.totalExpense, totalExpense) || other.totalExpense == totalExpense)&&(identical(other.balance, balance) || other.balance == balance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalIncome,totalExpense,balance);

@override
String toString() {
  return 'FinancialSummary(totalIncome: $totalIncome, totalExpense: $totalExpense, balance: $balance)';
}


}

/// @nodoc
abstract mixin class _$FinancialSummaryCopyWith<$Res> implements $FinancialSummaryCopyWith<$Res> {
  factory _$FinancialSummaryCopyWith(_FinancialSummary value, $Res Function(_FinancialSummary) _then) = __$FinancialSummaryCopyWithImpl;
@override @useResult
$Res call({
 double totalIncome, double totalExpense, double balance
});




}
/// @nodoc
class __$FinancialSummaryCopyWithImpl<$Res>
    implements _$FinancialSummaryCopyWith<$Res> {
  __$FinancialSummaryCopyWithImpl(this._self, this._then);

  final _FinancialSummary _self;
  final $Res Function(_FinancialSummary) _then;

/// Create a copy of FinancialSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalIncome = null,Object? totalExpense = null,Object? balance = null,}) {
  return _then(_FinancialSummary(
totalIncome: null == totalIncome ? _self.totalIncome : totalIncome // ignore: cast_nullable_to_non_nullable
as double,totalExpense: null == totalExpense ? _self.totalExpense : totalExpense // ignore: cast_nullable_to_non_nullable
as double,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
