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
      EventMemberMapper.ensureInitialized();
      FundraisingMapper.ensureInitialized();
      PetMapper.ensureInitialized();
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
  static DateTime? _$startingDate(Event v) => v.startingDate;
  static const Field<Event, DateTime> _f$startingDate = Field(
    'startingDate',
    _$startingDate,
    key: r'starting_date',
  );
  static DateTime? _$endedAt(Event v) => v.endedAt;
  static const Field<Event, DateTime> _f$endedAt = Field(
    'endedAt',
    _$endedAt,
    key: r'ended_at',
  );
  static List<EventMember>? _$members(Event v) => v.members;
  static const Field<Event, List<EventMember>> _f$members = Field(
    'members',
    _$members,
  );
  static Fundraising? _$fundraising(Event v) => v.fundraising;
  static const Field<Event, Fundraising> _f$fundraising = Field(
    'fundraising',
    _$fundraising,
  );
  static Pet? _$pet(Event v) => v.pet;
  static const Field<Event, Pet> _f$pet = Field('pet', _$pet);
  static int _$memberCount(Event v) => v.memberCount;
  static const Field<Event, int> _f$memberCount = Field(
    'memberCount',
    _$memberCount,
    key: r'member_count',
    mode: FieldMode.member,
  );
  static List<String>? _$transformedImages(Event v) => v.transformedImages;
  static const Field<Event, List<String>> _f$transformedImages = Field(
    'transformedImages',
    _$transformedImages,
    key: r'transformed_images',
    mode: FieldMode.member,
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
    #startingDate: _f$startingDate,
    #endedAt: _f$endedAt,
    #members: _f$members,
    #fundraising: _f$fundraising,
    #pet: _f$pet,
    #memberCount: _f$memberCount,
    #transformedImages: _f$transformedImages,
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
      data.dec(_f$startingDate),
      data.dec(_f$endedAt),
      data.dec(_f$members),
      data.dec(_f$fundraising),
      data.dec(_f$pet),
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
  ListCopyWith<
    $R,
    EventMember,
    EventMemberCopyWith<$R, EventMember, EventMember>
  >?
  get members;
  FundraisingCopyWith<$R, Fundraising, Fundraising>? get fundraising;
  PetCopyWith<$R, Pet, Pet>? get pet;
  $R call({
    int? id,
    String? title,
    String? description,
    DateTime? createdAt,
    String? createdBy,
    List<String>? images,
    List<String>? suggestions,
    List<Comment>? comments,
    DateTime? startingDate,
    DateTime? endedAt,
    List<EventMember>? members,
    Fundraising? fundraising,
    Pet? pet,
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
  ListCopyWith<
    $R,
    EventMember,
    EventMemberCopyWith<$R, EventMember, EventMember>
  >?
  get members => $value.members != null
      ? ListCopyWith(
          $value.members!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(members: v),
        )
      : null;
  @override
  FundraisingCopyWith<$R, Fundraising, Fundraising>? get fundraising =>
      $value.fundraising?.copyWith.$chain((v) => call(fundraising: v));
  @override
  PetCopyWith<$R, Pet, Pet>? get pet =>
      $value.pet?.copyWith.$chain((v) => call(pet: v));
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
    Object? startingDate = $none,
    Object? endedAt = $none,
    Object? members = $none,
    Object? fundraising = $none,
    Object? pet = $none,
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
      if (startingDate != $none) #startingDate: startingDate,
      if (endedAt != $none) #endedAt: endedAt,
      if (members != $none) #members: members,
      if (fundraising != $none) #fundraising: fundraising,
      if (pet != $none) #pet: pet,
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
    data.get(#startingDate, or: $value.startingDate),
    data.get(#endedAt, or: $value.endedAt),
    data.get(#members, or: $value.members),
    data.get(#fundraising, or: $value.fundraising),
    data.get(#pet, or: $value.pet),
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
  static List<String>? _$likes(Comment v) => v.likes;
  static const Field<Comment, List<String>> _f$likes = Field('likes', _$likes);
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
    #likes: _f$likes,
    #content: _f$content,
    #createdAt: _f$createdAt,
    #user: _f$user,
  };

  static Comment _instantiate(DecodingData data) {
    return Comment(
      data.dec(_f$id),
      data.dec(_f$likes),
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
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get likes;
  CommentUserCopyWith<$R, CommentUser, CommentUser> get user;
  $R call({
    int? id,
    List<String>? likes,
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
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get likes =>
      $value.likes != null
      ? ListCopyWith(
          $value.likes!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(likes: v),
        )
      : null;
  @override
  CommentUserCopyWith<$R, CommentUser, CommentUser> get user =>
      $value.user.copyWith.$chain((v) => call(user: v));
  @override
  $R call({
    int? id,
    Object? likes = $none,
    String? content,
    DateTime? createdAt,
    CommentUser? user,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (likes != $none) #likes: likes,
      if (content != null) #content: content,
      if (createdAt != null) #createdAt: createdAt,
      if (user != null) #user: user,
    }),
  );
  @override
  Comment $make(CopyWithData data) => Comment(
    data.get(#id, or: $value.id),
    data.get(#likes, or: $value.likes),
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
  static String? _$profileImageLink(CommentUser v) => v.profileImageLink;
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
  $R call({String? username, Object? profileImageLink = $none, String? id}) =>
      $apply(
        FieldCopyWithData({
          if (username != null) #username: username,
          if (profileImageLink != $none) #profileImageLink: profileImageLink,
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

class EventMemberMapper extends ClassMapperBase<EventMember> {
  EventMemberMapper._();

  static EventMemberMapper? _instance;
  static EventMemberMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EventMemberMapper._());
      MemberMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'EventMember';

  static int _$id(EventMember v) => v.id;
  static const Field<EventMember, int> _f$id = Field('id', _$id);
  static DateTime _$joinedAt(EventMember v) => v.joinedAt;
  static const Field<EventMember, DateTime> _f$joinedAt = Field(
    'joinedAt',
    _$joinedAt,
    key: r'joined_at',
  );
  static Member _$user(EventMember v) => v.user;
  static const Field<EventMember, Member> _f$user = Field('user', _$user);

  @override
  final MappableFields<EventMember> fields = const {
    #id: _f$id,
    #joinedAt: _f$joinedAt,
    #user: _f$user,
  };

  static EventMember _instantiate(DecodingData data) {
    return EventMember(
      data.dec(_f$id),
      data.dec(_f$joinedAt),
      data.dec(_f$user),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static EventMember fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EventMember>(map);
  }

  static EventMember fromJson(String json) {
    return ensureInitialized().decodeJson<EventMember>(json);
  }
}

mixin EventMemberMappable {
  String toJson() {
    return EventMemberMapper.ensureInitialized().encodeJson<EventMember>(
      this as EventMember,
    );
  }

  Map<String, dynamic> toMap() {
    return EventMemberMapper.ensureInitialized().encodeMap<EventMember>(
      this as EventMember,
    );
  }

  EventMemberCopyWith<EventMember, EventMember, EventMember> get copyWith =>
      _EventMemberCopyWithImpl<EventMember, EventMember>(
        this as EventMember,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return EventMemberMapper.ensureInitialized().stringifyValue(
      this as EventMember,
    );
  }

  @override
  bool operator ==(Object other) {
    return EventMemberMapper.ensureInitialized().equalsValue(
      this as EventMember,
      other,
    );
  }

  @override
  int get hashCode {
    return EventMemberMapper.ensureInitialized().hashValue(this as EventMember);
  }
}

extension EventMemberValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EventMember, $Out> {
  EventMemberCopyWith<$R, EventMember, $Out> get $asEventMember =>
      $base.as((v, t, t2) => _EventMemberCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class EventMemberCopyWith<$R, $In extends EventMember, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MemberCopyWith<$R, Member, Member> get user;
  $R call({int? id, DateTime? joinedAt, Member? user});
  EventMemberCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _EventMemberCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EventMember, $Out>
    implements EventMemberCopyWith<$R, EventMember, $Out> {
  _EventMemberCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EventMember> $mapper =
      EventMemberMapper.ensureInitialized();
  @override
  MemberCopyWith<$R, Member, Member> get user =>
      $value.user.copyWith.$chain((v) => call(user: v));
  @override
  $R call({int? id, DateTime? joinedAt, Member? user}) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (joinedAt != null) #joinedAt: joinedAt,
      if (user != null) #user: user,
    }),
  );
  @override
  EventMember $make(CopyWithData data) => EventMember(
    data.get(#id, or: $value.id),
    data.get(#joinedAt, or: $value.joinedAt),
    data.get(#user, or: $value.user),
  );

  @override
  EventMemberCopyWith<$R2, EventMember, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _EventMemberCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class MemberMapper extends ClassMapperBase<Member> {
  MemberMapper._();

  static MemberMapper? _instance;
  static MemberMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MemberMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Member';

  static String _$username(Member v) => v.username;
  static const Field<Member, String> _f$username = Field(
    'username',
    _$username,
  );
  static String? _$profileImageLink(Member v) => v.profileImageLink;
  static const Field<Member, String> _f$profileImageLink = Field(
    'profileImageLink',
    _$profileImageLink,
    key: r'profile_image_link',
  );
  static String _$id(Member v) => v.id;
  static const Field<Member, String> _f$id = Field('id', _$id);

  @override
  final MappableFields<Member> fields = const {
    #username: _f$username,
    #profileImageLink: _f$profileImageLink,
    #id: _f$id,
  };

  static Member _instantiate(DecodingData data) {
    return Member(
      data.dec(_f$username),
      data.dec(_f$profileImageLink),
      data.dec(_f$id),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Member fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Member>(map);
  }

  static Member fromJson(String json) {
    return ensureInitialized().decodeJson<Member>(json);
  }
}

mixin MemberMappable {
  String toJson() {
    return MemberMapper.ensureInitialized().encodeJson<Member>(this as Member);
  }

  Map<String, dynamic> toMap() {
    return MemberMapper.ensureInitialized().encodeMap<Member>(this as Member);
  }

  MemberCopyWith<Member, Member, Member> get copyWith =>
      _MemberCopyWithImpl<Member, Member>(this as Member, $identity, $identity);
  @override
  String toString() {
    return MemberMapper.ensureInitialized().stringifyValue(this as Member);
  }

  @override
  bool operator ==(Object other) {
    return MemberMapper.ensureInitialized().equalsValue(this as Member, other);
  }

  @override
  int get hashCode {
    return MemberMapper.ensureInitialized().hashValue(this as Member);
  }
}

extension MemberValueCopy<$R, $Out> on ObjectCopyWith<$R, Member, $Out> {
  MemberCopyWith<$R, Member, $Out> get $asMember =>
      $base.as((v, t, t2) => _MemberCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MemberCopyWith<$R, $In extends Member, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? username, String? profileImageLink, String? id});
  MemberCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MemberCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Member, $Out>
    implements MemberCopyWith<$R, Member, $Out> {
  _MemberCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Member> $mapper = MemberMapper.ensureInitialized();
  @override
  $R call({String? username, Object? profileImageLink = $none, String? id}) =>
      $apply(
        FieldCopyWithData({
          if (username != null) #username: username,
          if (profileImageLink != $none) #profileImageLink: profileImageLink,
          if (id != null) #id: id,
        }),
      );
  @override
  Member $make(CopyWithData data) => Member(
    data.get(#username, or: $value.username),
    data.get(#profileImageLink, or: $value.profileImageLink),
    data.get(#id, or: $value.id),
  );

  @override
  MemberCopyWith<$R2, Member, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _MemberCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

