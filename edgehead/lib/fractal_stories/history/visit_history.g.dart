// GENERATED CODE - DO NOT MODIFY BY HAND

part of stranded.history.visit;

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<VisitHistory> _$visitHistorySerializer =
    new _$VisitHistorySerializer();
Serializer<VisitRecord> _$visitRecordSerializer = new _$VisitRecordSerializer();

class _$VisitHistorySerializer implements StructuredSerializer<VisitHistory> {
  @override
  final Iterable<Type> types = const [VisitHistory, _$VisitHistory];
  @override
  final String wireName = 'VisitHistory';

  @override
  Iterable<Object?> serialize(Serializers serializers, VisitHistory object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'records',
      serializers.serialize(object.records,
          specifiedType: const FullType(BuiltListMultimap,
              const [const FullType(String), const FullType(VisitRecord)])),
    ];

    return result;
  }

  @override
  VisitHistory deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new VisitHistoryBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'records':
          result.records.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltListMultimap, const [
                const FullType(String),
                const FullType(VisitRecord)
              ]))!);
          break;
      }
    }

    return result.build();
  }
}

class _$VisitRecordSerializer implements StructuredSerializer<VisitRecord> {
  @override
  final Iterable<Type> types = const [VisitRecord, _$VisitRecord];
  @override
  final String wireName = 'VisitRecord';

  @override
  Iterable<Object?> serialize(Serializers serializers, VisitRecord object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'actorId',
      serializers.serialize(object.actorId, specifiedType: const FullType(int)),
      'fromRoomName',
      serializers.serialize(object.fromRoomName,
          specifiedType: const FullType(String)),
      'roomName',
      serializers.serialize(object.roomName,
          specifiedType: const FullType(String)),
      'time',
      serializers.serialize(object.time,
          specifiedType: const FullType(DateTime)),
    ];
    Object? value;
    value = object.parentRoomName;
    if (value != null) {
      result
        ..add('parentRoomName')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  VisitRecord deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new VisitRecordBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'actorId':
          result.actorId = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
        case 'fromRoomName':
          result.fromRoomName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'parentRoomName':
          result.parentRoomName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'roomName':
          result.roomName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'time':
          result.time = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime;
          break;
      }
    }

    return result.build();
  }
}

class _$VisitHistory extends VisitHistory {
  @override
  final BuiltListMultimap<String, VisitRecord> records;

  factory _$VisitHistory([void Function(VisitHistoryBuilder)? updates]) =>
      (new VisitHistoryBuilder()..update(updates)).build();

  _$VisitHistory._({required this.records}) : super._() {
    BuiltValueNullFieldError.checkNotNull(records, 'VisitHistory', 'records');
  }

  @override
  VisitHistory rebuild(void Function(VisitHistoryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VisitHistoryBuilder toBuilder() => new VisitHistoryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VisitHistory && records == other.records;
  }

  @override
  int get hashCode {
    return $jf($jc(0, records.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('VisitHistory')
          ..add('records', records))
        .toString();
  }
}

class VisitHistoryBuilder
    implements Builder<VisitHistory, VisitHistoryBuilder> {
  _$VisitHistory? _$v;

  ListMultimapBuilder<String, VisitRecord>? _records;
  ListMultimapBuilder<String, VisitRecord> get records =>
      _$this._records ??= new ListMultimapBuilder<String, VisitRecord>();
  set records(ListMultimapBuilder<String, VisitRecord>? records) =>
      _$this._records = records;

  VisitHistoryBuilder();

  VisitHistoryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _records = $v.records.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VisitHistory other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$VisitHistory;
  }

  @override
  void update(void Function(VisitHistoryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$VisitHistory build() {
    _$VisitHistory _$result;
    try {
      _$result = _$v ?? new _$VisitHistory._(records: records.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'records';
        records.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'VisitHistory', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$VisitRecord extends VisitRecord {
  @override
  final int actorId;
  @override
  final String fromRoomName;
  @override
  final String? parentRoomName;
  @override
  final String roomName;
  @override
  final DateTime time;

  factory _$VisitRecord([void Function(VisitRecordBuilder)? updates]) =>
      (new VisitRecordBuilder()..update(updates)).build();

  _$VisitRecord._(
      {required this.actorId,
      required this.fromRoomName,
      this.parentRoomName,
      required this.roomName,
      required this.time})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(actorId, 'VisitRecord', 'actorId');
    BuiltValueNullFieldError.checkNotNull(
        fromRoomName, 'VisitRecord', 'fromRoomName');
    BuiltValueNullFieldError.checkNotNull(roomName, 'VisitRecord', 'roomName');
    BuiltValueNullFieldError.checkNotNull(time, 'VisitRecord', 'time');
  }

  @override
  VisitRecord rebuild(void Function(VisitRecordBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VisitRecordBuilder toBuilder() => new VisitRecordBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VisitRecord &&
        actorId == other.actorId &&
        fromRoomName == other.fromRoomName &&
        parentRoomName == other.parentRoomName &&
        roomName == other.roomName &&
        time == other.time;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc($jc($jc(0, actorId.hashCode), fromRoomName.hashCode),
                parentRoomName.hashCode),
            roomName.hashCode),
        time.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('VisitRecord')
          ..add('actorId', actorId)
          ..add('fromRoomName', fromRoomName)
          ..add('parentRoomName', parentRoomName)
          ..add('roomName', roomName)
          ..add('time', time))
        .toString();
  }
}

class VisitRecordBuilder implements Builder<VisitRecord, VisitRecordBuilder> {
  _$VisitRecord? _$v;

  int? _actorId;
  int? get actorId => _$this._actorId;
  set actorId(int? actorId) => _$this._actorId = actorId;

  String? _fromRoomName;
  String? get fromRoomName => _$this._fromRoomName;
  set fromRoomName(String? fromRoomName) => _$this._fromRoomName = fromRoomName;

  String? _parentRoomName;
  String? get parentRoomName => _$this._parentRoomName;
  set parentRoomName(String? parentRoomName) =>
      _$this._parentRoomName = parentRoomName;

  String? _roomName;
  String? get roomName => _$this._roomName;
  set roomName(String? roomName) => _$this._roomName = roomName;

  DateTime? _time;
  DateTime? get time => _$this._time;
  set time(DateTime? time) => _$this._time = time;

  VisitRecordBuilder();

  VisitRecordBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _actorId = $v.actorId;
      _fromRoomName = $v.fromRoomName;
      _parentRoomName = $v.parentRoomName;
      _roomName = $v.roomName;
      _time = $v.time;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VisitRecord other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$VisitRecord;
  }

  @override
  void update(void Function(VisitRecordBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$VisitRecord build() {
    final _$result = _$v ??
        new _$VisitRecord._(
            actorId: BuiltValueNullFieldError.checkNotNull(
                actorId, 'VisitRecord', 'actorId'),
            fromRoomName: BuiltValueNullFieldError.checkNotNull(
                fromRoomName, 'VisitRecord', 'fromRoomName'),
            parentRoomName: parentRoomName,
            roomName: BuiltValueNullFieldError.checkNotNull(
                roomName, 'VisitRecord', 'roomName'),
            time: BuiltValueNullFieldError.checkNotNull(
                time, 'VisitRecord', 'time'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
