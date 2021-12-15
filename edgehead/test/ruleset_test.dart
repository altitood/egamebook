import 'package:built_collection/built_collection.dart';
import 'package:edgehead/fractal_stories/action.dart';
import 'package:edgehead/fractal_stories/actor.dart';
import 'package:edgehead/fractal_stories/context.dart';
import 'package:edgehead/fractal_stories/simulation.dart';
import 'package:edgehead/fractal_stories/situation.dart';
import 'package:edgehead/fractal_stories/storyline/storyline.dart';
import 'package:edgehead/fractal_stories/world_state.dart';
import 'package:edgehead/fractal_stories/writer_action.dart';
import 'package:edgehead/ruleset/ruleset.dart';
import 'package:test/test.dart';

import 'src/test_random.dart';

void main() {
  final orc = Actor.initialized(1, testRandomIdGetter, "orc");
  final aren = Actor.initialized(2, testRandomIdGetter, "Aren", isPlayer: true);
  final mockAction = SimpleAction('', '', (c, a) => 'mockAction applied', '');
  final mockSimulation = Simulation(
      const [], const [], const {}, const Ruleset.empty(), const {}, const {});
  const sureSuccess = ReasonedSuccessChance.sureSuccess;

  final mockOutputWorldState = WorldStateBuilder()..time = DateTime(200);
  final mockWorldState = mockOutputWorldState.build();
  final mockStoryline = Storyline();

  test("ruleset with 1 rule applies that rule", () {
    var triggered = false;
    final ruleset = Ruleset(
      Rule(42, 1, false, (c) => c.actor.isPlayer, (_) => triggered = true),
    );
    final context = ActionContext(mockAction, aren, mockSimulation,
        mockWorldState, mockOutputWorldState, mockStoryline, sureSuccess);
    ruleset.apply(context);
    expect(triggered, isTrue);
  });

  test("ruleset that doesn't have any applicable rule throws", () {
    final ruleset = Ruleset(
      Rule(42, 1, false, (c) => c.actor.isPlayer, (_) {}),
    );
    final context = ActionContext(mockAction, orc, mockSimulation,
        mockWorldState, mockOutputWorldState, mockStoryline, sureSuccess);
    expect(() => ruleset.apply(context),
        throwsA(const TypeMatcher<NoRuleApplicableException>()));
  });

  test("ruleset with 3 rules applies the most specific one", () {
    var outcome = 0;
    final ruleset = Ruleset.unordered([
      Rule(42, 1, false, (c) => c.actor.isPlayer, (_) => outcome = 42),
      Rule(43, 2, false, (c) => c.actor.isPlayer && c.actor.name == "Aren",
          (_) => outcome = 43),
      Rule(44, 0, false, (_) => true, (_) => outcome = 44),
    ]);
    final orcContext = ActionContext(mockAction, orc, mockSimulation,
        mockWorldState, mockOutputWorldState, mockStoryline, sureSuccess);
    ruleset.apply(orcContext);
    expect(outcome, 44);
    final arenContext = ActionContext(mockAction, aren, mockSimulation,
        mockWorldState, mockOutputWorldState, mockStoryline, sureSuccess);
    ruleset.apply(arenContext);
    expect(outcome, 43);
  });

  test("ruleset saves used rules", () {
    const ruleId = 42;
    final ruleset = Ruleset(
      Rule(ruleId, 1, false, (c) => c.actor.isPlayer, (_) {}),
    );
    final world = WorldStateBuilder()
      ..actors = ListBuilder<Actor>(<Actor>[aren])
      ..situations = ListBuilder<Situation>(<Situation>[])
      ..statefulRandomState = 1337
      ..time = DateTime.utc(1000);
    final context = ActionContext(mockAction, aren, mockSimulation,
        world.build(), world, mockStoryline, sureSuccess);
    expect(world.build().ruleHistory.query(ruleId).hasHappened, isFalse);
    ruleset.apply(context);
    expect(world.build().ruleHistory.query(ruleId).hasHappened, isTrue);
  });

  test("onlyOnce rule is only triggered once", () {
    int state = 0;
    final ruleset = Ruleset(
      Rule(42, 1, true, (c) => c.actor.isPlayer, (_) => state = 1),
      Rule(43, 0, false, (_) => true, (_) => state = 2),
    );
    final world = WorldStateBuilder()
      ..actors = ListBuilder<Actor>(<Actor>[aren])
      ..situations = ListBuilder<Situation>(<Situation>[])
      ..statefulRandomState = 1337
      ..time = DateTime.utc(1000);
    final context = ActionContext(mockAction, aren, mockSimulation,
        world.build(), world, mockStoryline, sureSuccess);
    ruleset.apply(context);
    expect(state, 1);
    final nextWorld = context.outputWorld;
    final nextContext = ActionContext(mockAction, aren, mockSimulation,
        nextWorld.build(), nextWorld, mockStoryline, sureSuccess);
    ruleset.apply(nextContext);
    expect(state, 2);
  });
}
