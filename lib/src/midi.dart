import 'package:dart_midi/dart_midi.dart';
import 'package:logging/logging.dart';
import 'dart:math';
import '../snarelang4.dart';

bool soundFontHasSoftMediumLoudRecordings = false; // Change this later when sound font file has soft,med,loud recordings, and mapped offsets by 10
///
/// The Dart midi library with no explanations, which is basically a rewrite of a JavaScript library:
/// https://pub.dev/documentation/dart_midi/latest/midi/midi-library.html
/// Wish I knew where the javascript library was, or some kind of documentation behind these things.
/// And what is this?:
/// https://www.mixagesoftware.com/en/midikit/help/HTML/meta_events.html
/// A midi spec: http://www.cs.cmu.edu/~music/cmsip/readings/Standard-MIDI-file-format-updated.pdf
/// is based on https://github.com/gasman/jasmid, with no API documentation.
/// Don't know how close this is, but might also wanna look at javax.sound.midi library.
/// https://docs.oracle.com/javase/7/docs/api/javax/sound/midi/package-summary.html
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
/// In order to do midi events, you gotta understand timing.  That means understand things
/// like ticks, beats, clocks, seconds, or whatever.  At the lowest level of the Dart
/// library you have events, and those work off of timings.
///
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


/// 2.2 - MIDI File Formats 0,1 and 2A Format 0 file has a header chunk followed by one track chunk.
/// It is the most interchangeable representation of data.  It is very useful for a simple single-track
/// player in a program which needs to make synthesisers make sounds, but which is primarily concerned
/// with something else such as mixers or sound effect boxes. It is very desirable to be able to produce
/// such a format, even if your program is track-based, in order to work with these simple programs.
/// A Format 1 or 2 file has a header chunk followed by one or more track chunks. programs which support
/// several simultaneous tracks should be able to save and read data in format 1, a vertically one dimensional
/// form, that is, as a collection of tracks. Programs which support several independent patterns should be able to
/// save and read data in format 2, a horizontally one dimensional form. Providing these minimum capabilities
/// will ensure maximum interchangeability.In a MIDI system with a computer and a SMPTE synchroniser which uses
/// Song Pointer and Timing Clock,tempo maps (which describe the tempo throughout the track, and may also
/// include time signature information, so that the bar number may be derived) are generally created on the computer.
/// To use them with the synchroniser, it is necessary to transfer them from the computer. To make it easy for the synchroniser to
/// extract this data from a MIDI File, tempo information should always be stored in the first MTrk chunk. For a
/// format 0 file, the tempo will be scattered through the track and the tempo map reader should ignore the
/// intervening events; for a format 1 file, the tempo map must be stored as the first track. It is polite to a tempo
/// map reader to offer your user the ability to make a format 0 file with just the tempo, unless you can use
/// format 1.All MIDI Files should specify tempo and time signature. If they don't, the time signature is assumed to be
/// 4/4,and the tempo 120 beats per minute. In format 0, these meta-events should occur at least at the beginning of
/// the single multi-channel track. In format 1, these meta-events should be contained in the first track. In format2,
/// each of the temporally independent patterns should contain at least initial time signature and tempo
/// information.Format IDs to support other structures may be defined in the future. A program encountering an unknown
/// format ID may still read other MTrk chunks it finds from the file, as format 1 or 2, if its user can make sense
/// of them and arrange them into some other structure if appropriate. Also, more parameters may be added to the
/// MThd chunk in the future: it is important to read and honour the length, even if it is longer than 6.
///
/// Channel vs track vs patch vs program vs ...  I think maybe they're all kinda the same thing.
///
///
///
/// Standard MIDI file format, updatedhttp://www.csw2.co.uk/tech/midi2.htm5 of 2310/22/2003 10:35 AM
/// the synchroniser, it is necessary to transfer them from the computer. To make it easy for the synchroniser to
/// extract this data from a MIDI File, tempo information should always be stored in the first MTrk chunk. For a
/// format 0 file, the tempo will be scattered through the track and the tempo map reader should ignore the
/// intervening events; for a format 1 file, the tempo map must be stored as the first track. It is polite to a tempo
/// map reader to offer your user the ability to make a format 0 file with just the tempo, unless you can use
/// format 1.All MIDI Files should specify tempo and time signature. If they don't, the time signature is assumed
/// to be 4/4,and the tempo 120 beats per minute. In format 0, these meta-events should occur at least at the beginning of
/// the single multi-channel track. In format 1, these meta-events should be contained in the first track.
/// In format2, each of the temporally independent patterns should contain at least initial time signature and tempo
/// information.Format IDs to support other structures may be defined in the future. A program encountering an unknown
/// format ID may still read other MTrk chunks it finds from the file, as format 1 or 2, if its user can make sense
/// of them and arrange them into some other structure if appropriate. Also, more parameters may be added to the
/// MThd chunk in the future: it is important to read and honour the length, even if it is longer than 6
///
///
/// Every note has a channel.  I don't know how that works if you change the channel.  Perhaps it's only for "transport"
/// of signal?
///
/// Just a note, don't know where to put it for now.  Regarding buzz notes, we need different durations in the sound font.
/// If you only have one duration, say one that bounces a long time, it can't be used for very short buzzes.  For short
/// ones in the scores, you need a buzz that's short and more crushed.  So, to choose the correct buzz, it depends on the
/// target tempo.  When the user of MidiVoyager slows something way down, the buzzes will sound really short or longer,
/// depending on which one was chosen when the soundfont buzz was chosen.  I think that's about the best you can do, because
/// MidiVoyager doesn't make a selection based on tempo.  It would be good if it did.  (So I need to write my own midi player.)
///
/// As far as I know, a soundfont can contain multiple "presets", and maybe a preset is a list of "instruments", like
/// the instruments making up a brass section, and could be called "brass", or "drumline" for a set of snares and other drums.
/// And an instrument is composed of a set of samples.
///
/// When I create a soundfont file, usually it contains one preset, and that preset is "DrumLine".  I'd like to create another
/// one called "Pipes", and it would be composed of the instruments "HighlandPipes", "Chanter", "SmallPipes", "ePipes" or whatever.
/// And a "Chanter" instrument would be composed of around 30 samples, corresponding to the various note/embellishment combinations
/// that are common.
///
/// The problem is telling my software to use a different preset within that sondfont file.  Do you do it with ProgramChangeMidiEvent ????
/// I can create such an object, and set a "programNumber".  But maybe I have to next write it.
///
/// Okay, in the soundfont file tool I'm using, there's a "Bank", and a "preset".  I think a Bank can have multiple presets in it.
///

class Midi {
  static final ticksPerBeat = 10080; // put this elsewhere later
  static final microsecondsPerMinute = 60000000;

//  // Was getting double log messages, so maybe one global one is good enough, wich I think is in MyParser.dart
  final log = Logger('MyMidiWriter'); // does nothing on it's own, right?


  // When we have fractional ticks for note durations rounding causes some timings to be slightly off.
  // Keep track of how far off we get, and do something about it when necessary.  The
  // problem durations are for notes such as 9, 11, 13, 17, 18, 19 and others.  Not a big deal.
  double cumulativeRoundoffTicks = 0.0;

  ///
  ///   Create a MidiHeader object, which I did not define, which is part of MidiFile, and return it.
  ///   I don't think there's anything much in this header.  I don't know how it relates to a real
  ///   midi file.
  MidiHeader createMidiHeader() {
    // Construct a header with values for name, and whatever else
    // var midiHeaderOut = MidiHeader(ticksPerBeat: Midi.ticksPerBeat, format: 1, numTracks:2); // puts this in header with prop "ppq"  What would 2 do?
    log.finest('hey watch that numTracks thing in header (default 2), and also format (default 1).');
    // var midiHeaderOut = MidiHeader(ticksPerBeat: ticksPerBeat, format: 1, numTracks:3); // puts this in header with prop "ppq"  What would 2 do?
    // Format of 1 seems the only value that works.  See midi spec somewhere about this.
    // numTracks doesn't seem to matter???
    var midiHeaderOut = MidiHeader(ticksPerBeat: ticksPerBeat, format:1, numTracks:2); // puts this in header with prop "ppq"  What would 2 do?
    return midiHeaderOut;
  }


  /// Add lists of events to tracks, and add the tracks to the list of midiTracks passed in.
  /// For now, only one track is worked on at a time.  A new track is created when one of the elements
  /// is a Track element.  There would be a new track for each instrument, or ensemble.  Snare, snareUnison,
  /// pad, tenor, bass, pipes.
  ///
  /// So, we're cruisin' along adding elements to a list and if we run out of elements then we're done with
  /// the list and we add it, as a "track" to the midiTracks list.  Or, if we encounter a new Track element,
  /// then we probably just add the existing list to the midiTracks list, and start a new list and add it later.
  ///
  /// The midiTracks list already has a trackZero list, which contains timeSig, and Tempo, and is supposed to
  /// be able to hold a tempoMap.
  ///
  // List<List<MidiEvent>> addMidiEventsToTracks(List<List> midiTracks, List elements, num tempoScalar, TimeSig overrideTimeSig, bool usePadSoundFont, bool loopBuzzes, overrideTrack) {
  List<List<MidiEvent>> addMidiEventsToTracks(List<List> midiTracks, List elements, commandLine) { // this list of elements is supposed to be a list of midi events?  Why two names, elements and midiEvents?
    log.fine('In Midi.createMidiEventsTracksList()');
    var trackEventsList = <MidiEvent>[];

    var noteChannel = Channel.DefaultChannelNumber;
    //var currentVoice = Voice.solo; // Hmmmmm done differently elsewhere as in firstNote.  Check it out later
    var usePadSoundFont = commandLine.usePadSoundFont;
    var loopBuzzes = commandLine.loopBuzzes; // silly.  just use commandLine.loopBuzzes, right?
    var trackNameEvent = TrackNameEvent();
    trackNameEvent.text = trackIdToString(commandLine.track.id); // RIGHT????????????????????only useful if nothing specified at start of score, right?
    // print('Hey trackNameEvent.text is ${trackNameEvent.text}');
    trackNameEvent.deltaTime = 0;  // add track delay here?????
    var snareNumber; // keep null if don't want drumline sound, and only one snare (5?) is specified.



    // Experiment for snare line
    // Experiment for snare line
    Tempo mostRecentTempo; // assuming here that we'll hit a tempo before we hit a note, because already added a scaled tempo at start of list.
    num scaleAdjustForNon44 = 1.0;
    TimeSig mostRecentTimeSig;



// so a patch is an instrument?


    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // http://midi.teragonaudio.com/
// From http://midi.teragonaudio.com/tutr/bank.htm
// When the MIDI spec was first developed, it wasn't foreseen that anyone would need more than 128 patches on a given module.
// (Back then, most didn't even have anywhere near that number of patches). So, the MIDI Program Change message was hardwired
// to have a limit of counting only from 1 to 128.
// Later, modules with more than 128 patches came on the market. People needed some way of being able to switch
// to these extra patches, but which was still compatible with the old way of switching patches.
// The manufacturers adopted a scheme of arranging patches in "banks" (ie, groups of usually 128 patches).
// For example, the first 128 patches in a module may be "bank 1". The next 128 patches may be "bank 2". Etc.
// Theoretically, there can be up to 16,384 banks on a module.
    // The technique that the manufacturers adopted for MIDI control over patch changing is to have the musician first
    // select the bank that contains his desired patch, and then select the patch within that bank.
    // For example, assume that a musician wants to select the patch "Gungho" which happens to be the third patch
    // in the second bank. First the musician would have to send one or two (depending upon how the manufacturer arranged
    // patches into banks) MIDI messages to select the second bank (MIDI counts this as bank 1, since MIDI considers
    // bank number 0 to actually be the first bank). Then, the musician sends a MIDI message to select the third patch
    // (again, MIDI considers patch number 0 to be the first patch in a bank, so the third patch would actually be number 2).
    //
    // So, selecting a patch is a two-step (ie, 2 or 3 message) process. First, you send the Bank Select message(s)
    // to switch to the desired bank. Then you send an ordinary Program Change message to select which one of the
    // 128 possible patches in that bank you desire.
    //
    // The Bank Select messages are actually MIDI Controller messages, just like Volume, Pan, Sustain Pedal, Wind,
    // and other controllers. Specifically, the controller number for the "Most Significant Byte" (ie, MSB) of
    // Bank Select is controller 0. The controller number for "Least Significant Byte" (ie, LSB) of Bank Select
    // is controller 32. The data for these messages are the bank number you want to select. (Sometimes the MSB
    // Bank Select is referred to as the coarse adjustment for bank, and the LSB Bank Select is referred to as
    // the fine adjustment).
    //
    // NOTE: We need to use 2 messages to contain the bank number because, due to MIDI's design, it's not possible
    // to transmit a value greater than 128 in just one controller message. Remember that a bank number can go as
    // high as 16,384, and you need 2 MIDI controller messages to send such a large value. But, since most modules
    // do not have more than 128 banks anyway, these modules typically only use the MSB message (ie, controller number 0)
    // to select bank, and ignore any LSB message (ie, controller number 32). So then, here are the two messages
    // (in hexadecimal, assuming MIDI channel 1, and assuming that the module only uses the MSB Bank Select controller)
    // to select that "Gungho" patch:
    //
    // B0 00 01	Switch to bank 2 (NOTE: only the MSB message needed)
    // C0 02	Switch to the third patch in this bank

// Okay, so banks are a collection of patches.  A "program" contains patches.  So a program is a bank?
// What's a patch?  A single sample assigned to a number?

    // And then in the Polyphone program there are "Presets", which is a collection of "Instruments", and an instrument is a collection of samples.
    //
    // The Dart/JavaScript/Whatever midi commands/methods/functions only have
    // ControllerEvent: channel, number, type, value
    // ProgramChangeMidiEvent class, which has a channel number and a program number as fields.
    // SequenceNumberEvent class, prob nothing of interest
    // SequenceSpecificEvent, prob nothing of interest
    // TrackNameEvent
    // InstrumentNameEvent

    // I don't know how to use this program change stuff, but hopefully when I get it right it will allow me to change
    // the bank's preset

    // starting to think that you can maybe select a different "preset" in the sound font by specifying a ProgramChangeMidiEvent.
    // Perhaps a "preset" in the soundfont file is like a "bank", or maybe "program", or maybe a "patch", but not sure.
    // The following doesn't seem to do anything, but some values are required if you want to send that event.
    // But maybe a "patch" is an instrument.
    var controllerEvent = ControllerEvent();
    log.fine('controllerEvent: $controllerEvent');
    log.fine('controllerEvent: channel, number, type, value, deltaTime: ${controllerEvent.channel}, ${controllerEvent.number}, ${controllerEvent.type}, ${controllerEvent.value}, ${controllerEvent.deltaTime}');
    controllerEvent.channel = 0;
    controllerEvent.number = 1; // guess
    controllerEvent.type = "Bajingo"; // guess
    controllerEvent.value = 0; // guess
    controllerEvent.deltaTime = 0;
    //trackEventsList.add(controllerEvent);

    var programChangeMidiEvent = ProgramChangeMidiEvent();
    log.fine('programChangeMidiEvent.channel, .programNumber: ${programChangeMidiEvent.channel}, ${programChangeMidiEvent.programNumber}');
    programChangeMidiEvent.programNumber = 0; // maybe 1 for the next preset?????
    programChangeMidiEvent.channel = 5; // cannot be null, it seems, and whatever number this is, will turn off that channel that's specified in the file for the instrument.  Used as a track in my software????
    programChangeMidiEvent.deltaTime = 0;
    //trackEventsList.add(programChangeMidiEvent); // does this screw everything up?  Yes!  It causes the metronome to go away!  What's special about the metronome??????  In Black Bear metronome is channel 0
    // SEEMS THAT IF programNumber is 1 and channel is 5 then snare turns off.  But if program number is 0, then it doesn't turn off.!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // So, experiment with program number to see if can change to a different patch (instrument)

    // //programChangeMidiEvent.type = 'whatever';
    //
    // var instrumentNameEvent = InstrumentNameEvent();
    // print('instrumentNameEvent: $instrumentNameEvent');
    // instrumentNameEvent.text = 'bilbo';
    // trackEventsList.add(instrumentNameEvent);









    // Go through the elements, seeing what each one is, and add it to the current track if right kind of element.
    // Of course this is not yet written to midi.
    for (var element in elements) {
      if (element is Channel) {
        noteChannel = element.number;
        // what, no continue;?
        continue; // new
      }







      // Experiment for snare line
      // Experiment for snare line
      // Experiment for snare line
      // Experiment for snare line
      // Experiment for snare line
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
        mostRecentTempo = element;
      }

















      if (element is Track) { // I do not trust the logic in this section.  Revisit later.  Does this mean that we'd better have a Track command at the start of a score?????????????  Bad idea/dependency
        var thisTrack = element as Track;
        // // if (track.id == currentTrack.id || midiTracks.isEmpty) {
        // if (midiTracks.isEmpty) {
        //   print('In addMidiEventsToTracks and got a Track element, and is either same as current, or this track is empty, so doing nothing with it and skipping it.');
        //   continue;
        // }
        log.finer('New Track element ${thisTrack.id}');
        //print('New Track element ${thisTrack.id}');
        // do something here to change the patch or channel or something so the soundfont can be accessed correctly?
        if (thisTrack.id == TrackId.pad) { // this is kinda silly.  Pad should be an instrument
          usePadSoundFont = true;
        }
        else {
          usePadSoundFont = false;
        }

        // Is this needed any more if we're not doing offset based on where the snare is in the line?  Doing random instead?????
        // Or maybe there's just a little bit of effect, a real small amount?  It all depends on where the listener stands.  If
        // standing in the same line at the end, it would probably be worst.  In the middle, half as bad.  100 feet in front of
        // snare 5 might sound like one drum.  If I picture myself somewhere listening to a drum line, it would probably be 20
        // feet in front of snare 5.  And if only 9 snares, then the time sound difference won't be much.  So, I think this is
        // minimal, and the bigger difference is in individual NON-UNIFORM inaccuracies when playing.  So this is a note by note
        // randomness thing, I think.
        // hack:
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
            //print('Huh?  Whats this element.id?: ${thisTrack.id}'); // could be met or tenor or bass...
            break;
        }
        //
        // At this point we have a current track which may or may not have anything in it except maybe a track name event.
        // (Check that out)
        // Whether it does or doesn't, close it and add it (maybe), and start a new track and put the name into it.
        //
        if (trackEventsList.isNotEmpty) {
          var endOfTrackEvent = EndOfTrackEvent(); // this is new
          endOfTrackEvent.deltaTime = 0;  // subtract off track delay here??????  Just an idea
          trackEventsList.add(endOfTrackEvent); // sure???????
          log.fine('addMidiEventsToTrack() added endOfTrackEvent $endOfTrackEvent to trackEventsList');

          midiTracks.add(trackEventsList);
          trackEventsList = <MidiEvent>[]; // start a new one
        }
        var trackNameEvent = TrackNameEvent();
        // trackNameEvent.text = trackIdToString(overrideTrack.id); // ??
        trackNameEvent.text = trackIdToString(thisTrack.id); // ????????????????????????????????????????????????????????????????????????????????????????????????



        trackNameEvent.deltaTime = 0;  // time since the previous event?   Wonder if I can stick in the track delay here, for multiple snares






        // I don't think this is working so well.  I think it has to be random delay, per note.
        //
        // // LET'S TRY IT!!!!!!!!!!!!!!!!!!!!!!!!
        // // Well, it really doesn't sound like a line.  It sounds strange.  Perhaps need to detune some of the drums.
        // //   var tempoScaledDelay = (0.11 * thisTrack.delay * scaleAdjustForNon44 / (100 / mostRecentTempo.bpm)).round();
        //   var tempoScaledDelay = (0.1 * thisTrack.delay * scaleAdjustForNon44 / (100 / mostRecentTempo.bpm)).round();
        //   print('\tHey, tempoScaledDelay is $tempoScaledDelay because most recent tempo is ${mostRecentTempo.bpm}');
        //   trackNameEvent.deltaTime += tempoScaledDelay; // what's the units?  At 60bpm a delay of 1000 is almost the same as a 16th note, and at 30bpm it's twice as long.  So tempo sensitive.
        //   // We don't want that.  So, scale it by the tempo.
        //
        //















        trackEventsList.add(trackNameEvent);
        log.finer('Added track name: ${trackNameEvent.text}');
        // if (trackNameEvent.text == trackIdToString(TrackId.unison)) { // THIS IS A TOTAL HACK.  Clear up this Track/Track and Voice stuff.  Prob remove Voice, and make Unison an instrument
        //   currentVoice = Voice.unison;
        // }
        //continue; // was here, moved down
        //}
        continue; // new here
      }
      // if (element is Voice) { // may get rid of Voice, since starting to develop tracks
      //   currentVoice = element; // ????
      //   continue; // new
      // }
      if (element is Note) {
        //print('snareNumber: $snareNumber and nSnares is ${commandLine.nSnares}');

        // Adjust for cumulative increase in sound when have a drumline rather than a soloist
        // Only do this if we have a snare line, and the note is for a snare drum other than #5
        if (commandLine.nSnares > 3 && snareNumber != 5) {
          switch (element.noteType) {
            case NoteType.metLeft:
            case NoteType.metRight:
            case NoteType.bassLeft:
            case NoteType.bassRight:
            case NoteType.tenorLeft:
            case NoteType.tenorRight:
            case NoteType.rest:
              break;
            default: // includes previousNoteDurationOrType????
              log.fine('velocity was ${element.velocity}');
              element.velocity = element.velocity - (commandLine.nSnares * 4);
              log.fine('now velocity is ${element.velocity}');
          }
        }



        // If the note is flam, drag, or ruff we should adjust placement of the note in the timeline so that the
        // principle part of the note is where it should go (and adjust after the note by the same difference.)
        // To do this, we need access to the previous note to shorten it.  So that means gotta process in a separate
        // loop, probably, prior to this point, or maybe after.  And it's only for a snare staff/track.
        // And can't assume the previous element in the list was a note!  Could be a dynamic element, or tempo, etc.
        //
        // addNoteOnOffToTrackEventsList(element, noteChannel, trackEventsList, usePadSoundFont, loopBuzzes, currentVoice, snareNumber); // add track param?  // return value unused
        addNoteOnOffToTrackEventsList(element, noteChannel, trackEventsList, usePadSoundFont, loopBuzzes, snareNumber); // the snare number is for the most recent track.  add track param?  // return value unused
        continue;
      }
      if (element is Tempo) {
        // HEY THIS IS IMPORTANT!  IT'S WHAT SETS THE REAL PLAYBACK TEMPO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // HEY THIS IS IMPORTANT!  IT'S WHAT SETS THE REAL PLAYBACK TEMPO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // HEY THIS IS IMPORTANT!  IT'S WHAT SETS THE REAL PLAYBACK TEMPO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // HEY THIS IS IMPORTANT!  IT'S WHAT SETS THE REAL PLAYBACK TEMPO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        var tempo = element as Tempo; // don't have to do this, but wanna

        //Tempo.fillInTempoDuration(tempo, overrideTimeSig); // check on this.  If already has duration, what happens?
        // first one can be bpm==null, right?
        addTempoChangeToTrackEventsList(tempo, trackEventsList); // also add to trackzero?   hey, hey, hey, hey, tempo can have a duration first/second of null!!!!!!
        mostRecentTempo = element; // hey if this works here, don't need to do it up above
        continue;
      }
      if (element is TimeSig) { // THIS IS WRONG.  SHOULD BE 2/2 for that tune in 2/2  not 2/4 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
        // addTimeSigChangeToTrackEventsList(element, noteChannel, snareTrackEventsList);
        addTimeSigChangeToTrackEventsList(element, trackEventsList); // also add to trackzero?
        mostRecentTimeSig = element; // hey if this works here, don't need to do it up above.
        continue;
      }
      if (element is Comment) {
        log.finest('Not putting comment into track event list: ${element.comment}');
        continue;
      }
      if (element is Text) {
        var textEvent = TextEvent();
        textEvent.deltaTime = 0; // nec?  Ignored?
        textEvent.text = element.text;
        trackEventsList.add(textEvent);
        continue;
      }
      if (element is Marker) {
        var markerEvent = MarkerEvent();
        markerEvent.deltaTime = 0; // nec?  Ignored?
        markerEvent.text = element.text;
        trackEventsList.add(markerEvent);
        continue;
      }
      log.finest('have something else not putting into the track: ${element.runtimeType}, $element');
    } // end of list of events to add to snare track











    if (trackEventsList.isEmpty) {  // right here?????
      log.warning('What?  no events for track?');
    }
    // Is this necessary?  Was working fine without it.
    var endOfTrackEvent = EndOfTrackEvent(); // this is new too.  One above like it
    endOfTrackEvent.deltaTime = 0; // subtract off track delay here??????????????
    trackEventsList.add(endOfTrackEvent); // quite sure???

    midiTracks.add(trackEventsList); // right?
    // return trackEventsList;
    return midiTracks;
  }


  // Maybe we want to add these events to trackzero too?  And if so, and if trackzero is only supposed to contain timesig and tempo events,
  // then I need to keep a running total of times as events go into other tracks so as to put in the right timing info??????
  // No, there's no timing info in this kind of event, or in a tempo event, it seems.  So to space them out there has to be rests, I guess.
  // void addTimeSigChangeToTrackEventsList(TimeSig timeSig, int channel, List<MidiEvent> trackEventsList) {
  void addTimeSigChangeToTrackEventsList(TimeSig timeSig, List<MidiEvent> trackEventsList) {
    var timeSignatureEvent = TimeSignatureEvent();
    timeSignatureEvent.type = 'timeSignature';
    timeSignatureEvent.numerator = timeSig.numerator; // how are these used in a midi file?  Affects sound or tempo????
    timeSignatureEvent.denominator = timeSig.denominator;
    timeSignatureEvent.metronome = 18; // for module synchronization  What?
    timeSignatureEvent.thirtyseconds = 8; // Perhaps for notation purposes
    trackEventsList.add(timeSignatureEvent);  // Maybe can't do subsequent timesig changes without putting it into trackZero???
  }

  // Add this info to track zero too?
  // Prior to calling this, tempo should have a note duration in it
  // void addTempoChangeToTrackEventsList(Tempo tempo, int channel, List<MidiEvent> trackEventsList) {
  /// trackEventsList could be track zero or other
  void addTempoChangeToTrackEventsList(Tempo tempo, List<MidiEvent> trackEventsList) {
    //print('addTempoChangeToTrackEventsList(), tempo bpm was ${tempo.bpm}');
    //tempo.bpm = (tempo.bpm + tempo.bpm * tempo.scalar / 100).floor();
    //tempo.bpm += (tempo.bpm * tempo.scalar / 100).floor();
    //print('tempo bpm is now ${tempo.bpm}');
    var setTempoEvent = SetTempoEvent();
    setTempoEvent.type = 'setTempo';
    // I think this next line is to account for tempos based on nonquarter notes, like 6/8 time.
    //
    // addMidiEventsToTrack is what called this method!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // The following formula is strange.  I don't understand it.  I think the 4 is because most midi stuff is
    // based on a 4/4 bar.  But it seems to work.
    // When noteDuration is 4:1 (a quarter note), then useThisTempo = bpm/(4/1/4) = bpm * 1
    // And if noteDuration is 8:3, then useThisTempo = bpm/((8/3)/4) = bpm * 3/2
    // If duration is 2:1 (a half note), then useThisTempo = bpm * ((2/1) / 4) = bpm * 0.5
    num useThisTempo = tempo.bpm / ((tempo.noteDuration.firstNumber / tempo.noteDuration.secondNumber) / 4); // this isn't really right, is it????
    //var useThisTempo = tempo.bpm * tempo.noteDuration.secondNumber; // experiment.  Above line was producing 144 from 96 for 6/8 time
    //print('What the crap useThisTempo: $useThisTempo');
    //
    //
    //
    if (useThisTempo > 248 || useThisTempo < 10) {
      log.warning('I think MIDI has a hard time with tempos greater than around 300 and seems to max out around 250, but slowly approaches that limit???');
    }
    //print('addTempoChangeToTrackEventsList(), useThisTempo: $useThisTempo');
    // setTempoEvent.microsecondsPerBeat = (microsecondsPerMinute / useThisTempo).floor(); // not round()?   I think should be round, and maybe a float?   How does this affect anything?  If no tempo is set in 2nd track, then this takes precedence?
    log.finest('gunna do calculation for setTempoEvent for microsecondsPerBeat. Tempo in: $tempo, mspb: $microsecondsPerMinute,  useThisTempo: $useThisTempo  divided: ${microsecondsPerMinute / useThisTempo}  and rounded: ${(microsecondsPerMinute / useThisTempo).round()}');
    setTempoEvent.microsecondsPerBeat = (microsecondsPerMinute / useThisTempo).round(); // how does this affect anything?  If no tempo is set in 2nd track, then this takes precedence?
    // setTempoEvent.microsecondsPerBeat = (microsecondsPerMinute / useThisTempo).floor(); // how does this affect anything?  If no tempo is set in 2nd track, then this takes precedence?
    //print('addTempoChangeToTrackEventsList(), for the setTempoEvent we have microsecondsPerBeat: ${setTempoEvent.microsecondsPerBeat}');
    log.fine('Adding tempo change event (${useThisTempo}bpm, ${setTempoEvent.microsecondsPerBeat/1000000} Sec/beat)to some track events list, possibly track zero???, but any track events list');
    trackEventsList.add(setTempoEvent);
  }



  ///
  /// Create and add a NoteOnEvent and a NoteOffEvent to the list of events for a track,
  /// The caller of this method has access to the Note which holds the nameValue and type, etc.
  /// May want to watch out for cumulative rounding errors.  "snareLangNoteNameValue" can be
  /// a something like 1.333333, so it shouldn't be called a NameValue like "4:3" could be.
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
  /// So, basically you're looking at two notes at once: the current note and the previous note.
  /// If the current note has grace notes, reduce the previous note's NoteOff deltaTime, and
  /// increase the current note's NoteOff deltaTime the same amount.  Then advance.
  /// Special condition for first note.  Maybe not last note.
  ///
  /// BUT in this method we only have access to the current note.  So the logic doesn't go here.
  ///
  /// Clean this up later.  It's too long for one thing.
  ///
  /// And should we add rest notes to track zero so that we know where to do the timesig and tempo changes?
  ///
  /// And as of 2021/01/04 there's a new experimental thing to handle a drumline of 9 snares in a line, where
  /// timing will be used to simulate sound delay from the outer snares to the center, to make the sound fatter,
  /// which I think is part of the reason drumlines sound different than a single snare.  One reason anyway.
  /// So this is an experiment.  And rather than adjusting every note played by that instrument, is it possible
  /// to just do an offset at the very start before any note is played, or at the very first note?  And how are
  /// these notes calculated, isn't it based off the previous note?  So, after you've adjusted the first note
  /// then you don't adjust any more notes.
  /// Also, we don't want this based on tempo.  We want an absolute time, right?  Of course.  But in playback
  /// when the user speeds it up, that value probably shortens.  So, it's important for the tempo in the score
  /// to be the target tempo whereby the delay is calculated.
  // double addNoteOnOffToTrackEventsList(Note note, int channelNumber, List<MidiEvent> trackEventsList, bool usePadSoundFont, bool loopBuzzes, Voice voice, int snareNumber) { // add track?
  double addNoteOnOffToTrackEventsList(Note note, int channelNumber, List<MidiEvent> trackEventsList, bool usePadSoundFont, bool loopBuzzes, snareNumber) { // add track?
    // For now assume that if snareNumber is not null, then we want the drumline sound
    var wantDrumLine = snareNumber != null; // bad logic.  Could be here for met, tenor, bass
    // var graceOffset = 0;
    if (note.duration == null) {
      log.severe('note should not have a null duration.');
    }

    // Determine the noteNumber for the note.  The noteNumber determines what soundFont sample to play
    // note.setNoteNumber(voice, loopBuzzes, usePadSoundFont, snareNumber);
    note.setNoteNumber(loopBuzzes, usePadSoundFont, snareNumber); // hey, maybe "note" knows what snare number it is, if it's a snare, right?  Prob.

      // // var snareLangNoteNameValue = (note.duration.firstNumber / note.duration.secondNumber).floor(); // is this right???????
    var snareLangNoteNameValue = note.duration.firstNumber / note.duration.secondNumber; // is this right???????  A double?
    if (note.noteType == NoteType.rest) {
      note.velocity = 0; // new, nec?
    }


    //
    // Here it is.  Here's where the note will go into a list of midi events.
    // deltaTime has been 0, but may need to adjust for roundoffs, or perhaps for gracenotes preceding beat?
    //
    // Not sure.  But if the note is something like a three stroke ruff then it probably needs to be
    // shifted earlier in the timeline, which means subtract time off the previous note, and then add
    // that time back to the end of the note.  And to do this I need access to the previous note, or next
    // note.  And that means this adjustment has to be done before we write it to midi.  Well,
    // what happens in this method?  Do we write to midi here?  No, looks like it's just written to a
    // list.  But, noteOnEvent and noteOffEvent are midi objects, not mine.
    //
    // Something totally new now...2021 01 04 .... If we have a line of 9 snares, and the listener is in the middle,
    // or on the middle plane, sound from the edges takes longer to get to that plane, and so to simulate that
    // sound, we'd want to delay those outer snares in the balanced/panned midi so it sounds fatter.
    // If we don't, every snare track sounds at the same time and then the result is just one louder snare in the middle.
    //
    var noteOnEvent = NoteOnEvent();
    noteOnEvent.type = 'noteOn';






    // Maybe we can add a value here so that outer snares play later: ???????????????  No, I think we want to go random values
    noteOnEvent.deltaTime = 0; // might need to adjust to handle roundoff???  Can you do a negative amount, and add the rest on the off note?????????????????????????????????????????
    // This is total hack and guess.  Don't know if this will cause a slide of everything after this, or whether it's compensated for somehow
    // I think it compounds over time.  Needs adjustment for subsequent notes.
    //print('hey, note type is a ruff3Left: ${note.noteType == NoteType.ruff3Left}');
    // if (note.noteType == NoteType.ruff3Left || note.noteType == NoteType.ruff3Right || note.noteType == NoteType.ruff3AltLeft || note.noteType == NoteType.ruff3AltRight) {
    //   print('NoteType: $note');
    // }

    // if (note.deltaTimeDelayForRandomSnareLine > 0 && note.noteType != NoteType.ruff3Left && note.noteType != NoteType.ruff3Right) {
    //   if (wantDrumLine && snareNumber != 5 && note.deltaTimeDelayForRandomSnareLine > 0) {
    //     //print('\t\t\tnote.deltaTimeDelayForRandomSnareLine is ${note.deltaTimeDelayForRandomSnareLine} and noteOnEvent.deltaTime is ${noteOnEvent.deltaTime}');
    //     noteOnEvent.deltaTime += note.deltaTimeDelayForRandomSnareLine;  // Also don't know if the units are right, or need to be scaled.
    //     //print('\t\t\t\tso now noteOnEvent.deltaTime is ${noteOnEvent.deltaTime}');
    //   }
    noteOnEvent.deltaTime += note.deltaTimeDelayForRandomSnareLine;




      // noteOnEvent.deltaTime = graceOffset; // Can you do a negative amount, and add the rest on the off note?
      noteOnEvent.noteNumber = note.noteNumber; // this was determined above by all that code
      noteOnEvent.velocity = note.velocity;
      noteOnEvent.channel = channelNumber;  // why doesn't note have a channelNumber attribute?
      trackEventsList.add(noteOnEvent);
      log.finest('addNoteOnOffToTrackEventsList() added endOnEvent $noteOnEvent to trackEventsList');

      var noteOffEvent = NoteOffEvent();
      noteOffEvent.type = 'noteOff';




      // noteOffEvent.deltaTime = (4 * ticksPerBeat / snareLangNoteNameValue).round(); // keep track of roundoff?
      // // var diff = note.postNoteShift + note.preNoteShift;
      // noteOffEvent.deltaTime += note.noteOffDeltaTimeShift; // for grace notes.  May be zero if no grace notes, or if consecutive same grace notes, like 2 or more flams
      noteOffEvent.deltaTime = (4 * ticksPerBeat / snareLangNoteNameValue).round(); // keep track of roundoff?


      //print('\t\t\t\t\tnote.deltaTimeShiftForGraceNotes is ${note.deltaTimeShiftForGraceNotes} and noteOffEvent.deltaTime is ${noteOffEvent.deltaTime}');
      noteOffEvent.deltaTime += note.deltaTimeShiftForGraceNotes; // for grace notes.  May be zero if no grace notes, or if consecutive same grace notes, like 2 or more flams
      //print('\t\t\t\t\t\tSo now noteOffEvent.deltaTime is ${noteOffEvent.deltaTime}');



      // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!111111111
      // This is probably not the best way to make the sound of a snare line.  Perhaps we can assume the listener is at the END of the
      // line, and not directly in the middle, and everyone plays perfectly, but the sound delay is linear based on distance from the ear.
      // So, should try this out some time!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
      // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!11
      // if (note.deltaTimeDelayForRandomSnareLine > 0 && note.noteType != NoteType.ruff3Left) {
      // if (note.deltaTimeDelayForRandomSnareLine > 0 && note.noteType != NoteType.ruff3Left && note.noteType != NoteType.ruff3Right) {

// The following is troublesome
      // if (wantDrumLine && snareNumber != 5 && note.deltaTimeDelayForRandomSnareLine > 0) {
      //   //print('\t\t\tas before, note.deltaTimeDelayForRandomSnareLine is ${note.deltaTimeDelayForRandomSnareLine} and noteOffEvent.deltaTime is ${noteOffEvent.deltaTime}');
      //   noteOffEvent.deltaTime -= note.deltaTimeDelayForRandomSnareLine;
      //   //print('\t\t\t\tso now noteOffEvent.deltaTime is ${noteOffEvent.deltaTime}');
      // }
    noteOffEvent.deltaTime -= note.deltaTimeDelayForRandomSnareLine;



      noteOffEvent.noteNumber = note.noteNumber;
      // noteOffEvent.velocity = note.velocity; // shouldn't this just be 0?
      noteOffEvent.velocity = 0; // shouldn't this just be 0?
      noteOffEvent.channel = channelNumber;

      trackEventsList.add(noteOffEvent);
      log.finest('addNoteOnOffToTrackEventsList() added endOffEvent $noteOffEvent to trackEventsList');

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
      num noteTicksAsDouble = 4 * ticksPerBeat / snareLangNoteNameValue; // round this?
      var diffTicksAsDouble = noteTicksAsDouble - noteOffEvent.deltaTime;
      cumulativeRoundoffTicks += diffTicksAsDouble;

      log.finest('noteOnNoteOff, Created note events for noteNameValue ${snareLangNoteNameValue}, '
          'deltaTime ${noteOffEvent.deltaTime} (${noteTicksAsDouble}), velocity: ${note.velocity}, '
          'number: ${note.noteNumber}, channel: $channelNumber, cumulative roundoff ticks: $cumulativeRoundoffTicks');

      return diffTicksAsDouble; // kinda strange
    }
}

/// Following comes from http://www.ccarh.org/courses/253/handout/smf/
/// A standard MIDI file is composed of "chunks". It starts with a header chunk and is followed by one or more track chunks.
/// The header chunk contains data that pertains to the overall file. Each track chunk defines a logical track.
//
//
//    SMF = <header_chunk> + <track_chunk> [+ <track_chunk> ...]
// A chunk always has three components, similar to Microsoft RIFF files (the only difference is that SMF files are big-endian,
// while RIFF files are usually little-endian). The three parts to each chunk are:
//
// The track ID string which is four charcters long. For example, header chunk IDs are "MThd", and Track chunk IDs are "MTrk".
// next is a four-byte unsigned value that specifies the number of bytes in the data section of the track (part 3).
// finally comes the data section of the chunk. The size of the data is specified in the length field which follows the chunk ID (part 2).
// Header Chunk
// The header chunk consists of a literal string denoting the header, a length indicator, the format of the MIDI file,
// the number of tracks in the file, and a timing value specifying delta time units. Numbers larger than one byte are placed most significant byte first.
//
//    header_chunk = "MThd" + <header_length> + <format> + <n> + <division>
//
// "MThd" 4 bytes
// the literal string MThd, or in hexadecimal notation: 0x4d546864. These four characters at the start of the MIDI file
// indicate that this is a MIDI file.
// <header_length> 4 bytes
// length of the header chunk (always 6 bytes long--the size of the next three fields which are considered the header chunk).
// <format> 2 bytes
// 0 = single track file format
// 1 = multiple track file format
// 2 = multiple song file format (i.e., a series of type 0 files)
// <n> 2 bytes
// number of track chunks that follow the header chunk
// <division> 2 bytes
// unit of time for delta timing. If the value is positive, then it represents the units per beat. For example, +96 would mean
// 96 ticks per beat. If the value is negative, delta times are in SMPTE compatible units.
// Track Chunk
// A track chunk consists of a literal identifier string, a length indicator specifying the size of the track, and actual event
// data making up the track.
//
//    track_chunk = "MTrk" + <length> + <track_event> [+ <track_event> ...]
//
// "MTrk" 4 bytes
// the literal string MTrk. This marks the beginning of a track.
// <length> 4 bytes
// the number of bytes in the track chunk following this number.
// <track_event>
// a sequenced track event.
// Track Event
// A track event consists of a delta time since the last event, and one of three types of events.
//
//    track_event = <v_time> + <midi_event> | <meta_event> | <sysex_event>
//
// <v_time>
// a variable length value specifying the elapsed time (delta time) from the previous event to this event.
// <midi_event>
// any MIDI channel message such as note-on or note-off. Running status is used in the same manner as it is used between MIDI devices.
// <meta_event>
// an SMF meta event.
// <sysex_event>
// an SMF system exclusive event.
// Meta Event
// Meta events are non-MIDI data of various sorts consisting of a fixed prefix, type indicator, a length field, and actual event data..
//
//    meta_event = 0xFF + <meta_type> + <v_length> + <event_data_bytes>
//
// <meta_type> 1 byte
// meta event types:
// Type	Event	Type	Event
// 0x00	Sequence number	0x20	MIDI channel prefix assignment
// 0x01	Text event	0x2F	End of track
// 0x02	Copyright notice	0x51	Tempo setting
// 0x03	Sequence or track name	0x54	SMPTE offset
// 0x04	Instrument name	0x58	Time signature
// 0x05	Lyric text	0x59	Key signature
// 0x06	Marker text	0x7F	Sequencer specific event
// 0x07	Cue point
// <v_length>
// length of meta event data expressed as a variable length value.
// <event_data_bytes>
// the actual event data.
// System Exclusive Event
// A system exclusive event can take one of two forms:
// sysex_event = 0xF0 + <data_bytes> 0xF7 or sysex_event = 0xF7 + <data_bytes> 0xF7
//
// In the first case, the resultant MIDI data stream would include the 0xF0. In the second case the 0xF0 is omitted.