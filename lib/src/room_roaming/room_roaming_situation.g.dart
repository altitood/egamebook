// GENERATED CODE - DO NOT MODIFY BY HAND

part of stranded.room_roaming.room_roaming_situation;

// **************************************************************************
// Generator: BuiltValueGenerator
// Target: abstract class RoomRoamingSituation
// **************************************************************************

class _$RoomRoamingSituation extends RoomRoamingSituation {
  @override
  final String currentRoomName;
  @override
  final int id;
  @override
  final bool monstersAlive;
  @override
  final int time;

  factory _$RoomRoamingSituation(
          [void updates(RoomRoamingSituationBuilder b)]) =>
      (new RoomRoamingSituationBuilder()..update(updates)).build();

  _$RoomRoamingSituation._(
      {this.currentRoomName, this.id, this.monstersAlive, this.time})
      : super._() {
    if (currentRoomName == null)
      throw new ArgumentError.notNull('currentRoomName');
    if (id == null) throw new ArgumentError.notNull('id');
    if (monstersAlive == null) throw new ArgumentError.notNull('monstersAlive');
    if (time == null) throw new ArgumentError.notNull('time');
  }

  @override
  RoomRoamingSituation rebuild(void updates(RoomRoamingSituationBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  RoomRoamingSituationBuilder toBuilder() =>
      new RoomRoamingSituationBuilder()..replace(this);

  @override
  bool operator ==(dynamic other) {
    if (identical(other, this)) return true;
    if (other is! RoomRoamingSituation) return false;
    return currentRoomName == other.currentRoomName &&
        id == other.id &&
        monstersAlive == other.monstersAlive &&
        time == other.time;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc(0, currentRoomName.hashCode), id.hashCode),
            monstersAlive.hashCode),
        time.hashCode));
  }

  @override
  String toString() {
    return 'RoomRoamingSituation {'
        'currentRoomName=${currentRoomName.toString()},\n'
        'id=${id.toString()},\n'
        'monstersAlive=${monstersAlive.toString()},\n'
        'time=${time.toString()},\n'
        '}';
  }
}

class RoomRoamingSituationBuilder
    implements Builder<RoomRoamingSituation, RoomRoamingSituationBuilder> {
  _$RoomRoamingSituation _$v;

  String _currentRoomName;
  String get currentRoomName => _$this._currentRoomName;
  set currentRoomName(String currentRoomName) =>
      _$this._currentRoomName = currentRoomName;

  int _id;
  int get id => _$this._id;
  set id(int id) => _$this._id = id;

  bool _monstersAlive;
  bool get monstersAlive => _$this._monstersAlive;
  set monstersAlive(bool monstersAlive) =>
      _$this._monstersAlive = monstersAlive;

  int _time;
  int get time => _$this._time;
  set time(int time) => _$this._time = time;

  RoomRoamingSituationBuilder();

  RoomRoamingSituationBuilder get _$this {
    if (_$v != null) {
      _currentRoomName = _$v.currentRoomName;
      _id = _$v.id;
      _monstersAlive = _$v.monstersAlive;
      _time = _$v.time;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RoomRoamingSituation other) {
    if (other == null) throw new ArgumentError.notNull('other');
    _$v = other as _$RoomRoamingSituation;
  }

  @override
  void update(void updates(RoomRoamingSituationBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$RoomRoamingSituation build() {
    final result = _$v ??
        new _$RoomRoamingSituation._(
            currentRoomName: currentRoomName,
            id: id,
            monstersAlive: monstersAlive,
            time: time);
    replace(result);
    return result;
  }
}
