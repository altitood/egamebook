// @dart=2.9

import 'package:edgehead/fractal_stories/action.dart';
import 'package:edgehead/fractal_stories/actor.dart';
import 'package:edgehead/fractal_stories/anatomy/body_part.dart';
import 'package:edgehead/fractal_stories/context.dart';
import 'package:edgehead/fractal_stories/pose.dart';
import 'package:edgehead/fractal_stories/simulation.dart';
import 'package:edgehead/fractal_stories/storyline/storyline.dart';
import 'package:edgehead/fractal_stories/world_state.dart';
import 'package:edgehead/src/fight/common/conflict_chance.dart';
import 'package:edgehead/src/fight/common/humanoid_pain_or_death.dart';

ReasonedSuccessChance computeOpportunityThrust(
    Actor a, Simulation sim, WorldState w, Actor enemy) {
  return getCombatMoveChance(a, enemy, 0.4, w.statefulRandomState, [
    const Modifier(20, CombatReason.dexterity),
    const Penalty(20, CombatReason.targetHasShield),
    const Modifier(20, CombatReason.balance),
    ...disabledModifiers,
  ]);
}

class OffBalanceOpportunityThrust extends EnemyTargetAction {
  static const String className = "OffBalanceOpportunityThrust";

  static final OffBalanceOpportunityThrust singleton =
      OffBalanceOpportunityThrust();

  @override
  final String helpMessage = "When an opponent is out of balance they are the "
      "most vulnerable.";

  @override
  final bool isAggressive = true;

  @override
  final bool isProactive = true;

  @override
  final bool rerollable = true;

  @override
  final Resource rerollResource = Resource.stamina;

  @override
  List<String> get commandPathTemplate => ["stab <object>"];

  @override
  String get name => className;

  @override
  String get rollReasonTemplate => "will <subject> hit <objectPronoun>?";

  @override
  String applyFailure(ActionContext context, Actor enemy) {
    Actor a = context.actor;
    Storyline s = context.outputStoryline;
    a.report(s, "<subject> tr<ies> to stab <object>", object: enemy);
    a.report(s, "<subject> {go<es> wide|fail<s>|miss<es>}", but: true);
    return "${a.name} fails to stab ${enemy.name}";
  }

  @override
  String applySuccess(ActionContext context, Actor enemy) {
    Actor a = context.actor;
    WorldStateBuilder w = context.outputWorld;
    Storyline s = context.outputStoryline;
    final damage = a.currentDamageCapability.thrustingDamage;
    if (!enemy.isInvincible) {
      w.updateActorById(enemy.id, (b) => b..hitpoints -= damage);
    }
    final updatedEnemy = w.getActorById(enemy.id);
    bool killed = !updatedEnemy.isAnimated && !enemy.isInvincible;
    if (!killed) {
      // TODO: actually decide which body part to hit
      a.report(
          s,
          "<subject> thrust<s> <object2> "
          "deep into <object's> {shoulder|hip|thigh}",
          object: updatedEnemy,
          object2: a.currentWeaponOrBodyPart,
          positive: true);
      inflictPain(context, enemy.id, damage,
          enemy.anatomy.findByDesignation(BodyPartDesignation.torso));
    } else {
      a.report(s, "<subject> run<s> <object2> through <object>",
          object: updatedEnemy,
          object2: a.currentWeaponOrBodyPart,
          positive: true);
      killHumanoid(context, enemy.id);
    }
    return "${a.name} stabs ${enemy.name}";
  }

  @override
  ReasonedSuccessChance getSuccessChance(
      Actor a, Simulation sim, WorldState w, Actor enemy) {
    return computeOpportunityThrust(a, sim, w, enemy);
  }

  @override
  bool isApplicable(ApplicabilityContext c, Actor a, Simulation sim,
          WorldState w, Actor enemy) =>
      !a.anatomy.isBlind &&
      a.currentDamageCapability.isThrusting &&
      a.pose >= Pose.standing &&
      enemy.pose <= Pose.extended;
}
