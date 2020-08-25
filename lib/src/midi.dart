import 'package:dart_midi/dart_midi.dart';
import 'package:logging/logging.dart';

import '../snarelang4.dart';


///
/// The Dart midi library, which is basically a rewrite of a JavaScript library:
/// https://pub.dev/documentation/dart_midi/latest/midi/midi-library.html
///
/// A midi spec: http://www.cs.cmu.edu/~music/cmsip/readings/Standard-MIDI-file-format-updated.pdf
/// is based on https://github.com/gasman/jasmid, with no API documentation.
///
/// A converter of a midi file to JSON:
/// https://tonejs.github.io/Midi/
///
/// Maybe something to study:
/// https://tonejs.github.io/
///
/// RoseGarden software can play midi that this program creates.  It needs QSynth to be running
/// which knows about my sound font file.  Start QSynth first.
///
/// All SnareLang note designations are just the reciprocal of their ratio durations
/// to a 4/4 bar.
///
/// The form is X:Y where X is the number of notes in Y bars.
/// There are 4 quarter notes in 1 4/4 bar.  Therefore "4:1", or just "4"
/// Or, there is 1 quarter note in 1/4 of a bar: 1:1/4, which is also "4:1", or just "4"
/// A note that takes 2/5ths of a bar is 1:2/5 or "5:2".  No decimal values, like "2.5"
///
/// A "tick" is the resolution of a midi clock, and is used in midi note durations.
///
/// I do not know how a midi clock is calibrated.
///
/// A "beat" is a metronome click, which is determined by a desired tempo, like 84 bpm.
///
/// "ticksPerBeat" (or "ppq"?) is the number of subdivisions in a metronome beat.
/// This is important.
///
/// I don't know how ticksPerBeat is determined.  It may be just a convenient number
/// like 384.  If the tempo is slow, like 64, it probably makes sense to have more
/// ticksPerBeat than if the tempo is fast, like 148.  I don't know if you can change
/// this number in a midi file once it's set in the header, even if the tempo changes,
/// which can be set anywhere in a piece.
///
/// At 60 bpm I've seen a ticksPerBeat of 384 but not sure.  Here are some candidate:
///
/// 840 * 4, divides by 2,3,4,5,6,7,8,  10,12,14,15,16,  20,21,24,28,30,32,35,   40,42,   48,56,60
/// 630 * 4, divides by 2,3,4,5,6,7,8,9,10,12,14,15,  18,20,21,24,28,30,   35,36,40,42,45,   56,60,63
/// 480 * 4, divides by 2,3,4,5,6,  8,  10,12,   15,16,  20,   24,   30,32,   40,         48,   60,   64
/// 384 * 4, divides by 2,3,4,  6,  8,     12,      16,        24,      32,               48,         64
///
/// Tempo is related to the value of "microsecondsPerBeat".  60 bpm is 1 beat per second,
/// or 1,000,000 microseconds.  The formulas for tempo and microsecondsPerBeat are
/// tempoBpm = 60,000,000 / microsecondsPerBeat
/// microsecondsPerBeat = 60,000,000 / tempoBpm
///
/// We don't care about durations per second or microsecond.  We also don't care about the
/// "metronome number" which is the number of midi clock ticks per metronome click because
/// I think it's only used for device synchronization.
///
/// So, how do you calculate and set midi note durations (deltaTime in ticksPerBeat) for
/// SnareLang note name durations such as "5:2"  or "30"?  It may be as simple as this:
///
/// noteTicks = (4 * ticksPerBeat) / SnareLangNoteNameValue
///
/// It seems it is that simple, based on the few tests I ran when only the tempo was
/// changed, and also when the time signature was changed, (4/4, 3/4, 6/8, with and without
/// metronome set to dotted quarter for the 6/8).  Therefore, to ward off problems
/// with integer math round errors, it would be good to use 840 for the "ppq"
/// (microsecondsPerBeat) value.  The missing even subdivisions would might be helpful
/// are 9, 36, and 64.  Plus a higher number will probably make gracenotes better positioned.
///
///
///
/// (Hmmmmm, don't forget to record two and three note ruffs.)
///
///
///
/// So, when I write a Midi file, I'll set ticksPerBeat to 840, microsecondsPerBeat based on
/// the desired tempo.  Chanel(?)/Instrument(?) to snare drum somehow, and then a single(?)
/// track with a set of notes having durations and volumes, and note name that relates to
/// the type of note, and the hand (for pitch difference).



/// The determination of that value *may* partially be a result of the SetTempo
/// event, although that's a track parameter.
///
/// Later in the file, in a "track" section there can be a TimeSignature event
/// and also a SetTempo event.  In the TimeSignature event there is a
/// numerator number, a denominator, a metronome number, and a thirtyseconds number.
///
/// The "metronome" number, like 18, and a "thirtyseconds" number, like 8,
/// probably don't have any bearing on how "ticksPerBeat" is determined.
///
/// The "metronome number" (e.g. 18) is the number of "midi clocks" in a metronome click
/// (same as a 'beat'?). I think a midi clock or a midi click is a synchronization
/// mechanism when there are multiple devices.  I think it varies with the tempo.
/// Therefore, I doubt it's important for what I'm doing.
///
/// The SetTempo thing only has only "microsecondsPerBeat"  That number could be 1M
/// or 2M or something else, I guess. Since 1 second is 1M microseconds, the
/// tempo is:  (microsecondsPerBeat / 16,667).round()
///
/// The number for "thirtyseconds" is the number of 32nds in a metronome beat.
/// For a time sig of 4/4 there are 8 32nd's per beat, which is a quarter note.  But for
/// 6/8 time where the beat is set to every 3rd 8th note, there would be 12 32nds per
/// metronome beat/click.  Again, I don't think this has any bearing on note duration
/// analysis.
///
/// What's the best number to use for ticksPerBeat?  Probably a number that's divided
/// by small prime numbers like 2 and 3, and not too big or too small so as to handle
/// long notes like a dotted whole note, and short notes, like a 64th note.  For
/// SnareLang stuff I think most notes will be between quarter and 32nd notes, and
/// tempos would be between 60 and 180 (?).  I think 480 is typical for most music
/// at a tempo of 120bpm.  But we'll generally be at 84bpm so we should go higher.
/// I think 960 is a decent number, (divisible by 2, 3, & 5)
///
/// So, when I write my own midi file, I should use 840 (better than 960) for ticksPerBeat,
/// because 840 is 2^3 * 3 * 5 * 7  (whereas 960 is 2^6 * 3 * 5) and can therefore subdivide
/// a quarter note into several subdivisions evenly.



class Midi {
  static final ticksPerBeat = 10080;
//  // Was getting double log messages, so maybe one global one is good enough, wich I think is in MyParser.dart
  final log = Logger('MyMidiWriter'); // does nothing on it's own, right?
  //MyMidiWriter() {
//    Logger.root.level = Level.ALL;
//    Logger.root.onRecord.listen((record) {
//      log.info('MyMidiWriter.dart ${record.level.name}: ${record.time}: ${record.message}');
//    });
  // }


  // When we have fractional ticks for note durations rounding causes some timings to be slightly off.
  // Keep track of how far off we get, and do something about it when necessary.  The
  // problem durations are for notes such as 9, 11, 13, 17, 18, 19 and others.  Not a big deal.
  double cumulativeRoundoffTicks = 0.0;

  ///   Create a MidiHeader object, which I did not define, which is part of MidiFile, and return it.
//  MidiHeader createMidiHeader(int ticksPerBeat) {
  MidiHeader createMidiHeader() {
    // Construct a header with values for name, and whatever else
    var midiHeaderOut = MidiHeader(ticksPerBeat: Midi.ticksPerBeat, format: 1, numTracks:2); // puts this in header with prop "ppq"  What would 2 do?
//    var midiHeaderOut = MidiHeader(ticksPerBeat: ticksPerBeat, format: 1, numTracks:2); // puts this in header with prop "ppq"  What would 2 do?
    return midiHeaderOut;
  }

  List<MidiEvent> doSpecialFirstTrack(TimeSig timeSig, int bpm) {
    // Construct a list to put track events in.
    var trackEventsList = <MidiEvent>[];

    // Start the special first track.  Not sure this is how it has to be, but it's
    // how other midi files have done it.

    // Add a track name
    var trackNameEvent = TrackNameEvent();
    trackNameEvent.text = 'Snare'; // strangely puts this in the header, under the prop "name"
    trackNameEvent.deltaTime = 0;
    trackEventsList.add(trackNameEvent);

    // Add file creation meta data, like the program that created the midi file.
    var textEvent = TextEvent();
    textEvent.type = 'text';
    textEvent.text = 'creator:';
    trackEventsList.add(textEvent);
    textEvent = TextEvent();
    textEvent.type = 'text';
    textEvent.text = 'SnareLang';
    trackEventsList.add(textEvent);

    // Add a time signature event for this track, though this can happen anywhere, right?
    // But I guess they need to have this before any notes.
    var timeSignatureEvent = TimeSignatureEvent();
    timeSignatureEvent.type = 'timeSignature';
    timeSignatureEvent.numerator = timeSig.numerator; // how are these used in a midi file?  Affects sound or tempo????
    timeSignatureEvent.denominator = timeSig.denominator;
    timeSignatureEvent.metronome = 18; // for module synchronization
    timeSignatureEvent.thirtyseconds = 8; // Perhaps for notation purposes
    trackEventsList.add(timeSignatureEvent);

    // Add a tempo event.  Again, can't this happen anywhere?
    // But I guess they need to have this before any notes.
    var setTempoEvent = SetTempoEvent();
    setTempoEvent.type = 'setTempo';
    setTempoEvent.microsecondsPerBeat = (60000000.0 / bpm).floor(); // not round()?
    trackEventsList.add(setTempoEvent);

    return trackEventsList;
  }

  /// Create a list of MidiEvent lists, one list per track.  First list is special.  After that it's just tracks.
  /// For now we have two tracks only.
  List<List<MidiEvent>> createMidiEventsTracksList(List elements, TimeSig timeSig, int bpm, Dynamic dynamic) {
    // Construct a list to put lists of track events in.
    var listOfTrackEventsLists = <List<MidiEvent>>[];
    // Do special first track (why?)
    var trackEventsList = doSpecialFirstTrack(timeSig, bpm);
    listOfTrackEventsLists.add(trackEventsList);


    // Start a new list of events, most will be notes, but not all.
    // Set event velocities for notes from elements (including ramps).
    // Process any tempo elements.

    trackEventsList = <MidiEvent>[];

//    int noteVelocityAddition;
//    var noteNumber = 60; // Initial/default note number == tap
//    var noteVolume = dynamicToVelocity(dynamic);
    var noteChannel = 0;
//    var newVelocity = 0;
//    Ramp currentRamp;
//    var inRamp = false;
//    var isFirstNoteInRamp = true;
//    Note previousNote;
//    num cumulativeDurationSinceRampStartNote = 0;











































//    log.fine('Starting to convert score elements into midi events.');
//    for (var element in elements) {
//      log.finer('In Midi.createMidiEventsList top of loop, with $element');
//
//      if (element is Tempo) {
//        bpm = element.bpm;
//        var setTempoEvent = SetTempoEvent();
//        setTempoEvent.type = 'setTempo';
//        setTempoEvent.microsecondsPerBeat = (60000000.0 / bpm).floor(); // not round()?
//        trackEventsList.add(setTempoEvent);
//        log.finest('Midi.createMidiEventsList loop, We got a setTempo event');
//        continue;
//      }
//      // Don't worry about doing timeSigs for now, I think, but later probably yes, when do Sets.
//      // I mean, tempo for a 6/8 is set where the beat is a dotted eighth.  Does that fit in here?
//
//
//        if (element is Ramp) {
//          log.fine('\t\tMidi.createMidiEventsList loop, This dynamic element is a ramp which already has the slope in it, to calculate the new velocitis for all notes in the ramp: ${element}');
//          inRamp = true;
//          currentRamp = element;
//          continue;
//        }
//
//      // I think by this time every element has a dynamic value, so should be able to skip Dynamic elements,
//      // but still want to turn off inRamp so won't apply ramp slope to following notes.
//      if (element is Dynamic) {
//        log.fine('Midi.createMidiEventsList loop, element is a Dynamic, so it means the end of a ramp if in a ramp, but make sure finish off the previous note.');
//        inRamp = false; // whether in a ramp or not, inRamp should go false here
//        currentRamp = null;  // is this right????????
//        //        newVelocity = dynamicToVelocity(element);
////        log.finer('Midi.createMidiEventsList, This is a Dynamic element, and it is $element, and has an equivalent velocity of $newVelocity to be used for future notes until next dynamic element occurs.');
//        continue;
//      }
//
//      if (element is Note) {
//        noteVelocityAddition = 0; // ???????????????
//
//        log.finest('In Midi createMidiEventsTracksList, in loop, so will assign and adjust velocities for this note: $element');
//        // Adjust note volumes based on type of note and articulation and ramp slope
//        //
//        // Accents/Articulations affect velocities.
//        // "_" add 16, ">" add 32, and "^" and 48, but cap at 127.
//        //
//        // Note types affect velocities to some extent.
//        // A flam is maybe an increase of 6, a drag increases by 10 (of course with a note cap of 127).
//        // (Grace notes are recorded with their principle notes, so there are no separate grace notes.  If there were, they'd be
//        // at an absolute level of about 10 (for 2 and 3 stroke ruffs and maybe flams, but not drags))
//        //
//        // 1.  Note's get velocities first, based on their current Dynamic.
//        // 2.  After that we calculate and adjust the velocity according to its Ramp.
//        // 3.  Then articulations, and then
//        // 4.  note types, and
//        // 5.  finally clamp.
//
//        if (element.duration == null || element.duration.firstNumber == null) {
//          log.warning('hey, watch out this note has a duration that has not been set.  why??????????????????????');
//        }
//
//
//        var velocity = dynamicToVelocity(element.dynamic);
//        //print('\t\t\tHey, are we gunna go into ramp?');
//        if (inRamp) {
//          print('\t\t\tWe re in a ramp');
//          if (isFirstNoteInRamp) {
//            print('\t\tThis is first note in ramp so will not adjust velocity due to ramp.');
//            previousNote = element;
//            isFirstNoteInRamp = false;
//          }
//          else {
//            // To calculate the change in velocity, need to know the note's current time position in the ramp.
//            print('\t\tThis is subsequent note in a ramp, so will calculate time position relative to first note by doing accumulation.');
//            cumulativeDurationSinceRampStartNote += (previousNote.duration.secondNumber / previousNote.duration.firstNumber);
//            print('\t\tcumulativeDurationSinceRampStartNote: $cumulativeDurationSinceRampStartNote');
//            int cumulativeTicksSinceRampStartNote = beatFractionToTicks(cumulativeDurationSinceRampStartNote);
//            print('\t\t\tcumulativeTicksSinceRampStartNote: $cumulativeTicksSinceRampStartNote and ramp slope is ${currentRamp.slope}');
////            num newVelocity = dynamicToVelocity(currentRamp.startDynamic) + currentRamp.slope * cumulativeDurationSinceRampStartNote;
////            velocity += (currentRamp.slope * cumulativeDurationSinceRampStartNote).round();
////            velocity += (currentRamp.slope * cumulativeTicksSinceRampStartNote).round();
//            print('\t\t\tHey, wanna add this much to the velocity: ${currentRamp.slope * cumulativeTicksSinceRampStartNote}');
//            velocity += (currentRamp.slope * cumulativeTicksSinceRampStartNote).round();
//            isFirstNoteInRamp = false;
//            previousNote = element; // new
//          }
//        }
//        print('\t\tAfter scaling velocity due to ramp, it is $velocity');
//
//
//
//
//
//        // Determine volume/velocity additions based on articulations/accents
//        switch (element.articulation) {
//          case NoteArticulation.tenuto: // '_'
//            velocity += 16;
////          noteVelocityAddition = (noteVelocity * 0.25).round();
//            break;
//          case NoteArticulation.accent: // '>'
//            velocity += 32;
//            break;
//          case NoteArticulation.marcato: // '^'
//            velocity += 48;
////          noteVelocityAddition = (noteVelocity * 0.75).round();
//            break;
//        }
//
//
//        // Do changes based on note type
//        switch (element.noteType) {
//          case NoteType.leftTap:
//          case NoteType.rightTap:
//            break;
//          case NoteType.leftFlam:
//          case NoteType.rightFlam:
//          velocity += 6;
//            break;
//          case NoteType.leftDrag:
//          case NoteType.rightDrag:
//          velocity += 10;
//            break;
//          case NoteType.leftBuzz:
//          case NoteType.rightBuzz:
//            break;
//          case NoteType.rest:
//            break;
//          default:
//            log.warning('What the heck was that note? $element.type');
//        }
//
//
//
//        print('adjusted velocity is $velocity');
//        element.velocity = velocity.clamp(0,127); // clip it
//        //        element.velocity = (velocity + noteVelocityAddition).clamp(0,127); // clip it
//        print('clamped velocity is ${element.velocity}');
//
//
//
//
//        //final ticksPerBeat = 10080; // better than 840 or 480      TODO: PUT THIS ELSEWHERE LATER
//        addNoteOnOffToTrackEventsList(element, noteChannel, trackEventsList); // what, does this add the note to the list?  Prob
////        addNoteOnOffToTrackEventsList(element, noteChannel, Midi.ticksPerBeat, trackEventsList); // what, does this add the note to the list?  Prob
//        continue;
//      }
//      log.info('skipping this note since not a note.  It is a ${element.runtimeType}');
//    };



    for (var element in elements) {
      if (element is Note) {
        addNoteOnOffToTrackEventsList(element, noteChannel, trackEventsList);
        continue;
      }
      // What about elements like tempo changes?
        log.warning('have something else not putting into the track: ${element.runtimeType}');
    }




    if (trackEventsList.isEmpty) {
      log.warning('What?  no events for track?');
    }
    // Add this second list to the list of lists
    listOfTrackEventsLists.add(trackEventsList);

    return listOfTrackEventsLists;
  }



  ///
  /// Create and add a NoteOnEvent and a NoteOffEvent to the list of events for a track,
  /// The caller of this method has access to the Note which holds the nameValue and type, etc.
  /// May want to watch out for cumulative rounding errors.  "snareLangNoteNameValue" can be
  /// a something like 1.333333, so it shouldn't be called a NameValue like "4:3" could be.
  /// Clean this up later.
  ///
//  double noteOnNoteOff(num snareLangNoteNameValue, int noteNumber, int velocity, int channel, int ticksPerBeat, List<MidiEvent> trackEventsList) {
//  double addNoteOnOffToTrackEventsList(Note note, int channel, int ticksPerBeat, List<MidiEvent> trackEventsList) {
  double addNoteOnOffToTrackEventsList(Note note, int channel, List<MidiEvent> trackEventsList) {

//    num snareLangNoteNameValue = note.duration.firstNumber / note.duration.secondNumber;
//    num snareLangNoteNameValue;
//    if (note.duration != null) {
    if (note.duration == null) {
      log.severe('note should not have a null duration.');
    }
//    num snareLangNoteNameValue = note.duration.firstNumber / note.duration.secondNumber;
    var snareLangNoteNameValue = (note.duration.firstNumber / note.duration.secondNumber).floor(); // is this right???????
//    }
    //var noteNumber = note.number;
//    var velocity = note.velocity;
//    var velocity = note.dynamic == Dynamic.mf ? 64 : 65; // fix later
    if (note.noteType == NoteType.rest) {
      note.velocity = 0; // new, nec?
    }
    // Maybe this should be put into Note, even though it's a MIDI thing.
    var noteNumber;
    switch (note.noteType) {
      case NoteType.rightTap:
        noteNumber = 60;
        break;
      case NoteType.leftTap:
        noteNumber = 70;
        break;
      case NoteType.rightFlam:
        noteNumber = 61;
        break;
      case NoteType.leftFlam:
        noteNumber = 71;
        break;
      case NoteType.rightDrag:
        noteNumber = 62;
        break;
      case NoteType.leftDrag:
        noteNumber = 72;
        break;
      case NoteType.rightBuzz:
        noteNumber = 69;
        break;
      case NoteType.leftBuzz:
        noteNumber = 69;
        break;
      case NoteType.rest:
        noteNumber = 99; // see if this helps stop blowups when writing
        break;
      default:
        log.fine('noteOnNoteOff, What the heck was that note? $note.type');
    }


    var noteOnEvent = NoteOnEvent();
    noteOnEvent.type = 'noteOn';
    noteOnEvent.deltaTime = 0; // might need to adjust to handle roundoff???
    noteOnEvent.noteNumber = noteNumber;
    noteOnEvent.velocity = note.velocity;
    noteOnEvent.channel = channel;
    trackEventsList.add(noteOnEvent);

    var noteOffEvent = NoteOffEvent();
    noteOffEvent.type = 'noteOff';
    noteOffEvent.deltaTime = (4 * Midi.ticksPerBeat / snareLangNoteNameValue).round(); // keep track of roundoff?
    noteOffEvent.noteNumber = noteNumber;
    noteOffEvent.velocity = note.velocity; // shouldn't this just be 0?
    noteOffEvent.channel = channel;
    
    trackEventsList.add(noteOffEvent);

    // By rounding, what fraction of a tick are we adding or subtracting to the set of notes?
    // If the number of ticks for this note should be 53.33333, but it gets rounded down to 53
    // then the note ended 1/3 of a tick too soon, making the next note start 1/3 of a tick too soon.
    // We cannot push the next note back 1/3 of a tick, but we can keep track of what fraction of a tick
    // we're off.  If the next note is also supposed to be 53.3333, and we set it to 53, then its following
    // note will start 2/3 of a tick too soon.  So do we extend this note to 54?  Perhaps so but it might
    // also depend on what the next note is.  This is a solvable problem, of course, but not worth
    // the time right now, since we are taking about small numbers, and typical notes, like 16th notes
    // don't have a roundoff error, only the weird ones like 9, 13, 17, 18, 19 ... notes.  Actually I
    // wish I had 9th and 18th notes, which are triplets in triplets, so this is worth working on in
    // the future.
    //
    var noteTicksAsDouble = 4 * Midi.ticksPerBeat / snareLangNoteNameValue;
    var diffTicksAsDouble = noteTicksAsDouble - noteOffEvent.deltaTime;
    cumulativeRoundoffTicks += diffTicksAsDouble;

    log.info('noteOnNoteOff, Created note events for noteName ${snareLangNoteNameValue}, '
        'deltaTime ${noteOffEvent.deltaTime} (${noteTicksAsDouble}), velocity: ${note.velocity}, '
        'number: ${noteNumber}, cumulative roundoff ticks: $cumulativeRoundoffTicks');
    return diffTicksAsDouble; // kinda strange
  }
}

