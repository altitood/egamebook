library storyline.shadow_graph;

import 'dart:collection';

import 'package:built_value/built_value.dart' show $jf, $jc;
import 'package:edgehead/fractal_stories/storyline/storyline.dart';

part 'src/identifier.dart';
part 'src/report_pair.dart';
part 'src/sentence_join_type.dart';

/// A graph that tells [Storyline] where to use what qualification (e.g. "he" or
/// "the goblin" or "the red goblin") and how to join sentences (e.g. "and" or
/// "but" or just plain period).
///
/// Algorithm at a glance:
///
/// * construct a "graph" like above - how each entity goes in and out of the
/// discourse * create a "shadow graph" which has "minimum qualification
/// (pronoun -> proper noun)" and "maximum qualification" for each entity for
/// each report. At first, this is all at the lowest level (everything is
/// pronoun) for "minimum" and highest (proper noun) for the "maximum" *
/// actually, this should be a `Set<QualificationLevel>` * also create a graph
/// of begin / end sentence possibilities (`Set<SentenceJoinType>`) (sentence
/// joiners: period, comma, period-and, period-but, and, but) * fill the joiner
/// graph with obvious / forced stuff * wholeSentence == period * but == but *
/// detect "forced pronoun" (when the string says `<subjectPronoun>` but no
/// `<subject>`, for example) * these things will collapse minimum and maximum
/// to just "pronoun" * detect missing proper nouns * these will lower maximum
/// beneath proper nouns * detect missing adjectives * removes everything that
/// involves an adjective * start filling in the obvious. E.g.: 	* start of
/// Storyline must have ">pronoun" for everything. 	* (the above, more
/// generally) - everything that hasn't been mentioned must be ">pronoun" * if
/// there are two sentences next to each other, and the second one has the same
/// pair of entities (1 + 2), the minimum qualification level of the subject of
/// the second sentence goes to a level that makes it obvious which one we're
/// talking about * identify places that are great opportunities. e.g. 	* 2 + 3
/// is great, because it's the same subject, and the second sentence doesn't
/// have another entity in it * the sentence joiner between 2 and 3 is "and" *
/// the qualification level for subject in 3 is `pronoun` (or even "omitted"?) *
/// qual level of every other entity in these sentences is modified accordingly
/// (i.e. other entity with same pronoun becomes ">pronoun") * another great
/// opportunity is a string of 3 reports with the same subject * joiners are:
/// comma + and * qual level for second and third sentence are "omitted" *
/// identify good opportunities (second pass) * Alternate long and short
/// sentences. * Join "but" sentences with same subject with "but" (not period).
/// * Join "but" sentences with different subjects with "but-period". * Prevent
/// two "buts" next to each other. * We apply baseline rules * "the other" -
/// only when there are two entities of same class and nobody else * adjective +
/// "one" - only when the sentence has a subject with same name but different
/// adjective, and we used the adjective for the subject recently * "the other
/// $noun" - only when there are only two instances of $noun (red and green
/// goblin, no blue goblin) * noun - only when there is no other entity with the
/// same $name in the whole storyline * AI: maybe give Storyline a list of
/// active entities before realization. Because the paragraph might not mention
/// the blue orc, so Storyline omits "red" in "red orc", but it's still
/// confusing for the player ("which one?"). * Lastly, go from left to right and
/// fill in the rest of the joiners and concretize the qualification level of
/// each entity * use the least qualified level (e.g. omit / pronoun when
/// possible) * Assert that there is no place where we have nothing to choose
/// from.
class ShadowGraph {
  /// An [Entity] used to signify that no entity can be referred to by
  /// an identifier. This usually means that, for example, [Pronoun.HE]
  /// cannot be used because two of the entities use it.
  static final Entity noEntity = Entity(name: 'NO ENTITY');

  /// For each report, this lists the possible identifiers to use.
  ///
  /// For example, the second sentence might be able to refer to its
  /// subject with a pronoun or with the name (but not with "the other one").
  ///
  /// [ReportIdentifiers] for each report starts with everything allowed,
  /// and the algorithm removes impossibilities.
  List<ReportIdentifiers> _reportIdentifiers;

  /// The way sentences are stringed together (with period, with comma,
  /// or without anything).
  ///
  /// A [_joiner] for index `i` describes how a [Report] at index `i` flows
  /// from report at index `i - 1`.
  ///
  /// [_joiners] starts with everything allowed, and the algorithm removes
  /// impossibilities (so that at the end, only a few or just one possibility
  /// survives).
  List<Set<SentenceJoinType>> _joiners;

  /// The conjunction between two sentences (but or and).
  ///
  /// A [_conjunctions] for index `i` describes how a [Report] at
  /// index `i` flows from report at index `i - 1`.
  ///
  /// [_conjunctions] starts as an empty set. The algorithm may add
  /// [SentenceConjunction.and] or [SentenceConjunction.but].
  List<Set<SentenceConjunction>> _conjunctions;

  /// For each report, this maps from different concrete identifiers
  /// (such as "he" or "the goblin") to entities in that report.
  List<Map<Identifier, Entity>> _identifiers;

  Set<Entity> _mentionedEntities;

  final UnmodifiableMapView<int, Entity> _storylineEntities;

  ShadowGraph.from(Storyline storyline)
      : _storylineEntities = storyline.allEntities {
    // At first, all qualifications and all joiners are possible.
    _reportIdentifiers = List.generate(
      storyline.reports.length,
      (_) => ReportIdentifiers(),
      growable: false,
    );
    _joiners = List.generate(
      storyline.reports.length,
      (_) => SentenceJoinType.values.toSet(),
      growable: false,
    );
    // No conjunction is possible at the start, we add possibilities
    // as we go.
    _conjunctions = List.generate(
      storyline.reports.length,
      (_) => {SentenceConjunction.nothing},
      growable: false,
    );

    _mentionedEntities = _getAllMentionedEntities(storyline.reports);

    // TODO: allow pronouns for player
    _fillForcedJoinersAndConjunctions(storyline.reports);
    __assertAtLeastOneJoiner(storyline.reports);
    _detectMissingProperNouns(storyline.reports);
    __assertAtLeastOneIdentifier(storyline.reports);
    _detectReportsNotStartingWithSubject(storyline.reports);
    __assertAtLeastOneIdentifier(storyline.reports);
    _detectMissingAdjectives(storyline.reports);
    __assertAtLeastOneIdentifier(storyline.reports);
    _detectMissingOwners(storyline.reports);
    __assertAtLeastOneIdentifier(storyline.reports);
    _forceOwners(storyline.reports);
    __assertAtLeastOneIdentifier(storyline.reports);
    _detectFirstMentions(storyline.reports, _mentionedEntities);
    __assertAtLeastOneIdentifier(storyline.reports);
    _identifiers =
        _getIdentifiersThroughoutStory(storyline.reports, _mentionedEntities);
    _removeQualificationsWhereUnavailable(storyline.reports, _identifiers);
    __assertAtLeastOneIdentifier(storyline.reports);
    _findPositiveNegativeButConjunctions(storyline.reports);
    __assertAtLeastOneIdentifier(storyline.reports);
    __assertAtLeastOneJoiner(storyline.reports);
    _find2JoinerOpportunitiesP0(storyline.reports);
    __assertAtLeastOneIdentifier(storyline.reports);
    __assertAtLeastOneJoiner(storyline.reports);
    _find2JoinerOpportunitiesP1(storyline.reports);
    __assertAtLeastOneIdentifier(storyline.reports);
    __assertAtLeastOneJoiner(storyline.reports);
    _fillOtherJoiners(storyline.reports);
    __assertAtLeastOneIdentifier(storyline.reports);
    __assertExactlyOnePossibleJoiner(storyline.reports);
    _removeOmittedAtStartsOfSentences(storyline.reports);
    __assertAtLeastOneIdentifier(storyline.reports);
    _detectForcedPronouns(storyline.reports);
    __assertAtLeastOneIdentifier(storyline.reports);
    _removeButsTooClose(storyline.reports);

    _retainTheLowestPossibleIdentifiers(storyline.reports);
    _retainTheHighestPossibleConjunction(storyline.reports);
  }

  Set<Entity> get allMentionedEntities => _mentionedEntities;

  UnmodifiableListView<SentenceConjunction> get conjunctions =>
      UnmodifiableListView(_conjunctions.map((set) => set.single));

  UnmodifiableListView<SentenceJoinType> get joiners =>
      UnmodifiableListView(_joiners.map((set) => set.single));

  UnmodifiableListView<ReportIdentifiers> get qualifications =>
      UnmodifiableListView(_reportIdentifiers);

  String describe() {
    final buf = StringBuffer();

    for (int i = 0; i < _reportIdentifiers.length; i++) {
      final qual = _reportIdentifiers[i];
      buf.writeln('=== ${i + 1} ===');
      buf.writeln('subject: ${qual._subjectRange}');
      buf.writeln('object: ${qual._objectRange}');
      buf.writeln('object2: ${qual._object2Range}');

      final ids = _identifiers[i];
      buf.writeln('identifiers: $ids');

      buf.writeln(_joiners[i]);
      buf.writeln(_conjunctions[i]);
      buf.writeln();
    }
    return buf.toString();
  }

  /// Uses the [currentEntities] to find the entity with the provided [id].
  ///
  /// If it cannot find the entity among the current ones (usually the ones
  /// mentioned in the current [Storyline]), it will broaden the search
  /// to [_storylineEntities] (which are generally all entities in the Book).
  ///
  /// Returns `null` if the entity with [id] cannot be found.
  Entity getEntityById(int id, Set<Entity> currentEntities) {
    for (final entity in currentEntities) {
      if (entity.id == id) return entity;
    }

    final result = _storylineEntities[id];
    assert(
        result != null,
        'The entity with id=$id is missing from both '
        'currentEntities=$currentEntities and from '
        '_storylineEntities=$_storylineEntities');
    return result;
  }

  void __assertAtLeastOneIdentifier(UnmodifiableListView<Report> reports) {
    for (int i = 0; i < _reportIdentifiers.length; i++) {
      final report = reports[i];
      _reportIdentifiers[i].forEachEntityIn(report, (complement, entity, set) {
        assert(
            set.isNotEmpty,
            "We have an empty range ($set) for $entity ($complement) "
            "in $report (#$i).\n"
            "Reports: $reports\n\n"
            "Identifiers: $_identifiers\n\n"
            "ReportIdentifiers: $_reportIdentifiers");
        assert(
            complement == ComplementType.SUBJECT ||
                set.difference(const {IdentifierLevel.omitted}).isNotEmpty,
            "The identifier range only has 'omitted' despite the fact that "
            "complement is $complement for $entity in $report (#$i).");
      });
    }
  }

  void __assertAtLeastOneJoiner(UnmodifiableListView<Report> reports) {
    for (int i = 0; i < _joiners.length; i++) {
      assert(
          _joiners[i].isNotEmpty,
          "There should be at least one joiner "
          "for ${reports[i]} at this point "
          "but instead there is: ${_joiners[i]}.");
    }
  }

  void __assertExactlyOnePossibleJoiner(UnmodifiableListView<Report> reports) {
    for (int i = 0; i < _joiners.length; i++) {
      assert(
          _joiners[i].length == 1,
          "There should be a single joiner "
          "for ${reports[i]} but instead there is: ${_joiners[i]}.");
    }
  }

  void _allowAnd(int i) {
    if (i < 0 || i >= _conjunctions.length) return;
    _conjunctions[i].add(SentenceConjunction.and);
  }

  void _allowBut(int i) {
    if (i < 0 || i >= _conjunctions.length) return;
    _conjunctions[i].add(SentenceConjunction.but);
  }

  void _allowObjectPronoun(int i) {
    _reportIdentifiers[i]._objectRange.add(IdentifierLevel.pronoun);
  }

  /// Detects entities that have `<*wner>` before them, and removes
  /// all irrelevant [IdentifierLevel]s.
  ///
  /// Entities with `<*wner>` before them cannot be just [IdentifierLevel.noun],
  /// for example. They are forced to be either
  /// [IdentifierLevel.ownerPronounsNoun] or
  /// [IdentifierLevel.ownerNamesNounNoun].
  void _forceOwners(UnmodifiableListView<Report> reports) {
    for (int i = 0; i < reports.length; i++) {
      final report = reports[i];

      if (report.string.contains(ComplementType.OWNER.genericPossessive) &&
          report.subject.firstOwnerId != null) {
        _reportIdentifiers[i]._subjectRange.retainAll([
          IdentifierLevel.ownerPronounsNoun,
          IdentifierLevel.ownerNamesNoun,
        ]);
      }

      if (report.string
              .contains(ComplementType.OBJECT_OWNER.genericPossessive) &&
          report.object.firstOwnerId != null) {
        _reportIdentifiers[i]._objectRange.retainAll([
          IdentifierLevel.ownerPronounsNoun,
          IdentifierLevel.ownerNamesNoun,
        ]);
      }
    }
  }

  /// In any storyline, the first time we mention anyone after a while,
  /// we cannot use pronouns or any other confusing identifiers.
  void _detectFirstMentions(
      UnmodifiableListView<Report> reports, Set<Entity> entities) {
    final Set<int> everMentionedIds = {};
    // Maps from entity ID to the most recent report index it was referenced.
    final Map<int, int> lastMentionedTimes = {};
    for (int i = 0; i < reports.length; i++) {
      final report = reports[i];
      _reportIdentifiers[i].forEachEntityIn(report, (complement, entity, set) {
        if (!entity.isPlayer && !everMentionedIds.contains(entity.id)) {
          // If this is the first time we mention this entity, call it by
          // at least the noun.
          set.removeAll([
            IdentifierLevel.omitted,
            IdentifierLevel.pronoun,
            IdentifierLevel.adjectiveOne,
          ]);

          everMentionedIds.add(entity.id);
        }

        assert(
            set.isNotEmpty,
            'The range of identifiers for $entity ($complement) '
            'is already empty. Entities: $entities.');

        // Unless we just talked about the entity...
        if ((lastMentionedTimes[entity.id] ?? -1000) < i - 1) {
          // ... disallow any identifiers that might confuse this with
          // any other entity.
          set.removeAll(_getConflictingQualificationLevels(entity, entities));
        }

        assert(
            set.isNotEmpty,
            'The range of identifiers for $entity ($complement) '
            'is already empty. Entities: $entities.');

        lastMentionedTimes[entity.id] = i;

        if (entity.firstOwnerId != null) {
          // Also solve this for the owner of the entity.
          final owner = getEntityById(entity.firstOwnerId, entities);

          if (!owner.isPlayer && !everMentionedIds.contains(owner.id)) {
            // If we haven't mentioned the owner yet, we can't use their
            // pronoun.
            set.removeAll([
              IdentifierLevel.ownerPronounsNoun,
            ]);
          }
        }
      });
    }
  }

  /// Detect "forced pronouns" (when the string says `<subjectPronoun>`
  /// but no `<subject>`, for example).
  void _detectForcedPronouns(UnmodifiableListView<Report> reports) {
    for (int i = 0; i < reports.length; i++) {
      final report = reports[i];

      for (final complement in ComplementType.all) {
        if (report.string.contains(complement.pronoun) &&
            !report.string.contains(complement.generic)) {
          _reportIdentifiers[i].getRangeByType(complement)
            ..clear()
            ..add(IdentifierLevel.pronoun);
        }
      }
    }
  }

  /// Detects entities that have [Entity.adjective] == `null`, and removes
  /// the relevant [IdentifierLevel]s.
  void _detectMissingAdjectives(UnmodifiableListView<Report> reports) {
    for (int i = 0; i < reports.length; i++) {
      final report = reports[i];
      _reportIdentifiers[i].forEachEntityIn(report, (complement, entity, set) {
        if (entity.adjective == null) {
          set.removeAll(
              [IdentifierLevel.adjectiveOne, IdentifierLevel.adjectiveNoun]);
        }
      });
    }
  }

  /// Detects entities that have [Entity.firstOwnerId] == `null`, and removes
  /// the relevant [IdentifierLevel]s.
  void _detectMissingOwners(UnmodifiableListView<Report> reports) {
    for (int i = 0; i < reports.length; i++) {
      final report = reports[i];
      _reportIdentifiers[i].forEachEntityIn(report, (complement, entity, set) {
        if (entity.firstOwnerId == null) {
          set.removeAll([
            IdentifierLevel.ownerPronounsNoun,
            IdentifierLevel.ownerNamesNoun,
          ]);
        }
      });
    }
  }

  /// Detect missing proper nouns -- when an entity does not have a proper
  /// noun (e.g. "John").
  void _detectMissingProperNouns(UnmodifiableListView<Report> reports) {
    for (int i = 0; i < reports.length; i++) {
      final report = reports[i];
      _reportIdentifiers[i].forEachEntityIn(report, (complement, entity, set) {
        if (!entity.nameIsProperNoun) {
          set.remove(IdentifierLevel.properNoun);
        }
      });
    }
  }

  /// Detect sentences which don't start with "<subject>", and therefore
  /// cannot omit subject.
  ///
  /// For example, a sentence like "in the meantime, <subject> take<s> <object>"
  /// does not start with "<subject>", and so subject cannot be omitted.
  void _detectReportsNotStartingWithSubject(
      UnmodifiableListView<Report> reports) {
    for (int i = 0; i < reports.length; i++) {
      final report = reports[i];
      if (!report.string.startsWith(ComplementType.SUBJECT.generic)) {
        _reportIdentifiers[i]._subjectRange.remove(IdentifierLevel.omitted);
      }
    }
  }

  /// Fill the joiner graph with obvious / forced stuff, such as:
  ///
  /// * wholeSentence == none
  void _fillForcedJoinersAndConjunctions(UnmodifiableListView<Report> reports) {
    // Always start with new sentence (no ", and" or period).
    _joiners[0]
      ..clear()
      ..add(SentenceJoinType.none);

    for (int i = 0; i < reports.length; i++) {
      final report = reports[i];
      if (report.wholeSentence) {
        _limitJoinerToPeriodOrNone(i);
        _limitJoinerToNone(i + 1);
      }
      if (report.endSentence) {
        _limitJoinerToPeriod(i + 1);
      }
      if (report.but) {
        _allowBut(i);
      }
    }
  }

  void _fillOtherJoiners(UnmodifiableListView<Report> reports) {
    for (int i = 0; i < reports.length; i++) {
      final set = _joiners[i];
      if (set.length > 1) {
        if (set.contains(SentenceJoinType.period)) {
          set.retainAll([SentenceJoinType.period]);
        } else if (set.contains(SentenceJoinType.none)) {
          set.retainAll([SentenceJoinType.none]);
        } else {
          throw StateError("Set: $set");
        }
      }
    }
  }

  /// Find opportunities to join two sentences in one.
  ///
  /// P0 means these are the best ones, we should definitely go for them.
  void _find2JoinerOpportunitiesP0(UnmodifiableListView<Report> reports) {
    for (final pair in _ReportPair.getPairs(reports)) {
      // The goblin tries to dodge and/but fails.
      if (pair.hasSameVerbType &&
          pair.hasSameSubject &&
          pair.first.object == null &&
          pair.second.object == null &&
          _joiners[pair.index].hasPeriodOrNone &&
          _joiners[pair.index + 1].hasComma) {
        _limitJoinerToPeriodOrNone(pair.index);
        _limitJoinerToComma(pair.index + 1);
        _allowAnd(pair.index + 1);
      }

      // The orcish captain avoids the goblin and regains balance.
      if (pair.hasSameVerbType &&
          pair.hasSameSubject &&
          pair.second.object == null &&
          _joiners[pair.index].hasPeriodOrNone &&
          _joiners[pair.index + 1].hasComma) {
        _limitJoinerToPeriodOrNone(pair.index);
        _limitJoinerToComma(pair.index + 1);
        _allowAnd(pair.index + 1);
        continue;
      }

      // He lifts the goblin captain via telekinesis,
      // and hurls him at the orcish one.
      if (pair.hasSameVerbType &&
          pair.hasSameSubject &&
          pair.hasSameObject &&
          _joiners[pair.index].hasPeriodOrNone &&
          _joiners[pair.index + 1].hasComma) {
        _limitJoinerToPeriodOrNone(pair.index);
        _limitJoinerToComma(pair.index + 1);
        _allowObjectPronoun(pair.index + 1);
        _allowAnd(pair.index + 1);
        continue;
      }
    }
  }

  /// Find opportunities to join two sentences in one.
  ///
  /// P1 means these are not as great at [_find2JoinerOpportunitiesP0].
  void _find2JoinerOpportunitiesP1(UnmodifiableListView<Report> reports) {
    for (final pair in _ReportPair.getPairs(reports)) {
      // He has his dagger and his shield.
      if (pair.hasSameVerbType &&
          pair.hasSameSubject &&
          _joiners[pair.index].hasPeriodOrNone &&
          _joiners[pair.index + 1].hasComma) {
        _limitJoinerToPeriodOrNone(pair.index);
        _limitJoinerToComma(pair.index + 1);
        _allowAnd(pair.index + 1);
        continue;
      }

      // I dodge the red orc and he hits the concrete floor.
      if (pair.hasSameVerbType &&
          pair.first.object != null &&
          pair.second.subject == pair.first.object &&
          _joiners[pair.index].hasPeriodOrNone &&
          _joiners[pair.index + 1].hasComma) {
        _limitJoinerToPeriodOrNone(pair.index);
        _limitJoinerToComma(pair.index + 1);
        _allowAnd(pair.index + 1);
        continue;
      }
    }
  }

  /// Finds pairs of sentences that should be joined by "but" because
  /// they are "opposite sentiments". For example:
  ///
  ///     The goblin stands up but doesn't regain full balance.
  void _findPositiveNegativeButConjunctions(
      UnmodifiableListView<Report> reports) {
    for (final pair in _ReportPair.getPairs(reports)) {
      // The goblin stands up but doesn't regain full balance.
      if (pair.hasSameSubject && pair.positiveNegativeAreSwitched) {
        _allowBut(pair.index + 1);
      }

      // I stand up but the goblin slashes me again.
      if (pair.hasSameVerbType &&
          pair.subjectsAreEnemies &&
          ((pair.first.object == null || pair.secondSubjectIsFirstObject) ||
              (pair.second.object == null ||
                  pair.firstSubjectIsSecondObject)) &&
          pair.positiveNegativeAreSame) {
        _allowBut(pair.index + 1);
      }
    }
  }

  /// Gets all mentioned entities in [reports].
  ///
  /// The entities will be stored in their initial state (for example,
  /// if an entity changes pronoun during [reports], this will
  /// not be reflected: only the original pronoun will be listed.
  Set<Entity> _getAllMentionedEntities(UnmodifiableListView<Report> reports) {
    final result = <Entity>{};
    final resultIds = <int>{};
    for (final report in reports) {
      for (final entity in report.allEntities) {
        if (!resultIds.contains(entity.id)) {
          result.add(entity);
          resultIds.add(entity.id);
        }
      }
    }
    return result;
  }

  /// Returns a set of [IdentifierLevel] where [entity] clashes with
  /// any other entity in [allEntities].
  ///
  /// [allEntities] can include the [entity] itself. This method will
  /// automatically discard it (because obviously, an entity will clash
  /// with itself).
  ///
  /// For an example of a "clashing" qualification level, let's have two
  /// entities:
  ///
  ///   * A burly man
  ///   * A burly boy
  ///
  /// The output of this method would be [IdentifierLevel.pronoun] (because
  /// both the burly man and the burly boy are "he") and
  /// [IdentifierLevel.adjectiveOne] (because both are "the burly one").
  Iterable<IdentifierLevel> _getConflictingQualificationLevels(
      Entity entity, Set<Entity> allEntities) sync* {
    final others =
        Set<Entity>.from(allEntities.where((e) => e.id != entity.id));

    if (others.any((e) => e.pronoun == entity.pronoun)) {
      yield IdentifierLevel.pronoun;
    }

    if (entity.adjective != null &&
        others.any((e) => e.adjective == entity.adjective)) {
      yield IdentifierLevel.adjectiveOne;
    }

    if (!entity.isCommon && others.any((e) => e.name == entity.name)) {
      yield IdentifierLevel.noun;
    }

    if (entity.firstOwnerId != null &&
        others.any((e) =>
            e.name == entity.name && e.firstOwnerId == entity.firstOwnerId)) {
      // TODO: Also check for owner's pronoun equality, not just id equality.
      yield IdentifierLevel.ownerPronounsNoun;
      yield IdentifierLevel.ownerNamesNoun;
    }

    if (entity.adjective != null &&
        others.any((e) =>
            '${e.adjective} ${e.name}' ==
            '${entity.adjective} ${entity.name}')) {
      yield IdentifierLevel.adjectiveNoun;
    }

    if (entity.nameIsProperNoun && others.any((e) => e.name == entity.name)) {
      yield IdentifierLevel.properNoun;
    }
  }

  /// Finds out which [Entity] is referred to by which [Identifier] as the
  /// story unfolds.
  ///
  /// For example, [Pronoun.HE] will not identify anything at first, until
  /// a report mentions an entity that uses the pronoun as [Entity.pronoun].
  List<Map<Identifier, Entity>> _getIdentifiersThroughoutStory(
      UnmodifiableListView<Report> reports, Set<Entity> entities) {
    final result = List<Map<Identifier, Entity>>(reports.length);
    var previous = <Identifier, Entity>{};

    // Used to ensure that no two unrelated entities have the same id.
    final assertionIdMap = <int, Type>{};

    for (int i = 0; i < reports.length; i++) {
      final current = <Identifier, Entity>{};

      // Mark [entity] as identifiable with [id], or mark the [id]
      // unusable ([noEntity]) if it's already assigned to some other entity.
      void assign(Identifier id, Entity entity) {
        if (previous.containsKey(id) && previous[id] != entity) {
          // A new entity assignable to an id that was assignable to someone
          // else in the preceding report.
          return;
        }
        if (current.containsKey(id) && current[id].id != entity.id) {
          // The identifier already points to an entity. Also, that entity
          // isn't _this_ [entity] (which might happen when an entity is both
          // the subject and the object of a report).
          current[id] = noEntity;
        } else {
          current[id] = entity;
        }
      }

      // Mark the previous report's subject as the omitted one in this report.
      if (i >= 1) {
        final previousSubject = reports[i - 1].subject;
        if (previousSubject != null &&
            reports[i].subject?.id == previousSubject.id) {
          current[const Identifier.omitted()] = previousSubject;
        }
      }

      final reportEntities = reports[i].allEntities.toList(growable: false);

      for (final entityInReport in reportEntities) {
        assert(!assertionIdMap.containsKey(entityInReport.id) ||
            assertionIdMap[entityInReport.id] == entityInReport.runtimeType);
        assert(() {
          assertionIdMap[entityInReport.id] = entityInReport.runtimeType;
          return true;
        }());

        final entity = entities.singleWhere((e) => e.id == entityInReport.id);

        if (entity.isCommon) {
          // Can share a storyline with entities of same name, like "thrust".
          final commonNameId = Identifier.commonNoun(entity.name, entity.id);
          assign(commonNameId, entity);
        }

        final pronounId = Identifier.pronoun(entity.pronoun);
        assign(pronounId, entity);

        if (entity.adjective != null &&
            reportEntities.where((e) => e.name == entity.name).length >= 2) {
          final adjectiveOneId = Identifier.adjectiveOne(entity.adjective);
          assign(adjectiveOneId, entity);
        }

        if (!entity.nameIsProperNoun) {
          final nounId = Identifier.noun(entity.name);
          assign(nounId, entity);
        }

        if (entity.firstOwnerId != null) {
          final owner = getEntityById(entity.firstOwnerId, entities);

          final ownerPronounsNounId = Identifier.ownerPronounsNoun(
              '${owner.pronoun.genitive} ${entity.name}');
          assign(ownerPronounsNounId, entity);

          final ownerNamesNounId =
              Identifier.ownerNamesNoun('${owner.name}\'s ${entity.name}');
          assign(ownerNamesNounId, entity);
        }

        // TODO: theOtherNoun - by definition, this one will have 2 entities
        //       we would have to know if this is an object or a subject

        if (entity.adjective != null) {
          final adjectiveNounId =
              Identifier.adjectiveNoun('${entity.adjective} ${entity.name}');
          assign(adjectiveNounId, entity);
        }

        if (entity.nameIsProperNoun) {
          final properNounId = Identifier.properNoun(entity.name);
          assign(properNounId, entity);
        }
      }

      assert(
          reportEntities
              .every((entity) => current.values.any((e) => e.id == entity.id)),
          'An entity is missing completely from $current');

      result[i] = current;
      previous = current;
    }

    return result;
  }

  void _limitJoinerToComma(int i) {
    if (i < 0 || i >= _joiners.length) return;
    _joiners[i].retainAll(const {
      SentenceJoinType.comma,
    });
  }

  void _limitJoinerToNone(int i) {
    if (i < 0 || i >= _joiners.length) return;
    _joiners[i].retainAll(const {
      SentenceJoinType.none,
    });
  }

  void _limitJoinerToPeriod(int i) {
    if (i < 0 || i >= _joiners.length) return;
    _joiners[i]
      ..clear()
      ..addAll(const {
        SentenceJoinType.period,
      });
  }

  void _limitJoinerToPeriodOrNone(int i) {
    if (i < 0 || i >= _joiners.length) return;
    _joiners[i].retainAll(const {
      SentenceJoinType.none,
      SentenceJoinType.period,
    });
  }

  /// Removes buts when two of them are next to each other.
  void _removeButsTooClose(UnmodifiableListView<Report> reports) {
    for (int i = 0; i < _conjunctions.length - 1; i++) {
      if (_conjunctions[i].contains(SentenceConjunction.but) &&
          _conjunctions[i + 1].contains(SentenceConjunction.but)) {
        // Favor the forced "but".
        if (reports[i].but) {
          _conjunctions[i + 1].removeAll(const {SentenceConjunction.but});
          continue;
        }
        if (reports[i + 1].but) {
          _conjunctions[i].removeAll(const {SentenceConjunction.but});
          continue;
        }

        // Otherwise, go with the first "but" and remove the second.
        _conjunctions[i + 1].removeAll(const {SentenceConjunction.but});
      }
    }
  }

  void _removeOmittedAtStartsOfSentences(UnmodifiableListView<Report> reports) {
    const startNewSentenceJoiners = [
      SentenceJoinType.period,
      SentenceJoinType.none,
    ];

    for (int i = 0; i < _reportIdentifiers.length; i++) {
      // At this point, the final joiner must have been selected.
      final joiner = joiners[i];
      if (startNewSentenceJoiners.contains(joiner)) {
        _reportIdentifiers[i].forEachEntityIn(reports[i],
            (complement, entity, set) {
          set.remove(IdentifierLevel.omitted);
        });
      }
    }
  }

  /// Use the data in [identifiers] to remove qualifications levels
  /// that would be confusing.
  ///
  /// Most of the work has already been done -- we know which identifiers
  /// (such as "he" or "the goblin") can potentially refer to which
  /// entity in each report. Now we just need to update
  /// the [ReportIdentifiers] accordingly.
  void _removeQualificationsWhereUnavailable(
      UnmodifiableListView<Report> reports,
      List<Map<Identifier, Entity>> identifiers) {
    for (int i = 0; i < reports.length; i++) {
      final report = reports[i];
      final current = identifiers[i];
      _reportIdentifiers[i].forEachEntityIn(report, (complement, entity, set) {
        // Take the identifiers that refer to the entity.
        // For example, in a particular sentence, "he" and "Aren" can
        // both be relevant identifiers for the actor named Aren.
        final relevantIdentifiers = current.entries
            .where((entry) => entry.value.id == entity.id)
            .map((entry) => entry.key)
            .toList(growable: false);

        assert(
            relevantIdentifiers.isNotEmpty,
            "relevantIdentifiers for $entity are empty in $report: "
            "$current");

        // Retain only the part of the entity's current range
        // (`Set<QualificationLevel>`) that is supported by one of
        // these identifiers.
        set.retainWhere((level) => relevantIdentifiers
            .any((identifier) => identifier.satisfiedBy(level)));

        assert(
            set.isNotEmpty,
            "range of identifiers for $entity ($complement) is empty "
            "in $report: current");
      });
    }
  }

  void _retainTheHighestPossibleConjunction(
      UnmodifiableListView<Report> reports) {
    for (int i = 0; i < _conjunctions.length; i++) {
      final report = reports[i];
      final conjunctions = _conjunctions[i];
      assert(conjunctions.isNotEmpty, "Missing conjunction for $report (#$i).");
      if (conjunctions.contains(SentenceConjunction.but)) {
        conjunctions.retainAll({SentenceConjunction.but});
      } else if (conjunctions.contains(SentenceConjunction.and)) {
        conjunctions.retainAll({SentenceConjunction.and});
      } else {
        conjunctions.retainAll({SentenceConjunction.nothing});
      }
    }
  }

  /// Only retain the lowest (i.e., least specific) qualification level
  /// for each entity in each report.
  void _retainTheLowestPossibleIdentifiers(
      UnmodifiableListView<Report> reports) {
    for (int i = 0; i < _reportIdentifiers.length; i++) {
      final report = reports[i];
      _reportIdentifiers[i].forEachEntityIn(report, (complement, entity, set) {
        assert(set.isNotEmpty,
            "We have an empty range ($set) for $entity in $report.");
        int j = 0;
        while (set.length > 1) {
          set.remove(orderedQualificationLevels[j]);
          j += 1;
        }
        assert(set.length == 1);
      });
    }
  }
}
