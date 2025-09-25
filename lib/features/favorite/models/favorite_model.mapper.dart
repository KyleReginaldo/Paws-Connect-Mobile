// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'favorite_model.dart';

class FavoriteMapper extends ClassMapperBase<Favorite> {
  FavoriteMapper._();

  static FavoriteMapper? _instance;
  static FavoriteMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = FavoriteMapper._());
      PetMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Favorite';

  static int _$id(Favorite v) => v.id;
  static const Field<Favorite, int> _f$id = Field('id', _$id);
  static DateTime _$createdAt(Favorite v) => v.createdAt;
  static const Field<Favorite, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static Pet _$pet(Favorite v) => v.pet;
  static const Field<Favorite, Pet> _f$pet = Field('pet', _$pet);

  @override
  final MappableFields<Favorite> fields = const {
    #id: _f$id,
    #createdAt: _f$createdAt,
    #pet: _f$pet,
  };

  static Favorite _instantiate(DecodingData data) {
    return Favorite(
      id: data.dec(_f$id),
      createdAt: data.dec(_f$createdAt),
      pet: data.dec(_f$pet),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Favorite fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Favorite>(map);
  }

  static Favorite fromJson(String json) {
    return ensureInitialized().decodeJson<Favorite>(json);
  }
}

mixin FavoriteMappable {
  String toJson() {
    return FavoriteMapper.ensureInitialized().encodeJson<Favorite>(
      this as Favorite,
    );
  }

  Map<String, dynamic> toMap() {
    return FavoriteMapper.ensureInitialized().encodeMap<Favorite>(
      this as Favorite,
    );
  }

  FavoriteCopyWith<Favorite, Favorite, Favorite> get copyWith =>
      _FavoriteCopyWithImpl<Favorite, Favorite>(
        this as Favorite,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return FavoriteMapper.ensureInitialized().stringifyValue(this as Favorite);
  }

  @override
  bool operator ==(Object other) {
    return FavoriteMapper.ensureInitialized().equalsValue(
      this as Favorite,
      other,
    );
  }

  @override
  int get hashCode {
    return FavoriteMapper.ensureInitialized().hashValue(this as Favorite);
  }
}

extension FavoriteValueCopy<$R, $Out> on ObjectCopyWith<$R, Favorite, $Out> {
  FavoriteCopyWith<$R, Favorite, $Out> get $asFavorite =>
      $base.as((v, t, t2) => _FavoriteCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class FavoriteCopyWith<$R, $In extends Favorite, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  PetCopyWith<$R, Pet, Pet> get pet;
  $R call({int? id, DateTime? createdAt, Pet? pet});
  FavoriteCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _FavoriteCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Favorite, $Out>
    implements FavoriteCopyWith<$R, Favorite, $Out> {
  _FavoriteCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Favorite> $mapper =
      FavoriteMapper.ensureInitialized();
  @override
  PetCopyWith<$R, Pet, Pet> get pet =>
      $value.pet.copyWith.$chain((v) => call(pet: v));
  @override
  $R call({int? id, DateTime? createdAt, Pet? pet}) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (createdAt != null) #createdAt: createdAt,
      if (pet != null) #pet: pet,
    }),
  );
  @override
  Favorite $make(CopyWithData data) => Favorite(
    id: data.get(#id, or: $value.id),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    pet: data.get(#pet, or: $value.pet),
  );

  @override
  FavoriteCopyWith<$R2, Favorite, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _FavoriteCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

