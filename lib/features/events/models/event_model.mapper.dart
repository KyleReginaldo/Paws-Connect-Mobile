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

  @override
  final MappableFields<Event> fields = const {
    #id: _f$id,
    #title: _f$title,
    #description: _f$description,
    #createdAt: _f$createdAt,
    #createdBy: _f$createdBy,
    #images: _f$images,
    #suggestions: _f$suggestions,
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
  $R call({
    int? id,
    String? title,
    String? description,
    DateTime? createdAt,
    String? createdBy,
    List<String>? images,
    List<String>? suggestions,
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
  $R call({
    int? id,
    String? title,
    String? description,
    DateTime? createdAt,
    String? createdBy,
    Object? images = $none,
    Object? suggestions = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (title != null) #title: title,
      if (description != null) #description: description,
      if (createdAt != null) #createdAt: createdAt,
      if (createdBy != null) #createdBy: createdBy,
      if (images != $none) #images: images,
      if (suggestions != $none) #suggestions: suggestions,
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
  );

  @override
  EventCopyWith<$R2, Event, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _EventCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

