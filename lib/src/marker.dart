import 'package:petitparser/petitparser.dart';
import '../snarelang4.dart';

///
/// Want to do markers using '/marker <text>' to end of line where <text> is what should be placed in the track
///

class Marker {
  String text;
  String toString() {
    return 'marker: $text';
  }
}

///
/// markerParser
///
Parser markerParser = (
    string('/marker') & pattern('\n\r').neg().star() & pattern('\n\r').optional()
).flatten().trim().map((value) {
  log.finest('In markerParser and value is -->$value<--');
  var marker = Marker();
  var textPart = value.trim().substring(7);
  marker.text = textPart;
  log.finest('Leaving markerParser returning -->$marker<--');
  return marker;
});

