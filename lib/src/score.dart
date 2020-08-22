import 'dart:io';
import 'package:petitparser/petitparser.dart';
import '../snarelang4.dart';

// TODO: Put public facing types in this file.

/// A Score is kinda a top level thing although maybe ScoreSet or TuneSet
/// will come along.  A Score should hold the list of notes and other elements
/// that were entered by way of a score text file, and then had shorthands
/// (and static dynamics) applied to the notes.
///
/// That list can be handed over to a Midi processor to be used to create
/// a list of midi events.  At some time in that process note velocities
/// will get applied, which are a product of the absolute and scaled dynamics
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
      print('gunna process file $filePath');
      var inputFile = File(filePath);
      if (!inputFile.existsSync()) {
        print('File does not exist at ${inputFile.path}');
        continue;
      }
      var fileContents = inputFile.readAsStringSync(); // per line better?
      if (fileContents.length == 0) {
        continue;
      }
      scoresBuffer.write(fileContents);
    }
    var result = scoreParser.parse(scoresBuffer.toString());
    if (result.isSuccess) {
      Score score = result.value;
      print('parse succeeded.  This many elements: ${score.elements.length}'); // wrong
    }
    else {
      print('parse failed: ${result.message}');
    }
    return result;
  }

  ///
  /// Apply shorthands, meaning that missing properties of duration and type for a text note get filled in from the previous
  /// note.  This would include notes specified by ".", which means use previous note's duration and type.  This will be
  /// expanded to volume/velocity later.
  /// Also, when the note type is not specified, swap hand order from the previous note.
  ///
  void applyShorthands() {
    // bad logic.  Off by one stuff:
    var previousNote = Note();
    previousNote.duration.firstNumber = 4;
    previousNote.duration.secondNumber = 1;
    previousNote.noteType = NoteType.leftTap; // ???
    previousNote.dynamic = Dynamic.mf; // new.  Conflicts with what may come in on command line

    for (var element in elements) {
      if (element.runtimeType != Note) {
        continue;
      }
      Note note = element;
      if (note.duration == null || note.noteType == NoteType.previousNoteDurationOrType) { // looks bad logic
        note.duration = previousNote.duration;
      }
      if (note.noteType == null || note.noteType == NoteType.previousNoteDurationOrType) {
        note.noteType = previousNote.noteType;
        // Also swap hands
        note.swapHands();
      }
      if (note.dynamic == null || note.noteType == NoteType.previousNoteDurationOrType) {
        note.dynamic = previousNote.dynamic;
      }
//      if (note.velocity == null || note.noteType == NoteType.previousNoteDurationOrType) {
//        note.velocity = previousNote.velocity;
//      }
      previousNote = note; // watch for previousNoteDurationOrType
    }
    return;
  }

  void applyDynamics() {
    Dynamic currentDynamic;
    for (var element in elements) {
      print('looking at $element to apply dynamics');
    }
    return;
  }
}

///
/// ScoreParser
///
Parser scoreParser = ((tempoParser | dynamicParser | timeSigParser | noteParser).plus()).trim().end().map((values) {    // trim()?
  //print('\nIn Scoreparser');
  var score = Score();
  if (values is List) {
    for (var value in values) {
      //print('ScoreParser, value: -->$value<--');
      score.elements.add(value);
      //print('ScoreParser, Now score.elements has this many elements: ${score.elements.length}');
    }
  }
  else { // I don't think this happens when there's only one value.  It's still in a list
    print('Did not get a list, got this: -->$values<--');
    score.elements.add(values); // right? new
  }
  //print('Leaving Scoreparser returning score $score');
  return score;
});
