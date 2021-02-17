import 'package:petitparser/petitparser.dart';
import '../snarelang4.dart';

enum NoteArticulation {
  tenuto, // '_' small accent
  accent, // '>' normal accent
  marcato // '^' big accent
}

class NoteDuration { // change this to Duration if possible, which conflicts, I think with something
  static final DefaultFirstNumber = 4;
  static final DefaultSecondNumber = 1;
  // Maybe should change the following to doubles even though I wanted a ratio of two whole numbers?
  int firstNumber; // initialize????  // trying again 10/16/20
  int secondNumber;

  NoteDuration() {
    //print('in NoteDuration() constructor and will set firstNumber and secondNumber');
    // firstNumber = DefaultFirstNumber; // removing the setting of default values for now, because seems cleaner to use null, and not assume anything 11/4/2020
    // secondNumber = DefaultSecondNumber;
  }
//  num firstNumber; // should be an int?
//  num secondNumber;

//  NoteDuration(); // what?  Specifying an empty constructor?  Why?
//  NoteDuration(this.firstNumber, this.secondNumber);


  String toString() {
    return 'NoteDuration: $firstNumber:$secondNumber';
  }
}

num beatFractionToTicks(num beatFraction) {
  num durationInTicks = (Midi.ticksPerBeat * beatFraction).round();
//  var durationInTicks = (4 * Midi.ticksPerBeat * secondNumber / firstNumber).floor(); // why not .round()?
  return durationInTicks;
}

// add ensemble (SLOT) notes too, and rolls for loops
enum NoteType { // I think I can change this to "Type", because I don't think it's a keyword, but maybe it is
  tapRight,
  tapLeft,
  //tapUnison,
  flamRight, // in the future I'll have to record a much fatter flam to match how James plays them
  flamLeft,
  //flamUnison,
  openDragRight, // not a 2-stroke ruff, and not a dead drag.  No recording yet
  openDragLeft,
  dragRight,
  dragLeft,
  //dragUnison,
  buzzRight, // this can be looped
  buzzLeft, // this can be looped
  ruff3AltLeft,
  ruff3AltRight,
  // tuzzLeft,
  // tuzzRight,
  // tuzzUnison,
  ruff2Left, // how often do these show up?  Prob almost never.  Instead, an "open drag"
  ruff2Right,
  //ruff2Unison,
  ruff3Left,
  ruff3Right,
  //ruff3Unison,
  roll, // prob need to add roll recordings for snare and pad.  Currently only have SLOT recording I think
  tenorLeft,
  tenorRight,
  bassLeft,
  bassRight,
  metLeft,
  metRight,
  rest,
  previousNoteDurationOrType
}

class Note {
  NoteArticulation articulation;
  NoteDuration duration; // prob should have constructor construct one of these.  Of course.  also "SnareLangNoteNameValue".  can be used to calculate ticks, right?  noteTicks = (4 * ticksPerBeat) / SnareLangNoteNameValue
  NoteType noteType;
  int velocity;
  Dynamic dynamic;
  int noteNumber;
  int deltaTimeShiftForGraceNotes; // this is being used for gracenotes, and should probably be renamed to reflect that
  // int deltaTimeDelayForRandomSnareLine; // don't know how this relates to noteOffDeltaTimeShift
  int deltaTimeDelayForRandomSnareLine; // don't know how this relates to noteOffDeltaTimeShift
  //int midiNoteNumber; // experiment 9/20/2020  This would be the midi soundfont number, related to NoteType
  Note() {
    //print('in Note() constructor');
    duration = NoteDuration();
    articulation = null; // just for now
    noteType = NoteType.tapRight;  // correct here?  Maybe make this null too?
    velocity = 0;
    //dynamic = Dynamic.mf; What if we leave this null so that a value can be assigned later according to command line value, or something else?
    noteNumber = 0; // for now, new 10/4/2020
    deltaTimeShiftForGraceNotes = 0;
    deltaTimeDelayForRandomSnareLine = 0;
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
      case NoteType.ruff3AltRight:
        noteType = NoteType.ruff3AltLeft;
        break;
      case NoteType.ruff3AltLeft:
        noteType = NoteType.ruff3AltRight;
        break;
      // case NoteType.tuzzRight:
      //   noteType = NoteType.tuzzLeft;
      //   break;
      // case NoteType.tuzzLeft:
      //   noteType = NoteType.tuzzRight;
      //   break;
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
      case NoteType.tenorRight:
        noteType = NoteType.tenorLeft;
        break;
      case NoteType.tenorLeft:
        noteType = NoteType.tenorRight;
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
      case NoteType.metLeft:
        noteType = NoteType.metRight;
        break;
      case NoteType.metRight:
        noteType = NoteType.metLeft;
        break;
      case NoteType.rest:
        break;
      default:
        log.info('What was that note type?  $noteType');
        break;
    }
  }



  // void setNoteNumber(Voice voice, bool loopBuzzes, bool usePadSoundFont, int snareNumber) {
  void setNoteNumber(bool loopBuzzes, bool usePadSoundFont, int snareNumber) {
    // Hey not all notes are snare notes, so handle snare notes differently here.
    if (snareNumber == 0) {
      snareNumber = 5;
    }

    // Maybe this should be put into Note, even though it's a MIDI thing.
    // This stuff should be in a table, and be a mapping
    switch (noteType) { // hey noteType, would know if this is a snare????  And where is noteType coming from anyway?
      case NoteType.tapRight:
        noteNumber = 7;
        noteNumber += ((snareNumber - 1) * 12);
        // noteNumber = 127;
        break;
      case NoteType.tapLeft:
        noteNumber = 1;
        noteNumber += ((snareNumber - 1) * 12);
        // noteNumber = 126;
        break;
      case NoteType.flamRight:
        noteNumber = 8;
        noteNumber += ((snareNumber - 1) * 12);
        // noteNumber = 125;
        break;
      case NoteType.flamLeft:
        noteNumber = 2;
        noteNumber += ((snareNumber - 1) * 12);
        // noteNumber = 124;
        break;
      case NoteType.dragRight:
        noteNumber = 9;
        noteNumber += ((snareNumber - 1) * 12);
        // noteNumber = 123;
        break;
      case NoteType.dragLeft:
        noteNumber = 3;
        noteNumber += ((snareNumber - 1) * 12);
        // noteNumber = 122;
        break;
      case NoteType.buzzRight:
        noteNumber = 10;
        noteNumber += ((snareNumber - 1) * 12);
        // noteNumber = 121;
        break;
      case NoteType.buzzLeft:
        noteNumber = 4;
        noteNumber += ((snareNumber - 1) * 12);
        break;
      // case NoteType.ruff3AltRight:
      //   noteNumber = 117; // wrong.  For now just copying the "swiss ruff" which doesn't alternate
      //   break;
      // case NoteType.ruff3AltLeft:
      //   noteNumber = 116; // wrong, for now just copying the regular 3 stroke ruff
      //   break;
      case NoteType.ruff2Right:
        noteNumber = 11;
        noteNumber += ((snareNumber - 1) * 12);
        // noteNumber = 117;
        break;
      case NoteType.ruff2Left:
        noteNumber = 5;
        noteNumber += ((snareNumber - 1) * 12);
        // noteNumber = 116;
        break;
      case NoteType.ruff3Right:
        noteNumber = 11;
        noteNumber += ((snareNumber - 1) * 12);
        // noteNumber = 115;
        break;
      case NoteType.ruff3Left:
        noteNumber = 6;
        noteNumber += ((snareNumber - 1) * 12);
        // noteNumber = 114;
        break;
      // case NoteType.roll:
      //   noteNumber = 113;
      //   break;
      case NoteType.tenorRight:
        noteNumber = 122;
        // noteNumber = 109;
        break;
      case NoteType.tenorLeft:
        noteNumber = 121;
        // noteNumber = 108;
        break;
      case NoteType.bassRight:
        noteNumber = 124; // temp until find out soundfont problem
        // noteNumber = 111; // temp until find out soundfont problem
        break;
      case NoteType.bassLeft:
        noteNumber = 123;
        // noteNumber = 110;
        break;
      case NoteType.metLeft: // new
        // noteNumber = 112;
        noteNumber = 125;
        break;
      case NoteType.metRight: // new
        // noteNumber = 112;
        noteNumber = 126;
        break;
      case NoteType.rest:
        noteNumber = 0;
        break;
      default:
        log.fine('noteOnNoteOff, What the heck was that note? $noteType');
    }

    // Adjust the 'bank' or whatever by the snare number.  They're all 12 numbers away
    // from the previous or next snare.  Snares 1 - 9.  5 is in the middle.
    //noteNumber += ((snareNumber - 1) * 12); // but only if it's a snare, right?


    // FIX THIS LATER WHEN SOUND FONT HAS SOFT/MED/LOUD RECORDINGS.
    // if (soundFontHasSoftMediumLoudRecordings) {
    //   //
    //   // This is new, to take advantage of the 3 different volume levels in the recordings, which were separated by 10 note numbers.
    //   //
    //   if (velocity < 50) {
    //     log.finer('Note velocity is ${velocity}, so switched to quiet recording.');
    //     noteNumber -= 10;
    //   }
    //   else if (velocity > 100) {
    //     log.finer('Note velocity is ${velocity}, so switched to loud recording.');
    //     noteNumber += 10;
    //   }
    //   else {
    //     log.finer('Note velocity is ${velocity}, so did not switch recording.');
    //   }
    // }

    if (usePadSoundFont) {
      noteNumber += 108;
      // noteNumber -= 20;
    }
    return;
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
  log.finest('In Articulationparser');
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
  log.finest('In WholeNumberparser');
  final theWholeNumber = int.parse(value);
  //log.info('Leaving WholeNumberparser returning theWholeNumber $theWholeNumber');
  return theWholeNumber;
});

///
/// Duration Parser
///

Parser durationParser = (wholeNumberParser & (char(':').trim() & wholeNumberParser).optional()).map((value) { // trim?
  log.finest('In DurationParser');
  //print('in durationParser.');
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
Parser typeParser = pattern('TtFfDdZzXxYyVvRMNnBbr.').trim().map((value) { // trim?
  log.finest('In TypeParser');
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
      noteType = NoteType.ruff3AltRight;
      break;
    case 'x':
      noteType = NoteType.ruff3AltLeft;
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
      noteType = NoteType.metRight;
      break;
    case 'm': // I know it doesn't make sense to do M and m for left and right met.  They do sound slightly different, but should reserve for very different mets.
      noteType = NoteType.metLeft;
      break;
    case 'B': // wrong to give an instrument just a note type like this because then you can't specify flams, rolls, and other strokes
      noteType = NoteType.bassRight;
      break;
    case 'b':  // wrong to give an instrument just a note type like this because then you can't specify flams, rolls, and other strokes
      noteType = NoteType.bassLeft;
      break;
    case 'N': // wrong to give an instrument just a note type like this because then you can't specify flams, rolls, and other strokes
      noteType = NoteType.tenorRight;
      break;
    case 'n':  // wrong to give an instrument just a note type like this because then you can't specify flams, rolls, and other strokes
      noteType = NoteType.tenorLeft;
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
  log.finest('In NoteParser');
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
