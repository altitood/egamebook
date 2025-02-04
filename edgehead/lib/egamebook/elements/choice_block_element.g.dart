// GENERATED CODE - DO NOT MODIFY BY HAND

part of egamebook.element.choice_block;

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<ChoiceBlock> _$choiceBlockSerializer = new _$ChoiceBlockSerializer();

class _$ChoiceBlockSerializer implements StructuredSerializer<ChoiceBlock> {
  @override
  final Iterable<Type> types = const [ChoiceBlock, _$ChoiceBlock];
  @override
  final String wireName = 'ChoiceBlock';

  @override
  Iterable<Object?> serialize(Serializers serializers, ChoiceBlock object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'choices',
      serializers.serialize(object.choices,
          specifiedType:
              const FullType(BuiltList, const [const FullType(Choice)])),
      'saveGame',
      serializers.serialize(object.saveGame,
          specifiedType: const FullType(SaveGame)),
    ];

    return result;
  }

  @override
  ChoiceBlock deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new ChoiceBlockBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'choices':
          result.choices.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(Choice)]))!
              as BuiltList<Object?>);
          break;
        case 'saveGame':
          result.saveGame.replace(serializers.deserialize(value,
              specifiedType: const FullType(SaveGame))! as SaveGame);
          break;
      }
    }

    return result.build();
  }
}

class _$ChoiceBlock extends ChoiceBlock {
  @override
  final BuiltList<Choice> choices;
  @override
  final SaveGame saveGame;

  factory _$ChoiceBlock([void Function(ChoiceBlockBuilder)? updates]) =>
      (new ChoiceBlockBuilder()..update(updates)).build();

  _$ChoiceBlock._({required this.choices, required this.saveGame}) : super._() {
    BuiltValueNullFieldError.checkNotNull(choices, 'ChoiceBlock', 'choices');
    BuiltValueNullFieldError.checkNotNull(saveGame, 'ChoiceBlock', 'saveGame');
  }

  @override
  ChoiceBlock rebuild(void Function(ChoiceBlockBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChoiceBlockBuilder toBuilder() => new ChoiceBlockBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChoiceBlock &&
        choices == other.choices &&
        saveGame == other.saveGame;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, choices.hashCode), saveGame.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('ChoiceBlock')
          ..add('choices', choices)
          ..add('saveGame', saveGame))
        .toString();
  }
}

class ChoiceBlockBuilder implements Builder<ChoiceBlock, ChoiceBlockBuilder> {
  _$ChoiceBlock? _$v;

  ListBuilder<Choice>? _choices;
  ListBuilder<Choice> get choices =>
      _$this._choices ??= new ListBuilder<Choice>();
  set choices(ListBuilder<Choice>? choices) => _$this._choices = choices;

  SaveGameBuilder? _saveGame;
  SaveGameBuilder get saveGame => _$this._saveGame ??= new SaveGameBuilder();
  set saveGame(SaveGameBuilder? saveGame) => _$this._saveGame = saveGame;

  ChoiceBlockBuilder();

  ChoiceBlockBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _choices = $v.choices.toBuilder();
      _saveGame = $v.saveGame.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChoiceBlock other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ChoiceBlock;
  }

  @override
  void update(void Function(ChoiceBlockBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$ChoiceBlock build() {
    _$ChoiceBlock _$result;
    try {
      _$result = _$v ??
          new _$ChoiceBlock._(
              choices: choices.build(), saveGame: saveGame.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'choices';
        choices.build();
        _$failedField = 'saveGame';
        saveGame.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'ChoiceBlock', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
