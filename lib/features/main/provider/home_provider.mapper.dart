// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'home_provider.dart';

class CapstoneLinkMapper extends ClassMapperBase<CapstoneLink> {
  CapstoneLinkMapper._();

  static CapstoneLinkMapper? _instance;
  static CapstoneLinkMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CapstoneLinkMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'CapstoneLink';

  static int _$id(CapstoneLink v) => v.id;
  static const Field<CapstoneLink, int> _f$id = Field('id', _$id);
  static DateTime _$createdAt(CapstoneLink v) => v.createdAt;
  static const Field<CapstoneLink, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static String _$title(CapstoneLink v) => v.title;
  static const Field<CapstoneLink, String> _f$title = Field('title', _$title);
  static String _$link(CapstoneLink v) => v.link;
  static const Field<CapstoneLink, String> _f$link = Field('link', _$link);
  static String? _$description(CapstoneLink v) => v.description;
  static const Field<CapstoneLink, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static String? _$imageLink(CapstoneLink v) => v.imageLink;
  static const Field<CapstoneLink, String> _f$imageLink = Field(
    'imageLink',
    _$imageLink,
    key: r'image_link',
    opt: true,
  );
  static String? _$buttonLabel(CapstoneLink v) => v.buttonLabel;
  static const Field<CapstoneLink, String> _f$buttonLabel = Field(
    'buttonLabel',
    _$buttonLabel,
    key: r'button_label',
    opt: true,
  );

  @override
  final MappableFields<CapstoneLink> fields = const {
    #id: _f$id,
    #createdAt: _f$createdAt,
    #title: _f$title,
    #link: _f$link,
    #description: _f$description,
    #imageLink: _f$imageLink,
    #buttonLabel: _f$buttonLabel,
  };

  static CapstoneLink _instantiate(DecodingData data) {
    return CapstoneLink(
      id: data.dec(_f$id),
      createdAt: data.dec(_f$createdAt),
      title: data.dec(_f$title),
      link: data.dec(_f$link),
      description: data.dec(_f$description),
      imageLink: data.dec(_f$imageLink),
      buttonLabel: data.dec(_f$buttonLabel),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CapstoneLink fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CapstoneLink>(map);
  }

  static CapstoneLink fromJson(String json) {
    return ensureInitialized().decodeJson<CapstoneLink>(json);
  }
}

mixin CapstoneLinkMappable {
  String toJson() {
    return CapstoneLinkMapper.ensureInitialized().encodeJson<CapstoneLink>(
      this as CapstoneLink,
    );
  }

  Map<String, dynamic> toMap() {
    return CapstoneLinkMapper.ensureInitialized().encodeMap<CapstoneLink>(
      this as CapstoneLink,
    );
  }

  CapstoneLinkCopyWith<CapstoneLink, CapstoneLink, CapstoneLink> get copyWith =>
      _CapstoneLinkCopyWithImpl<CapstoneLink, CapstoneLink>(
        this as CapstoneLink,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CapstoneLinkMapper.ensureInitialized().stringifyValue(
      this as CapstoneLink,
    );
  }

  @override
  bool operator ==(Object other) {
    return CapstoneLinkMapper.ensureInitialized().equalsValue(
      this as CapstoneLink,
      other,
    );
  }

  @override
  int get hashCode {
    return CapstoneLinkMapper.ensureInitialized().hashValue(
      this as CapstoneLink,
    );
  }
}

extension CapstoneLinkValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CapstoneLink, $Out> {
  CapstoneLinkCopyWith<$R, CapstoneLink, $Out> get $asCapstoneLink =>
      $base.as((v, t, t2) => _CapstoneLinkCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CapstoneLinkCopyWith<$R, $In extends CapstoneLink, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    int? id,
    DateTime? createdAt,
    String? title,
    String? link,
    String? description,
    String? imageLink,
    String? buttonLabel,
  });
  CapstoneLinkCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CapstoneLinkCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CapstoneLink, $Out>
    implements CapstoneLinkCopyWith<$R, CapstoneLink, $Out> {
  _CapstoneLinkCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CapstoneLink> $mapper =
      CapstoneLinkMapper.ensureInitialized();
  @override
  $R call({
    int? id,
    DateTime? createdAt,
    String? title,
    String? link,
    Object? description = $none,
    Object? imageLink = $none,
    Object? buttonLabel = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (createdAt != null) #createdAt: createdAt,
      if (title != null) #title: title,
      if (link != null) #link: link,
      if (description != $none) #description: description,
      if (imageLink != $none) #imageLink: imageLink,
      if (buttonLabel != $none) #buttonLabel: buttonLabel,
    }),
  );
  @override
  CapstoneLink $make(CopyWithData data) => CapstoneLink(
    id: data.get(#id, or: $value.id),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    title: data.get(#title, or: $value.title),
    link: data.get(#link, or: $value.link),
    description: data.get(#description, or: $value.description),
    imageLink: data.get(#imageLink, or: $value.imageLink),
    buttonLabel: data.get(#buttonLabel, or: $value.buttonLabel),
  );

  @override
  CapstoneLinkCopyWith<$R2, CapstoneLink, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CapstoneLinkCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

