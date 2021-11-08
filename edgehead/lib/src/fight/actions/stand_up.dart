// @dart=2.9

import 'package:edgehead/fractal_stories/action.dart';
import 'package:edgehead/fractal_stories/actor.dart';
import 'package:edgehead/fractal_stories/context.dart';
import 'package:edgehead/fractal_stories/pose.dart';
import 'package:edgehead/fractal_stories/simulation.dart';
import 'package:edgehead/fractal_stories/storyline/randomly.dart';
import 'package:edgehead/fractal_stories/storyline/storyline.dart';
import 'package:edgehead/fractal_stories/world_state.dart';
import 'package:edgehead/src/fight/common/recently_forced_to_ground.dart';

class StandUp extends Action<Nothing> {
  static final StandUp singleton = StandUp();

  static const String className = "StandUp";

  @override
  final String helpMessage = "Being on the ground is very bad in a fight. "
      "A prone warrior is easier to hit, easier to disarm, and has a harder "
      "time reaching anything.";

  @override
  final bool isAggressive = false;

  @override
  final bool isProactive = true;

  @override
  final bool isImplicit = false;

  @override
  final bool rerollable = true;

  @override
  final Resource rerollResource = Resource.stamina;

  @override
  List<String> get commandPathTemplate =>
      const ["self", "get up from the ground"];

  @override
  String get name => className;

  @override
  String applyFailure(_, __) {
    throw UnimplementedError();
  }

  @override
  String applySuccess(ActionContext context, void _) {
    Actor a = context.actor;
    WorldStateBuilder w = context.outputWorld;
    Storyline s = context.outputStoryline;
    a.report(
        s,
        "<subject> {rise<s>|stand<s> up|get<s> to <subject's> feet|"
        "get<s> up|pick<s> <subjectPronounSelf> up}");
    Randomly.run(
        () => a.report(
            s, "<subject> {stagger<s>|sway<s>} back before finding balance"),
        () => a.report(s, "<subject> stead<ies> <subjectPronounSelf>"));
    if (a.isPlayer) {
      // Don't force the player to stand in two moves.
      w.updateActorById(a.id, (b) => b.pose = a.poseMax);
    } else {
      w.updateActorById(a.id, (b) => b.pose = Pose.offBalance);
    }
    return "${a.name} stands up";
  }

  @override
  String getRollReason(Actor a, Simulation sim, WorldState w, void _) =>
      "Will ${a.pronoun.nominative} stand up?";

  @override
  Duration getRecoveryDuration(ApplicabilityContext context, Nothing _) {
    if (context.actor.isPlayer) {
      //  Standing up should be super fast for the player.
      return const Duration(milliseconds: 200);
    }

    return super.getRecoveryDuration(context, null);
  }

  @override
  ReasonedSuccessChance getSuccessChance(
          Actor a, Simulation sim, WorldState w, void _) =>
      ReasonedSuccessChance.sureSuccess;

  @override
  bool isApplicable(ApplicabilityContext c, Actor a, Simulation sim,
          WorldState world, void _) =>
      a.isOnGround &&
      !a.anatomy.hasCrippledLegs &&
      // If this actor just fell, do not let him stand up.
      !recentlyForcedToGround(a, world);
}
