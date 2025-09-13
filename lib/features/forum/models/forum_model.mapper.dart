// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'forum_model.dart';

class ForumMapper extends ClassMapperBase<Forum> {
  ForumMapper._();

  static ForumMapper? _instance;
  static ForumMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ForumMapper._());
      MemberMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Forum';

  static int _$id(Forum v) => v.id;
  static const Field<Forum, int> _f$id = Field('id', _$id);
  static DateTime _$createdAt(Forum v) => v.createdAt;
  static const Field<Forum, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static String _$forumName(Forum v) => v.forumName;
  static const Field<Forum, String> _f$forumName = Field(
    'forumName',
    _$forumName,
    key: r'forum_name',
  );
  static DateTime? _$updatedAt(Forum v) => v.updatedAt;
  static const Field<Forum, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
    key: r'updated_at',
    opt: true,
  );
  static String _$createdBy(Forum v) => v.createdBy;
  static const Field<Forum, String> _f$createdBy = Field(
    'createdBy',
    _$createdBy,
    key: r'created_by',
  );
  static List<Member>? _$members(Forum v) => v.members;
  static const Field<Forum, List<Member>> _f$members = Field(
    'members',
    _$members,
    opt: true,
  );
  static int _$memberCount(Forum v) => v.memberCount;
  static const Field<Forum, int> _f$memberCount = Field(
    'memberCount',
    _$memberCount,
    key: r'member_count',
  );
  static bool _$private(Forum v) => v.private;
  static const Field<Forum, bool> _f$private = Field('private', _$private);

  @override
  final MappableFields<Forum> fields = const {
    #id: _f$id,
    #createdAt: _f$createdAt,
    #forumName: _f$forumName,
    #updatedAt: _f$updatedAt,
    #createdBy: _f$createdBy,
    #members: _f$members,
    #memberCount: _f$memberCount,
    #private: _f$private,
  };

  static Forum _instantiate(DecodingData data) {
    return Forum(
      id: data.dec(_f$id),
      createdAt: data.dec(_f$createdAt),
      forumName: data.dec(_f$forumName),
      updatedAt: data.dec(_f$updatedAt),
      createdBy: data.dec(_f$createdBy),
      members: data.dec(_f$members),
      memberCount: data.dec(_f$memberCount),
      private: data.dec(_f$private),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Forum fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Forum>(map);
  }

  static Forum fromJson(String json) {
    return ensureInitialized().decodeJson<Forum>(json);
  }
}

mixin ForumMappable {
  String toJson() {
    return ForumMapper.ensureInitialized().encodeJson<Forum>(this as Forum);
  }

  Map<String, dynamic> toMap() {
    return ForumMapper.ensureInitialized().encodeMap<Forum>(this as Forum);
  }

  ForumCopyWith<Forum, Forum, Forum> get copyWith =>
      _ForumCopyWithImpl<Forum, Forum>(this as Forum, $identity, $identity);
  @override
  String toString() {
    return ForumMapper.ensureInitialized().stringifyValue(this as Forum);
  }

  @override
  bool operator ==(Object other) {
    return ForumMapper.ensureInitialized().equalsValue(this as Forum, other);
  }

  @override
  int get hashCode {
    return ForumMapper.ensureInitialized().hashValue(this as Forum);
  }
}

extension ForumValueCopy<$R, $Out> on ObjectCopyWith<$R, Forum, $Out> {
  ForumCopyWith<$R, Forum, $Out> get $asForum =>
      $base.as((v, t, t2) => _ForumCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ForumCopyWith<$R, $In extends Forum, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Member, MemberCopyWith<$R, Member, Member>>? get members;
  $R call({
    int? id,
    DateTime? createdAt,
    String? forumName,
    DateTime? updatedAt,
    String? createdBy,
    List<Member>? members,
    int? memberCount,
    bool? private,
  });
  ForumCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ForumCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Forum, $Out>
    implements ForumCopyWith<$R, Forum, $Out> {
  _ForumCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Forum> $mapper = ForumMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Member, MemberCopyWith<$R, Member, Member>>? get members =>
      $value.members != null
      ? ListCopyWith(
          $value.members!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(members: v),
        )
      : null;
  @override
  $R call({
    int? id,
    DateTime? createdAt,
    String? forumName,
    Object? updatedAt = $none,
    String? createdBy,
    Object? members = $none,
    int? memberCount,
    bool? private,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (createdAt != null) #createdAt: createdAt,
      if (forumName != null) #forumName: forumName,
      if (updatedAt != $none) #updatedAt: updatedAt,
      if (createdBy != null) #createdBy: createdBy,
      if (members != $none) #members: members,
      if (memberCount != null) #memberCount: memberCount,
      if (private != null) #private: private,
    }),
  );
  @override
  Forum $make(CopyWithData data) => Forum(
    id: data.get(#id, or: $value.id),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    forumName: data.get(#forumName, or: $value.forumName),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
    createdBy: data.get(#createdBy, or: $value.createdBy),
    members: data.get(#members, or: $value.members),
    memberCount: data.get(#memberCount, or: $value.memberCount),
    private: data.get(#private, or: $value.private),
  );

  @override
  ForumCopyWith<$R2, Forum, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ForumCopyWithImpl<$R2, $Out2>($value, $cast, t);
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

  static int _$forumMemberId(Member v) => v.forumMemberId;
  static const Field<Member, int> _f$forumMemberId = Field(
    'forumMemberId',
    _$forumMemberId,
    key: r'forum_member_id',
  );
  static String _$id(Member v) => v.id;
  static const Field<Member, String> _f$id = Field('id', _$id);
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
    opt: true,
  );
  static DateTime _$joinedAt(Member v) => v.joinedAt;
  static const Field<Member, DateTime> _f$joinedAt = Field(
    'joinedAt',
    _$joinedAt,
    key: r'joined_at',
  );
  static String _$invitationStatus(Member v) => v.invitationStatus;
  static const Field<Member, String> _f$invitationStatus = Field(
    'invitationStatus',
    _$invitationStatus,
    key: r'invitation_status',
  );

  @override
  final MappableFields<Member> fields = const {
    #forumMemberId: _f$forumMemberId,
    #id: _f$id,
    #username: _f$username,
    #profileImageLink: _f$profileImageLink,
    #joinedAt: _f$joinedAt,
    #invitationStatus: _f$invitationStatus,
  };

  static Member _instantiate(DecodingData data) {
    return Member(
      forumMemberId: data.dec(_f$forumMemberId),
      id: data.dec(_f$id),
      username: data.dec(_f$username),
      profileImageLink: data.dec(_f$profileImageLink),
      joinedAt: data.dec(_f$joinedAt),
      invitationStatus: data.dec(_f$invitationStatus),
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
  $R call({
    int? forumMemberId,
    String? id,
    String? username,
    String? profileImageLink,
    DateTime? joinedAt,
    String? invitationStatus,
  });
  MemberCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MemberCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Member, $Out>
    implements MemberCopyWith<$R, Member, $Out> {
  _MemberCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Member> $mapper = MemberMapper.ensureInitialized();
  @override
  $R call({
    int? forumMemberId,
    String? id,
    String? username,
    Object? profileImageLink = $none,
    DateTime? joinedAt,
    String? invitationStatus,
  }) => $apply(
    FieldCopyWithData({
      if (forumMemberId != null) #forumMemberId: forumMemberId,
      if (id != null) #id: id,
      if (username != null) #username: username,
      if (profileImageLink != $none) #profileImageLink: profileImageLink,
      if (joinedAt != null) #joinedAt: joinedAt,
      if (invitationStatus != null) #invitationStatus: invitationStatus,
    }),
  );
  @override
  Member $make(CopyWithData data) => Member(
    forumMemberId: data.get(#forumMemberId, or: $value.forumMemberId),
    id: data.get(#id, or: $value.id),
    username: data.get(#username, or: $value.username),
    profileImageLink: data.get(#profileImageLink, or: $value.profileImageLink),
    joinedAt: data.get(#joinedAt, or: $value.joinedAt),
    invitationStatus: data.get(#invitationStatus, or: $value.invitationStatus),
  );

  @override
  MemberCopyWith<$R2, Member, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _MemberCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ForumChatMapper extends ClassMapperBase<ForumChat> {
  ForumChatMapper._();

  static ForumChatMapper? _instance;
  static ForumChatMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ForumChatMapper._());
      UsersMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ForumChat';

  static int _$id(ForumChat v) => v.id;
  static const Field<ForumChat, int> _f$id = Field('id', _$id);
  static DateTime _$sentAt(ForumChat v) => v.sentAt;
  static const Field<ForumChat, DateTime> _f$sentAt = Field(
    'sentAt',
    _$sentAt,
    key: r'sent_at',
  );
  static String _$sender(ForumChat v) => v.sender;
  static const Field<ForumChat, String> _f$sender = Field('sender', _$sender);
  static String _$message(ForumChat v) => v.message;
  static const Field<ForumChat, String> _f$message = Field(
    'message',
    _$message,
  );
  static Users _$users(ForumChat v) => v.users;
  static const Field<ForumChat, Users> _f$users = Field('users', _$users);

  @override
  final MappableFields<ForumChat> fields = const {
    #id: _f$id,
    #sentAt: _f$sentAt,
    #sender: _f$sender,
    #message: _f$message,
    #users: _f$users,
  };

  static ForumChat _instantiate(DecodingData data) {
    return ForumChat(
      id: data.dec(_f$id),
      sentAt: data.dec(_f$sentAt),
      sender: data.dec(_f$sender),
      message: data.dec(_f$message),
      users: data.dec(_f$users),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ForumChat fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ForumChat>(map);
  }

  static ForumChat fromJson(String json) {
    return ensureInitialized().decodeJson<ForumChat>(json);
  }
}

mixin ForumChatMappable {
  String toJson() {
    return ForumChatMapper.ensureInitialized().encodeJson<ForumChat>(
      this as ForumChat,
    );
  }

  Map<String, dynamic> toMap() {
    return ForumChatMapper.ensureInitialized().encodeMap<ForumChat>(
      this as ForumChat,
    );
  }

  ForumChatCopyWith<ForumChat, ForumChat, ForumChat> get copyWith =>
      _ForumChatCopyWithImpl<ForumChat, ForumChat>(
        this as ForumChat,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ForumChatMapper.ensureInitialized().stringifyValue(
      this as ForumChat,
    );
  }

  @override
  bool operator ==(Object other) {
    return ForumChatMapper.ensureInitialized().equalsValue(
      this as ForumChat,
      other,
    );
  }

  @override
  int get hashCode {
    return ForumChatMapper.ensureInitialized().hashValue(this as ForumChat);
  }
}

extension ForumChatValueCopy<$R, $Out> on ObjectCopyWith<$R, ForumChat, $Out> {
  ForumChatCopyWith<$R, ForumChat, $Out> get $asForumChat =>
      $base.as((v, t, t2) => _ForumChatCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ForumChatCopyWith<$R, $In extends ForumChat, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  UsersCopyWith<$R, Users, Users> get users;
  $R call({
    int? id,
    DateTime? sentAt,
    String? sender,
    String? message,
    Users? users,
  });
  ForumChatCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ForumChatCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ForumChat, $Out>
    implements ForumChatCopyWith<$R, ForumChat, $Out> {
  _ForumChatCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ForumChat> $mapper =
      ForumChatMapper.ensureInitialized();
  @override
  UsersCopyWith<$R, Users, Users> get users =>
      $value.users.copyWith.$chain((v) => call(users: v));
  @override
  $R call({
    int? id,
    DateTime? sentAt,
    String? sender,
    String? message,
    Users? users,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (sentAt != null) #sentAt: sentAt,
      if (sender != null) #sender: sender,
      if (message != null) #message: message,
      if (users != null) #users: users,
    }),
  );
  @override
  ForumChat $make(CopyWithData data) => ForumChat(
    id: data.get(#id, or: $value.id),
    sentAt: data.get(#sentAt, or: $value.sentAt),
    sender: data.get(#sender, or: $value.sender),
    message: data.get(#message, or: $value.message),
    users: data.get(#users, or: $value.users),
  );

  @override
  ForumChatCopyWith<$R2, ForumChat, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ForumChatCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class UsersMapper extends ClassMapperBase<Users> {
  UsersMapper._();

  static UsersMapper? _instance;
  static UsersMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UsersMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Users';

  static String _$id(Users v) => v.id;
  static const Field<Users, String> _f$id = Field('id', _$id);
  static String _$username(Users v) => v.username;
  static const Field<Users, String> _f$username = Field('username', _$username);

  @override
  final MappableFields<Users> fields = const {
    #id: _f$id,
    #username: _f$username,
  };

  static Users _instantiate(DecodingData data) {
    return Users(id: data.dec(_f$id), username: data.dec(_f$username));
  }

  @override
  final Function instantiate = _instantiate;

  static Users fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Users>(map);
  }

  static Users fromJson(String json) {
    return ensureInitialized().decodeJson<Users>(json);
  }
}

mixin UsersMappable {
  String toJson() {
    return UsersMapper.ensureInitialized().encodeJson<Users>(this as Users);
  }

  Map<String, dynamic> toMap() {
    return UsersMapper.ensureInitialized().encodeMap<Users>(this as Users);
  }

  UsersCopyWith<Users, Users, Users> get copyWith =>
      _UsersCopyWithImpl<Users, Users>(this as Users, $identity, $identity);
  @override
  String toString() {
    return UsersMapper.ensureInitialized().stringifyValue(this as Users);
  }

  @override
  bool operator ==(Object other) {
    return UsersMapper.ensureInitialized().equalsValue(this as Users, other);
  }

  @override
  int get hashCode {
    return UsersMapper.ensureInitialized().hashValue(this as Users);
  }
}

extension UsersValueCopy<$R, $Out> on ObjectCopyWith<$R, Users, $Out> {
  UsersCopyWith<$R, Users, $Out> get $asUsers =>
      $base.as((v, t, t2) => _UsersCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class UsersCopyWith<$R, $In extends Users, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? id, String? username});
  UsersCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _UsersCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Users, $Out>
    implements UsersCopyWith<$R, Users, $Out> {
  _UsersCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Users> $mapper = UsersMapper.ensureInitialized();
  @override
  $R call({String? id, String? username}) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (username != null) #username: username,
    }),
  );
  @override
  Users $make(CopyWithData data) => Users(
    id: data.get(#id, or: $value.id),
    username: data.get(#username, or: $value.username),
  );

  @override
  UsersCopyWith<$R2, Users, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _UsersCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class AvailableUserMapper extends ClassMapperBase<AvailableUser> {
  AvailableUserMapper._();

  static AvailableUserMapper? _instance;
  static AvailableUserMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AvailableUserMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'AvailableUser';

  static String _$id(AvailableUser v) => v.id;
  static const Field<AvailableUser, String> _f$id = Field('id', _$id);
  static String _$username(AvailableUser v) => v.username;
  static const Field<AvailableUser, String> _f$username = Field(
    'username',
    _$username,
  );
  static String? _$profileImageLink(AvailableUser v) => v.profileImageLink;
  static const Field<AvailableUser, String> _f$profileImageLink = Field(
    'profileImageLink',
    _$profileImageLink,
    key: r'profile_image_link',
    opt: true,
  );

  @override
  final MappableFields<AvailableUser> fields = const {
    #id: _f$id,
    #username: _f$username,
    #profileImageLink: _f$profileImageLink,
  };

  static AvailableUser _instantiate(DecodingData data) {
    return AvailableUser(
      id: data.dec(_f$id),
      username: data.dec(_f$username),
      profileImageLink: data.dec(_f$profileImageLink),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static AvailableUser fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AvailableUser>(map);
  }

  static AvailableUser fromJson(String json) {
    return ensureInitialized().decodeJson<AvailableUser>(json);
  }
}

mixin AvailableUserMappable {
  String toJson() {
    return AvailableUserMapper.ensureInitialized().encodeJson<AvailableUser>(
      this as AvailableUser,
    );
  }

  Map<String, dynamic> toMap() {
    return AvailableUserMapper.ensureInitialized().encodeMap<AvailableUser>(
      this as AvailableUser,
    );
  }

  AvailableUserCopyWith<AvailableUser, AvailableUser, AvailableUser>
  get copyWith => _AvailableUserCopyWithImpl<AvailableUser, AvailableUser>(
    this as AvailableUser,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return AvailableUserMapper.ensureInitialized().stringifyValue(
      this as AvailableUser,
    );
  }

  @override
  bool operator ==(Object other) {
    return AvailableUserMapper.ensureInitialized().equalsValue(
      this as AvailableUser,
      other,
    );
  }

  @override
  int get hashCode {
    return AvailableUserMapper.ensureInitialized().hashValue(
      this as AvailableUser,
    );
  }
}

extension AvailableUserValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AvailableUser, $Out> {
  AvailableUserCopyWith<$R, AvailableUser, $Out> get $asAvailableUser =>
      $base.as((v, t, t2) => _AvailableUserCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AvailableUserCopyWith<$R, $In extends AvailableUser, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? id, String? username, String? profileImageLink});
  AvailableUserCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AvailableUserCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AvailableUser, $Out>
    implements AvailableUserCopyWith<$R, AvailableUser, $Out> {
  _AvailableUserCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AvailableUser> $mapper =
      AvailableUserMapper.ensureInitialized();
  @override
  $R call({String? id, String? username, Object? profileImageLink = $none}) =>
      $apply(
        FieldCopyWithData({
          if (id != null) #id: id,
          if (username != null) #username: username,
          if (profileImageLink != $none) #profileImageLink: profileImageLink,
        }),
      );
  @override
  AvailableUser $make(CopyWithData data) => AvailableUser(
    id: data.get(#id, or: $value.id),
    username: data.get(#username, or: $value.username),
    profileImageLink: data.get(#profileImageLink, or: $value.profileImageLink),
  );

  @override
  AvailableUserCopyWith<$R2, AvailableUser, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AvailableUserCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

