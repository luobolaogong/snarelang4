import 'package:petitparser/petitparser.dart'; // defines Result
import '../snarelang4.dart';
///
/// Placing tempo events into a MIDI file is important, but to do accel's and rit's
/// are not important for pipe band music, and therefore is less important than other
/// development tasks.  Still, if it was easy, I'd do it.
///
/// The way to do tempo ramps is probably to use track 0 and put the incremental tempo
/// changes into the score spaced out by rests.
///
/// I assume that a tempo event in any track will affect all other tracks.  I doubt you
/// can have two different tracks running at two different tempos.  So, normally I'd
/// put the tempo change into the score along with the notes, but doing ramped incremental
/// tempo changes would mess up the notes, and therefore would need to be in a different
/// track.  This kinda means that you have to create a "map" of tempos, and then go back
/// and update track 0.
///
///
///
/// LilyPond uses '\tempo <note> = <bpm>'
/// e.g.  \tempo 4 = 132
/// Midi requires tempo to be in microseconds per beat (60000000.0 / bpm)
/// So, we just need to know what note is the beat (like 4) and the bpm.
/// And since a note can be of the form int:int, the format will probably be
/// \tempo <int>:<int> = <int>
/// We could try to do shorthands, but it could get mixed up with note durations.
/// For example could do this:
/// \tempo durationParser.optional() & char('=').optional & wholeNumberParser
/// but that would be problematic for scores that contained this:
/// \tempo 4 132 16
/// where you don't know if the tempo is 4 and then two notes of duration 132 and 16
/// or if it's tempo of quarter note is 132 followed by a 16th note.
///
/// So, for now, just to be clear, we will allow only one form with or without whitespace delims:
/// \tempo durationParser & char('=') wholeNumberParser
/// So, test cases:
/// \tempo 2:3 = 456   okay
/// \tempo 2:3=456   okay
/// \tempo 7=8 9   okay, and 9 is a note
/// \tempo 7:8 9   fail because 9 might be a note
/// \tempo 10  fail because next thing might be a number for a note
///
/// But really this should also be accepted:    \tempo <bpm>


/// Now different issue: Tempo ramping, as in accel and deaccel from one tempo to another.
/// This is not the same application of linear equation y=mx+b for dynamics where y is the
/// dynamic value at x, because you just can't set a new tempo at every note.  It has to be
/// evenly spaced incremental between the start of the ramp until the next /tempo setting
/// in the score.  It's true that y=mx+b, for knowing the tempo at any given x, but to get
/// to that tempo you have to change it very often in equal increments of time.
///
/// So, how does a midi tempo event work?  You basically create a SetTempoEvent, and then set
/// the value for microsecondsPerBeat, and then add the event to the trackEventsList.
/// I think it's an immediate event, once you add it.  They go as fast as the list is processed.
/// I mean, it's not like you add a quarter note, and then another quarter note, where there's
/// a duration for every note event.  I think if you stuff a bunch of them into the list all
/// at once, then they'll all get processed almost immediately, and the last tempo event is
/// the one that matters.  This assumes that the processing is really fast, because otherwise
/// it would postpone the following timed events.  That would be a good test.  Issue 8
/// 32nd notes, but between the 4th and 5th add a thousand different tempo events, and see
/// if the 5th note is delayed.
///
/// So, to evenly space out these events, say to one per beat for the
/// duration of the ramp, I wonder if I should create a second track just for tempo changes, and put
/// quarter note rests between them.   If the ramp was 1 bar of 4/4 long, going from 100bpm to 200bpm
/// I could put a tempos of 100, 125, 150, 175, 200, maybe.  The first one should be the starting
/// tempo on the first quarter note rest, the second on the second, etc.
///
/// We don't want to put these quarter note rests into the regular track.  Looks like this 2ndary
/// track should be created after the other one is created.  Hmmmmm I don't know how this is done.
///
///Rallentando is a deaccelarando.  What about ritard? (rit) ritardando
///
/// Hmmmmm, some sort of tempo track.
/// "In the Tempo track, tempo changes are represented by tempo points.
/// You create tempo changes by adding tempo points and editing their values.
/// You can expand the Tempo track to give yourself more room to work,
/// and adjust the range of values for the Tempo track"
///
/// "The first track contains the timing info which will be applied for the entire arrangement,
/// so you apply these messages for each of the tracks with the same absolute time.
/// Since all events use an offset in ticks, you need to first extract the tempo change messages,
/// convert them to absolute time, and then as you are reading in the other tracks you will apply
/// these messages based on that timeline."
//
// From the MIDI fanatic's technical brainwashing center:
//
// In a format 0 file, the tempo changes are scattered throughout the one MTrk.
// In format 1, the very first MTrk should consist of only the tempo (and time signature)
// events so that it could be read by some device capable of generating a "tempo map".
// It is best not to place MIDI events in this MTrk.
// In format 2, each MTrk should begin with at least one initial tempo (and time signature) event.
//
// That said, some sequencers do break this rule and put actual MIDI events in the first track
// alongside timing info, since the standard isn't so specific in this regard.
// Your program should deal with both cases, since it is likely to encounter MIDI files
// in the wild which are formatted in this way.
/// So it seems to me that I can put timing ramps in track 0
class TempoRamp {
  Tempo startTempo; // perhaps should store as velocity?
  Tempo endTempo;
  int totalTicksStartToEnd;
  num slope;

  String toString() {
    return 'TempoRamp: startTempo: $startTempo, endTempo: $endTempo, totalTicksStartToEnd: $totalTicksStartToEnd, Slope: $slope';
  }
}

class Tempo {
  NoteDuration noteDuration = NoteDuration(); // oh, we do create the NoteDuration.  Good
  int bpm = 84; // initialize?  Wow, it's set elsewhere isn't it?  Where do this best, if at all?

  String toString() {
    return 'Tempo: bpm: $bpm, $noteDuration';
  }

}

/// I think we're not going to allow for accel or deaccel
/// because I think that means a change to ticks per second or
/// something, for every note, and I don't know how well that would work.
/// So skip for now
//enum TempoScaleRampWhatever {
//  accel, // \accel ?
//  deaccel // \deaccel ?
//}
Parser TempoRampParser = (
    string('/deaccel') |
    string('/accel')
).trim().map((value) {
  log.finest('In TempoRampParser');
  TempoRamp tempoRamp;
  switch (value) {
    case '/accel':
    case '/deaccel':
      tempoRamp =  TempoRamp();
      break;
  }
  log.finest('Leaving TempoRampParser returning value $tempoRamp');
  return tempoRamp;
});

///
/// tempoParser
///
Parser tempoParser = ( // what about whitespace?
    string('/tempo').trim() & (durationParser.trim() & char('=').trim()).optional().trim() & wholeNumberParser
//Parser tempoParser = ( // what about whitespace?
//    string('\\tempo').trim() & durationParser.trim() & char('=').trim() & wholeNumberParser
).trim().map((value) {
  //log.info('\nIn TempoParser and value is -->$value<--');
  var tempo = Tempo();
  if (value[1] != null) {
    NoteDuration noteDuration = value[1][0]; // NoteDurationParser returns an object
    tempo.noteDuration = noteDuration;
  }
  tempo.bpm = value[2];
  //log.info('Leaving tempoParser returning value $tempo');
  return tempo; // This goes into the list of elements that make up a score, which we process one by one later.
});
