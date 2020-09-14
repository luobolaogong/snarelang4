import 'package:petitparser/petitparser.dart';
import '../snarelang4.dart';

///
/// LilyPond uses '\time <int>/<int>'
/// e.g.  \time 3/4
/// Midi requires numerator and denominator metronome (18) and thirtyseconds (8)
///


class TimeSig {
  int numerator;
  int denominator;

  String toString() {
    return 'TimeSig: $numerator/$denominator';
  }

}

///
/// timeSigParser
///
Parser timeSigParser = ( // what about whitespace?
//    string('/time').trim() & wholeNumberParser.trim() & char('/').trim() & wholeNumberParser.trim()
    string('/time').trim() & wholeNumberParser.trim() & char('/').trim() & wholeNumberParser

).trim().map((value) {
  //log.info('\nIn timeSigParser and value is -->$value<--');
  var timeSig = TimeSig();
  timeSig.numerator = value[1];
  timeSig.denominator = value[3];
  //log.info('Leaving TimeSigParser returning value $timeSig');
  return timeSig; // this element eventually goes into a list of other elements that make up a score
});
