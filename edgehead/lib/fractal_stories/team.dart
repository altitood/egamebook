library stranded.team;

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:meta/meta.dart';

part 'team.g.dart';

const _neutralTeamId = 0;

final Team defaultEnemyTeam = Team((b) => b.id = 2);

final Team neutralTeam = Team((b) => b.id = _neutralTeamId);

final Team playerTeam = Team((b) => b.id = 1);

@immutable
abstract class Team implements Built<Team, TeamBuilder> {
  static Serializer<Team> get serializer => _$teamSerializer;

  factory Team([void updates(TeamBuilder b)]) = _$Team;

  // ignore: prefer_const_constructors_in_immutables
  Team._();

  int get id;

  /// Currently, every team is enemy of every other team. In the future,
  /// we can implement allegiances etc.
  ///
  /// Neutral team is never enemy with any other team.
  bool isEnemyWith(Team other) =>
      id != _neutralTeamId && other.id != _neutralTeamId && id != other.id;

  /// Currently, only team members are friendly with each other. In the future,
  /// we can have alliances.
  bool isFriendWith(Team other) => id == other.id;
}
