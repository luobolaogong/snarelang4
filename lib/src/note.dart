import 'package:petitparser/petitparser.dart';

enum NoteArticulation {
  marcato, // '^' big accent
  accent, // '>' normal accent
  tenuto // '_' small accent
}

class NoteDuration {
  num firstNumber; // should be an int?
  num secondNumber;

  NoteDuration();
//  NoteDuration(this.firstNumber, this.secondNumber);



  String toString() {
    return '$firstNumber:$secondNumber';
  }
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
  rest,
  previousNoteDurationOrType
}

class Note {
  NoteArticulation articulation;
  NoteDuration duration;
  NoteType noteType = NoteType.rightTap;  // correct here?
  int velocity;
  Note() {
    duration = NoteDuration();
  }
  String toString() {
    return 'Articulation: ${articulation}, Duration: ${duration}, NoteType: ${noteType}';
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
      case NoteType.previousNoteDurationOrType:
        print('Do what?????');
        break;
      case NoteType.rest:
        break;
      default:
        print('What was that note type?  $noteType');
        break;
    }
  }
}

///
/// ArticulationParser
///
Parser articulationParser = (
    char('^') | // maybe change these to pattern('\\^>-_')
    char('>') |
    char('_') |
    char('-')    // get rid of this one
).trim().map((value) { // trim()?
  //print('\nIn Articulationparser');
  NoteArticulation articulation;
  switch (value) {
    case '^':
      articulation = NoteArticulation.marcato;
      break;
    case '>':
      articulation = NoteArticulation.accent;
      break;
    case '_':
    case '-': // get rid of this one
      articulation = NoteArticulation.tenuto;
      break;
    default:
      print('What was that articulation? -->${value}<--');
  }
  //print('Leaving Articulationparser returning articulation $articulation');
  return articulation;
});



///
/// WholeNumberParser
///
Parser wholeNumberParser = digit().plus().flatten().trim().map((value) { // not sure need sideeffect true
  //print('\nIn WholeNumberparser');
  final theWholeNumber = int.parse(value);
  //print('Leaving WholeNumberparser returning theWholeNumber $theWholeNumber');
  return theWholeNumber;
});

///
/// Duration Parser
///

Parser durationParser = (wholeNumberParser & (char(':').trim() & wholeNumberParser).optional()).map((value) { // trim?
  //print('\nIn DurationParser');
  var duration = NoteDuration();
  duration.firstNumber = value[0];
  if (value[1] != null) { // prob unnec
    duration.secondNumber = value[1][1];
  }
  //print('Leaving DurationParser returning duration $duration');
  return duration;
});

///
/// TypeParser
///
Parser typeParser = pattern('TtFfDdZzr.').trim().map((value) { // trim?
  //print('\nIn TypeParser');
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
    case 'r':
      noteType = NoteType.rest;
      break;
    case '.':
      noteType = NoteType.previousNoteDurationOrType;
      break;
    default:
      print('Hey, this shoulda been a failure cause got -->${value[0]}<-- and will return null');
      break;
  }
  //print('Leaving TypeParser returning noteType $noteType');
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
  //print('\nIn NoteParser');
  var note = Note();

  if (valuesOrValue == null) {  //
    print('does this ever happen?  Hope not.  Perhaps if no match?');
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

  //print('Leaving NoteParser returning note -->$note<--');
  return note;
});
