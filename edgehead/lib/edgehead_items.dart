import 'package:edgehead/edgehead_ids.dart';
import 'package:edgehead/fractal_stories/item.dart';
import 'package:edgehead/fractal_stories/items/damage_capability.dart';
import 'package:edgehead/fractal_stories/items/edibility.dart';
import 'package:edgehead/fractal_stories/items/weapon_type.dart';

final Item akxe = Item.weapon(
  akxeId,
  WeaponType.axe,
  name: 'poleaxe',
  adjective: 'large',
  firstOwnerId: dargId,
  isCleaving: true,
);

final Item barbecuedBat = Item(
  barbecuedBatId,
  name: 'barbecued',
  adjective: 'bat',
  damageCapability: DamageCapability(WeaponType.harmless).toBuilder(),
  edibility: Edibility.food(
          2,
          'I have never eaten a bat so I approach it with disgust. '
          'But the meal is nutritious and tastes fairly well.')
      .toBuilder(),
);

final Item barbecuedSquirrel = Item(
  barbecuedSquirrelId,
  name: 'barbecued',
  adjective: 'squirrel',
  damageCapability: DamageCapability(WeaponType.harmless).toBuilder(),
  edibility: Edibility.food(
          2,
          'The meat is dry and plain. '
          'But the meal is nutritious nonetheless.')
      .toBuilder(),
);

final Item cockroachCake = Item(
  cockroachCakeId,
  name: 'cockroach cake',
  adjective: 'brown',
  damageCapability: DamageCapability(WeaponType.harmless).toBuilder(),
  edibility: Edibility.disgusting.toBuilder(),
);

final Item compass = Item(
  compassId,
  name: 'compass',
  adjective: 'rock-like',
);

final Item dragonEgg = Item.weapon(
  dragonEggId,
  WeaponType.rock,
  name: 'egg',
  adjective: 'dragon',
);

final Item familyPortrait = Item(
  familyPortraitId,
  name: 'portrait',
  adjective: 'family',
  firstOwnerId: ladyHopeId,
);

final Item hawkmanJacket = Item(
  hawkmanJacketId,
  name: 'suit',
  adjective: 'ancient',
  firstOwnerId: hawkmanId,
  // Don't allow hitting someone with a suit.
  damageCapability: DamageCapability(WeaponType.clothing).toBuilder(),
);

final Item jisadApple = Item(
  jisadAppleId,
  name: 'apple',
  adjective: 'green',
  damageCapability: DamageCapability(WeaponType.harmless).toBuilder(),
  edibility:
      Edibility.food(3, "The apple is crisp and invigorating.").toBuilder(),
);

final Item katana = Item.weapon(
  katanaId,
  WeaponType.sword,
  name: "katana",
  adjective: "ancient",
  firstOwnerId: ladyHopeId,
  // Katana is a long sword, longer than normal.
  length: 3,
  isCleaving: true,
);

final Item lairOfGodStar = Item(
  lairOfGodStarId,
  name: "the Artifact Star",
  nameIsProperNoun: true,
);

final Item letterFromFather = Item(
  letterFromFatherId,
  name: "letter",
  adjective: "father's",
);

final Item northSkull = Item.weapon(
  northSkullId,
  WeaponType.rock,
  name: "the North Skull",
  nameIsProperNoun: true,
);

final Item oracleApple = Item(
  oracleAppleId,
  name: 'apple',
  adjective: 'red',
  damageCapability: DamageCapability(WeaponType.harmless).toBuilder(),
  edibility:
      Edibility.food(5, "The apple is the freshest thing I've ever eaten.")
          .toBuilder(),
);

final Item rockFromMeadow = Item.weapon(
  rockFromMeadowId,
  WeaponType.rock,
  name: "rock",
  adjective: "mossy",
);

final Item sarnHammer = Item.weapon(
  sarnHammerId,
  WeaponType.club,
  name: 'hammer',
  adjective: 'giant',
  bluntDamage: 2,
);

final Item sixtyFiverShield = Item.weapon(
  sixtyFiverShieldId,
  WeaponType.shield,
  name: 'shield',
  adjective: 'sixty-fiver',
  firstOwnerId: sixtyFiverOrcId,
);

final Item staleBread = Item(
  staleBreadId,
  name: 'bread',
  adjective: 'stale',
  damageCapability: DamageCapability(WeaponType.rock).toBuilder(),
  edibility: Edibility.food(
          2,
          "The bread is extremely hard to bite and swallow, "
          "but it does fill the belly nicely.")
      .toBuilder(),
);

final Item startBranch = Item.weapon(
  startBranchId,
  WeaponType.club,
  name: 'branch',
  adjective: 'redwood',
);

final Item tamarasDagger = Item.weapon(
  tamarasDaggerId,
  WeaponType.dagger,
  name: "dagger",
  adjective: "long",
  firstOwnerId: tamaraId,
);

final Item theNull = Item(
  theNullId,
  name: 'badge',
  adjective: 'iron',
);
