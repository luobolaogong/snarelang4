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
  TimeSig firstTimeSig;
  Tempo firstTempo;

  String toString() {
    return 'Score: ${elements.toString()}'; // could do a forEach and collect each element into a string with \n between each
  }

  static Result load(List<String> scoresPaths) {
    var scoresBuffer = StringBuffer();
    for (var filePath in scoresPaths) {
      log.fine('Parsing file $filePath');
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
    // Parse the score's text elements, notes and other stuff.  The intermediate parse results like Tempo and TimeSig
    // are in the list that is result.value, and processed later.
    //
    var result = scoreParser.parse(scoresBuffer.toString());
    if (result.isSuccess) {
      Score score = result.value;
      log.finer('parse succeeded.  This many elements: ${score.elements.length}\n'); // wrong
      for (var element in score.elements) {
        log.finest('\tAfter score raw parse, element list has this: $element');
      }
      log.fine('Done with first pass -- loaded raw notes, no shorthands yet.\n');
    }
    else {
      log.finer('Score parse failed.  Parse message: ${result.message}');
    }
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
    log.fine('In applyShorthands');
    var previousNote = Note();
    previousNote.dynamic = defaultNote.dynamic; // unnec
    previousNote.velocity = defaultNote.velocity; // unnec
    previousNote.articulation = defaultNote.articulation;
    previousNote.duration = defaultNote.duration;
    previousNote.noteType = defaultNote.noteType;
    log.finest('In top of Score.applyShorthands and just set "previousNote" to be the defaultNote passed in, which is $defaultNote');
    for (var element in elements) {
      //log.finest('In Score.applyShorthands(), and element is type ${element.runtimeType} ==> $element');
//      if (element is Dynamic) { // new
      if (element is Dynamic) { // new
        log.finest('In Score.applyShorthands(), and because element is ${element.runtimeType} and not a ramp, I am marking previousNote s dynamic to be same, and skipping');
        previousNote.dynamic = element;
        continue;
      }
      if (element is Ramp) {
        log.finest('Score.applyShorthands(), and element is a Ramp so skipping it.');
        continue;
      }
      if (element is Tempo) {
        log.finer('Score.applyShorthands(), Not applying shorthand to Tempo element.  Skipping it for now.');
        continue;
      }
      if (element is TimeSig) {
        log.finer('Score.applyShorthands(), Not applying shorthand to TimeSig element.  Skipping it for now.');
        continue;
      }
      if (!(element is Note)) {
        log.finer('Score.applyShorthands(), What is this element, which will be skipped for now?: ${element.runtimeType}');
        continue;
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
        log.finest('In Score.applyShorthands(), and since note was just a dot, just set element to have previousNote props, so element is now ${element}.');
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
        log.finest('In Score.applyShorthands(), and note was not just a dot, but wanted to make sure did the shorthand fill in, so now element is ${element}.');
      }
      //previousNote = element; // No.  Do a copy, not a reference.       watch for previousNoteDurationOrType
      previousNote.dynamic = element.dynamic;
      previousNote.velocity = element.velocity; // unnec?
      previousNote.articulation = element.articulation;
      previousNote.duration = element.duration;
      previousNote.noteType = element.noteType;

      log.finest('bottom of loop Score.applyShorthands(), just updated previousNote to point to be this ${previousNote}.');
    }
    log.finer('leaving Score.applyShorthands()\n');
    return;
  }


  void applyDynamics() {
    log.fine('In Score.applyDynamics()');
    // First set note velocities based on their dynamic values only.
    for (var element in elements) {
      if (!(element is Note)) {
        continue;
      }
      var note = element as Note; // this looks like a cast, which is what I want
      if (note.dynamic == null) {
        continue;
      }
      element.velocity = dynamicToVelocity(element.dynamic);
    }

    // 3.  Scan the elements list for ramp markers, and set their properties
    print('');
    log.finest('Score.applyDynamics(), Starting search for ramps and setting their values.  THIS MAY BE WRONG NOW THAT I''M APPLYING DYNAMICS DURING SHORTHAND PHASE');
    Ramp currentRamp;
    Dynamic mostRecentDynamic;
    num accumulatedDurationAsFraction = 0;
    //double currentRampDurationInTicks;
    var inRamp = false;
    for (var element in elements) {

      if (element is Note) {
        mostRecentDynamic = element.dynamic; // I know, hack,
        if (inRamp) {
          accumulatedDurationAsFraction += element.duration.secondNumber / element.duration.firstNumber;
          log.finest('Score.applyDynamics(), Doing ramps... This note is inside a ramp.  accumulated duration: $accumulatedDurationAsFraction');
        }
        else {
          log.finest('Score.applyDynamics(), Doing ramps... This note is NOT inside a ramp, so is ignored in this phase of setting ramp values.');
        }
        continue;
      }

      if (element is Ramp) {
        currentRamp = element;
        currentRamp.startDynamic = mostRecentDynamic;
        currentRamp.startVelocity = dynamicToVelocity(mostRecentDynamic);
        inRamp = true;
        log.finest('Score.applyDynamics(), Doing ramps while looping only for ramps... found ramp marker and starting a ramp.');
        continue;
      }

      if (element is Dynamic) {
        if (inRamp) {
          currentRamp.endDynamic = element;
          currentRamp.endVelocity = dynamicToVelocity(element);
          var accumulatedTicks = (Midi.ticksPerBeat * accumulatedDurationAsFraction).round();
          currentRamp.totalTicksStartToEnd = accumulatedTicks;
          currentRamp.slope = (currentRamp.endVelocity - currentRamp.startVelocity) / accumulatedTicks;    // rise / run
          log.finest('Score.applyDynamics(), Doing ramps... hit a Dynamic ($element) and currently in ramp, so ending ramp.  ramp slope: ${currentRamp.slope}, accumulatedTicks: $accumulatedTicks, accumulatedDurationAsFraction: $accumulatedDurationAsFraction');
          accumulatedDurationAsFraction = 0;

          currentRamp = null; // good idea?
          inRamp = false;
        }
        else {
          log.finest('Score.applyDynamics(), Doing ramps... hit a Dynamic but not in currently in ramp.');
        }
        mostRecentDynamic = element; // yeah, we can have a dynamic mark followed immediately by a ramp, and so the previous note will not have the new dynamic
        continue;
      }
      log.finest('Score.applyDynamics(), Doing ramps... found other kine element: ${element.runtimeType} and ignoring.');
    }
    log.finest('Score.applyDynamics(), Done finding and setting ramp values for entire score.\n');


    log.finest('Score.applyDynamics(), starting to adjust ramped notes...');
    // Adjust ramp note velocities based solely on their ramp and position in ramp, not articulations or type.
    // Each note already has a velocity.
    inRamp = false;
    var isFirstNoteInRamp = true;
    Note previousNote;
    num cumulativeDurationSinceRampStartNote = 0;
    for (var element in elements) {
      if (element is Ramp) {
        log.finest('\telement is a Ramp, so setting inRamp to true, and setting currentRamp to point to it.');
        inRamp = true;
        currentRamp = element;
        isFirstNoteInRamp = true;
        cumulativeDurationSinceRampStartNote = 0; // new
        continue;
      }
      if (element is Dynamic) {
        log.finest('\telement is a Dynamic, so resetting ramp related stuff.');
        inRamp = false;
        currentRamp = null;
        isFirstNoteInRamp = true;
        cumulativeDurationSinceRampStartNote = 0; // new
        continue;
      }
      if (element is Note) {
        log.finest('\telement is a Note...');
        var note = element as Note;
        // If a note is not in a ramp, skip it
        if (!inRamp) {
          log.finest('\t\tNote element is not in ramp, so skipping it.  But it has velocity ${note.velocity}');
          continue;
        }
        // We have a note in a ramp, and will now adjust its velocity solely by it's Ramp slope and starting time in the ramp.
        if (isFirstNoteInRamp) {
          log.finest('\t\tGot first note in ramp.  Will not adjust velocity, which is ${note.velocity}');
          previousNote = note;
          isFirstNoteInRamp = false;
        }
        else {
          // Get note's current time position in the ramp.
          log.finest('\t\tGot subsequent note in a ramp, so will calculate time position relative to first note by doing accumulation.');
          cumulativeDurationSinceRampStartNote += (previousNote.duration.secondNumber / previousNote.duration.firstNumber);
          log.finest('\t\t\tcumulativeDurationSinceRampStartNote: $cumulativeDurationSinceRampStartNote');
          var cumulativeTicksSinceRampStartNote = beatFractionToTicks(cumulativeDurationSinceRampStartNote);
          log.finest('\t\t\tcumulativeTicksSinceRampStartNote: $cumulativeTicksSinceRampStartNote and ramp slope is ${currentRamp.slope}');
          log.finest('\t\t\tUsing slope and position in ramp, wanna add this much to the velocity: ${currentRamp.slope * cumulativeTicksSinceRampStartNote}');
          note.velocity += (currentRamp.slope * cumulativeTicksSinceRampStartNote).round();
          log.finest('\t\t\tSo now this element has velocity ${note.velocity}');
          isFirstNoteInRamp = false;
          previousNote = note; // new
        }
      }
    }

    log.fine('Adjusting note velocities by articulation...');

    // Adjust note velocity based on articulation and type, and clamp.
    for (var element in elements) {
      if (!(element is Note)) {
        continue;
      }
      var note = element as Note;
      switch (note.articulation) {
        case NoteArticulation.tenuto: // '_'
          note.velocity += 16;
          break;
        case NoteArticulation.accent: // '>'
          note.velocity += 32;
          break;
        case NoteArticulation.marcato: // '^'
          note.velocity += 48;
          break;
      }

      switch (note.noteType) {
        case NoteType.leftTap:
        case NoteType.rightTap:
          break;
        case NoteType.leftFlam:
        case NoteType.rightFlam:
          note.velocity += 6;
          break;
        case NoteType.leftDrag:
        case NoteType.rightDrag:
          //note.velocity += 10; // commented out because of a video I saw which says it softens the note
          break;
        case NoteType.leftBuzz:
        case NoteType.rightBuzz:
          break;
        case NoteType.leftTuzz:
        case NoteType.rightTuzz:
          break;
        case NoteType.leftRuff2:
        case NoteType.rightRuff2:
          break;
        case NoteType.leftRuff3:
        case NoteType.rightRuff3:
          break;
        case NoteType.rest:
          break;
        default:
          log.warning('What the heck was that note? $note.type');
      }

      log.finest('adjusted velocity is ${note.velocity}');
      if (note.velocity > 127 || note.velocity < 0) {    // hmmmm did I screw this up by doing the cast with "as" to Note?  Lost velocity value????
        log.finest('Will clamp velocity because it is ${note.velocity}');
        note.velocity = note.velocity.clamp(0, 127);
        log.finest('clamped velocity is ${note.velocity}');
      }
    }


  }

//  void applyDynamics() {
//    Dynamic currentDynamic;
//    for (var element in elements) {
//      print('looking at $element to apply dynamics');
//    }
//    return;
//  }

  // These two are new.  We want to know the first tempo and time signature that is specified in the score.
  // There may not be either value, but if there is we want to set them for the midi file header, I think.
  // Not sure it's required though for the header.  Check on that.  Also, don't need to return it if it's
  // also available as part of the Score object.
  //
  TimeSig scanForFirstTimeSig() {
    for (var element in elements) {
      if (!(element is TimeSig)) {
        continue;
      }
      firstTimeSig = element;
      return firstTimeSig;
    }
    return null;
  }

  Tempo scanForFirstTempo() {
    for (var element in elements) {
      if (!(element is Tempo)) {
        continue;
      }
      firstTempo = element;
      return firstTempo;
    }
    return null;
  }



}

///
/// ScoreParser
///
//Parser scoreParser = ((tempoParser | dynamicParser | timeSigParser | noteParser).plus()).trim().end().map((values) {    // trim()?
// Parser scoreParser = ((timeSigParser | tempoParser | dynamicParser | rampParser | noteParser).plus()).trim().end().map((values) {    // trim()?
Parser scoreParser = ((commentParser | timeSigParser | tempoParser | dynamicParser | rampParser | noteParser).plus()).trim().end().map((values) {    // trim()?
  log.finer('In Scoreparser, will now add values from parse result list to score.elements');
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
  log.finest('Leaving Scoreparser returning score in parsed and objectified form.');
  return score;
});
