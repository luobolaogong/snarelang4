import 'package:petitparser/petitparser.dart';
//import 'note.dart';
//import 'tempo.dart';
//import 'dynamic.dart';
//import 'timesig.dart';
import '../snarelang4.dart';

// TODO: Put public facing types in this file.

class Score {
  List elements = [];

  String toString() {
    return elements.toString(); // could do a forEach and collect each element into a string with \n between each
  }


  ///
  /// Apply shortcuts, meaning that missing properties of duration and type for a text note get filled in from the previous
  /// note.  This would include notes specified by ".", which means use previous note's duration and type.  This will be
  /// expanded to volume/velocity later.
  /// Also, when the note type is not specified, swap hand order from the previous note.
  ///
  void applyShortcuts() {
    // bad logic.  Off by one stuff:
    var previousNote = Note();
    previousNote.duration.firstNumber = 4;
    previousNote.duration.secondNumber = 1;
    previousNote.noteType = NoteType.leftTap; // ???

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
      if (note.velocity == null || note.noteType == NoteType.previousNoteDurationOrType) {
        note.velocity = previousNote.velocity;
      }
      previousNote = note;
    }
    return;
  }
}

///
/// ScoreParser
///
//Parser scoreParser = ((noteParser | dynamicParser).plus()).trim().end().map((values) {    // trim()?
//Parser scoreParser = ((noteParser | dynamicParser | timeSigParser | tempoParser).plus()).trim().end().map((values) {    // trim()?
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
