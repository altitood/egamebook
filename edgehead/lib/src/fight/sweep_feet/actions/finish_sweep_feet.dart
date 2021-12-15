import 'package:edgehead/fractal_stories/action.dart';
import 'package:edgehead/fractal_stories/actor.dart';
import 'package:edgehead/fractal_stories/context.dart';
import 'package:edgehead/fractal_stories/simulation.dart';
import 'package:edgehead/fractal_stories/storyline/randomly.dart';
import 'package:edgehead/fractal_stories/storyline/storyline.dart';
import 'package:edgehead/fractal_stories/world_state.dart';
import 'package:edgehead/src/fight/common/fall.dart';
import 'package:edgehead/src/fight/fight_situation.dart';
import 'package:edgehead/src/fight/sweep_feet/sweep_feet_situation.dart';

class FinishSweepFeet extends OtherActorAction {
  static final FinishSweepFeet singleton = FinishSweepFeet();

  static const String className = "FinishSweepFeet";

  @override
  final String? helpMessage = null;

  @override
  final bool isAggressive = true;

  @override
  final bool isProactive = false;

  @override
  final bool isImplicit = true;

  @override
  final bool rerollable = false;

  @override
  List<String> get commandPathTemplate => const [];

  @override
  String get name => className;

  @override
  Resource? get rerollResource => null;

  @override
  String get rollReasonTemplate => "(WARNING should not be user-visible)";

  @override
  String applyFailure(ActionContext context, Actor enemy) {
    throw UnimplementedError();
  }

  @override
  String applySuccess(ActionContext context, Actor enemy) {
    Actor a = context.actor;
    WorldStateBuilder w = context.outputWorld;
    Storyline s = context.outputStoryline;

    var threadId = getThreadId(context.simulation, w, sweepFeetSituationName);

    Randomly.run(() {
      a.report(s, "<subject> sweep<s> <object's> feet away",
          object: enemy,
          positive: true,
          endSentence: true,
          actionThread: threadId);
    }, () {
      a.report(s, "<subject> kick<s> <object's> {right|left} shin",
          object: enemy, positive: true, actionThread: threadId);
      if (!enemy.isUndead) {
        enemy.report(s, "<subject> {grunt|shriek}<s>", actionThread: threadId);
      }
    });

    final groundMaterial = getGroundMaterial(w);
    enemy.report(s, "<subject> fall<s> to the $groundMaterial",
        actionThread: threadId, negative: true);

    // Summary
    a.report(s, "<subject> sweep<s> <object's> feet away",
        object: enemy,
        positive: true,
        actionThread: threadId,
        replacesThread: true);
    enemy.report(s, "<subject> fall<s> to the $groundMaterial",
        actionThread: threadId, replacesThread: true, negative: true);

    makeActorFall(context.world, w, s, enemy);
    return "${a.name} sweeps ${enemy.name} off feet";
  }

  @override
  ReasonedSuccessChance getSuccessChance(
          Actor a, Simulation sim, WorldState w, Actor enemy) =>
      ReasonedSuccessChance.sureSuccess;

  @override
  bool isApplicable(ApplicabilityContext c, Actor a, Simulation sim,
          WorldState w, Actor enemy) =>
      true;
}
