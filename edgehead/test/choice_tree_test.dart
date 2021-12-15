import 'package:built_collection/built_collection.dart';
import 'package:edgehead/egamebook/elements/choice_block_element.dart';
import 'package:edgehead/egamebook/elements/choice_element.dart';
import 'package:edgehead/egamebook/elements/choice_tree.dart';
import 'package:edgehead/egamebook/elements/save_element.dart';
import 'package:test/test.dart';

Choice _buildChoice(String commandWithCarets, {bool isImplicit = false}) {
  return Choice((b) => b
    ..commandPath = ListBuilder<String>(commandWithCarets.split('>>'))
    ..commandSentence = commandWithCarets.replaceAll(' >> ', ' ')
    ..isImplicit = isImplicit
    ..successChance = 100
    ..actionName = 'Dummy'
    ..additionalData = ListBuilder<int>());
}

void main() {
  final emptySaveGame = SaveGameBuilder()..saveGameSerialized = '';

  test("generates no groups when no >> choices", () {
    final choice1 = _buildChoice('Slap him with a trout');
    final choice2 = _buildChoice('Slap him with a leaf');

    final choiceBlock = (ChoiceBlockBuilder()
          ..choices.addAll([
            choice1,
            choice2,
          ])
          ..saveGame = emptySaveGame)
        .build();

    final tree = ChoiceTree(choiceBlock);

    expect(tree.root.choices, unorderedMatches(<Choice>[choice1, choice2]));
    expect(tree.root.groups, isEmpty);
  });

  test("generates simple tree with two >> choices", () {
    final choice1 = _buildChoice('Slap him >> with a trout');
    final choice2 = _buildChoice('Slap him >> with a leaf');

    final choiceBlock = (ChoiceBlockBuilder()
          ..choices.addAll([
            choice1,
            choice2,
          ])
          ..saveGame = emptySaveGame)
        .build();

    final tree = ChoiceTree(choiceBlock);

    expect(tree.root.choices, isEmpty);
    expect(tree.root.groups, hasLength(1));
    expect(tree.root.groups.single.groups, isEmpty);
    expect(tree.root.groups.single.choices, hasLength(2));
  });

  test("generates tree with choices of order of 2 (have two >>)", () {
    final choice1 =
        _buildChoice('Attack goblin >> by slapping him >> with a trout');
    final choice2 =
        _buildChoice('Attack goblin >> by slapping him >> with a leaf');

    final choiceBlock = (ChoiceBlockBuilder()
          ..choices.addAll([
            choice1,
            choice2,
          ])
          ..saveGame = emptySaveGame)
        .build();

    final tree = ChoiceTree(choiceBlock);

    expect(tree.root.choices, isEmpty);
    expect(tree.root.groups, hasLength(1));
    expect(tree.root.groups.single.choices, isEmpty);
    expect(tree.root.groups.single.groups, hasLength(1));
    expect(tree.root.groups.single.groups.single.choices,
        unorderedMatches(<Choice>[choice1, choice2]));
  });

  test("generates a level for each >>", () {
    final choice1 = _buildChoice('Kick >> goblin >> to the groin');
    final choice2 = _buildChoice('Punch >> goblin >> in the face');

    final choiceBlock = (ChoiceBlockBuilder()
          ..choices.addAll([
            choice1,
            choice2,
          ])
          ..saveGame = emptySaveGame)
        .build();

    final tree = ChoiceTree(choiceBlock);

    expect(tree.root.choices, isEmpty);
    expect(tree.root.groups, hasLength(2));
    expect(tree.root.groups.first.choices, isEmpty);
    expect(tree.root.groups.first.groups, hasLength(1));
    expect(tree.root.groups.first.groups.single.choices,
        unorderedMatches(<Choice>[choice1]));
    expect(tree.root.groups.last.choices, isEmpty);
    expect(tree.root.groups.last.groups, hasLength(1));
    expect(tree.root.groups.last.groups.single.choices,
        unorderedMatches(<Choice>[choice2]));
  });

  test("generates tree with one choices when there's one choice", () {
    final choice1 = _buildChoice('End game');

    final choiceBlock = (ChoiceBlockBuilder()
          ..choices.addAll([
            choice1,
          ])
          ..saveGame = emptySaveGame)
        .build();

    final tree = ChoiceTree(choiceBlock);

    expect(tree.root.choices, unorderedMatches(<Choice>[choice1]));
    expect(tree.root.groups, isEmpty);
  });

  test("root node has correct order (0)", () {
    final choice1 =
        _buildChoice('Attack goblin >> by slapping him >> with a trout');
    final choice2 =
        _buildChoice('Attack goblin >> by slapping him >> with a leaf');

    final choiceBlock = (ChoiceBlockBuilder()
          ..choices.addAll([
            choice1,
            choice2,
          ])
          ..saveGame = emptySaveGame)
        .build();

    final tree = ChoiceTree(choiceBlock);

    expect(tree.root.order, equals(0));
  });

  test("capitalization is preserved", () {
    final choice1 = _buildChoice('Horseman White >> talk >> "Greetings."');
    final choice2 = _buildChoice('Horseman White >> talk >> "I need you."');

    final choiceBlock = (ChoiceBlockBuilder()
          ..choices.addAll([
            choice1,
            choice2,
          ])
          ..saveGame = emptySaveGame)
        .build();

    final tree = ChoiceTree(choiceBlock);

    expect(tree.root.groups.single.prefix, "Horseman White");
  });

  test("leaf nodes are trimmed", () {
    final choice1 = _buildChoice('Horseman White >> talk >> "Greetings."');
    final choice2 = _buildChoice('Horseman White >> talk >> "I need you."');

    final choiceBlock = (ChoiceBlockBuilder()
          ..choices.addAll([
            choice1,
            choice2,
          ])
          ..saveGame = emptySaveGame)
        .build();

    final tree = ChoiceTree(choiceBlock);

    expect(tree.root.groups.single.groups.single.choices.first,
        isNot(startsWith(' ')));
  });
}
