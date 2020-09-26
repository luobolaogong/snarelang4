import 'package:petitparser/petitparser.dart';
import '../snarelang4.dart';

enum NoteArticulation {
  tenuto, // '_' small accent
  accent, // '>' normal accent
  marcato // '^' big accent
}

class NoteDuration { // change this to Duration if possible, which conflicts, I think with something
  int firstNumber; // initialize????
  int secondNumber;
//  int firstNumber = 4; // initialize????
//  int secondNumber = 1;

//  num firstNumber; // should be an int?
//  num secondNumber;

  NoteDuration();
//  NoteDuration(this.firstNumber, this.secondNumber);


  String toString() {
    return 'NoteDuration: $firstNumber:$secondNumber';
  }
}

int beatFractionToTicks(num beatFraction) {
  //int ticksPerBeat = 10080
  var durationInTicks = (Midi.ticksPerBeat * beatFraction).floor(); // why not .round()?
//  var durationInTicks = (4 * Midi.ticksPerBeat * secondNumber / firstNumber).floor(); // why not .round()?
  return durationInTicks;
}

// add ensemble (SLOT) notes too, and rolls for loops
enum NoteType { // I think I can change this to "Type", because I don't think it's a keyword, but maybe it is
  tapRight,
  tapLeft,
  tapUnison,
  flamRight,
  flamLeft,
  flamUnison,
  dragRight,
  dragLeft,
  dragUnison,
  buzzRight, // this can be looped
  buzzLeft, // this can be looped
  tuzzLeft,
  tuzzRight,
  tuzzUnison,
  ruff2Left,
  ruff2Right,
  ruff2Unison,
  ruff3Left,
  ruff3Right,
  ruff3Unison,
  roll, // prob need to add roll recordings for snare and pad.  Currently only have SLOT recording I think
  bassLeft,
  bassRight,
  met,
  rest,
  previousNoteDurationOrType
}
// enum NoteType { // I think I can change this to "Type", because I don't think it's a keyword, but maybe it is
//   rightTap,
//   leftTap,
//   rightFlam,
//   leftFlam,
//   rightDrag,
//   leftDrag,
//   rightBuzz,
//   leftBuzz,
//   leftTuzz,
//   rightTuzz,
//   leftRuff2,
//   rightRuff2,
//   leftRuff3,
//   rightRuff3,
//   rest,
//   previousNoteDurationOrType
// }

class Note {
  NoteArticulation articulation;
  NoteDuration duration; // prob should have constructor construct one of these.  Of course.  also "SnareLangNoteNameValue".  can be used to calculate ticks, right?  noteTicks = (4 * ticksPerBeat) / SnareLangNoteNameValue
  NoteType noteType = NoteType.tapRight;  // correct here?
  int velocity; // Perhaps this will go into MidiNote or something, new
  Dynamic dynamic; // gets a value during first pass through the score list
  //int midiNoteNumber; // experiment 9/20/2020  This would be the midi soundfont number, related to NoteType
  Note() {
    duration = NoteDuration();
  }

  String toString() {
    return 'Note: Articulation: $articulation, Duration: $duration, NoteType: $noteType, Dynamic: $dynamic';
  }

  swapHands() {
    switch (noteType) {
      case NoteType.tapRight:
        noteType = NoteType.tapLeft;
        break;
      case NoteType.tapLeft:
        noteType = NoteType.tapRight;
        break;
      case NoteType.flamRight:
        noteType = NoteType.flamLeft;
        break;
      case NoteType.flamLeft:
        noteType = NoteType.flamRight;
        break;
      case NoteType.dragRight:
        noteType = NoteType.dragLeft;
        break;
      case NoteType.dragLeft:
        noteType = NoteType.dragRight;
        break;
      case NoteType.buzzRight:
        noteType = NoteType.buzzLeft;
        break;
      case NoteType.buzzLeft:
        noteType = NoteType.buzzRight;
        break;
      case NoteType.tuzzRight:
        noteType = NoteType.tuzzLeft;
        break;
      case NoteType.tuzzLeft:
        noteType = NoteType.tuzzRight;
        break;
      case NoteType.ruff2Right:
        noteType = NoteType.ruff2Left;
        break;
      case NoteType.ruff2Left:
        noteType = NoteType.ruff2Right;
        break;
      case NoteType.ruff3Right:
        noteType = NoteType.ruff3Left;
        break;
      case NoteType.ruff3Left:
        noteType = NoteType.ruff3Right;
        break;
      case NoteType.bassRight:
        noteType = NoteType.bassLeft;
        break;
      case NoteType.bassLeft:
        noteType = NoteType.bassRight;
        break;
      case NoteType.previousNoteDurationOrType:
        log.info('Do what?????');
        break;
      case NoteType.roll:
        break;
      case NoteType.met:
        break;
      case NoteType.rest:
        break;
      default:
        log.info('What was that note type?  $noteType');
        break;
    }
  }

//  int durationToTicks(int ticksPerBeat, Duration snareLangNoteNameValue) {
//    int ticks = (4 * ticksPerBeat / snareLangNoteNameValue).floor(); // ????
//    return ticks;
//  }
}

///
/// ArticulationParser
///
Parser articulationParser = (
    char('^') | // maybe change these to pattern('/^>-_')
    char('>') |
    char('_') |
    char('-')    // get rid of this one
).trim().map((value) { // trim()?
  //log.info('\nIn Articulationparser');
  NoteArticulation articulation;
  switch (value) {
    case '_':
      articulation = NoteArticulation.tenuto;
      break;
    case '>':
      articulation = NoteArticulation.accent;
      break;
    case '^':
      articulation = NoteArticulation.marcato;
      break;
    default:
      log.info('What was that articulation? -->${value}<--');
  }
  //log.info('Leaving Articulationparser returning articulation $articulation');
  return articulation;
});



///
/// WholeNumberParser
///
Parser wholeNumberParser = digit().plus().flatten().trim().map((value) { // not sure need sideeffect true
  //log.info('\nIn WholeNumberparser');
  final theWholeNumber = int.parse(value);
  //log.info('Leaving WholeNumberparser returning theWholeNumber $theWholeNumber');
  return theWholeNumber;
});

///
/// Duration Parser
///

Parser durationParser = (wholeNumberParser & (char(':').trim() & wholeNumberParser).optional()).map((value) { // trim?
  //log.info('\nIn DurationParser');
  var duration = NoteDuration();
  duration.firstNumber = value[0];
  if (value[1] != null) { // prob unnec
    duration.secondNumber = value[1][1];
  }
  else {
    duration.secondNumber = 1; // wild guess that this fixes things
  }
  //log.info('Leaving DurationParser returning duration $duration');
  return duration;
});

///
/// TypeParser
///
Parser typeParser = pattern('TtFfDdZzXxYyVvRMBbr.').trim().map((value) { // trim?
  //log.info('\nIn TypeParser');
  NoteType noteType;
  switch (value) {
    case 'T':
      noteType = NoteType.tapRight;
      break;
    case 't':
      noteType = NoteType.tapLeft;
      break;
    case 'F':
      noteType = NoteType.flamRight;
      break;
    case 'f':
      noteType = NoteType.flamLeft;
      break;
    case 'D':
      noteType = NoteType.dragRight;
      break;
    case 'd':
      noteType = NoteType.dragLeft;
      break;
    case 'Z':
      noteType = NoteType.buzzRight;
      break;
    case 'z':
      noteType = NoteType.buzzLeft;
      break;
    case 'X':
      noteType = NoteType.tuzzRight;
      break;
    case 'x':
      noteType = NoteType.tuzzLeft;
      break;
    case 'Y':
      noteType = NoteType.ruff2Right;
      break;
    case 'y':
      noteType = NoteType.ruff2Left;
      break;
    case 'V':
      noteType = NoteType.ruff3Right;
      break;
    case 'v':
      noteType = NoteType.ruff3Left;
      break;
    case 'R':
      noteType = NoteType.roll;
      break;
    case 'M':
      noteType = NoteType.met;
      break;
    case 'B':
      noteType = NoteType.bassRight;
      break;
    case 'b':
      noteType = NoteType.bassLeft;
      break;
    case 'r':
      noteType = NoteType.rest;
      break;
    case '.':
      noteType = NoteType.previousNoteDurationOrType;
      break;
    default:
      log.info('Hey, this shoulda been a failure cause got -->${value[0]}<-- and will return null');
      break;
  }
  //log.info('Leaving TypeParser returning noteType $noteType');
  return noteType;
});

///
/// NoteParser
///
// A note must consist of A or B or C or AB or AC or BC or ABC
// Be careful of order!
Parser noteParser = (
    (articulationParser & durationParser & typeParser) |
    (articulationParser & durationParser) |
    (articulationParser & typeParser) |
    (durationParser & typeParser) |
    (articulationParser) |
    (durationParser) |
    (typeParser)
).trim().map((valuesOrValue) { // trim?
  //log.info('\nIn NoteParser');
  var note = Note();

  if (valuesOrValue == null) {  //
    log.info('does this ever happen?  Hope not.  Perhaps if no match?');
  }
  // Handle cases ABC, AB, AC, BC
  if (valuesOrValue is List) {
    for (var value in valuesOrValue) {
      if (value is NoteArticulation) { // A
        note.articulation = value;
      }
      else if (value is NoteDuration) { // B
        note.duration.firstNumber = value.firstNumber;
        note.duration.secondNumber = value.secondNumber; // check;
      }
      else if (value is NoteType) { // C
        note.noteType = value;
      }
    }
  }
  else { // Handle cases A, B, C
    if (valuesOrValue is NoteArticulation) { // A
      note.articulation = valuesOrValue;
    }
    else if (valuesOrValue is NoteDuration) { // B
      note.duration.firstNumber = valuesOrValue.firstNumber;
      note.duration.secondNumber = valuesOrValue.secondNumber; // check;
    }
    else if (valuesOrValue is NoteType) { // C
      note.noteType = valuesOrValue;
    }
  }

  //log.info('Leaving NoteParser returning note -->$note<--');
  return note;
});
