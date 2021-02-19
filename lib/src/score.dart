import 'dart:io';
import 'dart:math';
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
/// will get applied, which are a product of the absolute and dynamicRampd dynamics
/// and note type.
///
/// Actually, a Score is perhaps made up of multiple "staves", or "tracks".  All the
/// tracks/staves are called a system, I think.
/// So, a score could be composed of a snare track and a tenor track, and a bass track,
/// and each is played simultaneously for a score.  The tempo and tempo changes will be
/// for the set of parallel staves.
///
/// So, to support this, I think SNL should allow for a new designation word, like
/// "track n", or "stave n", or "stave all" and maybe "track end".  I suppose "n" could
/// be the name of the stave.  A stave would correspond to a track, perhaps.  I don't
/// know what a channel is yet in this Dart library.  If you change the channel number
/// does it change the track?  I don't think so.  I think channel is perhaps the "transport"
/// mechanism, and I don't need to worry about it.  Perhaps it's ignored.  I don't know.
///
/// I collect events into an events list, and add that list to the midi lists of event lists.
/// I don't think each event list starts out with a name, does it?  I think the midi header
/// says something.
///
///
///
class Score {
  List elements = [];
  TimeSig firstTimeSig;
  Tempo firstTempo;
  num tempoScalar = 1; // new
  //Tempo latestTempo; // new
  Track firstTrack;
  Channel firstChannel; // not sure at all, just copying what I did with Track

  String toString() {
    return 'Score: ${elements.toString()}'; // could do a forEach and collect each element into a string with \n between each
  }

  static Result loadAndParse(List<String> scoresPaths, CommandLine commandLine) {
    log.finest('loadAndParse(), commandLine dynamic is ${commandLine.dynamic}');
    //
    // First load the raw score files, one at a time and check for errors and report to help pinpoint syntax error.
    // Also, I guess put it all together so can parse the string?
    // I may have screwed this up while editing.
    //
    var scoresStringBuffer = StringBuffer();
    for (var filePath in scoresPaths) {
      log.info('Loading file $filePath');
      var inputFile = File(filePath);
      if (!inputFile.existsSync()) {
        log.severe('File does not exist at "${inputFile.path}", exiting...');
        exit(42);
        continue;
      }
      var fileContents = inputFile.readAsStringSync(); // per line better?
      if (fileContents.isEmpty) {
        log.info('File ${filePath} appears to be empty.  Skipping it.');
        continue;
      }
      //
      // Do an initial parse for validity, exiting if failure, and throw away result no matter what.
      //
      log.finest('\t\tGunna do an initial parse just to check if its a legal file.');
      var result = scoreParser.parse(fileContents);
      if (result.isFailure) {
        log.severe('Failed to parse $filePath. Message: ${result.message}');
        var rowCol = result.toPositionString().split(':');
        log.severe('Check line ${rowCol[0]}, character ${rowCol[1]}');
        log.severe('Should be around this character: ${result.buffer[result.position]}');
        return result; // yeah I know the parent function will report too.  Fix later.
      }
      scoresStringBuffer.write(fileContents); // what the crap?  Why write this?  I thought we were only checking.
    }
    if (scoresStringBuffer.isEmpty) {
      log.severe('There is nothing to parse.  Exiting...');
      exit(42); // 42 is a joke
    }
    //
    // Parse the score's text elements, notes and other stuff.  The intermediate parse results like Tempo and TimeSig
    // are in the list that is result.value, and processed later.
    //
    log.finest('\t\there comes the real parse now, since we have a legal file.  I dislike this double thing.');
    var result = scoreParser.parse(scoresStringBuffer.toString());
    if (result.isSuccess) {
      Score score = result.value;
      log.finer('parse succeeded.  This many elements: ${score.elements.length}'); // wrong
      for (var element in score.elements) {
        log.finest('\tAfter score raw parse, element list has this: $element');
      }
      log.fine('Done with loadAndParse / first pass -- loaded raw notes, no shorthands yet.\n');
    }
    else {
      log.finer('Score parse failed.  Parse message: ${result.message}');
    }
    // And return the actual Result object, which contains a Score object, which contains elements.
    return result;
  }

  ///
  /// Apply shorthands, meaning that missing properties of duration and type for a text note get filled in from the previous
  /// note.  This would include notes specified by ".", which means use previous note's duration and type.
  /// Also, when the note type is not specified, swap hand order from the previous note.
  /// This also sets the dynamic field, but not velocities.
  /// Also, if there's a /dd (default dynamic), it is replaced by the default dynamic value.
  void applyShorthands(CommandLine commandLine) {
    log.fine('In applyShorthands, AND THIS IS PROBABLY WHERE THERE IS A PROBLEM WITH DYNAMICS NOT WORKING RIGHT!!!!!!!!!!!!!!!!!!!!!!11');
    var previousNote = Note();
    // I don't like the way this is done to account for a first note situation.  Perhaps use a counter and special case for first note
    previousNote.dynamic = commandLine.dynamic; // unnec???
    for (var elementIndex = 0; elementIndex < elements.length; elementIndex++) {
      if (elements[elementIndex] is Dynamic) { // new
        if (elements[elementIndex] == Dynamic.dd) {
          elements[elementIndex] = commandLine.dynamic;
        }
        log.finer('In Score.applyShorthands(), and because element is ${elements[elementIndex].runtimeType} and not a dynamicRamp, I am marking previousNote s dynamic to be same, and skipping');
        previousNote.dynamic = elements[elementIndex];
        continue;
      }
      if (elements[elementIndex] is Note) {
        var note = elements[elementIndex] as Note; // new
        // So this next stuff assumes element is a Note, and it could be a rest
        // This section is risky. This could contain bad logic:
        //
        // Usually to repeat a previous note we just have '.' by itself, but we could have
        // '4.' to mean quarter note, but same note type as before, or
        // '.T' to mean same duration as previous note, but make this one a right tap, or
        // '>.' to mean same note as before, but accented this time.
        //
        if (note.noteType == NoteType.previousNoteDurationOrType) { // I think this means "." dot.  Why not just call it "dot"?
          note.duration = previousNote.duration;
          note.noteType = previousNote.noteType;
          note.dynamic = previousNote.dynamic;
          note.swapHands(); // check that nothing stupid happens if note is a rest or dynamic or something else
          log.finest('In Score.applyShorthands(), and since note was just a dot, just set note to have previousNote props, so note is now ${note}.');
        }
        else {
//        note.duration ??= previousNote.duration;
          note.duration.firstNumber ??= previousNote.duration.firstNumber; // new
          note.duration.secondNumber ??= previousNote.duration.secondNumber;
          if (note.noteType == null) { // does this ever happen?
            note.noteType = previousNote.noteType;
            note.swapHands();
          }
          note.dynamic ??= previousNote.dynamic; // Even if this is a rest I think we might have to do this to make "previous" work.  Yup.
          // if (note.noteType != NoteType.rest) { // new 10/24/2020.  No, I think we have to have dynamic for a rest so that "previous" works.
          //   note.dynamic ??= previousNote.dynamic; // only if note.dynamic is null.  Not same as above.
          // }
          log.finest('In Score.applyShorthands(), and note was not just a dot, but wanted to make sure did the shorthand fill in, so now note is ${note}.');
        }
        //previousNote = note; // No.  Do a copy, not a reference.       watch for previousNoteDurationOrType
        previousNote.dynamic = note.dynamic; // redundant or not?
        previousNote.velocity = note.velocity; // unnec?
        previousNote.articulation = note.articulation;
        previousNote.duration = note.duration;
        previousNote.noteType = note.noteType;

        log.finest('bottom of loop Score.applyShorthands(), just updated previousNote to point to be this ${previousNote}.');
      }
     }
    log.finest('leaving Score.applyShorthands()\n');
    return;
  }

  // This is a strange method.  Seems dependent upon elements in the list, and also it
  // has a continue at the end of the for loop.  But also fillInTempoDuration is only for triplet tempos???
  void correctTripletTempos(CommandLine commandLine) {
    latestTimeSig = commandLine.timeSig;
    for (var element in elements) {
      if (element is TimeSig) {
        latestTimeSig = element; // latestTimeSig is a global defined in timesig.dart file
        continue;
      }
      if (element is Tempo) {
        Tempo.fillInTempoDuration(element, latestTimeSig); // Yes, I know latestTimeSig is a global, just a test.  There's no guarantee commandLine.timeSig or tempo will have values that represent what's in the file
        continue;
      }
      // if (element is TimeSig) {
      //   latestTimeSig = element; // latestTimeSig is a global defined in timesig.dart file
      //   continue;
      // }
      //continue; // what?
    }
    return;
  }
  // This is a big one.  Maybe break it up?
  // Looks like several phases to this.
  void applyDynamics() {
    log.fine('In Score.applyDynamics()');
    // For each note in the list set the velocity field based on the dynamic field, which is strange, because why not do it initially?
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

    log.finest('gunna start looking for dynamic ramp markers and set their values');
    // Scan the elements list for dynamicRamp markers, and set their properties
    log.finest('');
    log.finest('Score.applyDynamics(), Starting search for dynamicRamps and setting their values.  THIS MAY BE WRONG NOW THAT I''M APPLYING DYNAMICS DURING SHORTHAND PHASE');
    DynamicRamp currentDynamicRamp;
    Dynamic mostRecentDynamic;
    num accumulatedDurationAsFraction = 0;
    var inDynamicRamp = false;
    for (var element in elements) {

      if (element is Note) {
        mostRecentDynamic = element.dynamic; // I know, hack,
        if (inDynamicRamp) {
          accumulatedDurationAsFraction += element.duration.secondNumber / element.duration.firstNumber;
          log.finest('Score.applyDynamics(), Doing dynamicRamps... This note is inside a dynamicRamp.  accumulated duration: $accumulatedDurationAsFraction');
        }
        else {
          log.finest('Score.applyDynamics(), Doing dynamicRamps... This note is NOT inside a dynamicRamp, so is ignored in this phase of setting dynamicRamp values.');
        }
        continue;
      }

      if (element is DynamicRamp) {
        currentDynamicRamp = element;
        currentDynamicRamp.startDynamic = mostRecentDynamic;
        currentDynamicRamp.startVelocity = dynamicToVelocity(mostRecentDynamic);
        inDynamicRamp = true;
        log.finest('Score.applyDynamics(), Doing dynamicRamps while looping only for dynamicRamps... found dynamicRamp marker and starting a dynamicRamp.');
        continue;
      }

      if (element is Dynamic) {
        if (inDynamicRamp) {
          currentDynamicRamp.endDynamic = element;
          currentDynamicRamp.endVelocity = dynamicToVelocity(element);
          var accumulatedTicks = (Midi.ticksPerBeat * accumulatedDurationAsFraction).round();
          currentDynamicRamp.totalTicksStartToEnd = accumulatedTicks;
          currentDynamicRamp.slope = (currentDynamicRamp.endVelocity - currentDynamicRamp.startVelocity) / accumulatedTicks;    // rise / run
          log.finest('Score.applyDynamics(), Doing dynamicsDynamicRamps... hit a Dynamic ($element) and currently in dynamicRamp, so ending dynamicRamp.  dynamicRamp slope: ${currentDynamicRamp.slope}, accumulatedTicks: $accumulatedTicks, accumulatedDurationAsFraction: $accumulatedDurationAsFraction');
          accumulatedDurationAsFraction = 0;

          currentDynamicRamp = null; // good idea?
          inDynamicRamp = false;
        }
        else {
          log.finest('Score.applyDynamics(), Doing dynamicRamps... hit a Dynamic but not in currently in dynamicRamp.');
        }
        mostRecentDynamic = element; // yeah, we can have a dynamic mark followed immediately by a dynamicRamp, and so the previous note will not have the new dynamic
        continue;
      }
      log.finest('Score.applyDynamics(), Doing dynamicRamps... found other kine element: ${element.runtimeType} and ignoring.');
    }
    log.finer('Score.applyDynamics(), Done finding and setting dynamicRamp values for entire score.\n');


    log.finer('Score.applyDynamics(), starting to adjust dynamicRamped notes...');
    // Adjust dynamicRamp note velocities based solely on their dynamicRamp and position in dynamicRamp, not articulations or type.
    // Each note already has a velocity.
    inDynamicRamp = false;
    var isFirstNoteInDynamicRamp = true;
    Note previousNote;
    num cumulativeDurationSinceDynamicRampStartNote = 0;
    var elementCtr = 0; // test to see if can help pinpoint dynamic ramp mistake in score
    for (var element in elements) {
      elementCtr++;
      if (element is DynamicRamp) {
        log.finest('\telement $elementCtr is a DynamicRamp, so setting inDynamicRamp to true, and setting currentDynamicRamp to point to it.');
        inDynamicRamp = true;
        currentDynamicRamp = element;
        isFirstNoteInDynamicRamp = true;
        cumulativeDurationSinceDynamicRampStartNote = 0; // new
        continue;
      }
      if (element is Dynamic) {
        log.finest('\telement $elementCtr is a Dynamic, so resetting dynamicRamp related stuff.');
        inDynamicRamp = false;
        currentDynamicRamp = null;
        isFirstNoteInDynamicRamp = true;
        cumulativeDurationSinceDynamicRampStartNote = 0; // new
        continue;
      }
      if (element is Note) {
        log.finest('\telement is a Note...');
        var note = element as Note;
        // If a note is not in a dynamicRamp, skip it
        if (!inDynamicRamp) {
          log.finest('\t\tNote element $elementCtr is not in dynamicRamp, so skipping it.  But it has velocity ${note.velocity}');
          continue;
        }
        // We have a note in a dynamicRamp, and will now adjust its velocity solely by it's DynamicRamp slope and starting time in the dynamicRamp.
        if (isFirstNoteInDynamicRamp) {
          log.finest('\t\tGot first note (#$elementCtr ) in dynamicRamp.  Will not adjust velocity, which is ${note.velocity}');
          previousNote = note;
          isFirstNoteInDynamicRamp = false;
        }
        else {
          // Get note's current time position in the dynamicRamp.
          log.finest('\t\tGot subsequent note (#$elementCtr) in a dynamicRamp, so will calculate time position relative to first note by doing accumulation.');
          cumulativeDurationSinceDynamicRampStartNote += (previousNote.duration.secondNumber / previousNote.duration.firstNumber);
          log.finest('\t\t\tcumulativeDurationSinceRampStartNote: $cumulativeDurationSinceDynamicRampStartNote');
          var cumulativeTicksSinceDynamicRampStartNote = beatFractionToTicks(cumulativeDurationSinceDynamicRampStartNote);
          log.finest('\t\t\tcumulativeTicksSinceDynamicRampStartNote: $cumulativeTicksSinceDynamicRampStartNote and dynamicsDynamicRamp slope is ${currentDynamicRamp.slope}');
          if (currentDynamicRamp.slope == null) { // hack
            log.warning('Still in dynamic ramp, right?  Well, got a null at note element $elementCtr, Note duration: ${note.duration}');
            log.severe('Error in dynamic ramp.  Not sure what to do.  Did we have a ramp start, and no ramp end?');
          }
          else {
            log.finest('\t\t\tUsing slope and position in dynamicRamp, wanna add this much to the velocity: ${currentDynamicRamp.slope *
                cumulativeTicksSinceDynamicRampStartNote}');
            note.velocity += (currentDynamicRamp.slope * cumulativeTicksSinceDynamicRampStartNote).round();
            log.finest('\t\t\tSo now this element has velocity ${note.velocity}');
            isFirstNoteInDynamicRamp = false;
            previousNote = note; // new
          }
        }
      }
    }

    log.finer('Adjusting note velocities by articulation...');

    // Adjust note velocity based on articulation and type, and then clamp.
    // No, adjust note velocity based on dynamic and articulation together, and then clamp if nec.
    for (var element in elements) {
      if (!(element is Note)) {
        continue;
      }
      if (element.noteType == NoteType.rest) {
        continue;
      }
      var note = element as Note;
      if (note.articulation != null) {
        //print('Hey watchit, because we already did note ramp calculations to set velocities, so the following should account for velocities, not dynamics.');
        log.finest('\t\tthis note has an articulation (${note.articulation}), and dynamic (${note.dynamic}), and it has current velocity of ${note.velocity}');
        note.velocity = adjustVelocityByDynamicAndArticulation(note);
        log.finest('\t\tNow it has current velocity of ${note.velocity}');
      }

      // This section is questionable.  Should flams be accented normally?
      // I don't think so.  This section maybe could be used to adjust for
      // bad sound font recordings, but only as a hack.  Fix the recordings.
      switch (note.noteType) {
        case NoteType.tapLeft:
          note.velocity += 4; // This is a guess.  I think generally left is softer
          break;
        case NoteType.tapRight:
          break;
        case NoteType.flamLeft:
        case NoteType.flamRight:
          //note.velocity += 10; // was 6
          note.velocity += 0; // was 6
          break;
        case NoteType.dragLeft:
        case NoteType.dragRight:
          //note.velocity += 10; // commented out because of a video I saw which says it softens the note
          //note.velocity -= 10; // No, too soft according to how James Laughlin plays.  Plays it like a flam in volume
          // note.velocity += 12; // this is a bit softer than a flam due to the recording volume
          note.velocity += 15; // this is a bit softer than a flam due to the recording volume
          break;
        case NoteType.buzzLeft:
        case NoteType.buzzRight:
          note.velocity += 6; // new 12/13/2020
          break;
        case NoteType.ruff3AltLeft:
        case NoteType.ruff3AltRight:
        note.velocity += 20; // recorded too softly
          break;
        // case NoteType.tuzzLeft:
        // case NoteType.tuzzRight:
        //   break;
        case NoteType.ruff2Left:
        case NoteType.ruff2Right:
          break;
        case NoteType.ruff3Left:
        case NoteType.ruff3Right:
        note.velocity += 15; // recorded too softly
          break;
        case NoteType.tenorLeft:
        case NoteType.tenorRight:
          note.velocity += 0; // was 20
          break;
        case NoteType.bassLeft:
        case NoteType.bassRight:
          note.velocity += 0; // was 40
          break;
        case NoteType.roll:
          break;
        case NoteType.metLeft:
        case NoteType.metRight:
          // note.velocity -= 40;
          note.velocity -= 10;
          break;
        case NoteType.rest:
          log.warning('hey man we got a rest.  Why should there be a velocity for it?');
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

    return;
  }


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

  Track scanForFirstTrack() {
    for (var element in elements) {
      if (!(element is Track)) {
        continue;
      }
      firstTrack = element;
      return firstTrack;
    }
    return null;
  }
  Channel scanForFirstChannel() {
    for (var element in elements) {
      if (!(element is Channel)) {
        continue;
      }
      firstChannel = element;
      return firstChannel;
    }
    return null;
  }


  // check that this does what I think it is supposed to do
  void scaleTempos(CommandLine commandLine) {
    //Tempo newTempo;
    for (var element in elements) { // better check to see that element in elements really changes.
      if (element is Tempo) {
        var tempo = element as Tempo;
        //print('scaleTempos(), element is currently: $tempo and scalar is ${commandLine.tempoScalar}');
        tempo = Tempo.scaleThis(tempo, commandLine.tempoScalar); // WHY CALL  THIS IF scalar won't change anything? like 1.0
        element.bpm = tempo.bpm; // this is awkward
        log.fine('scaleTempos(), now element is $element');
      }
    }
  }

  // At this time the note should have a dynamic and an articulation.
  // There are many ways to do this.  This will probably be quick/dirty way.
  // Note that because we already did note ramp calculations to set velocities, these supplemental velocity boosts might be off.')
  num adjustVelocityByDynamicAndArticulation(Note note) {
    //print('\t\tHEY HEY HEY HERE COMES AN ADJUSTMENT BY ARTICULATION BASED ON CURRENT DYNAMIC!');
    // Figure this out later.  Make a function that adds the right amount, or recalculates the velocity.
    //     print('\t\t\t\tnote dynamic: ${note.dynamic}, which has index of ${note.dynamic.index}');
    //     print('\t\t\t\tand that has a dynamic value of ${dynamicToVelocity(note.dynamic)}');
    //     print('\t\t\t\twhich is this percentage of the loudest/127: ${dynamicToVelocity(note.dynamic) * 100 / 127}');
    //     num newVelocity = 0;
    //     num whatever;
    // switch (note.articulation) {
    //   case NoteArticulation.tenuto:
    //     var whatever = note.dynamic.index + 1;
    //     newVelocity = dynamicToVelocity(Dynamic.values[whatever]);
    //     break;
    //   case NoteArticulation.accent:
    //     var whatever = max(note.dynamic.index + 2, Dynamic.values.length);
    //     newVelocity = dynamicToVelocity(Dynamic.values[whatever]);
    //     break;
    //   case NoteArticulation.tenuto:
    //     var whatever = note.dynamic.index + 1;
    //     newVelocity = dynamicToVelocity(Dynamic.values[whatever]);
    //     break;
    // }
    num newVelocity;
    switch (note.dynamic) {
      case Dynamic.ppp:
        if (note.articulation == NoteArticulation.tenuto) {
          return note.velocity + 24; // was 14
        }
        if (note.articulation == NoteArticulation.accent) {
          return note.velocity + 34; // was 24
        }
        if (note.articulation == NoteArticulation.marcato) {
          return note.velocity + 54; // was 44
        }
        log.warning('what happened?');
        break;
      case Dynamic.pp:
        if (note.articulation == NoteArticulation.tenuto) {
          return note.velocity + 28; // was 20
        }
        if (note.articulation == NoteArticulation.accent) {
          return note.velocity + 40; // was 32
        }
        if (note.articulation == NoteArticulation.marcato) {
          return note.velocity + 52; // was 44
        }
        log.warning('what happened?');
        break;
      case Dynamic.p:
        if (note.articulation == NoteArticulation.tenuto) {
          return note.velocity + 31; // was 25
        }
        if (note.articulation == NoteArticulation.accent) {
          return note.velocity + 42; // was 36
        }
        if (note.articulation == NoteArticulation.marcato) {
          return note.velocity + 54; // was 48
        }
        log.warning('what happened?');
        break;
      case Dynamic.mp:
        if (note.articulation == NoteArticulation.tenuto) {
          return note.velocity + 28; // was 24
        }
        if (note.articulation == NoteArticulation.accent) {
          return note.velocity + 38; // was 34
        }
        if (note.articulation == NoteArticulation.marcato) {
          return note.velocity + 54; // was 50 // was 44, james plays loud
        }
        log.warning('what happened?');
        break;
      case Dynamic.mf:
        if (note.articulation == NoteArticulation.tenuto) {
          return note.velocity + 18; // was 16
        }
        if (note.articulation == NoteArticulation.accent) {
          return note.velocity + 28; // was 26
        }
        if (note.articulation == NoteArticulation.marcato) {
          return note.velocity + 52; // was 50 // was 36
        }
        log.warning('what happened?');
        break;
      case Dynamic.f:
        if (note.articulation == NoteArticulation.tenuto) {
          return note.velocity + 14; // was 12// was 8
        }
        if (note.articulation == NoteArticulation.accent) {
          return note.velocity + 22; // was 20 // was 14
        }
        if (note.articulation == NoteArticulation.marcato) {
          return note.velocity + 36; // was 32, was 30 // was 18,24
        }
        log.warning('what happened?');
        break;
      case Dynamic.ff:
        if (note.articulation == NoteArticulation.tenuto) {
          return note.velocity + 5; // was 3 // was 1
        }
        if (note.articulation == NoteArticulation.accent) {
          return note.velocity + 7; // was 5 // was 3
        }
        if (note.articulation == NoteArticulation.marcato) {
          return note.velocity + 16; // was 12, was 10 // was 5 clips?
        }
        log.warning('what happened?');
        break;
      case Dynamic.fff: // if fff is at 127 then these numbers will just get clipped:
        if (note.articulation == NoteArticulation.tenuto) {
          return note.velocity + 5; // was 3// was 1
        }
        if (note.articulation == NoteArticulation.accent) {
          return note.velocity + 7; // was 5 // was 3
        }
        if (note.articulation == NoteArticulation.marcato) {
          return note.velocity + 10; // was 8 // was 5, clips for sure, right?
        }
        log.warning('what happened?');
        break;
      default:
        log.warning('uh oh');
    }
    return newVelocity;
  }

  ///
  /// This is experimental.  The idea here is to help a snare line of up to
  /// 9 snares sound like a snare line rather than a single snare, by applying
  /// random amounts of inaccuracies in timing to notes.  Every note will have
  /// an amount of delay, from 0 to X units.  Not sure what those units are.
  /// You'd think it would be in milliseconds (1/1000 of a second, or 0.001s)
  /// If playing at 120 bpm, a 32nd note is 0.03125s    A 64th note would be
  /// 0.015625.  A 128th note would be  0.007812, or about 8 milliseconds.
  /// So, I'd guess that errors in playing should be less than 8ms.  Of course
  /// unfortunately midi doesn't take milliseconds.  I think it takes ticks, and
  /// tick durations are based on tempo, I think.  So, that's not cool.  Anyway,
  /// this method should probably just do a random number generation from 0 to 8
  /// milliseconds to add to the note, and then subtract that same amount to the
  /// other end, so it's not cumulative.  So maybe you add the random delay to
  /// the NoteOnEvent.deltaTime, and subtract it off the NoteOffEvent.deltaTime.
  /// Maybe I'll add those things to the Note class just for this experiment to make
  /// it easier than dealing with durations or something.
  void addDelaysForSnareNotesForDrumLine(CommandLine commandLine) {
    log.fine('In addRandomDelaysForSnareNotesForDrumLine()');

    var random = Random();
    var randomDelayForANote = 0;

    //var previousNote = Note();
    //previousNote.deltaTimeDelayForRandomSnareLine = 0;
    Tempo mostRecentTempo;
    TimeSig mostRecentTimeSig; // assuming we'll hit one before we hit a note.
    num scaleAdjustForNon44 = 1.0;
    var snareNumber = 5; // ??
    //var nSnares = 5; // what??????
    var nSnares = commandLine.nSnares ?? 1;
    for (var element in elements) {

      if (element is TimeSig) {
        mostRecentTimeSig = element;
        if (mostRecentTimeSig.denominator == 1) { // total hack
          scaleAdjustForNon44 = 4.0; // total hack
        }
        else if (mostRecentTimeSig.denominator == 2) { // total hack
          scaleAdjustForNon44 = 2.0; // total hack
        }
        else if (mostRecentTimeSig.denominator == 8 && mostRecentTimeSig.numerator % 3 == 0) { // total hack
          scaleAdjustForNon44 = 1.5; // total hack, and a big guess
        }
        else if (mostRecentTimeSig.denominator == 8 && mostRecentTimeSig.numerator % 3 != 0) { // total hack
          scaleAdjustForNon44 = 0.5; // total hack
        }
        else if (mostRecentTimeSig.denominator == 16) { // total hack
          scaleAdjustForNon44 = 0.25; // total hack
        }
        else {
          scaleAdjustForNon44 = 1.0;
        }
        continue; // added 2/7/21
      }

      if (element is Tempo) {
        mostRecentTempo = element;
        continue;
      }

      if (element is Track) { // I do not trust the logic in this section.  Revisit later.  Does this mean that we'd better have a Track command at the start of a score?????????????  Bad idea/dependency
        var thisTrack = element as Track;
        switch (thisTrack.id) {
          case TrackId.snare:
            snareNumber = 5;
            break;
          case TrackId.snare1:
            snareNumber = 1;
            break;
          case TrackId.snare2:
            snareNumber = 2;
            break;
          case TrackId.snare3:
            snareNumber = 3;
            break;
          case TrackId.snare4:
            snareNumber = 4;
            break;
          case TrackId.snare5:
            snareNumber = 5;
            break;
          case TrackId.snare6:
            snareNumber = 6;
            break;
          case TrackId.snare7:
            snareNumber = 7;
            break;
          case TrackId.snare8:
            snareNumber = 8;
            break;
          case TrackId.snare9:
            snareNumber = 9;
            break;
          default:
          print('Huh?  Whats this element.id?: ${thisTrack.id}');
            break;
        }
        continue;
      }

      else if (element is Note) {
        var note = element as Note; // unnec cast, it says, but I want to


        // The random value 200 is found by trial and error.  If smaller it doesn't sound as much of a line, and flams/drags/ruffs stand out and if too big, it's muddled.  So this is a quick setting, and depends on other factors.
        // note.deltaTimeDelayForRandomSnareLine = (scaleAdjustForNon44 * random.nextInt(200) / (100 / mostRecentTempo.bpm)).round(); // The 180 is based on a tempo of 100bpm.  What does this do for dotted quarter tempos?
        // note.deltaTimeDelayForRandomSnareLine = (scaleAdjustForNon44 * random.nextInt(150) / (100 / mostRecentTempo.bpm)).round(); // The 180 is based on a tempo of 100bpm.  What does this do for dotted quarter tempos?

        // note.deltaTimeDelayForRandomSnareLine = ((scaleAdjustForNon44 * 100 * (snareNumber - 1)) / (100 / mostRecentTempo.bpm)).round(); // The 180 is based on a tempo of 100bpm.  What does this do for dotted quarter tempos?
        // print('mostRecentTempo.bpm: ${mostRecentTempo.bpm}');
        // print('scaleAdjustForNon44: $scaleAdjustForNon44');
        // num factorBasedOn100Bpm = 100 / mostRecentTempo.bpm;
        // print('factorBasedon108Bpm: $factorBasedOn100Bpm');
        // var scaleAdjustForNon44Times100TimesSnareNumMinus1 = (scaleAdjustForNon44 * 25 * (snareNumber - 1));
        // print('scaleAdjustForNon44Times100TimesSnareNumMinus1: $scaleAdjustForNon44Times100TimesSnareNumMinus1');
        // var snareNumTimeDelayScaledBasedOn100Bpm = (scaleAdjustForNon44Times100TimesSnareNumMinus1 / factorBasedOn100Bpm).round();
        // print('snareNumTimeDelayScaledBasedOn100Bpm: $snareNumTimeDelayScaledBasedOn100Bpm');
        // note.deltaTimeDelayForRandomSnareLine = snareNumTimeDelayScaledBasedOn100Bpm; // The 180 is based on a tempo of 100bpm.  What does this do for dotted quarter tempos?
        note.deltaTimeDelayForRandomSnareLine = calcSoundDelayFromCenter(snareNumber, mostRecentTempo.bpm, scaleAdjustForNon44, nSnares); // The 180 is based on a tempo of 100bpm.  What does this do for dotted quarter tempos?

        //print('\t\trandomDelayForANote: $randomDelayForANote');
        //print('delay for snare $snareNumber is ${note.deltaTimeDelayForRandomSnareLine} and for grace notes: ${note.deltaTimeShiftForGraceNotes}');


        //previousNote = note; // probably wrong.  Just want to work with pointers
        continue;
      }
    }
    log.finest('Leaving addRandomDelaysForSnareNotesForDrumLine(), and updated notes to have delta time shifts to account for simulating an inexact drumline.');
    return;
  }

  // The idea here is to calculate a time difference from the center snare drum, as if you
  // were the center snare.  The time delay from the furthest snare would be very small, but
  // I think it is possible to detect it.  For example, if you have drummers packed into a
  // football field, you'll hear a rolling roar of snares if they try to play a single tap at
  // the same time.
  // But one problem with making the left side and the right side equal in time delay is that
  // they cancel out, and make a single sound as if it's in the middle, and then there's
  // no stereo sound.  So, I'm thinking that if I stagger out the differences so that snares 1 and 9
  // are not exactly the same in "distance" from the center, you'll hear them both on left and right.
  // I'm not sure that's correct, but the goal is to stagger the delays.  For example,
  // assume snare 5 (middle) is exactly with the metronome.  Snares 4 and snare 6 would be on
  // either side, equal distance, and their sound would normally be "1 unit" away.  And snares
  // 3 and 7 would be 2 units away.  And snares 2 and 8 would be 3 units away, and finally,
  // snares 1 and 9 would be 4 units away from the center.  I think if everyone played exactly
  // according to the metronome, there'd be a fat sound, but it would be in the center of
  // the stereo image.  But maybe if the snares 4 and 6 were 0.9 and 1.1 units away, and
  // snares 3 and 7 were 1.9 and 2.1 units away (or 2.1 and 1.9), etc, then you'd get the
  // fat sound, but you'd also get more of a stereo image.
  //
  // Time for bed.  Finish this later
  //
  int calcSoundDelayFromCenter(int snareNum, int tempoBpm, num scaleAdjustForNon44, int nSnares) {
    num soundDelay;
    // print('snareNum: $snareNum');
    // print('tempoBpm: $tempoBpm');
    // print('scaleAdjustForNon44: $scaleAdjustForNon44');
    num factorBasedOn100Bpm = 100 / tempoBpm;
    // print('factorBasedon108Bpm: $factorBasedOn100Bpm');
    // var scaleAdjustForNon44Times100TimesSnareNumMinus1 = (scaleAdjustForNon44 * 25 * (snareNum - 1));
    // print('scaleAdjustForNon44Times100TimesSnareNumMinus1: $scaleAdjustForNon44Times100TimesSnareNumMinus1');
    // soundDelay = (scaleAdjustForNon44Times100TimesSnareNumMinus1 / factorBasedOn100Bpm).round();
    // print('soundDelay: $soundDelay');
    // the more snares you have, the more tunnel sounding it is
    // 5 snares, separated as much as possible sounds better than 9
    switch (snareNum) { // this is a test based on a set tempo.  Needs adjustment for diff tempos.  The slower the tempo the more it's off.  Faster tempos reduce delay diffs
      case 1:
        soundDelay = 112;
        break;
      case 2:
        soundDelay = 80;
        break;
      case 3:
        soundDelay = 48;
        break;
      case 4:
        soundDelay = 16;
        break;
      case 5:
        soundDelay = 0;
        break;
      case 6:
        soundDelay = 32;
        break;
      case 7:
        soundDelay = 64;
        break;
      case 8:
        soundDelay = 96;
        break;
      case 9:
        soundDelay = 128;
        break;
      default:
        print('what snare was that?: $snareNum');
        break;
    } //i screwed something up adding nSnares, and other stuff around here
    var multiplierBasedOnNumberOfSnares = 3;
    switch (nSnares) {
      case 1:
      case 2:
      case 3:
      case 4:
        multiplierBasedOnNumberOfSnares = 2; // maybe 3 better?
        break;
      case 5:
        multiplierBasedOnNumberOfSnares = 3;
        break;
      case 6:
      case 7:
        multiplierBasedOnNumberOfSnares = 4;
        break;
      case 8:
      case 9:
        multiplierBasedOnNumberOfSnares = 5;
        break;
      default:
        print('What is this nSnares? $nSnares');
        break;
    }
    //return soundDelay; // bad tunnel
    //return soundDelay * 2; // without *2 it sounds more like you're in a tunnel
    //return soundDelay * 3; // even better. With 5 snares, separated widely, this sounds the best
    //return soundDelay * 4; // probably a bit better, but starting to get too fat.
    //return soundDelay * 5; // probably a bit better, but starting to get too fat, but the more snares you have the more separation you need to avoid tunnel sound.  This is okay for 9 snares, and maybe 5 close snares
    // return (soundDelay * multiplierBasedOnNumberOfSnares * factorBasedOn100Bpm).round();
    var finalSoundDelay = (soundDelay * multiplierBasedOnNumberOfSnares * factorBasedOn100Bpm).round();
    //print('finalSoundDelay: $finalSoundDelay, soundDelay: $soundDelay, multiplier: $multiplierBasedOnNumberOfSnares, factor: $factorBasedOn100Bpm');
    //return finalSoundDelay;
    return soundDelay;
  }

  /// This comment is also in midi.dart.  So change/summarize it there.
  ///
  /// Need to work out timing of notes that have grace notes, like 3 stroke ruffs.
  ///
  /// First, for a snare drum I usually think of the note as happening at a point in time and
  /// that the note has no duration, but that's not really true.  A tenor drum has a long ring
  /// to is.  The sound decays over a long period of time.  The snare not so much, but it
  /// too has a sound that has a duration, if only for the acoustics of the room where it was
  /// recorded.  It's just not as noticeable.  So, I should forget the idea that a note is
  /// just a point in time.  A note has a duration that is specified by the NoteOn and NoteOff
  /// events.  When the NoteOff event happens, then the note's duration stops.
  ///
  /// Every note has a NoteOn and NoteOff event, and both those events have a deltaTime value.
  /// DeltaTime says when the event starts relative to the previous NoteOn or NoteOff.
  /// A NoteOn event usually has a DeltaTime of 0 because it starts immediately when the
  /// previous NoteOff event occurs.  A NoteOff event has a DeltaTime that represents the
  /// duration of the note, which means the amount of time since NoteOn started.
  ///
  /// So, DeltaTime is a duration since the previous event, but for the NoteOff event it represents the
  /// duration of the note which started with a NoteOn event.
  ///
  /// This would therefore be a simple sequence of 0 followed by the note duration for the
  /// NoteOn and NoteOff sequence for each note, if we didn't have to adjust for grace notes.
  ///
  /// For notes with grace notes we need to slide the note's sound/sample to the left by
  /// the duration of the grace notes so that the principle note will be where it's expected to be.
  /// That means the the previous note's duration has to be shortened, which means it's
  /// NoteOff event's DeltaTime has to be reduced, and the current note's NoteOff deltaTime
  /// should be lengthened the same amount.  (Don't play with the NoteOn's deltaTime.  More complicated that way)
  /// But that lengthened NoteOff's deltaTime may be shortened later if the following note
  /// has grace notes.
  ///
  /// But, we should be talking about absolute time, which is not affected by tempo.  The gracenotes have
  /// an absolute time duration, in milliseconds, not some function of the tempo.  So, MAYBE if
  /// the tempo is 60bpm, then the numbers are right here.  But if the tempo is slower, these numbers
  /// are too high, and if if the tempo is faster, these notes are too low
  ///
  /// I set some values empirically.  They're based on a tempo of 100bpm.  They have to be scaled by the current tempo.
  /// I don't know how that affects time signature tempos like 3/8, 6/8, 9/8, where the beat is a dotted quarter.
  ///
  /// Okay, just learned that 2/2 time the shift is off by a factor of 2.  Should be twice as much!!!!!!!!
  /// I'd suspect things are off for 3/8, 6/8, 9/8, and even 2/8, 4/8, x/8 time too.  The numbers
  /// below are based on x/4 time.  I don't even know what the formula is here.
  ///
  /// The formula is used to calculate the time shift amount in milliseconds or some other unit, and this is
  /// used when setting on/off values in midi, which I'd think would NOT be based on tempo. Should be an
  /// absolute value no matter what the tempo, I'd think.  But I don't know how this stuff is calculated
  /// in midi.  So need to review.  But the time signature does matter.  That is, the beat.  If we're in
  /// 2/4, 3/4, 4/4, x/4, it's been working okay.  Maybe even working in 6/8.  But in 2/2 it is off by a
  /// factor of 2.  So, we've got a beat, and a tempo based on that beat.
  ///
  /// So, basically you're looking at two notes at once: the current note and the previous note.
  /// If the current note has grace notes, reduce the previous note's NoteOff deltaTime, and
  /// increase the current note's NoteOff deltaTime the same amount.  Then advance.
  /// Special condition for first note.  Maybe not last note.
  ///
  // void adjustForGraceNotes() {
  // void adjustForGraceNotes(Tempo initialTempo, num tempoScalar) {
  void adjustForGraceNotes(CommandLine commandLine) {

    log.fine('In adjustForGraceNotes.');

    var graceNotesDuration = 0; // Actually, the units are wrong.  This should be a percentage thing, I think.  Changes based on tempo.  For slow tempos the number is too high.  For fast tempos, too low.
    var noteOffDeltaTimeShift = 0;

    // just a wild stab to handle first note case in list
    var previousNote = Note();
    previousNote.deltaTimeShiftForGraceNotes = 0;
    //
    // Clean up this crap in non-prototype version
    //
    // Tempo mostRecentScaledTempo; // assuming here that we'll hit a tempo before we hit a note, because already added a scaled tempo at start of list.
    Tempo mostRecentTempo; // assuming here that we'll hit a tempo before we hit a note, because already added a scaled tempo at start of list.
    TimeSig mostRecentTimeSig; // assuming we'll hit one before we hit a note.
    num scaleAdjustForNon44 = 1.0;
    for (var element in elements) {
      if (element is TimeSig) {
        mostRecentTimeSig = element;
        if (mostRecentTimeSig.denominator == 1) { // total hack
          scaleAdjustForNon44 = 4.0; // total hack
        }
        else if (mostRecentTimeSig.denominator == 2) { // total hack
          scaleAdjustForNon44 = 2.0; // total hack
        }
        else if (mostRecentTimeSig.denominator == 8 && mostRecentTimeSig.numerator % 3 == 0) { // total hack
          scaleAdjustForNon44 = 1.5; // total hack, and a big guess
        }
        else if (mostRecentTimeSig.denominator == 8 && mostRecentTimeSig.numerator % 3 != 0) { // total hack
          scaleAdjustForNon44 = 0.5; // total hack
        }
        else if (mostRecentTimeSig.denominator == 16) { // total hack
          scaleAdjustForNon44 = 0.25; // total hack
        }
        else {
          scaleAdjustForNon44 = 1.0;
        }
      }
      if (element is Tempo) {
        //log.finest('In adjustForGraceNotes(), tempo is $element and looks like we will scale it just to keep track of the most recent tempo, but not changing it in the list');
        //tempoBpm = element.bpm; // but not adjusted for tempo scalar
        // mostRecentTempoBpm += (element.bpm * tempoScalar / 100).floor(); // OH MY.  Right???????????
        //mostRecentScaledTempo = Tempo.scaleThis(element, tempoScalar);
        //print('adjustForGraceNotes(), got a tempo element $element and just scaled it by ${commandLine.tempoScalar} and so mostRecentScaledTempo is $mostRecentTempo');
        //print('I kinda think this is an okay time to modify this Tempo element in the list.  Why wait until midi???????????????????????????????????????????????????????????????????  Okay do it now.');
        //element = mostRecentScaledTempo; // Could this possibly work?  We're playing with pointers
        //mostRecentTempoBpm = mostRecentScaledTempo.bpm;
        mostRecentTempo = element;
        continue;
      }
      else if (element is Note) {
        //print('In Score.adjustForGraceNotes, and element is a note, and mostRecentTempo is ${mostRecentTempo}');
        var note = element as Note; // unnec cast, it says, but I want to
        // Bad logic, I'm sure:
        switch (note.noteType) {
          case NoteType.flamLeft:
          case NoteType.flamRight:
          // case NoteType.flamUnison:
            // graceNotesDuration = (scaleAdjustForNon44 * 180 / (100 / mostRecentTempo.bpm)).round(); // The 180 is based on a tempo of 100bpm.  What does this do for dotted quarter tempos?
            graceNotesDuration = (scaleAdjustForNon44 * 180 / (100 / mostRecentTempo.bpm)).round(); // The 180 is based on a tempo of 100bpm.  What does this do for dotted quarter tempos?
            //print('graceNotesDuration for flam: $graceNotesDuration at $mostRecentTempo');
            //graceNotesDuration = (mostRecentTempo.noteDuration.secondNumber / mostRecentTempo.noteDuration.firstNumber) * .008 / (100 / mostRecentTempo.bpm)).round(); // The 180 is based on a tempo of 100bpm.  What does this do for dotted quarter tempos?
            previousNote.deltaTimeShiftForGraceNotes -= graceNotesDuration;
            note.deltaTimeShiftForGraceNotes += graceNotesDuration;
            previousNote = note; // probably wrong.  Just want to work with pointers
            break;
          case NoteType.dragLeft:
          case NoteType.dragRight:
          // case NoteType.dragUnison:
            // graceNotesDuration = (scaleAdjustForNon44 * 250 / (100 / mostRecentTempo.bpm)).round();
            graceNotesDuration = (scaleAdjustForNon44 * 250 / (100 / mostRecentTempo.bpm)).round();
            //print('graceNotesDuration for drag: $graceNotesDuration at $mostRecentTempo');
            previousNote.deltaTimeShiftForGraceNotes -= graceNotesDuration;
            note.deltaTimeShiftForGraceNotes += graceNotesDuration;
            previousNote = note; // probably wrong.  Just want to work with pointers
            break;
          case NoteType.ruff2Left:
          case NoteType.ruff2Right:
          // case NoteType.ruff2Unison:
            graceNotesDuration = (scaleAdjustForNon44 * 1400 / (100 / mostRecentTempo.bpm)).round();
            //print('graceNotesDuration for ruff2: $graceNotesDuration at $mostRecentTempo');
            previousNote.deltaTimeShiftForGraceNotes -= graceNotesDuration;
            note.deltaTimeShiftForGraceNotes += graceNotesDuration;
            previousNote = note; // probably wrong.  Just want to work with pointers
            break;
          case NoteType.ruff3Left:
          case NoteType.ruff3Right:
          case NoteType.ruff3AltLeft:
          case NoteType.ruff3AltRight:
          // case NoteType.ruff3Unison: // hey I think these numbers are not right.
            // A ruff3Right gracenotes duration is 0.1442s on the snare, and 0.1323s on a pad.  Average: 0.1382s.
            // With the current formula, at 60bpm in 4/4 time, the number to use is 1290, it seems.  Hmmmmm, that's close
            // At 120bpm the number is twice that (2580).  Seems to me we could use the actual milliseconds, assume it's at
            // 60bpm 4/4 time.  If it's 2/2 time, then
            // graceNotesDuration = (1900 / (100 / mostRecentTempo.bpm)).round(); // duration is absolute, but have to work with tempo ticks or something
            // graceNotesDuration = (2150 / (100 / mostRecentTempo.bpm)).round(); // duration is absolute, but have to work with tempo ticks or something
            graceNotesDuration = (scaleAdjustForNon44 * 2150 / (100 / mostRecentTempo.bpm)).round(); // duration is absolute, but have to work with tempo ticks or something
            // graceNotesDuration = (2150 / (100 / mostRecentTempo.bpm)).round(); // duration is absolute, but have to work with tempo ticks or something
            //graceNotesDuration = (2 * 2150 / (100 / mostRecentTempo.bpm)).round(); // duration is absolute, but have to work with tempo ticks or something
            //print('graceNotesDuration for ruff3: $graceNotesDuration at $mostRecentTempo');
            previousNote.deltaTimeShiftForGraceNotes -= graceNotesDuration; // at slow tempos coming in too late
            note.deltaTimeShiftForGraceNotes += graceNotesDuration;
            previousNote = note; // probably wrong.  Just want to work with pointers
            break;
          default: // a note without gracenotes, or a rest
            graceNotesDuration = 0;
            previousNote = note; // probably wrong.  Just want to work with pointers
            break;

        }
        continue;
      }
      else {
        log.finest('Score.adjustForGraceNotes() whatever this element is ($element), it is not important for adjusting durations due to gracenotes.');
        continue;
      }

    }
    log.finest('Leaving adjustForGraceNotes(), and updated notes to have delta time shifts to account for gracenotes.');
    return;

  }

}

///
/// ScoreParser
///
//Parser scoreParser = ((commentParser | markerParser | textParser | trackParser | channelParser | timeSigParser | tempoParser | voiceParser | dynamicParser | dynamicRampParser | noteParser).plus()).trim().end().map((values) {    // trim()?
Parser scoreParser = ((commentParser | markerParser | textParser | trackParser | channelParser | timeSigParser | tempoParser | dynamicParser | dynamicRampParser | noteParser).plus()).trim().end().map((values) {    // trim()?
  log.finest('In Scoreparser, will now add values from parse result list to score.elements');
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

// Maybe change track to "track"
/// I think the idea here is to be able to insert the keywords '/track snare' or
/// '/track tenor', ... and that track continues on as the only track being written
/// to, until either the end of the score, or there's another /track designation.
/// So, it's 'track <name>'
enum TrackId {
  snare,
  snare1,
  snare2,
  snare3,
  snare4,
  snare5,
  snare6,
  snare7,
  snare8,
  snare9,
  //unison, // snareEnsemble
  pad,
  tenor, // possibly pitch based notes rather than having tenor1, tenor2, ...
  bass,
  met,
  tempo,
  pipes
}

class Track {
  // Why not initialize?
  TrackId id; // the default should be snare.  How do you do that?
  // Maybe this will be expanded to include more than just TrackId, otherwise just an enum
  // and not a class will do, right?  I mean, why doesn't Dynamic do it this way?
  //int delay; // new 1/4/2021  representing the number of milliseconds delay in the case where we have 9 snares in a line, and the listener is in the middle.
  String toString() {
    // return 'Track: id: $id, delay: $delay ms';
    return 'Track: id: $id';
  }
  Track() {
    id = TrackId.snare; // good idea????
    //delay = 0;
  }
}

//final trackId = (letter() & word().star()).flatten();
//Parser trackParser = ((string('/track')|(string('/staff'))).trim() & trackId).trim().map((value) {
// Parser trackParser = (string('/track').trim() & word().plus().flatten() & (digit().plus().flatten().trim()).optional()).map((value) { // real close
Parser trackParser = (    string('/track').trim()   &   word().plus().flatten()   &   digit().plus().flatten().trim().optional()     ).map((value) { // works, but maybe not best creates a null element.

  //print('Maybe a Track object should also hold a time delay value so that the sound in the midi from snare1 takes longer to hit the ear than snare 5 which is in the middle');
  //print('In trackParser and value is -->$value<--');
  log.finest('In trackParser and value is -->$value<--');
  var track = Track();
  track.id = trackStringToId(value[1]);
  //print('hey value is $value and length is ${value.length}');
  log.finest('Leaving trackParser returning value $track');
  //print('Leaving trackParser returning value $track but not gunna use that delay');
  return track;
});

TrackId trackStringToId(String trackString) {
  TrackId trackId;
  switch (trackString) {
    case 'snare':
      trackId = TrackId.snare;
      break;
    case 'snare1':
      trackId = TrackId.snare1;
      break;
    case 'snare2':
      trackId = TrackId.snare2;
      break;
    case 'snare3':
      trackId = TrackId.snare3;
      break;
    case 'snare4':
      trackId = TrackId.snare4;
      break;
    case 'snare5':
      trackId = TrackId.snare5;
      break;
    case 'snare6':
      trackId = TrackId.snare6;
      break;
    case 'snare7':
      trackId = TrackId.snare7;
      break;
    case 'snare8':
      trackId = TrackId.snare8;
      break;
    case 'snare9':
      trackId = TrackId.snare9;
      break;
    case 'pad':
      trackId = TrackId.pad;
      break;
    case 'tenor':
      trackId = TrackId.tenor;
      break;
    case 'bass':
      trackId = TrackId.bass;
      break;
    case 'met':
    case 'metronome':
      trackId = TrackId.met;
      break;
    case 'tempo':
      trackId = TrackId.tempo; // hey what about trackzero?  Should use it instead?
      break;
    case 'pipes':
      trackId = TrackId.pipes;
      break;
    default:
      log.severe('Bad track identifier: $trackString');
      trackId = TrackId.snare;
      break;
  }
  return trackId;
}

String trackIdToString(TrackId id) {
  switch (id) {
    case TrackId.snare:
      return 'snare';
    case TrackId.snare1:
      return 'snare1';
    case TrackId.snare2:
      return 'snare2';
    case TrackId.snare3:
      return 'snare3';
    case TrackId.snare4:
      return 'snare4';
    case TrackId.snare5:
      return 'snare5';
    case TrackId.snare6:
      return 'snare6';
    case TrackId.snare7:
      return 'snare7';
    case TrackId.snare8:
      return 'snare8';
    case TrackId.snare9:
      return 'snare9';
    // case TrackId.unison:
    //   return 'unison';
    case TrackId.pad:
      return 'pad';
    case TrackId.tenor:
      return 'tenor';
    case TrackId.bass:
      return 'bass';
    case TrackId.met:
      return 'met';
    case TrackId.tempo: // what about trackzero?
      return 'tempo';
    case TrackId.pipes:
      return 'pipes';
    default:
      log.severe('Bad track id: $id');
      return null;
  }
}

//import '../snarelang4.dart';
/// I think the idea here is to be able to insert the keywords '/channel <num>' or
/// '/chan <num>' or '/program <num>', or '/prog <num>' and that channel
/// continues on as the only channel being written
/// to, until either the end of the score, or there's another /channel designation.
/// The default number is 0.
class Channel {
  static const DefaultChannelNumber = 0;
  int number; // the default should be 0.

  Channel() {
    number = DefaultChannelNumber;
  }

  @override
  String toString() {
    return 'Channel: num: $number';
  }
}



///
/// channelParser
///
Parser channelParser = (
    (string('/channel') | string('/chan') | string('/program')).trim()
    & wholeNumberParser.trim()).trim().map((value) {
  log.finest('In channelParser and value is -->$value<--');
  var channel = Channel();
  channel.number = value[1];
  log.finest('Leaving channelParser returning value $channel');
  return channel;
});

