import 'package:snarelang4/snarelang4.dart';
import 'package:petitparser/petitparser.dart';

void main() {
//  var testString = '\\time 3/4 \\tempo 4=86  F \\cresc . . . ^ \\mf 16 T >8 \\ff _Z 24f ^6d \\dim . . . \\p F \\tempo 4:3=88 \\time 5/6 ';
//  var testString = '.^24Z..'; // Wow, no space delimiters nec!!!!!!  Awesome if this continues to work as new stuff is added and tested
//  var testString = '8r \\p ^24Z . . \\f ';
  var testString = '8f9t10z';
//  var testString = '8t';

  print('Will try to parse -->$testString<--');


  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Stuff below here should be in Score or somewhere, and all we should have here is
  // something like 'process(testString)' which would generate a midi file
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


  // For now, i'll just experiment here.  Later this stuff will go in lib src files
  Result result;
  result = scoreParser.parse(testString);  // Should be able to just do this:   result = ScoreParser.parse(testString);
  if (result.isFailure) {
    print('Failed to parse -->$testString<--');
    print('Message: ${result.message}');
    return; //// ???????????????????????????????????????
  }
  Score score = result.value;
  List scoreElements = score.elements;

  // Now that we have a list of raw score elements, we need to apply
  // shortcuts by going through the list from top to bottom.  If a note
  // is missing a duration of type, take it from the previous note.
  //
  // We also need to set velocities from dynamics.  Just setting
  // a velocity based on the last dynamic static setting (like \mf)
  // is easy and only takes one loop through the list (perhaps even
  // the loop for doing shortcuts),
  //
  // Doing a cresc or decresc would take a subsequent run through the list,
  // and it takes analysis based on the timings of the notes, and not just the number of
  // notes over the range.  So,
  // 1.  Determine the total time duration from the start to the end,
  // 2.  For each note
  // 3.     calculate the percentage of the elapsed time to that note compared to the total time
  // 4.     Scale the velocity accordingly (Set the velocity to that fraction of the dynamic difference)


  // Apply shortcuts and absolute velocities
  //

//  Note currentNote;
//  Dynamic currentDynamic;
//  var currentTimeSig = TimeSig();
//  currentTimeSig.numerator = 4;
//  currentTimeSig.denominator = 4;
//  var currentTempo = Tempo();
//  currentTempo.noteDuration.firstNumber = 4;
//  currentTempo.noteDuration.secondNumber = 1;
//  currentTempo.bpm = 84;

  var previousNote = Note();
  previousNote.velocity = 64;
  previousNote.duration.firstNumber = 4;
  previousNote.duration.secondNumber = 1;
  previousNote.noteType = NoteType.leftTap;
  for (var element in scoreElements) {
    if (element.runtimeType != Note) {
      continue;
    }
    //print('    Element (note): $element');
    Note elementNote = element;
    elementNote.duration.firstNumber ??= previousNote.duration.firstNumber;
    elementNote.duration.secondNumber ??= previousNote.duration.secondNumber;
    elementNote.noteType ??= previousNote.noteType;
    if (element.noteType == NoteType.previousNoteDurationOrType) {
      elementNote.noteType = previousNote.noteType;
    }
    elementNote.velocity ??= previousNote.velocity;
    elementNote.swapHands();

    previousNote.duration = elementNote.duration;
    previousNote.noteType = elementNote.noteType;
    previousNote.velocity = elementNote.velocity;
    //print('Now element (note): $element');
  }

  print('\nNow list should have had shortcuts applied, but not dynamic ranges');
  for (var element in scoreElements) {
    print(element);
  }



}
