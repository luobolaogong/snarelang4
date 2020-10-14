import 'package:petitparser/petitparser.dart';
import '../snarelang4.dart';

///
/// Want to do text using '/text <text>' to end of line where <text> is what should be placed in the track
///

class Text {
  String text;
  String toString() {
    return 'text: $text';
  }
}

///
/// textParser
///
Parser textParser = (
    string('/text') & pattern('\n\r').neg().star() & pattern('\n\r').optional()
).flatten().trim().map((value) {
  log.finest('In textParser and value is -->$value<--');
  var text = Text();
  text.text = value.trim().substring(6);
  log.finest('Leaving textParser returning -->$text<--');
  return text;
});

