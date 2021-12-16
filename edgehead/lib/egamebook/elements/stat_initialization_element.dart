library egamebook.element.stat_initialization;

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:edgehead/egamebook/elements/element_base.dart';
import 'package:edgehead/stat.dart';

part 'stat_initialization_element.g.dart';

/// Like [StatUpdate], but will not make the UI show any animation.
///
/// This is meant to be sent by the [Book] just after initialization
/// (new game or loaded game) to create the starting UI state.
abstract class StatInitialization extends ElementBase
    implements Built<StatInitialization, StatInitializationBuilder> {
  static Serializer<StatInitialization> get serializer =>
      _$statInitializationSerializer;

  factory StatInitialization([void updates(StatInitializationBuilder b)]) =
      _$StatInitialization;

  StatInitialization._();

  /// The value of the stat at the beginning of play.
  int get initialValue;

  /// Name of the stat. Corresponds to [Stat.name].
  String get name;

  /// The kind of stat that this initialization is setting.
  ///
  /// This is a safety/convenience getter to prevent string-checking
  /// (`name == "stamina"`) in client code.
  StatInitializationType get type {
    switch (name) {
      case "stamina":
        return StatInitializationType.stamina;
      case "sanity":
        return StatInitializationType.sanity;
    }
    throw StateError('unsupported type: name=$name');
  }

  /// Creates a sanity initialization.
  /// ignore: prefer_constructors_over_static_methods
  static StatInitialization sanity(int initial) {
    return StatInitialization((b) => b
      ..name = "sanity"
      ..initialValue = initial);
  }

  /// Creates a stamina initialization.
  /// ignore: prefer_constructors_over_static_methods
  static StatInitialization stamina(int initial) {
    return StatInitialization((b) => b
      ..name = "stamina"
      ..initialValue = initial);
  }
}

enum StatInitializationType {
  sanity,
  stamina,
}
