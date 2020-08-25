import 'dart:io';
import 'package:petitparser/petitparser.dart';
import '../snarelang4.dart';
import 'package:logging/logging.dart';



//final log = Logger('Score');

// TODO: Put public facing types in this file.

/// A Score is kinda a top level thing although maybe ScoreSet or TuneSet
/// will come along.  A Score should hold the list of notes and other elements
/// that were entered by way of a score text file, and then had shorthands
/// (and static dynamics) applied to the notes.
///
/// That list can be handed over to a Midi processor to be used to create
/// a list of midi events.  At some time in that process note velocities
/// will get applied, which are a product of the absolute and rampd dynamics
/// and note type.
///
class Score {
  List elements = [];

  String toString() {
    return 'Score: ${elements.toString()}'; // could do a forEach and collect each element into a string with \n between each
  }

  static Result load(List<String> scoresPaths) {
    var scoresBuffer = StringBuffer();
    for (var filePath in scoresPaths) {
      log.info('gunna process file $filePath');
      var inputFile = File(filePath);
      if (!inputFile.existsSync()) {
        log.warning('File does not exist at ${inputFile.path}');
        continue;
      }
      var fileContents = inputFile.readAsStringSync(); // per line better?
      if (fileContents.length == 0) {
        continue;
      }
      scoresBuffer.write(fileContents);
    }
    //
    // Parse the score's text elements, notes and other stuff
    //
    var result = scoreParser.parse(scoresBuffer.toString());
    if (result.isSuccess) {
      Score score = result.value;
      log.info('parse succeeded.  This many elements: ${score.elements.length}\n'); // wrong
      for (var element in score.elements) {
        print('\tAfter score raw parse, element list has this: $element');
      }
    }
    else {
      log.warning('parse failed: ${result.message}');
    }
    print('Done with first pass -- loaded raw notes, no shorthands yet.\n');
    return result;
  }

  ///
  /// Apply shorthands, meaning that missing properties of duration and type for a text note get filled in from the previous
  /// note.  This would include notes specified by ".", which means use previous note's duration and type.  This will be
  /// expanded to volume/velocity later.
  /// Also, when the note type is not specified, swap hand order from the previous note.
  /// This also sets the dynamic field, but not velocities.
  ///
//  void applyShorthands() {
  void applyShorthands(Note defaultNote) {
    // bad logic.  Off by one stuff:
//    var previousNote = defaultNote;
    //Tempo latestTempo;
    log.info('In applyShorthands');
    var previousNote = Note();
    previousNote.dynamic = defaultNote.dynamic; // unnec
    previousNote.velocity = defaultNote.velocity; // unnec
    previousNote.articulation = defaultNote.articulation;
    previousNote.duration = defaultNote.duration;
    previousNote.noteType = defaultNote.noteType;
    log.finer('In top of Score.applyShorthands and just set "previousNote" to be the defaultNote passed in, which is $defaultNote');
    for (var element in elements) {
      log.finer('In Score.applyShorthands(), and element is type ${element.runtimeType} ==> $element');
//      if (element is Dynamic) { // new
      if (element is Dynamic) { // new
//        if (element == Dynamic.ramp) {
//          log.fine('In Score.applyShorthands(), and since element is type ${element.runtimeType}, I am skipping it.');
//          continue;
//        }
        log.finer('In Score.applyShorthands(), and because element is ${element.runtimeType} and not a ramp, I am marking previousNote s dynamic to be same, and skipping');
        previousNote.dynamic = element;
        continue;
      }
      if (element is Ramp) {
        log.finer('Score.applyShorthands(), and element is a Ramp so skipping it.');
        continue;
      }
      if (element is Tempo) {
        //latestTempo = element;
        log.warning('Score.applyShorthands(), Not applying shorthand to Tempo element.  Skipping it for now.');
        continue;
      }
      if (!(element is Note)) {
        log.warning('Score.applyShorthands(), What is this element, which will be skipped for now?: ${element.runtimeType}');
        continue; // what else are we skipping here?
      }
      //
      // This section is risky. This could contain bad logic:
      //
      // Usually to repeat a previous note we just have '.' by itself, but we could have
      // '4.' to mean quarter note, but same note type as before, or
      // '.T' to mean same duration as previous note, but make this one a right tap, or
      // '>.' to mean same note as before, but accented this time.
      //
      if (element.noteType == NoteType.previousNoteDurationOrType) {
        element.duration = previousNote.duration;
        element.dynamic = previousNote.dynamic;
        element.noteType = previousNote.noteType;
        element.swapHands(); // check that nothing stupid happens if element is a rest or dynamic or something else
        log.finer('In Score.applyShorthands(), and since note was just a dot, just set element to have previousNote props, so element is now ${element}.');
      }
      else {
//        element.duration ??= previousNote.duration;
        element.duration.firstNumber ??= previousNote.duration.firstNumber; // new
        element.duration.secondNumber ??= previousNote.duration.secondNumber;
        element.dynamic ??= previousNote.dynamic;
        if (element.noteType == null) {
          element.noteType = previousNote.noteType;
          element.swapHands();
        }
        log.finer('In Score.applyShorthands(), and note was not just a dot, but wanted to make sure did the shorthand fill in, so now element is ${element}.');
      }
      //previousNote = element; // No.  Do a copy, not a reference.       watch for previousNoteDurationOrType
      previousNote.dynamic = element.dynamic;
      previousNote.velocity = element.velocity; // unnec?
      previousNote.articulation = element.articulation;
      previousNote.duration = element.duration;
      previousNote.noteType = element.noteType;

      log.finer('bottom of loop Score.applyShorthands(), just updated previousNote to point to be this ${previousNote}.');
    }
    log.info('leaving Score.applyShorthands()\n');
    return;
  }

//  void applyDynamics() {
//    Dynamic currentDynamic;
//    for (var element in elements) {
//      print('looking at $element to apply dynamics');
//    }
//    return;
//  }
}

///
/// ScoreParser
///
//Parser scoreParser = ((tempoParser | dynamicParser | timeSigParser | noteParser).plus()).trim().end().map((values) {    // trim()?
Parser scoreParser = ((tempoParser | dynamicParser | rampParser | noteParser).plus()).trim().end().map((values) {    // trim()?
  log.fine('In Scoreparser, will now add values from parse result list to score.elements');
  var score = Score();
  if (values is List) {
    for (var value in values) {
      //log.info('ScoreParser, value: -->$value<--');
      score.elements.add(value);
      //log.info('ScoreParser, Now score.elements has this many elements: ${score.elements.length}');
    }
  }
  else { // I don't think this happens when there's only one value.  It's still in a list
    log.info('Did not get a list, got this: -->$values<--');
    score.elements.add(values); // right? new
  }
  log.fine('Leaving Scoreparser returning score in parsed and objectified form.');
  return score;
});
