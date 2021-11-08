// @dart=2.9

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:edgehead/edgehead_lib.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../bin/default_savegames.dart';
import '../bin/play.dart';

Future<void> main() async {
  test("edgehead runs to completion from start", () async {
    final runner =
        CliRunner(true, true, null, maxTimeAutomated: maxTimeAutomated);
    await runner.initialize(EdgeheadGame());
    runner.startBook();
    await runner.bookEnd.first;
    runner.close();
  }, tags: ["long-running"]);

  test("2 run-throughs with same seed end up with the same state", () async {
    final seed = Random().nextInt(0xffffff);

    Future<String> runAndGetFinalWorld(int seed) async {
      final runner = CliRunner(true, true, null,
          random: Random(seed), maxAutomatedChoicesTaken: 10);
      await runner.initialize(EdgeheadGame(
        randomSeed: seed,
        randomizeAfterPlayerChoice: false,
      ));
      runner.startBook();
      await runner.bookEnd.first;
      runner.close();
      return runner.latestSaveGame;
    }

    final first = await runAndGetFinalWorld(seed);
    final second = await runAndGetFinalWorld(seed);

    expect(first, second);
  }, tags: ["long-running"]);

  Directory tempDir =
      await Directory.systemTemp.createTemp("edgehead_fuzzy_test");
  group("logged", () {
    testWithStopWords(["[SEVERE]", "[SHOUT]"], tempDir, Level.INFO, 10,
        savegame: "bleedsFight");

    testWithStopWords(
        ["[WARNING]", "[SEVERE]", "[SHOUT]"], tempDir, Level.INFO, 10);

    testWithStopWords(["[SEVERE]", "[SHOUT]"], tempDir, Level.INFO, 10);
  });
}

/// The maximum time to run a fuzzy test.
const Duration maxTimeAutomated = Duration(seconds: 30);

String createLogFilePath(Directory tempDir, int i, String description) =>
    path.absolute(path.join(
        tempDir.path, "${description}_${i.toString().padLeft(3, '0')}.log"));

void testWithStopWords(
    List<String> stopWords, Directory tempDir, Level logLevel, int iterations,
    {String savegame}) {
  final identifier =
      stopWords.join("_").replaceAll("[", "").replaceAll("]", "").toLowerCase();
  for (int i = 0; i < iterations; i++) {
    var logPath = createLogFilePath(tempDir, i, identifier);
    var logFile = File(logPath);
    var saveComment = savegame == null ? '' : " (from savegame '$savegame')";
    logFile.writeAsStringSync("");
    test('$identifier-aware test #${i + 1}$saveComment ($logPath)', () async {
      // Make sure the file exists even when there are no errors.
      final runner = CliRunner(
        true,
        true,
        logFile,
        logLevel: logLevel,
        maxTimeAutomated: maxTimeAutomated,
      );
      await runner.initialize(EdgeheadGame(
        saveGameSerialized:
            savegame == null ? null : defaultSavegames[savegame],
        randomizeAfterPlayerChoice: false,
      ));
      try {
        runner.startBook();
        await runner.bookEnd.first;
      } finally {
        runner.close();
      }
      for (final line in logFile.readAsLinesSync()) {
        for (final word in stopWords) {
          if (line.contains(word)) {
            fail("Warning-aware playthrough $i had a severe error. "
                "Log file: $logPath\n"
                "Error: $line");
          }
        }
      }
    }, tags: ["long-running"]);
  }
}
