import 'package:petitparser/petitparser.dart'; // defines Result
import '../snarelang4.dart';
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
  return tempo;
});
