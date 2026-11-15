// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CatalogData {

 List<Product> get products; List<Banner> get banners; List<Shop> get shops; List<Challenge> get challenges; Member? get member;
/// Create a copy of CatalogData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogDataCopyWith<CatalogData> get copyWith => _$CatalogDataCopyWithImpl<CatalogData>(this as CatalogData, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CatalogData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogData&&const DeepCollectionEquality().equals(other.products, _this.products)&&const DeepCollectionEquality().equals(other.banners, _this.banners)&&const DeepCollectionEquality().equals(other.shops, _this.shops)&&const DeepCollectionEquality().equals(other.challenges, _this.challenges)&&(identical(other.member, _this.member) || other.member == _this.member));
}


@override
int get hashCode {
  final _this = this as CatalogData;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.products),const DeepCollectionEquality().hash(_this.banners),const DeepCollectionEquality().hash(_this.shops),const DeepCollectionEquality().hash(_this.challenges),_this.member);
}

@override
String toString() {
  final _this = this as CatalogData;
  return 'CatalogData(products: ${_this.products}, banners: ${_this.banners}, shops: ${_this.shops}, challenges: ${_this.challenges}, member: ${_this.member})';
}


}

/// @nodoc
abstract mixin class $CatalogDataCopyWith<$Res>  {
  factory $CatalogDataCopyWith(CatalogData value, $Res Function(CatalogData) _then) = _$CatalogDataCopyWithImpl;
@useResult
$Res call({
 List<Product> products, List<Banner> banners, List<Shop> shops, List<Challenge> challenges, Member? member
});


$MemberCopyWith<$Res>? get member;

}
/// @nodoc
class _$CatalogDataCopyWithImpl<$Res>
    implements $CatalogDataCopyWith<$Res> {
  _$CatalogDataCopyWithImpl(this._self, this._then);

  final CatalogData _self;
  final $Res Function(CatalogData) _then;

/// Create a copy of CatalogData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? products = null,Object? banners = null,Object? shops = null,Object? challenges = null,Object? member = freezed,}) {
  return _then(CatalogData(
products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<Product>,banners: null == banners ? _self.banners : banners // ignore: cast_nullable_to_non_nullable
as List<Banner>,shops: null == shops ? _self.shops : shops // ignore: cast_nullable_to_non_nullable
as List<Shop>,challenges: null == challenges ? _self.challenges : challenges // ignore: cast_nullable_to_non_nullable
as List<Challenge>,member: freezed == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as Member?,
  ));
}
/// Create a copy of CatalogData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MemberCopyWith<$Res>? get member {
    if (_self.member == null) {
    return null;
  }

  return $MemberCopyWith<$Res>(_self.member!, (value) {
    return _then(_self.copyWith(member: value));
  });
}
}


/// Adds pattern-matching-related methods to [CatalogData].
extension CatalogDataPatterns on CatalogData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CatalogData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CatalogData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CatalogData value)  $default,){
final _that = this;
switch (_that) {
case _CatalogData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CatalogData value)?  $default,){
final _that = this;
switch (_that) {
case _CatalogData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Product> products,  List<Banner> banners,  List<Shop> shops,  List<Challenge> challenges,  Member? member)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CatalogData() when $default != null:
return $default(_that.products,_that.banners,_that.shops,_that.challenges,_that.member);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Product> products,  List<Banner> banners,  List<Shop> shops,  List<Challenge> challenges,  Member? member)  $default,) {final _that = this;
switch (_that) {
case _CatalogData():
return $default(_that.products,_that.banners,_that.shops,_that.challenges,_that.member);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Product> products,  List<Banner> banners,  List<Shop> shops,  List<Challenge> challenges,  Member? member)?  $default,) {final _that = this;
switch (_that) {
case _CatalogData() when $default != null:
return $default(_that.products,_that.banners,_that.shops,_that.challenges,_that.member);case _:
  return null;

}
}

}

/// @nodoc


class _CatalogData extends CatalogData {
  const _CatalogData({ List<Product> products = const <Product>[],  List<Banner> banners = const <Banner>[],  List<Shop> shops = const <Shop>[],  List<Challenge> challenges = const <Challenge>[], this.member}): _products = products,_banners = banners,_shops = shops,_challenges = challenges,super._();
  

 final  List<Product> _products;
@override@JsonKey() List<Product> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}

 final  List<Banner> _banners;
@override@JsonKey() List<Banner> get banners {
  if (_banners is EqualUnmodifiableListView) return _banners;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_banners);
}

 final  List<Shop> _shops;
@override@JsonKey() List<Shop> get shops {
  if (_shops is EqualUnmodifiableListView) return _shops;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_shops);
}

 final  List<Challenge> _challenges;
@override@JsonKey() List<Challenge> get challenges {
  if (_challenges is EqualUnmodifiableListView) return _challenges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_challenges);
}

@override final  Member? member;

/// Create a copy of CatalogData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CatalogDataCopyWith<_CatalogData> get copyWith => __$CatalogDataCopyWithImpl<_CatalogData>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CatalogData&&const DeepCollectionEquality().equals(other.products, _products)&&const DeepCollectionEquality().equals(other.banners, _banners)&&const DeepCollectionEquality().equals(other.shops, _shops)&&const DeepCollectionEquality().equals(other.challenges, _challenges)&&(identical(other.member, member) || other.member == member));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_products),const DeepCollectionEquality().hash(_banners),const DeepCollectionEquality().hash(_shops),const DeepCollectionEquality().hash(_challenges),member);
}

@override
String toString() {
    return 'CatalogData(products: $products, banners: $banners, shops: $shops, challenges: $challenges, member: $member)';
}


}

/// @nodoc
abstract mixin class _$CatalogDataCopyWith<$Res> implements $CatalogDataCopyWith<$Res> {
  factory _$CatalogDataCopyWith(_CatalogData value, $Res Function(_CatalogData) _then) = __$CatalogDataCopyWithImpl;
@override @useResult
$Res call({
 List<Product> products, List<Banner> banners, List<Shop> shops, List<Challenge> challenges, Member? member
});


@override $MemberCopyWith<$Res>? get member;

}
/// @nodoc
class __$CatalogDataCopyWithImpl<$Res>
    implements _$CatalogDataCopyWith<$Res> {
  __$CatalogDataCopyWithImpl(this._self, this._then);

  final _CatalogData _self;
  final $Res Function(_CatalogData) _then;

/// Create a copy of CatalogData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? products = null,Object? banners = null,Object? shops = null,Object? challenges = null,Object? member = freezed,}) {
  return _then(_CatalogData(
products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<Product>,banners: null == banners ? _self._banners : banners // ignore: cast_nullable_to_non_nullable
as List<Banner>,shops: null == shops ? _self._shops : shops // ignore: cast_nullable_to_non_nullable
as List<Shop>,challenges: null == challenges ? _self._challenges : challenges // ignore: cast_nullable_to_non_nullable
as List<Challenge>,member: freezed == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as Member?,
  ));
}

/// Create a copy of CatalogData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MemberCopyWith<$Res>? get member {
    if (_self.member == null) {
    return null;
  }

  return $MemberCopyWith<$Res>(_self.member!, (value) {
    return _then(_self.copyWith(member: value));
  });
}
}

// dart format on
