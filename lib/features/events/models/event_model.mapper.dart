// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'event_model.dart';

class EventMapper extends ClassMapperBase<Event> {
  EventMapper._();

  static EventMapper? _instance;
  static EventMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EventMapper._());
      CommentMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Event';

  static int _$id(Event v) => v.id;
  static const Field<Event, int> _f$id = Field('id', _$id);
  static String _$title(Event v) => v.title;
  static const Field<Event, String> _f$title = Field('title', _$title);
  static String _$description(Event v) => v.description;
  static const Field<Event, String> _f$description = Field(
    'description',
    _$description,
  );
  static DateTime _$createdAt(Event v) => v.createdAt;
  static const Field<Event, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static String _$createdBy(Event v) => v.createdBy;
  static const Field<Event, String> _f$createdBy = Field(
    'createdBy',
    _$createdBy,
    key: r'created_by',
  );
  static List<String>? _$images(Event v) => v.images;
  static const Field<Event, List<String>> _f$images = Field('images', _$images);
  static List<String>? _$suggestions(Event v) => v.suggestions;
  static const Field<Event, List<String>> _f$suggestions = Field(
    'suggestions',
    _$suggestions,
  );
  static List<Comment>? _$comments(Event v) => v.comments;
  static const Field<Event, List<Comment>> _f$comments = Field(
    'comments',
    _$comments,
  );

  @override
  final MappableFields<Event> fields = const {
    #id: _f$id,
    #title: _f$title,
    #description: _f$description,
    #createdAt: _f$createdAt,
    #createdBy: _f$createdBy,
    #images: _f$images,
    #suggestions: _f$suggestions,
    #comments: _f$comments,
  };

  static Event _instantiate(DecodingData data) {
    return Event(
      data.dec(_f$id),
      data.dec(_f$title),
      data.dec(_f$description),
      data.dec(_f$createdAt),
      data.dec(_f$createdBy),
      data.dec(_f$images),
      data.dec(_f$suggestions),
      data.dec(_f$comments),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Event fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Event>(map);
  }

  static Event fromJson(String json) {
    return ensureInitialized().decodeJson<Event>(json);
  }
}

mixin EventMappable {
  String toJson() {
    return EventMapper.ensureInitialized().encodeJson<Event>(this as Event);
  }

  Map<String, dynamic> toMap() {
    return EventMapper.ensureInitialized().encodeMap<Event>(this as Event);
  }

  EventCopyWith<Event, Event, Event> get copyWith =>
      _EventCopyWithImpl<Event, Event>(this as Event, $identity, $identity);
  @override
  String toString() {
    return EventMapper.ensureInitialized().stringifyValue(this as Event);
  }

  @override
  bool operator ==(Object other) {
    return EventMapper.ensureInitialized().equalsValue(this as Event, other);
  }

  @override
  int get hashCode {
    return EventMapper.ensureInitialized().hashValue(this as Event);
  }
}

extension EventValueCopy<$R, $Out> on ObjectCopyWith<$R, Event, $Out> {
  EventCopyWith<$R, Event, $Out> get $asEvent =>
      $base.as((v, t, t2) => _EventCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class EventCopyWith<$R, $In extends Event, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get images;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get suggestions;
  ListCopyWith<$R, Comment, CommentCopyWith<$R, Comment, Comment>>?
  get comments;
  $R call({
    int? id,
    String? title,
    String? description,
    DateTime? createdAt,
    String? createdBy,
    List<String>? images,
    List<String>? suggestions,
    List<Comment>? comments,
  });
  EventCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _EventCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Event, $Out>
    implements EventCopyWith<$R, Event, $Out> {
  _EventCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Event> $mapper = EventMapper.ensureInitialized();
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
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>?
  get suggestions => $value.suggestions != null
      ? ListCopyWith(
          $value.suggestions!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(suggestions: v),
        )
      : null;
  @override
  ListCopyWith<$R, Comment, CommentCopyWith<$R, Comment, Comment>>?
  get comments => $value.comments != null
      ? ListCopyWith(
          $value.comments!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(comments: v),
        )
      : null;
  @override
  $R call({
    int? id,
    String? title,
    String? description,
    DateTime? createdAt,
    String? createdBy,
    Object? images = $none,
    Object? suggestions = $none,
    Object? comments = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (title != null) #title: title,
      if (description != null) #description: description,
      if (createdAt != null) #createdAt: createdAt,
      if (createdBy != null) #createdBy: createdBy,
      if (images != $none) #images: images,
      if (suggestions != $none) #suggestions: suggestions,
      if (comments != $none) #comments: comments,
    }),
  );
  @override
  Event $make(CopyWithData data) => Event(
    data.get(#id, or: $value.id),
    data.get(#title, or: $value.title),
    data.get(#description, or: $value.description),
    data.get(#createdAt, or: $value.createdAt),
    data.get(#createdBy, or: $value.createdBy),
    data.get(#images, or: $value.images),
    data.get(#suggestions, or: $value.suggestions),
    data.get(#comments, or: $value.comments),
  );

  @override
  EventCopyWith<$R2, Event, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _EventCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CommentMapper extends ClassMapperBase<Comment> {
  CommentMapper._();

  static CommentMapper? _instance;
  static CommentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CommentMapper._());
      CommentUserMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Comment';

  static int _$id(Comment v) => v.id;
  static const Field<Comment, int> _f$id = Field('id', _$id);
  static int _$like(Comment v) => v.like;
  static const Field<Comment, int> _f$like = Field('like', _$like);
  static String _$content(Comment v) => v.content;
  static const Field<Comment, String> _f$content = Field('content', _$content);
  static DateTime _$createdAt(Comment v) => v.createdAt;
  static const Field<Comment, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static CommentUser _$user(Comment v) => v.user;
  static const Field<Comment, CommentUser> _f$user = Field('user', _$user);

  @override
  final MappableFields<Comment> fields = const {
    #id: _f$id,
    #like: _f$like,
    #content: _f$content,
    #createdAt: _f$createdAt,
    #user: _f$user,
  };

  static Comment _instantiate(DecodingData data) {
    return Comment(
      data.dec(_f$id),
      data.dec(_f$like),
      data.dec(_f$content),
      data.dec(_f$createdAt),
      data.dec(_f$user),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Comment fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Comment>(map);
  }

  static Comment fromJson(String json) {
    return ensureInitialized().decodeJson<Comment>(json);
  }
}

mixin CommentMappable {
  String toJson() {
    return CommentMapper.ensureInitialized().encodeJson<Comment>(
      this as Comment,
    );
  }

  Map<String, dynamic> toMap() {
    return CommentMapper.ensureInitialized().encodeMap<Comment>(
      this as Comment,
    );
  }

  CommentCopyWith<Comment, Comment, Comment> get copyWith =>
      _CommentCopyWithImpl<Comment, Comment>(
        this as Comment,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CommentMapper.ensureInitialized().stringifyValue(this as Comment);
  }

  @override
  bool operator ==(Object other) {
    return CommentMapper.ensureInitialized().equalsValue(
      this as Comment,
      other,
    );
  }

  @override
  int get hashCode {
    return CommentMapper.ensureInitialized().hashValue(this as Comment);
  }
}

extension CommentValueCopy<$R, $Out> on ObjectCopyWith<$R, Comment, $Out> {
  CommentCopyWith<$R, Comment, $Out> get $asComment =>
      $base.as((v, t, t2) => _CommentCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CommentCopyWith<$R, $In extends Comment, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  CommentUserCopyWith<$R, CommentUser, CommentUser> get user;
  $R call({
    int? id,
    int? like,
    String? content,
    DateTime? createdAt,
    CommentUser? user,
  });
  CommentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CommentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Comment, $Out>
    implements CommentCopyWith<$R, Comment, $Out> {
  _CommentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Comment> $mapper =
      CommentMapper.ensureInitialized();
  @override
  CommentUserCopyWith<$R, CommentUser, CommentUser> get user =>
      $value.user.copyWith.$chain((v) => call(user: v));
  @override
  $R call({
    int? id,
    int? like,
    String? content,
    DateTime? createdAt,
    CommentUser? user,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (like != null) #like: like,
      if (content != null) #content: content,
      if (createdAt != null) #createdAt: createdAt,
      if (user != null) #user: user,
    }),
  );
  @override
  Comment $make(CopyWithData data) => Comment(
    data.get(#id, or: $value.id),
    data.get(#like, or: $value.like),
    data.get(#content, or: $value.content),
    data.get(#createdAt, or: $value.createdAt),
    data.get(#user, or: $value.user),
  );

  @override
  CommentCopyWith<$R2, Comment, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _CommentCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CommentUserMapper extends ClassMapperBase<CommentUser> {
  CommentUserMapper._();

  static CommentUserMapper? _instance;
  static CommentUserMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CommentUserMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'CommentUser';

  static String _$username(CommentUser v) => v.username;
  static const Field<CommentUser, String> _f$username = Field(
    'username',
    _$username,
  );
  static String _$profileImageLink(CommentUser v) => v.profileImageLink;
  static const Field<CommentUser, String> _f$profileImageLink = Field(
    'profileImageLink',
    _$profileImageLink,
    key: r'profile_image_link',
  );
  static String _$id(CommentUser v) => v.id;
  static const Field<CommentUser, String> _f$id = Field('id', _$id);

  @override
  final MappableFields<CommentUser> fields = const {
    #username: _f$username,
    #profileImageLink: _f$profileImageLink,
    #id: _f$id,
  };

  static CommentUser _instantiate(DecodingData data) {
    return CommentUser(
      data.dec(_f$username),
      data.dec(_f$profileImageLink),
      data.dec(_f$id),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CommentUser fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CommentUser>(map);
  }

  static CommentUser fromJson(String json) {
    return ensureInitialized().decodeJson<CommentUser>(json);
  }
}

mixin CommentUserMappable {
  String toJson() {
    return CommentUserMapper.ensureInitialized().encodeJson<CommentUser>(
      this as CommentUser,
    );
  }

  Map<String, dynamic> toMap() {
    return CommentUserMapper.ensureInitialized().encodeMap<CommentUser>(
      this as CommentUser,
    );
  }

  CommentUserCopyWith<CommentUser, CommentUser, CommentUser> get copyWith =>
      _CommentUserCopyWithImpl<CommentUser, CommentUser>(
        this as CommentUser,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CommentUserMapper.ensureInitialized().stringifyValue(
      this as CommentUser,
    );
  }

  @override
  bool operator ==(Object other) {
    return CommentUserMapper.ensureInitialized().equalsValue(
      this as CommentUser,
      other,
    );
  }

  @override
  int get hashCode {
    return CommentUserMapper.ensureInitialized().hashValue(this as CommentUser);
  }
}

extension CommentUserValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CommentUser, $Out> {
  CommentUserCopyWith<$R, CommentUser, $Out> get $asCommentUser =>
      $base.as((v, t, t2) => _CommentUserCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CommentUserCopyWith<$R, $In extends CommentUser, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? username, String? profileImageLink, String? id});
  CommentUserCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CommentUserCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CommentUser, $Out>
    implements CommentUserCopyWith<$R, CommentUser, $Out> {
  _CommentUserCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CommentUser> $mapper =
      CommentUserMapper.ensureInitialized();
  @override
  $R call({String? username, String? profileImageLink, String? id}) => $apply(
    FieldCopyWithData({
      if (username != null) #username: username,
      if (profileImageLink != null) #profileImageLink: profileImageLink,
      if (id != null) #id: id,
    }),
  );
  @override
  CommentUser $make(CopyWithData data) => CommentUser(
    data.get(#username, or: $value.username),
    data.get(#profileImageLink, or: $value.profileImageLink),
    data.get(#id, or: $value.id),
  );

  @override
  CommentUserCopyWith<$R2, CommentUser, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CommentUserCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

