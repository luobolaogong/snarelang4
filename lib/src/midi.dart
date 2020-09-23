import 'package:dart_midi/dart_midi.dart';
import 'package:logging/logging.dart';

import '../snarelang4.dart';

bool soundFontHasSoftMediumLoudRecordings = false; // Change this later when sound font file has soft,med,loud recordings, and mapped offsets by 10
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

/// Different subject: sustained notes, such as rolls and tap rolls (tuzzes).
/// If you record them faster, the pulse is faster and shorter, and you're squeezing in, pressuring in, rebounds.
/// If you record them slower, the pulse is slower and longer, and you're trying to get more rebounds to happen and smooth it out.
/// If you play back the midi at the tempo as recorded, it should sound fine, but if you change the tempo then what happens to the sustain?
/// Does the faster midi tempo clip off the sustain, or does it compress all the rebounds into the shorter duration?
/// I suspect it clips.
/// This means that if you record roll pulses fast, but play the midi slow, it will sound buzz, buzz, buzz, buzz, rather than
/// buzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz.
/// And if you record it slow, and play it back fast, it clips the buzz before you get all the notes to play, and so I think the pulses stand out more, and rolls sound lazy.
///
/// You could record both ways and have the program substitute in the correct sound font recording based on the tempo of the music at that place,
/// but the user changes the tempo, usually slowing it down.
///
/// So, it seems to me that when recording, slow it down to 75% of the performance tempo.  For example, if a march is to be played at 84, for practice
/// purposes someone may want to slow it down to 54, so maybe record it at 64

class Midi {
  static final ticksPerBeat = 10080; // put this elsewhere later
  static final microsecondsPerMinute = 60000000;

//  // Was getting double log messages, so maybe one global one is good enough, wich I think is in MyParser.dart
  final log = Logger('MyMidiWriter'); // does nothing on it's own, right?


  // When we have fractional ticks for note durations rounding causes some timings to be slightly off.
  // Keep track of how far off we get, and do something about it when necessary.  The
  // problem durations are for notes such as 9, 11, 13, 17, 18, 19 and others.  Not a big deal.
  double cumulativeRoundoffTicks = 0.0;

  ///   Create a MidiHeader object, which I did not define, which is part of MidiFile, and return it.
  MidiHeader createMidiHeader() {
    // Construct a header with values for name, and whatever else
    // var midiHeaderOut = MidiHeader(ticksPerBeat: Midi.ticksPerBeat, format: 1, numTracks:2); // puts this in header with prop "ppq"  What would 2 do?
    print('hey watch that numTracks thing in header (default 2), and also format (default 1).');
    // var midiHeaderOut = MidiHeader(ticksPerBeat: ticksPerBeat, format: 1, numTracks:3); // puts this in header with prop "ppq"  What would 2 do?
    // Format of 1 seems the only value that works.  See midi spec somewhere about this.
    // numTracks doesn't seem to matter???
    var midiHeaderOut = MidiHeader(ticksPerBeat: ticksPerBeat, format:1, numTracks:2); // puts this in header with prop "ppq"  What would 2 do?
    return midiHeaderOut;
  }



  List<MidiEvent> createMidiEventsMetronomeTrack(int nBarsMetronome, Tempo tempo, Note note) {
    var channel = 1; // ??????????????????????????  What's a channel?
    // var snareLangNoteNameValue = (note.duration.firstNumber / note.duration.secondNumber).floor(); // is this right???????
    var snareLangNoteNameValue = (note.duration.firstNumber / note.duration.secondNumber); // is this right???????

    var metronomeTrackEventsList = <MidiEvent>[];
    var totalNotes = nBarsMetronome * 4; // wrong, assumes 4/4, not 6/8
    for (var metBeatCtr = 0; metBeatCtr < totalNotes; metBeatCtr++) {
      var noteOnEvent = NoteOnEvent();
      noteOnEvent.type = 'noteOn';
      noteOnEvent.deltaTime = 0; // might need to adjust to handle roundoff???
      noteOnEvent.noteNumber = 60; // wrong, right is a right tap.  Let's have something special
      noteOnEvent.velocity = note.velocity;
      noteOnEvent.channel = channel;
      metronomeTrackEventsList.add(noteOnEvent);

      var noteOffEvent = NoteOffEvent();
      noteOffEvent.type = 'noteOff';
      noteOffEvent.deltaTime = (4 * ticksPerBeat / snareLangNoteNameValue).round(); // keep track of roundoff?
      noteOffEvent.noteNumber = 60;
      // noteOffEvent.velocity = note.velocity; // shouldn't this just be 0?
      noteOffEvent.velocity = 0; // shouldn't this just be 0?
      noteOffEvent.channel = channel;

      metronomeTrackEventsList.add(noteOffEvent);

    }
    return metronomeTrackEventsList;
  }

  // DOUBT WE NEED ALL THESE PARAMS
  List<MidiEvent> createTrackZeroMidiEventsList(List elements, TimeSig timeSig, Tempo tempo, Dynamic dynamic, bool usePadSoundFont) {
    log.fine('In Midi.createTrackZeroMidiEventsList()');
    //
    // Do TrackZero
    //
    var trackZeroEventsList = <MidiEvent>[];

    // Watch out, this is duplicate code in another place
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! This probably does nothing, because we're not monitoring for tempos or timesigs as parse through file or scan it previous to this point
    if (tempo.noteDuration.firstNumber == null || tempo.noteDuration.secondNumber == null) { // something's wrong, gotta fix it
      if (timeSig.denominator == 8 && timeSig.numerator % 3 == 0) { // if timesig is 6/8, or 9/8 or 12/8, or maybe even 3/8, then it should be 8:3
        tempo.noteDuration.firstNumber = 8;
        tempo.noteDuration.secondNumber = 3;
      }
      else {
        tempo.noteDuration.firstNumber ??= timeSig.denominator; // If timeSig is anything other than 3/8, 6/8, 9/8, 12/8, ...
        tempo.noteDuration.secondNumber ??= 1;
      }
    }


    // Add a track name
    var trackNameEvent = TrackNameEvent();
    trackNameEvent.text = 'Snare'; // strangely puts this in the header, under the prop "name"
    trackNameEvent.deltaTime = 0;
    trackZeroEventsList.add(trackNameEvent);

    // Add file creation meta data, like the program that created the midi file.
    var textEvent = TextEvent();
    textEvent.type = 'text';
    textEvent.text = 'creator:';
    trackZeroEventsList.add(textEvent);
    textEvent = TextEvent();
    textEvent.type = 'text';
    textEvent.text = 'SnareLang';
    trackZeroEventsList.add(textEvent);

    // Add a time signature event for this track, though this can happen anywhere, right?
    // But I guess they need to have this before any notes.
    var timeSignatureEvent = TimeSignatureEvent();
    timeSignatureEvent.type = 'timeSignature';
    timeSignatureEvent.numerator = timeSig.numerator; // how are these used in a midi file?  Affects tempo????
    timeSignatureEvent.denominator = timeSig.denominator;
    timeSignatureEvent.metronome = 18; // for module synchronization
    timeSignatureEvent.thirtyseconds = 8; // What used for?  Is this num 32nd's in a quarter, or in a beat?????????????????????????????????????????????????????
    trackZeroEventsList.add(timeSignatureEvent);

    //var noteChannel = 0; // Is this essentially a "tempo track", or a "control track"?

    // Watch out, this is duplicate code in another place
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if (tempo.noteDuration.firstNumber == null || tempo.noteDuration.secondNumber == null) { // something's wrong, gotta fix it
      if (timeSig.denominator == 8 && timeSig.numerator % 3 == 0) { // if timesig is 6/8, or 9/8 or 12/8, or maybe even 3/8, then it should be 8:3
        tempo.noteDuration.firstNumber = 8;
        tempo.noteDuration.secondNumber = 3;
      }
      else {
        tempo.noteDuration.firstNumber ??= timeSig.denominator; // If timeSig is anything other than 3/8, 6/8, 9/8, 12/8, ...
        tempo.noteDuration.secondNumber ??= 1;
      }
    }

    // addTempoChangeToTrackEventsList(tempo, noteChannel, trackZeroEventsList);
    addTempoChangeToTrackEventsList(tempo, trackZeroEventsList); // a bit strange.  Have to convert tempo to midi.  Can't just add tempo to track without converting


    // Put metronome here?

    // Do tempo ramps here?







    //listOfTrackEventsLists.add(trackZeroEventList); // Can we add to this track 0 later, to add metronome or tempo ramps?
    // var trackEventsList = doSpecialFirstTrack(timeSig, tempo); // do we really need this?  Maybe so if score doesn't do tempo or timeSig
    // listOfTrackEventsLists.add(trackEventsList);
    return trackZeroEventsList;
  }

  /// Create a list of MidiEvent lists, one list per track.  First list is for the special TrackZero
  /// which is timesig and tempo, but maybe will be used for tempo mapping if we do tempo ramps.
  /// After that tracks for snare, metronome, pad tenors? bass? pipes?
  /// But since we've only got one list of elements, and these are currently for snare, this method should
  /// be changed to "createSnareTrackList", given the snare score
  // List<List<MidiEvent>> createMidiEventsTracksList(List elements, TimeSig timeSig, int bpm, Dynamic dynamic) {
  List<MidiEvent> createSnareMidiEventsList(List elements, TimeSig timeSig, Tempo tempo, Dynamic dynamic, bool usePadSoundFont, bool loopBuzzes) {
    log.fine('In Midi.createMidiEventsTracksList()');

    //
    // Do Snare track
    //
    var snareTrackEventsList = <MidiEvent>[];

    //var noteChannel = 0; // what for?
    var currentVoice = Voice.solo; // Hmmmmm done differently elsewhere as in firstNote.  Check it out later

    for (var element in elements) {
      if (element is Voice) {
        currentVoice = element; // ????
      }
      if (element is Note) {
        // addNoteOnOffToTrackEventsList(element, noteChannel, snareTrackEventsList, usePadSoundFont);
        addNoteOnOffToTrackEventsList(element, snareTrackEventsList, usePadSoundFont, loopBuzzes, currentVoice); // return value unused
        continue;
      }
      if (element is Tempo) {
        var tempo = element as Tempo;
        // Fix tempos that didn't specify a note duration.  Usually should be 4:1 (for 2/4, 3/4, 4/4, 5/4, 6/4, 7/4, ...),
        // but could be 2:1 (for 2/2, 3/2, 4/2, 5/2, ...), 8:1 (for 1/8, 2/8, 4/8, 5/8, 7/8, ...) unless 6/8, 9/8, 12/8 time, then it's 8:3.
        // So, if tempo not specified, as in '/tempo 84' then look at time signature.
        // Use its denominator as the tempo.noteDuration.firstNumber.
        // But if denominator is 8 and numerator is multiple of 3, then set the tempo.noteDuration to be 8:3.
        //
        // WATCH OUT, DUPLICATE CODE
        if (tempo.noteDuration.firstNumber == null || tempo.noteDuration.secondNumber == null) { // something's wrong, gotta fix it
          if (timeSig.denominator == 8 && timeSig.numerator % 3 == 0) { // if timesig is 6/8, or 9/8 or 12/8, or maybe even 3/8, then it should be 8:3
            tempo.noteDuration.firstNumber = 8;
            tempo.noteDuration.secondNumber = 3;
          }
          else {
            tempo.noteDuration.firstNumber ??= timeSig.denominator; // If timeSig is anything other than 3/8, 6/8, 9/8, 12/8, ...
            tempo.noteDuration.secondNumber ??= 1;
          }
        }

        // addTempoChangeToTrackEventsList(tempo, noteChannel, snareTrackEventsList);
        addTempoChangeToTrackEventsList(tempo, snareTrackEventsList);
        continue;
      }
      if (element is TimeSig) { // what?  comment????
        // addTimeSigChangeToTrackEventsList(element, noteChannel, snareTrackEventsList);
        addTimeSigChangeToTrackEventsList(element, snareTrackEventsList);
        continue;
      }
      log.finer('have something else not putting into the track: ${element.runtimeType}, $element');
    } // end of list of events to add to snare track

    if (snareTrackEventsList.isEmpty) {
      log.warning('What?  no events for track?');
    }
    return snareTrackEventsList;
  }


  // void addTimeSigChangeToTrackEventsList(TimeSig timeSig, int channel, List<MidiEvent> trackEventsList) {
  void addTimeSigChangeToTrackEventsList(TimeSig timeSig, List<MidiEvent> trackEventsList) {
    var timeSignatureEvent = TimeSignatureEvent();
    timeSignatureEvent.type = 'timeSignature';
    timeSignatureEvent.numerator = timeSig.numerator; // how are these used in a midi file?  Affects sound or tempo????
    timeSignatureEvent.denominator = timeSig.denominator;
    timeSignatureEvent.metronome = 18; // for module synchronization
    timeSignatureEvent.thirtyseconds = 8; // Perhaps for notation purposes
    trackEventsList.add(timeSignatureEvent);
  }

  // Prior to calling this, tempo should have a note duration in it
  // void addTempoChangeToTrackEventsList(Tempo tempo, int channel, List<MidiEvent> trackEventsList) {
  /// trackEventsList could be track zero or other
  void addTempoChangeToTrackEventsList(Tempo tempo, List<MidiEvent> trackEventsList) {
    var setTempoEvent = SetTempoEvent();
    setTempoEvent.type = 'setTempo';
    var useThisTempo = tempo.bpm / (tempo.noteDuration.firstNumber / tempo.noteDuration.secondNumber / 4); // this isn't really right.
    setTempoEvent.microsecondsPerBeat = (microsecondsPerMinute / useThisTempo).floor(); // not round()?   How does this affect anything?  If no tempo is set in 2nd track, then this takes precedence?
    log.finer('Adding tempo change event to some track events list, possibly track zero, but any track events list');
    trackEventsList.add(setTempoEvent);
  }

  ///
  /// Create and add a NoteOnEvent and a NoteOffEvent to the list of events for a track,
  /// The caller of this method has access to the Note which holds the nameValue and type, etc.
  /// May want to watch out for cumulative rounding errors.  "snareLangNoteNameValue" can be
  /// a something like 1.333333, so it shouldn't be called a NameValue like "4:3" could be.
  /// Clean this up later.
  ///
  // double addNoteOnOffToTrackEventsList(Note note, int channel, List<MidiEvent> trackEventsList, bool usePadSoundFont) {
  double addNoteOnOffToTrackEventsList(Note note, List<MidiEvent> trackEventsList, bool usePadSoundFont, bool loopBuzzes, Voice voice) {

    if (note.duration == null) {
      log.severe('note should not have a null duration.');
    }
    // var snareLangNoteNameValue = (note.duration.firstNumber / note.duration.secondNumber).floor(); // is this right???????
    var snareLangNoteNameValue = note.duration.firstNumber / note.duration.secondNumber; // is this right???????
    if (note.noteType == NoteType.rest) {
      note.velocity = 0; // new, nec?
    }
    // Maybe this should be put into Note, even though it's a MIDI thing.
    var noteNumber;
    switch (note.noteType) {
      case NoteType.tapRight:
        noteNumber = 60;
        if (voice == Voice.unison) {
          noteNumber = 20;
        }
        break;
      // case NoteType.tapUnison:
      //   noteNumber = 20;
      //   break;
      case NoteType.tapLeft:
        noteNumber = 70;
        if (voice == Voice.unison) {
          noteNumber = 20;
        }
        break;
      // case NoteType.flamUnison:
      //   noteNumber = 21;
      //   break;
      case NoteType.flamRight:
        noteNumber = 61;
        if (voice == Voice.unison) {
          noteNumber = 21;
        }
        break;
      case NoteType.flamLeft:
        noteNumber = 71;
        if (voice == Voice.unison) {
          noteNumber = 21;
        }
        break;
      // case NoteType.dragUnison:
      //   noteNumber = 21; // wrong, but don't have a drag recorded yet by SLOT
      //   break;
      case NoteType.dragRight:
        noteNumber = 72; // temp until find out soundfont problem
        if (voice == Voice.unison) {
          noteNumber = 21;// wrong, but don't have a drag recorded yet by SLOT
        }
        break;
      case NoteType.dragLeft:
        noteNumber = 72;
        if (voice == Voice.unison) {
          noteNumber = 21;// wrong, but don't have a drag recorded yet by SLOT
        }
        break;
      // case NoteType.rollUnison:
      //   noteNumber = 23; // this one is looped.  This is called RollSlot
      //   break;
      case NoteType.buzzRight:
        noteNumber = 63;
        if (loopBuzzes) {
          noteNumber = 67; // this one is looped
        }
        if (voice == Voice.unison) {
          noteNumber = 23;// wrong, but don't have a drag recorded yet by SLOT
        }
        break;
      case NoteType.buzzLeft:
        // If loop, add 4 to be 77
        noteNumber = 73;
        if (loopBuzzes) {
          noteNumber = 77; // this one is looped
        }
        if (voice == Voice.unison) {
          noteNumber = 23;// wrong, but don't have a drag recorded yet by SLOT
        }
        break;
      // Later add SLOT Tuzzes, they have lots in the recording
      case NoteType.tuzzLeft:
        noteNumber = 74;
        break;
      case NoteType.tuzzRight:
        noteNumber = 64;
        break;
      case NoteType.ruff2Left:
      noteNumber = 75;
      break;
      case NoteType.ruff2Right:
      noteNumber = 65;
      break;
      case NoteType.ruff3Left:
      noteNumber = 76;
      break;
      case NoteType.ruff3Right:
      noteNumber = 66;
      break;
      case NoteType.rest:
        noteNumber = 99; // see if this helps stop blowups when writing
        break;
      default:
        log.fine('noteOnNoteOff, What the heck was that note? $note.type');
    }

    // FIX THIS LATER WHEN SOUND FONT HAS SOFT/MED/LOUD RECORDINGS.
    if (soundFontHasSoftMediumLoudRecordings) {
      //
      // This is new, to take advantage of the 3 different volume levels in the recordings, which were separated by 10 note numbers.
      //
      if (note.velocity < 50) {
        log.finer('Note velocity is ${note.velocity}, so switched to quiet recording.');
        noteNumber -= 10;
      }
      else if (note.velocity > 100) {
        log.finer('Note velocity is ${note.velocity}, so switched to loud recording.');
        noteNumber += 10;
      }
      else {
        log.finer('Note velocity is ${note.velocity}, so did not switch recording.');
      }
    }

    if (usePadSoundFont) {
      noteNumber -= 20;
    }

    var noteOnEvent = NoteOnEvent();
    noteOnEvent.type = 'noteOn';
    noteOnEvent.deltaTime = 0; // might need to adjust to handle roundoff???
    noteOnEvent.noteNumber = noteNumber;
    noteOnEvent.velocity = note.velocity;
    // noteOnEvent.channel = channel;
    noteOnEvent.channel = 0; // dumb question: What's a channel?  Will I ever need to use it?
    trackEventsList.add(noteOnEvent);

    var noteOffEvent = NoteOffEvent();
    noteOffEvent.type = 'noteOff';
    noteOffEvent.deltaTime = (4 * ticksPerBeat / snareLangNoteNameValue).round(); // keep track of roundoff?
    noteOffEvent.noteNumber = noteNumber;
    // noteOffEvent.velocity = note.velocity; // shouldn't this just be 0?
    noteOffEvent.velocity = 0; // shouldn't this just be 0?
    // noteOffEvent.channel = channel;
    noteOffEvent.channel = 0; // dumb question: What's a channel?  Will I ever need to use it?

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
    var noteTicksAsDouble = 4 * ticksPerBeat / snareLangNoteNameValue;
    var diffTicksAsDouble = noteTicksAsDouble - noteOffEvent.deltaTime;
    cumulativeRoundoffTicks += diffTicksAsDouble;

    log.finest('noteOnNoteOff, Created note events for noteName ${snareLangNoteNameValue}, '
        'deltaTime ${noteOffEvent.deltaTime} (${noteTicksAsDouble}), velocity: ${note.velocity}, '
        'number: ${noteNumber}, cumulative roundoff ticks: $cumulativeRoundoffTicks');
    return diffTicksAsDouble; // kinda strange
  }
}

