// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'director.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<DirectorCapability> _$directorCapabilitySerializer =
    new _$DirectorCapabilitySerializer();

class _$DirectorCapabilitySerializer
    implements StructuredSerializer<DirectorCapability> {
  @override
  final Iterable<Type> types = const [DirectorCapability, _$DirectorCapability];
  @override
  final String wireName = 'DirectorCapability';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, DirectorCapability object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'isActive',
      serializers.serialize(object.isActive,
          specifiedType: const FullType(bool)),
    ];

    return result;
  }

  @override
  DirectorCapability deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new DirectorCapabilityBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'isActive':
          result.isActive = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool;
          break;
      }
    }

    return result.build();
  }
}

class _$DirectorCapability extends DirectorCapability {
  @override
  final bool isActive;

  factory _$DirectorCapability(
          [void Function(DirectorCapabilityBuilder)? updates]) =>
      (new DirectorCapabilityBuilder()..update(updates)).build();

  _$DirectorCapability._({required this.isActive}) : super._() {
    BuiltValueNullFieldError.checkNotNull(
        isActive, 'DirectorCapability', 'isActive');
  }

  @override
  DirectorCapability rebuild(
          void Function(DirectorCapabilityBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DirectorCapabilityBuilder toBuilder() =>
      new DirectorCapabilityBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DirectorCapability && isActive == other.isActive;
  }

  @override
  int get hashCode {
    return $jf($jc(0, isActive.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('DirectorCapability')
          ..add('isActive', isActive))
        .toString();
  }
}

class DirectorCapabilityBuilder
    implements Builder<DirectorCapability, DirectorCapabilityBuilder> {
  _$DirectorCapability? _$v;

  bool? _isActive;
  bool? get isActive => _$this._isActive;
  set isActive(bool? isActive) => _$this._isActive = isActive;

  DirectorCapabilityBuilder();

  DirectorCapabilityBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _isActive = $v.isActive;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DirectorCapability other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$DirectorCapability;
  }

  @override
  void update(void Function(DirectorCapabilityBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$DirectorCapability build() {
    final _$result = _$v ??
        new _$DirectorCapability._(
            isActive: BuiltValueNullFieldError.checkNotNull(
                isActive, 'DirectorCapability', 'isActive'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
