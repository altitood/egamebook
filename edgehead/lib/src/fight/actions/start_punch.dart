import 'package:edgehead/fractal_stories/action.dart';
import 'package:edgehead/fractal_stories/actor.dart';
import 'package:edgehead/fractal_stories/pose.dart';
import 'package:edgehead/fractal_stories/simulation.dart';
import 'package:edgehead/fractal_stories/situation.dart';
import 'package:edgehead/fractal_stories/storyline/storyline.dart';
import 'package:edgehead/fractal_stories/world_state.dart';
import 'package:edgehead/src/fight/common/combat_command_path.dart';
import 'package:edgehead/src/fight/common/conflict_chance.dart';
import 'package:edgehead/src/fight/common/start_defensible_action.dart';
import 'package:edgehead/src/fight/punch/punch_defense/punch_defense_situation.dart';
import 'package:edgehead/src/fight/punch/punch_situation.dart';

const String startPunchHelpMessage =
    "Punching someone hard enough can cause them to lose their footing. "
    "And it hurts.";

ReasonedSuccessChance computeStartPunch(
    Actor a, Simulation sim, WorldState w, Actor enemy) {
  return getCombatMoveChance(a, enemy, 0.7, w.statefulRandomState, [
    const Modifier(75, CombatReason.dexterity),
    const Modifier(30, CombatReason.balance),
    ...disabledModifiers,
  ]);
}

EnemyTargetAction startPunchBuilder() => StartDefensibleAction(
      name: "StartPunch",
      combatCommandType: CombatCommandType.stance,
      commandPathTail: "punch",
      helpMessage: startPunchHelpMessage,
      applyStart: startPunchReportStart,
      isApplicable: (a, sim, w, enemy) =>
          !a.anatomy.isBlind &&
          !a.isUndead &&
          (a.pose >= Pose.offBalance) &&
          !enemy.isOnGround &&
          a.isBarehanded,
      mainSituationBuilder: (a, sim, w, enemy) =>
          createPunchSituation(w.randomInt(), a, enemy),
      defenseSituationBuilder: (a, sim, w, enemy, predetermination) =>
          createPunchDefenseSituation(
              w.randomInt(), a, enemy, predetermination),
      successChanceGetter: computeStartPunch,
      rerollable: true,
      rerollResource: Resource.stamina,
      rollReasonTemplate: "will <subject> hit <objectPronoun>?",
    );

void startPunchReportStart(Actor a, Simulation sim, WorldStateBuilder w,
    Storyline s, Actor enemy, Situation mainSituation) {
  var offHand = a.anatomy.primaryWeaponAppendageAvailable ? "" : "off hand ";
  s.add(
      "<subject> {thrust<s>|swing<s>} "
      "<subject's> ${offHand}fist at <object>",
      subject: a,
      object: enemy,
      actionThread: mainSituation.id,
      startsThread: true);
}
