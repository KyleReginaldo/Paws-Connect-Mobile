// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'posts_provider.dart';

class PostMapper extends ClassMapperBase<Post> {
  PostMapper._();

  static PostMapper? _instance;
  static PostMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PostMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Post';

  static int _$id(Post v) => v.id;
  static const Field<Post, int> _f$id = Field('id', _$id);
  static String? _$createdAt(Post v) => v.createdAt;
  static const Field<Post, String> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static String _$title(Post v) => v.title;
  static const Field<Post, String> _f$title = Field('title', _$title);
  static String _$category(Post v) => v.category;
  static const Field<Post, String> _f$category = Field('category', _$category);
  static List<String>? _$images(Post v) => v.images;
  static const Field<Post, List<String>> _f$images = Field('images', _$images);
  static List<String>? _$links(Post v) => v.links;
  static const Field<Post, List<String>> _f$links = Field('links', _$links);
  static List<Map<String, dynamic>>? _$comments(Post v) => v.comments;
  static const Field<Post, List<Map<String, dynamic>>> _f$comments = Field(
    'comments',
    _$comments,
  );
  static List<Map<String, dynamic>>? _$reactions(Post v) => v.reactions;
  static const Field<Post, List<Map<String, dynamic>>> _f$reactions = Field(
    'reactions',
    _$reactions,
  );
  static String _$description(Post v) => v.description;
  static const Field<Post, String> _f$description = Field(
    'description',
    _$description,
  );

  @override
  final MappableFields<Post> fields = const {
    #id: _f$id,
    #createdAt: _f$createdAt,
    #title: _f$title,
    #category: _f$category,
    #images: _f$images,
    #links: _f$links,
    #comments: _f$comments,
    #reactions: _f$reactions,
    #description: _f$description,
  };

  static Post _instantiate(DecodingData data) {
    return Post(
      id: data.dec(_f$id),
      createdAt: data.dec(_f$createdAt),
      title: data.dec(_f$title),
      category: data.dec(_f$category),
      images: data.dec(_f$images),
      links: data.dec(_f$links),
      comments: data.dec(_f$comments),
      reactions: data.dec(_f$reactions),
      description: data.dec(_f$description),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Post fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Post>(map);
  }

  static Post fromJson(String json) {
    return ensureInitialized().decodeJson<Post>(json);
  }
}

mixin PostMappable {
  String toJson() {
    return PostMapper.ensureInitialized().encodeJson<Post>(this as Post);
  }

  Map<String, dynamic> toMap() {
    return PostMapper.ensureInitialized().encodeMap<Post>(this as Post);
  }

  PostCopyWith<Post, Post, Post> get copyWith =>
      _PostCopyWithImpl<Post, Post>(this as Post, $identity, $identity);
  @override
  String toString() {
    return PostMapper.ensureInitialized().stringifyValue(this as Post);
  }

  @override
  bool operator ==(Object other) {
    return PostMapper.ensureInitialized().equalsValue(this as Post, other);
  }

  @override
  int get hashCode {
    return PostMapper.ensureInitialized().hashValue(this as Post);
  }
}

extension PostValueCopy<$R, $Out> on ObjectCopyWith<$R, Post, $Out> {
  PostCopyWith<$R, Post, $Out> get $asPost =>
      $base.as((v, t, t2) => _PostCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PostCopyWith<$R, $In extends Post, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get images;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get links;
  ListCopyWith<
    $R,
    Map<String, dynamic>,
    ObjectCopyWith<$R, Map<String, dynamic>, Map<String, dynamic>>
  >?
  get comments;
  ListCopyWith<
    $R,
    Map<String, dynamic>,
    ObjectCopyWith<$R, Map<String, dynamic>, Map<String, dynamic>>
  >?
  get reactions;
  $R call({
    int? id,
    String? createdAt,
    String? title,
    String? category,
    List<String>? images,
    List<String>? links,
    List<Map<String, dynamic>>? comments,
    List<Map<String, dynamic>>? reactions,
    String? description,
  });
  PostCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PostCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Post, $Out>
    implements PostCopyWith<$R, Post, $Out> {
  _PostCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Post> $mapper = PostMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get images =>
      $value.images != null
      ? ListCopyWith(
          $value.images!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(images: v),
        )
      : null;
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get links =>
      $value.links != null
      ? ListCopyWith(
          $value.links!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(links: v),
        )
      : null;
  @override
  ListCopyWith<
    $R,
    Map<String, dynamic>,
    ObjectCopyWith<$R, Map<String, dynamic>, Map<String, dynamic>>
  >?
  get comments => $value.comments != null
      ? ListCopyWith(
          $value.comments!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(comments: v),
        )
      : null;
  @override
  ListCopyWith<
    $R,
    Map<String, dynamic>,
    ObjectCopyWith<$R, Map<String, dynamic>, Map<String, dynamic>>
  >?
  get reactions => $value.reactions != null
      ? ListCopyWith(
          $value.reactions!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(reactions: v),
        )
      : null;
  @override
  $R call({
    int? id,
    Object? createdAt = $none,
    String? title,
    String? category,
    Object? images = $none,
    Object? links = $none,
    Object? comments = $none,
    Object? reactions = $none,
    String? description,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (createdAt != $none) #createdAt: createdAt,
      if (title != null) #title: title,
      if (category != null) #category: category,
      if (images != $none) #images: images,
      if (links != $none) #links: links,
      if (comments != $none) #comments: comments,
      if (reactions != $none) #reactions: reactions,
      if (description != null) #description: description,
    }),
  );
  @override
  Post $make(CopyWithData data) => Post(
    id: data.get(#id, or: $value.id),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    title: data.get(#title, or: $value.title),
    category: data.get(#category, or: $value.category),
    images: data.get(#images, or: $value.images),
    links: data.get(#links, or: $value.links),
    comments: data.get(#comments, or: $value.comments),
    reactions: data.get(#reactions, or: $value.reactions),
    description: data.get(#description, or: $value.description),
  );

  @override
  PostCopyWith<$R2, Post, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _PostCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

