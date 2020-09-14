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


enum NoteType { // I think I can change this to "Type", because I don't think it's a keyword, but maybe it is
  rightTap,
  leftTap,
  rightFlam,
  leftFlam,
  rightDrag,
  leftDrag,
  rightBuzz,
  leftBuzz,
  leftTuzz,
  rightTuzz,
  leftRuff2,
  rightRuff2,
  leftRuff3,
  rightRuff3,
  rest,
  previousNoteDurationOrType
}

class Note {
  NoteArticulation articulation;
  NoteDuration duration; // prob should have constructor construct one of these.  Of course.  also "SnareLangNoteNameValue".  can be used to calculate ticks, right?  noteTicks = (4 * ticksPerBeat) / SnareLangNoteNameValue
  NoteType noteType = NoteType.rightTap;  // correct here?
  int velocity; // Perhaps this will go into MidiNote or something, new
  Dynamic dynamic; // gets a value during first pass through the score list

  Note() {
    duration = NoteDuration();
  }

  String toString() {
    return 'Note: Articulation: $articulation, Duration: $duration, NoteType: $noteType, Dynamic: $dynamic';
  }

  swapHands() {
    switch (noteType) {
      case NoteType.rightTap:
        noteType = NoteType.leftTap;
        break;
      case NoteType.leftTap:
        noteType = NoteType.rightTap;
        break;
      case NoteType.rightFlam:
        noteType = NoteType.leftFlam;
        break;
      case NoteType.leftFlam:
        noteType = NoteType.rightFlam;
        break;
      case NoteType.rightDrag:
        noteType = NoteType.leftDrag;
        break;
      case NoteType.leftDrag:
        noteType = NoteType.rightDrag;
        break;
      case NoteType.rightBuzz:
        noteType = NoteType.leftBuzz;
        break;
      case NoteType.leftBuzz:
        noteType = NoteType.rightBuzz;
        break;
      case NoteType.rightTuzz:
        noteType = NoteType.leftTuzz;
        break;
      case NoteType.leftTuzz:
        noteType = NoteType.rightTuzz;
        break;
      case NoteType.rightRuff2:
        noteType = NoteType.leftRuff2;
        break;
      case NoteType.leftRuff2:
        noteType = NoteType.rightRuff2;
        break;
      case NoteType.rightRuff3:
        noteType = NoteType.leftRuff3;
        break;
      case NoteType.leftRuff3:
        noteType = NoteType.rightRuff3;
        break;
      case NoteType.previousNoteDurationOrType:
        log.info('Do what?????');
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
Parser typeParser = pattern('TtFfDdZzXxYyVvr.').trim().map((value) { // trim?
  //log.info('\nIn TypeParser');
  NoteType noteType;
  switch (value) {
    case 'T':
      noteType = NoteType.rightTap;
      break;
    case 't':
      noteType = NoteType.leftTap;
      break;
    case 'F':
      noteType = NoteType.rightFlam;
      break;
    case 'f':
      noteType = NoteType.leftFlam;
      break;
    case 'D':
      noteType = NoteType.rightDrag;
      break;
    case 'd':
      noteType = NoteType.leftDrag;
      break;
    case 'Z':
      noteType = NoteType.rightBuzz;
      break;
    case 'z':
      noteType = NoteType.leftBuzz;
      break;
    case 'X':
      noteType = NoteType.rightTuzz;
      break;
    case 'x':
      noteType = NoteType.leftTuzz;
      break;
    case 'Y':
      noteType = NoteType.rightRuff2;
      break;
    case 'y':
      noteType = NoteType.leftRuff2;
      break;
    case 'V':
      noteType = NoteType.rightRuff3;
      break;
    case 'v':
      noteType = NoteType.leftRuff3;
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
