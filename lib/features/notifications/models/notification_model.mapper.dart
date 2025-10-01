// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'notification_model.dart';

class NotificationMapper extends ClassMapperBase<Notification> {
  NotificationMapper._();

  static NotificationMapper? _instance;
  static NotificationMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = NotificationMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Notification';

  static int _$id(Notification v) => v.id;
  static const Field<Notification, int> _f$id = Field('id', _$id);
  static String _$title(Notification v) => v.title;
  static const Field<Notification, String> _f$title = Field('title', _$title);
  static String _$content(Notification v) => v.content;
  static const Field<Notification, String> _f$content = Field(
    'content',
    _$content,
  );
  static String _$user(Notification v) => v.user;
  static const Field<Notification, String> _f$user = Field('user', _$user);
  static String _$createdAt(Notification v) => v.createdAt;
  static const Field<Notification, String> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static bool? _$isViewed(Notification v) => v.isViewed;
  static const Field<Notification, bool> _f$isViewed = Field(
    'isViewed',
    _$isViewed,
    key: r'is_viewed',
    opt: true,
  );

  @override
  final MappableFields<Notification> fields = const {
    #id: _f$id,
    #title: _f$title,
    #content: _f$content,
    #user: _f$user,
    #createdAt: _f$createdAt,
    #isViewed: _f$isViewed,
  };

  static Notification _instantiate(DecodingData data) {
    return Notification(
      id: data.dec(_f$id),
      title: data.dec(_f$title),
      content: data.dec(_f$content),
      user: data.dec(_f$user),
      createdAt: data.dec(_f$createdAt),
      isViewed: data.dec(_f$isViewed),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Notification fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Notification>(map);
  }

  static Notification fromJson(String json) {
    return ensureInitialized().decodeJson<Notification>(json);
  }
}

mixin NotificationMappable {
  String toJson() {
    return NotificationMapper.ensureInitialized().encodeJson<Notification>(
      this as Notification,
    );
  }

  Map<String, dynamic> toMap() {
    return NotificationMapper.ensureInitialized().encodeMap<Notification>(
      this as Notification,
    );
  }

  NotificationCopyWith<Notification, Notification, Notification> get copyWith =>
      _NotificationCopyWithImpl<Notification, Notification>(
        this as Notification,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return NotificationMapper.ensureInitialized().stringifyValue(
      this as Notification,
    );
  }

  @override
  bool operator ==(Object other) {
    return NotificationMapper.ensureInitialized().equalsValue(
      this as Notification,
      other,
    );
  }

  @override
  int get hashCode {
    return NotificationMapper.ensureInitialized().hashValue(
      this as Notification,
    );
  }
}

extension NotificationValueCopy<$R, $Out>
    on ObjectCopyWith<$R, Notification, $Out> {
  NotificationCopyWith<$R, Notification, $Out> get $asNotification =>
      $base.as((v, t, t2) => _NotificationCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class NotificationCopyWith<$R, $In extends Notification, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    int? id,
    String? title,
    String? content,
    String? user,
    String? createdAt,
    bool? isViewed,
  });
  NotificationCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _NotificationCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Notification, $Out>
    implements NotificationCopyWith<$R, Notification, $Out> {
  _NotificationCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Notification> $mapper =
      NotificationMapper.ensureInitialized();
  @override
  $R call({
    int? id,
    String? title,
    String? content,
    String? user,
    String? createdAt,
    Object? isViewed = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (title != null) #title: title,
      if (content != null) #content: content,
      if (user != null) #user: user,
      if (createdAt != null) #createdAt: createdAt,
      if (isViewed != $none) #isViewed: isViewed,
    }),
  );
  @override
  Notification $make(CopyWithData data) => Notification(
    id: data.get(#id, or: $value.id),
    title: data.get(#title, or: $value.title),
    content: data.get(#content, or: $value.content),
    user: data.get(#user, or: $value.user),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    isViewed: data.get(#isViewed, or: $value.isViewed),
  );

  @override
  NotificationCopyWith<$R2, Notification, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _NotificationCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

