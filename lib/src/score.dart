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
    return elements.toString(); // could do a forEach and collect each element into a string with \n between each
  }

  static Result load(List<String> scoresPaths) {
    var scoresBuffer = StringBuffer();
    for (var filePath in scoresPaths) {
      log.info('gunna process file $filePath');
      var inputFile = File(filePath);
      if (!inputFile.existsSync()) {
        log.info('File does not exist at ${inputFile.path}');
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
      log.info('parse succeeded.  This many elements: ${score.elements.length}'); // wrong
    }
    else {
      log.info('parse failed: ${result.message}');
    }
    return result;
  }

  ///
  /// Apply shorthands, meaning that missing properties of duration and type for a text note get filled in from the previous
  /// note.  This would include notes specified by ".", which means use previous note's duration and type.  This will be
  /// expanded to volume/velocity later.
  /// Also, when the note type is not specified, swap hand order from the previous note.
  ///
//  void applyShorthands() {
  void applyShorthands(Note defaultNote) {
    // bad logic.  Off by one stuff:
    var previousNote = defaultNote;
    for (var element in elements) {
      print('element is ${element.runtimeType} and has this $element');
      if (element.runtimeType == Dynamic) { // new
        if (element == Dynamic.ramp) {
          continue;
        }
        previousNote.dynamic = element;
        continue;
      }
      if (element.runtimeType != Note) {
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
      }
//      if (note.duration == null || note.noteType == NoteType.previousNoteDurationOrType) { // looks bad logic
//        note.duration = previousNote.duration;
//      }
//      if (note.noteType == null || note.noteType == NoteType.previousNoteDurationOrType) {
//        note.noteType = previousNote.noteType;
//        // Also swap hands
//        note.swapHands();
//      }
//      if (note.dynamic == null || note.noteType == NoteType.previousNoteDurationOrType) {
//        note.dynamic = previousNote.dynamic;
//      }
//      if (note.velocity == null || note.noteType == NoteType.previousNoteDurationOrType) {
//        note.velocity = previousNote.velocity;
//      }
//      previousNote = note; // watch for previousNoteDurationOrType
      previousNote = element; // watch for previousNoteDurationOrType
    }
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
Parser scoreParser = ((tempoParser | dynamicParser | timeSigParser | noteParser).plus()).trim().end().map((values) {    // trim()?
  //log.info('\nIn Scoreparser');
  var score = Score();
  if (values is List) {
    for (var value in values) {
      log.info('ScoreParser, value: -->$value<--');
      score.elements.add(value);
      //log.info('ScoreParser, Now score.elements has this many elements: ${score.elements.length}');
    }
  }
  else { // I don't think this happens when there's only one value.  It's still in a list
    log.info('Did not get a list, got this: -->$values<--');
    score.elements.add(values); // right? new
  }
  //log.info('Leaving Scoreparser returning score $score');
  return score;
});
