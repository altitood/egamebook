// @dart=2.9

import 'package:edgehead/fractal_stories/action.dart';
import 'package:edgehead/fractal_stories/actor.dart';
import 'package:edgehead/fractal_stories/context.dart';
import 'package:edgehead/fractal_stories/pose.dart';
import 'package:edgehead/fractal_stories/simulation.dart';
import 'package:edgehead/fractal_stories/storyline/randomly.dart';
import 'package:edgehead/fractal_stories/storyline/storyline.dart';
import 'package:edgehead/fractal_stories/world_state.dart';
import 'package:edgehead/src/fight/common/attacker_situation.dart';
import 'package:edgehead/src/fight/common/conflict_chance.dart';
import 'package:edgehead/src/fight/common/defense_situation.dart';
import 'package:edgehead/src/fight/counter_attack/counter_attack_situation.dart';

ReasonedSuccessChance computeShieldBlockSlash(
    Actor a, Simulation sim, WorldState w, Actor enemy) {
  return getCombatMoveChance(a, enemy, 0.7, w.statefulRandomState, [
    const Modifier(50, CombatReason.dexterity),
    const Modifier(30, CombatReason.balance),
    const Bonus(50, CombatReason.targetHasSecondaryArmDisabled),
    const Bonus(30, CombatReason.targetHasOneLegDisabled),
    const Bonus(90, CombatReason.targetHasAllLegsDisabled),
    const Bonus(50, CombatReason.targetHasOneEyeDisabled),
    const Bonus(90, CombatReason.targetHasAllEyesDisabled),
  ]);
}

class ShieldBlockSlash extends OtherActorAction {
  static final ShieldBlockSlash singleton = ShieldBlockSlash();

  static const String className = "ShieldBlockSlash";

  @override
  final String helpMessage = "A shield blocks enemy attacks with the least "
      "amount of energy and movement. It is easy and quick to launch "
      "a counter-attack when the enemy's weapon is stopped in this way.";

  @override
  final bool isAggressive = false;

  @override
  final bool isProactive = false;

  @override
  final bool rerollable = true;

  @override
  final Resource rerollResource = Resource.stamina;

  @override
  List<String> get commandPathTemplate => ["block with shield and counter"];

  @override
  String get name => className;

  @override
  String get rollReasonTemplate => "will <subject> block the slash?";

  @override
  String applyFailure(ActionContext context, Actor enemy) {
    Actor a = context.actor;
    WorldStateBuilder w = context.outputWorld;
    Storyline s = context.outputStoryline;
    a.report(
        s,
        "<subject> tr<ies> to {block|stop|deflect} the {swing|attack|strike} "
        "with <object2>",
        object2: a.currentShield);
    if (a.pose == Pose.offBalance) {
      a.report(s, "<subject> <is> out of balance", but: true);
    } else {
      Randomly.run(
          () => a.report(s, "<subject> {fail<s>|<does>n't succeed}", but: true),
          () => a.report(s, "<subject> <is> too slow", but: true),
          () => enemy.report(s, "<subject> <is> too quick for <object>",
              object: a, but: true));
    }
    w.popSituation(context);
    return "${a.name} fails to block ${enemy.name} with shield";
  }

  @override
  String applySuccess(ActionContext context, Actor enemy) {
    Actor a = context.actor;
    WorldStateBuilder w = context.outputWorld;
    Storyline s = context.outputStoryline;
    if (enemy.pose == Pose.offBalance) {
      s.add("<subject> <is> out of balance",
          subject: enemy, negative: true, startSentence: true);
      s.add("so <ownerPronoun's> <subject> is {weak|feeble}",
          owner: enemy,
          subject: MoveEntity.getFromAttackerSituation(context.world));
      a.report(
          s,
          "<subject> easily {block<s>|stop<s>|deflect<s>} "
          "the {swing|attack|strike} "
          "with <object2>",
          object2: a.currentShield,
          positive: true);
    } else {
      a.report(
          s,
          "<subject> {block<s>|stop<s>|deflect<s>} the {swing|attack|strike} "
          "with <object2>",
          object2: a.currentShield,
          positive: true);
    }
    w.popSituationsUntil("FightSituation", context);

    if (a.isPlayer) {
      s.add("this opens an opportunity for a counter attack");
    }
    var counterAttackSituation =
        CounterAttackSituation.initialized(w.randomInt(), a, enemy);
    w.pushSituation(counterAttackSituation);
    return "${a.name} blocks ${enemy.name} with a shield";
  }

  @override
  ReasonedSuccessChance getSuccessChance(
      Actor a, Simulation sim, WorldState w, Actor enemy) {
    final situation = w.currentSituation as DefenseSituation;
    return situation.predeterminedChance
        .or(computeShieldBlockSlash(a, sim, w, enemy));
  }

  @override
  bool isApplicable(ApplicabilityContext c, Actor a, Simulation sim,
          WorldState w, Actor enemy) =>
      !a.anatomy.isBlind && a.currentShield != null;
}
